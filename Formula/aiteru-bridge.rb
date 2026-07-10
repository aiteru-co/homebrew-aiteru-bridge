class AiteruBridge < Formula
  desc "Bridge relaying Claude Code / Codex CLI traffic to the Aiteru relay"
  homepage "https://github.com/aiteru-co/homebrew-aiteru-bridge"
  version "0.1.5"

  on_macos do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.5/aiteru-bridge-0.1.5-macos-universal.tar.gz"
    sha256 "d7b9cf16837880bce51601d0d841486c680ee91894f721aba080d2d1d8b48afe"
  end

  on_linux do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.5/aiteru-bridge-0.1.5-linux-x86_64.tar.gz"
    sha256 "34ad215cee8b85ead8983aa626c4d915adf7f4e0804c7c970468ea5a4e07956b"
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
