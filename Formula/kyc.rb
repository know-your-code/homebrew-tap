require_relative "../lib/kyc_license_download_strategy"

class Kyc < Formula
  desc "Code comprehension engine"
  homepage "https://github.com/know-your-code/know-your-code"
  version "0.3.2-rc1"
  license :cannot_represent

  # The custom strategy authenticates release downloads with the user's
  # local KYC license, bootstrapping browser sign-in on first install if
  # the license file is missing.
  on_macos do
    on_arm do
      url "https://id.knowyourco.de/release/v#{version}/aarch64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "61152004a221cab0ad70a0c0f4a6e4337c506f389c0b1645528fc34ffb95a1e0"
    end
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-macos.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "1ba770cfcf85c2b5c989e1523295c8e1b713e538f93b0543d7a0308cf540d812"
    end
  end

  on_linux do
    on_intel do
      url "https://id.knowyourco.de/release/v#{version}/x86_64-linux.tar.gz",
          using: KycLicenseDownloadStrategy
      sha256 "914dbae559a66a741fc1206d003513061515263216fe8aa96188f3fde4e063d5"
    end
  end

  def install
    bin.install "kyc", "kycc-golang", "kycc-python"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kyc --version")
  end
end
