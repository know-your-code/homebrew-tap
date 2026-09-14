require_relative "../lib/kyc_license_download_strategy"

# Opt-in candidate build: macOS-only, never served as the default `kyc`.
# Install with `brew install know-your-code/tap/kyc@0.4.0-alpha.7`.
class KycAT040Alpha7 < Formula
  desc "Code comprehension engine (candidate build)"
  homepage "https://github.com/know-your-code/know-your-code"
  version "0.4.0-alpha.7"
  license :cannot_represent

  # Both formulas install bin/kyc — `brew unlink kyc` before linking this.
  conflicts_with "kyc", because: "both install the kyc binaries"

  on_macos do
    on_arm do
      url "https://id.knowyourco.de/release/v#{version}/aarch64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "f23881a46171c80e9d55d7674926cc5045d9edc1ee3835a2671ed48fbfb1a4d5"
    end
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "b81ca5d99b090d92969b0ae2a2d1572914216101c86d57de0073519e12771f17"
    end
  end

  def install
    bin.install "kyc", "kycc-golang", "kycc-python"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kyc --version")
  end
end
