class AiteruBridge < Formula
  desc "Bridge relaying Claude Code / Codex CLI traffic to the Aiteru relay"
  homepage "https://github.com/aiteru-co/homebrew-aiteru-bridge"
  version "0.1.3"

  on_macos do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.3/aiteru-bridge-0.1.3-macos-universal.tar.gz"
    sha256 "3e7471fbbe88bfa5e3f274b6642ff263601d80c5aeec651eded4436064a3df28"
  end

  on_linux do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.3/aiteru-bridge-0.1.3-linux-x86_64.tar.gz"
    sha256 "d604f3f26bef3cbfc36cc28f3a2db3bfda1096a537a25fb27f3824918ad3453a"
  end

  def install
    bin.install "aiteru-bridge"
  end

  service do
    run [opt_bin/"aiteru-bridge"]
    keep_alive true
    log_path var/"log/aiteru-bridge.log"
    error_log_path var/"log/aiteru-bridge.log"
  end

  test do
    assert_predicate bin/"aiteru-bridge", :exist?
  end
end
