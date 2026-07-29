require_relative "../lib/kyc_license_download_strategy"

class Kyc < Formula
  desc "Code comprehension engine"
  homepage "https://github.com/know-your-code/know-your-code"
  version "0.4.0-alpha.1"
  license :cannot_represent

  # The custom strategy authenticates release downloads with the user's
  # local KYC license, bootstrapping browser sign-in on first install if
  # the license file is missing.
  on_macos do
    on_arm do
      url "https://id.knowyourco.de/release/v#{version}/aarch64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "c39767eb3e4f9ec5774eda19d80d4a2519246d6d6c9298cdad41bfadbe4be24d"
    end
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "72363bf5b7f54746a7a6f44d1eeef767627c18757f4529b535d56f73c11dd756"
    end
  end

  on_linux do
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-linux.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "0dad36ac4f10b40f12719298ba6aa96bc09b156e52edb14329e84377c7bbfd00"
    end
  end

  def install
    bin.install "kyc", "kycc-golang", "kycc-python"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kyc --version")
  end
end
