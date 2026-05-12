require_relative "../lib/kyc_license_download_strategy"

class Kyc < Formula
  desc "Code comprehension engine"
  homepage "https://github.com/know-your-code/know-your-code"
  version "0.2.3"
  license :cannot_represent

  # The custom strategy authenticates release downloads with the user's
  # local KYC license, bootstrapping browser sign-in on first install if
  # the license file is missing.
  on_macos do
    on_arm do
      url "https://id.knowyourco.de/release/v#{version}/aarch64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "85b57de81bf4a6037d25649b32bb2e9d4039ef75da507d9e9cae96db33e4b9f9"
    end
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "9176fdc768fbd65938cd1e3a426fc85e9ea269a36f207da6f67935e64458133b"
    end
  end

  on_linux do
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-linux.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "83721806f30834b8dfd2b6058096aa2f0e6c98bad84eca023c4bede699de547b"
    end
  end

  # Install the main CLI and companion binaries from the release tarball.
  def install
    bin.install "kyc", "kycc-golang", "kycc-python", "kyc-trace", "kyc-bench"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kyc --version")
  end
end
