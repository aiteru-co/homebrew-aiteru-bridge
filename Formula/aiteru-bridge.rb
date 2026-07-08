class AiteruBridge < Formula
  desc "Bridge relaying Claude Code / Codex CLI traffic to the Aiteru relay"
  homepage "https://github.com/aiteru-co/homebrew-aiteru-bridge"
  version "0.1.1"

  on_macos do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.1/aiteru-bridge-0.1.1-macos-universal.tar.gz"
    sha256 "50f9e49ef606657357338f62cbe2430a8c6e6e09ccf77f69506baa6fe84e42b6"
  end

  on_linux do
    url "https://github.com/aiteru-co/homebrew-aiteru-bridge/releases/download/v0.1.1/aiteru-bridge-0.1.1-linux-x86_64.tar.gz"
    sha256 "9683e73e1e68f38c54a16ab6e13d2e4ab769d86585ea4e880b6fddb62c864f45"
  end

  def install
    bin.install "aiteru-bridge"
  end

  test do
    assert_predicate bin/"aiteru-bridge", :exist?
  end
end
