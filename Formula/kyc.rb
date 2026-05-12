require_relative "../lib/kyc_license_download_strategy"

class Kyc < Formula
  desc "Code comprehension engine"
  homepage "https://github.com/know-your-code/know-your-code"
  version "0.2.4"
  license :cannot_represent

  # The custom strategy authenticates release downloads with the user's
  # local KYC license, bootstrapping browser sign-in on first install if
  # the license file is missing.
  on_macos do
    on_arm do
      url "https://id.knowyourco.de/release/v#{version}/aarch64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "66666180cafda42a5e4a0c81d8cc19ec2c43235231f3d5755ce8bec2bbca39c6"
    end
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "ddd950eb5b22ae617f612e5f5bd7b6cae6a963cdb13cbb3b1cbc7002853a85f0"
    end
  end

  on_linux do
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-linux.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "0c93865aea035039d4c4d96ac5d4129edf0ee1c84e12bc2a1103ab5ee2322b1d"
    end
  end

  def install
    bin.install "kyc", "kycc-golang", "kycc-python"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kyc --version")
  end
end
