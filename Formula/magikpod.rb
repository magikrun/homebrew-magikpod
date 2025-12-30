# Homebrew formula for magikpod
# Pod-native runtime on OCI containers, WebAssembly, and microVM isolation

class Magikpod < Formula
  desc "Pod-native runtime on OCI containers, WebAssembly, and microVM isolation"
  homepage "https://github.com/magikrun/magikpod"
  url "https://github.com/magikrun/magikpod/archive/refs/tags/v0.3.8.tar.gz"
  sha256 "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed"
  license "Apache-2.0"
  head "https://github.com/magikrun/magikpod.git", branch: "main"

  depends_on "rust" => :build

  # libkrun for MicroVM support (macOS only for now)
  on_macos do
    depends_on "libkrun"
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
