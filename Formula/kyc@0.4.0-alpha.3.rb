require_relative "../lib/kyc_license_download_strategy"

# Opt-in candidate build: macOS-only, never served as the default `kyc`.
# Install with `brew install know-your-code/tap/kyc@0.4.0-alpha.3`.
class KycAT040Alpha3 < Formula
  desc "Code comprehension engine (candidate build)"
  homepage "https://github.com/know-your-code/know-your-code"
  version "0.4.0-alpha.3"
  license :cannot_represent

  # Both formulas install bin/kyc — `brew unlink kyc` before linking this.
  conflicts_with "kyc", because: "both install the kyc binaries"

  on_macos do
    on_arm do
      url "https://id.knowyourco.de/release/v#{version}/aarch64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "3a2258d7a6e5a9bba848618800f0e399d60446deb1ead6cd73aaa92f0935de4c"
    end
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "eb05c35256f2571eeecaff2b3ed8f84ad5242d4e86c8e9a4d729e6ea23414339"
    end
  end

  def install
    bin.install "kyc", "kycc-golang", "kycc-python"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kyc --version")
  end
end
