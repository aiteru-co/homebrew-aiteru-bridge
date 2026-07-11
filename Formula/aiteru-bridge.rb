class AiteruBridge < Formula
  desc "Bridge relaying Claude Code / Codex CLI traffic to the Aiteru relay"
  homepage "https://github.com/aiteru-co/homebrew-aiteru-bridge"
  version "0.1.6"

  on_macos do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.6/aiteru-bridge-0.1.6-macos-universal.tar.gz"
    sha256 "ba1ef3b03573f0a6a0570ebe3ab2ebf44d9826d9e8c7c4590d40e304ffcb0d6b"
  end

  on_linux do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.6/aiteru-bridge-0.1.6-linux-x86_64.tar.gz"
    sha256 "7ec0f38ff749f789fb9c1b2b0b6856832907b29f14bbf75f1a2622fe672f1554"
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
