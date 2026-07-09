class AiteruBridge < Formula
  desc "Bridge relaying Claude Code / Codex CLI traffic to the Aiteru relay"
  homepage "https://github.com/aiteru-co/homebrew-aiteru-bridge"
  version "0.1.2"

  on_macos do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.2/aiteru-bridge-0.1.2-macos-universal.tar.gz"
    sha256 "6d5616dd526cfd2a1669a3d7064485e074b24037c179a832d0c888bb84ae9381"
  end

  on_linux do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.2/aiteru-bridge-0.1.2-linux-x86_64.tar.gz"
    sha256 "4163dba420d2ca3adff2fc13bf675eaf05dd524ae0825a832bb3f9ab0a3efedc"
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
