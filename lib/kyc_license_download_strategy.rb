require "download_strategy"
require "base64"
require "fileutils"
require "json"
require "net/http"
require "uri"

# Download strategy for release tarballs that require a local KYC license.
# If the license file is missing, the strategy starts browser sign-in and
# stores the issued license before continuing the download.
class KycLicenseDownloadStrategy < CurlDownloadStrategy
  LICENSE_PATH = File.expand_path("~/.kyc/license").freeze
  INSTALL_ORIGIN = "https://id.knowyourco.de".freeze
  REFERRAL_TAG = "closed-beta".freeze

  # Bound how long we'll wait for the user to finish browser sign-in.
  BOOTSTRAP_TIMEOUT_SECONDS = 14 * 60

  # Homebrew retries failed downloads in-process; memoizing terminal
  # bootstrap failures avoids opening repeated browser tabs.
  class << self
    attr_accessor :bootstrap_failure
  end

  private

  def _fetch(url:, resolved_url:, timeout:)
    license_b64 = read_or_bootstrap_license
    curl_download(
      url,
      "--header", "Authorization: Kyc-License #{license_b64}",
      to: temporary_path,
      try_partial: @try_partial,
      timeout: timeout,
    )
  end

  def read_or_bootstrap_license
    return Base64.strict_encode64(File.read(LICENSE_PATH)) if File.exist?(LICENSE_PATH)
    raise self.class.bootstrap_failure if self.class.bootstrap_failure

    begin
      license = bootstrap_via_device_flow
    rescue StandardError => e
      self.class.bootstrap_failure = e
      raise
    end
    dir = File.dirname(LICENSE_PATH)
    FileUtils.mkdir_p(dir)
    File.chmod(0o700, dir) if File.owned?(dir)
    File.write(LICENSE_PATH, license, mode: "wb")
    File.chmod(0o600, LICENSE_PATH)
    Base64.strict_encode64(license)
  end

  # Complete browser sign-in via OAuth 2.0 Device Authorization Grant.
  def bootstrap_via_device_flow
    device = post_device
    url = device.fetch("verification_uri")
    code = device.fetch("user_code")

    # Print the sign-in URL + user code directly to $stderr. brew's
    # progress spinner repaints the last line of stdout on every tick
    # and would silently eat any `puts` / `ohai` output here. Stderr
    # isn't touched by the spinner.
    $stderr.puts
    $stderr.puts "kyc: sign in to install"
    $stderr.puts
    $stderr.puts "    Open this URL in a browser:"
    $stderr.puts "        #{url}"
    $stderr.puts
    $stderr.puts "    Then enter this code on that page:"
    $stderr.puts "        #{code}"
    $stderr.puts

    # Interactive shells: offer to launch the browser on Enter. The
    # user can also just open the URL themselves and ignore the
    # prompt. Non-interactive runs (CI, piped installs) skip the
    # prompt entirely — there's no terminal to read from and blocking
    # on stdin would hang the install. The URL was already printed
    # above; automation can scrape it.
    if $stdin.tty?
      # `puts` (newline) rather than `print` (no newline): brew's
      # progress spinner repaints the line it's sitting on every tick.
      # Without a newline the cursor would be on the same line as the
      # prompt, and the spinner would overwrite it.
      $stderr.puts "Press Enter to open the URL in your browser (or open it yourself)."
      # Don't block the poll loop on stdin. If the user opens the URL
      # themselves and completes the flow in the browser, /token will
      # resolve before they ever press Enter. The orphaned stdin
      # listener dies when the process exits.
      Thread.new do
        $stdin.gets
        open_verification_url(url)
      end
    end

    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + BOOTSTRAP_TIMEOUT_SECONDS
    interval = [device.fetch("interval", 5).to_i, 1].max

    loop do
      remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
      raise CurlDownloadStrategyError, "kyc: timed out waiting for sign-in" if remaining <= 0

      sleep(interval)
      resp = post_token(device.fetch("device_code"))

      if resp["license"]
        return resp["license"]
      end

      case resp["error"]
      when "authorization_pending"
        next # user hasn't finished OAuth yet; keep polling
      when "expired_token"
        raise CurlDownloadStrategyError,
              "kyc: sign-in code expired before you finished. Run `brew install kyc` again."
      when nil
        raise CurlDownloadStrategyError,
              "kyc: unexpected /token response (no license, no error)"
      else
        detail = resp["detail"].to_s.empty? ? resp["error"] : resp["detail"]
        raise CurlDownloadStrategyError, "kyc: #{detail}"
      end
    end
  end

  def post_device
    body = URI.encode_www_form(ref: REFERRAL_TAG)
    parse_json_response(post_form(URI.join(INSTALL_ORIGIN, "/device"), body), "POST /device")
  end

  def post_token(device_code)
    body = URI.encode_www_form(
      grant_type: "urn:ietf:params:oauth:grant-type:device_code",
      device_code: device_code,
    )
    resp = post_form(URI.join(INSTALL_ORIGIN, "/token"), body)
    # Some sign-in states are returned as 4xx JSON protocol responses.
    parse_json_response(resp, "POST /token", allow_4xx: true)
  end

  def post_form(uri, body)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                        open_timeout: 10, read_timeout: 30) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/x-www-form-urlencoded"
      req["Accept"] = "application/json"
      req.body = body
      http.request(req)
    end
  rescue StandardError => e
    raise CurlDownloadStrategyError, "kyc: network error talking to #{uri}: #{e.class}: #{e.message}"
  end

  def parse_json_response(resp, label, allow_4xx: false)
    unless resp.is_a?(Net::HTTPSuccess) || (allow_4xx && resp.is_a?(Net::HTTPClientError))
      raise CurlDownloadStrategyError,
            "kyc: #{label} returned HTTP #{resp.code} #{resp.message} - #{resp.body.to_s[0, 200]}"
    end
    JSON.parse(resp.body)
  rescue JSON::ParserError => e
    raise CurlDownloadStrategyError, "kyc: #{label} returned non-JSON body: #{e.message}"
  end

  def open_verification_url(url)
    cmd =
      if RUBY_PLATFORM.include?("darwin")
        ["open", url]
      elsif RUBY_PLATFORM.include?("linux")
        ["xdg-open", url]
      end
    return if cmd && system(*cmd)

    # Browser launch failed. The URL is already printed above so we
    # don't repeat it — just tell the user the auto-launch didn't work.
    opoo "Couldn't open a browser automatically — open the URL above manually."
  end
end
