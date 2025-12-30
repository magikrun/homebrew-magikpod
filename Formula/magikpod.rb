# Homebrew formula for magikpod
# Pod-native runtime on OCI containers, WebAssembly, and microVM isolation

class Magikpod < Formula
  desc "Pod-native runtime on OCI containers, WebAssembly, and microVM isolation"
  homepage "https://github.com/magikrun/magikpod"
  url "https://github.com/magikrun/magikpod/archive/refs/tags/v0.3.8.tar.gz"
  sha256 "f94be44103f321c3b876e5c019be9b96002e67ba21cd1bd952a7b7375e234aff"
  license "Apache-2.0"
  head "https://github.com/magikrun/magikpod.git", branch: "main"

  depends_on "rust" => :build

  # libkrun for MicroVM support (macOS only)
  on_macos do
    depends_on "slp/krun/libkrun"
  end

  def install
    system "cargo", "install", *std_cargo_args

    # Create entitlements file for hypervisor access
    entitlements = buildpath/"entitlements.plist"
    entitlements.write <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>com.apple.security.hypervisor</key>
        <true/>
      </dict>
      </plist>
    EOS

    # Sign binary with hypervisor entitlements for MicroVM support
    system "codesign", "--entitlements", entitlements, "--force", "-s", "-", bin/"magikpod"
  end

  test do
    # Basic version check
    assert_match version.to_s, shell_output("#{bin}/magikpod --version 2>&1", 1)
  end
end
