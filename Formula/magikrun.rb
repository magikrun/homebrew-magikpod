# Homebrew formula for magikrun
# Unified OCI runtime for containers, WebAssembly, and microVMs

class Magikrun < Formula
  desc "Unified OCI runtime for containers, WebAssembly, and microVMs"
  homepage "https://github.com/magikrun/magikrun"
  url "https://github.com/magikrun/magikrun/archive/refs/tags/v0.3.3.tar.gz"
  sha256 "39c21e9089b7dade1c20001b772f53ffb9413515fd71adf0bbec158881f5d091"
  license "Apache-2.0"
  head "https://github.com/magikrun/magikrun.git", branch: "main"

  depends_on "rust" => :build

  # libkrun for MicroVM support (Linux/macOS only)
  on_macos do
    depends_on "libkrun"
  end

  on_linux do
    depends_on "libkrun"
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    # Basic version check
    assert_match version.to_s, shell_output("#{bin}/magikrun --version 2>&1", 1)
  end
end
