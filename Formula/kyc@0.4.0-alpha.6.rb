require_relative "../lib/kyc_license_download_strategy"

# Opt-in candidate build: macOS-only, never served as the default `kyc`.
# Install with `brew install know-your-code/tap/kyc@0.4.0-alpha.6`.
class KycAT040Alpha6 < Formula
  desc "Code comprehension engine (candidate build)"
  homepage "https://github.com/know-your-code/know-your-code"
  version "0.4.0-alpha.6"
  license :cannot_represent

  # Both formulas install bin/kyc — `brew unlink kyc` before linking this.
  conflicts_with "kyc", because: "both install the kyc binaries"

  on_macos do
    on_arm do
      url "https://id.knowyourco.de/release/v#{version}/aarch64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "3a6b9d1c42ae85128e8de34752189b8165418c4da2e5bd1cc8ced817334dda76"
    end
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "5ad26a20ffcdc822af53bd2017881cd073019873fd456b5027f5f23bbb7d558a"
    end
  end

  def install
    bin.install "kyc", "kycc-golang", "kycc-python"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kyc --version")
  end
end
