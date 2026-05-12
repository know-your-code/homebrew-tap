require_relative "../lib/kyc_license_download_strategy"

class Kyc < Formula
  desc "Code comprehension engine"
  homepage "https://github.com/know-your-code/know-your-code"
  version "0.2.5"
  license :cannot_represent

  # The custom strategy authenticates release downloads with the user's
  # local KYC license, bootstrapping browser sign-in on first install if
  # the license file is missing.
  on_macos do
    on_arm do
      url "https://id.knowyourco.de/release/v#{version}/aarch64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "c41cce48240b493f6b54f33264e6b1562e1d6ca674184ef75a40433ace3301c0"
    end
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "f362ee68ab58469cd5156a0bd942f865ca1470d1b48e694fba43f48223f7f05b"
    end
  end

  on_linux do
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-linux.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "c44ffd0cf566658253744f8a433af83fcacb8dcc2ebb9fdf7a22d4b0ae2f0389"
    end
  end

  def install
    bin.install "kyc", "kycc-golang", "kycc-python"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kyc --version")
  end
end
