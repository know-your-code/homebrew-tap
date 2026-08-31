require_relative "../lib/kyc_license_download_strategy"

# Opt-in candidate build: macOS-only, never served as the default `kyc`.
# Install with `brew install know-your-code/tap/kyc@0.4.0-alpha.5`.
class KycAT040Alpha5 < Formula
  desc "Code comprehension engine (candidate build)"
  homepage "https://github.com/know-your-code/know-your-code"
  version "0.4.0-alpha.5"
  license :cannot_represent

  # Both formulas install bin/kyc — `brew unlink kyc` before linking this.
  conflicts_with "kyc", because: "both install the kyc binaries"

  on_macos do
    on_arm do
      url "https://id.knowyourco.de/release/v#{version}/aarch64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "58496213ace16c8ae79e0d09f70095cc106678c3f7eb96a6c04aead15844e950"
    end
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "081640810b477787ca9109a2956ac27e58767de6935f1ad70811660aba57e7b6"
    end
  end

  def install
    bin.install "kyc", "kycc-golang", "kycc-python"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kyc --version")
  end
end
