require_relative "../lib/kyc_license_download_strategy"

# Opt-in candidate build: macOS-only, never served as the default `kyc`.
# Install with `brew install know-your-code/tap/kyc@0.4.0-alpha.4`.
class KycAT040Alpha4 < Formula
  desc "Code comprehension engine (candidate build)"
  homepage "https://github.com/know-your-code/know-your-code"
  version "0.4.0-alpha.4"
  license :cannot_represent

  # Both formulas install bin/kyc — `brew unlink kyc` before linking this.
  conflicts_with "kyc", because: "both install the kyc binaries"

  on_macos do
    on_arm do
      url "https://id.knowyourco.de/release/v#{version}/aarch64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "fc3ee8c4ffb0b1aa7f493a5b718c22bb1c9e30b7a62405fef29bc31e7f11aae0"
    end
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "97a2a9c4caf9f70989ff14e4059397556353c6f8740b16bfd6af0b434d4c35ee"
    end
  end

  def install
    bin.install "kyc", "kycc-golang", "kycc-python"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kyc --version")
  end
end
