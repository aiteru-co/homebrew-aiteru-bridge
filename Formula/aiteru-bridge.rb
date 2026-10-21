class AiteruBridge < Formula
  desc "Bridge relaying Claude Code / Codex CLI traffic to the Aiteru relay"
  homepage "https://github.com/aiteru-co/homebrew-aiteru-bridge"
  version "0.2.0"

  on_macos do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.2.0/aiteru-bridge-0.2.0-macos-universal.tar.gz"
    sha256 "ee0452220b2f9dc8a9621060bb9cca73d8fe30e77d536d192ba0e0c36c65ecf9"
  end

  on_linux do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.2.0/aiteru-bridge-0.2.0-linux-x86_64.tar.gz"
    sha256 "a36bee8131ba8b6a35da6e24bf4d49b75b933456bf554248b6c28c19feab5e9b"
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
