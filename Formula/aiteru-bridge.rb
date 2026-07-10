class AiteruBridge < Formula
  desc "Bridge relaying Claude Code / Codex CLI traffic to the Aiteru relay"
  homepage "https://github.com/aiteru-co/homebrew-aiteru-bridge"
  version "0.1.4"

  on_macos do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.4/aiteru-bridge-0.1.4-macos-universal.tar.gz"
    sha256 "cb0f7be471d3b3d12bf673ca59fbe90ad508ffb3a4d929c5de2516b649dbb2b6"
  end

  on_linux do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.4/aiteru-bridge-0.1.4-linux-x86_64.tar.gz"
    sha256 "5ff41161083b7115f1853cec6c66d93069ad2332f28b4dbed4969096b8fccb04"
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
