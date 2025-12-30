# Homebrew formula for magikpod
# Pod-native runtime on OCI containers, WebAssembly, and microVM isolation

class Magikpod < Formula
  desc "Pod-native runtime on OCI containers, WebAssembly, and microVM isolation"
  homepage "https://github.com/magikrun/magikpod"
  url "https://github.com/magikrun/magikpod/archive/refs/tags/v0.3.8.tar.gz"
  sha256 "f94be44103f321c3b876e5c019be9b96002e67ba21cd1bd952a7b7375e234aff"
  license "Apache-2.0"
  head "https://github.com/magikrun/magikpod.git", branch: "main"

  depends_on "rustup" => :build

  # libkrun for MicroVM support (macOS only)
  on_macos do
    depends_on "slp/krun/libkrun"

    # Cross-compilation toolchain for building magikpod-vminit (Linux binary)
    depends_on "filosottile/musl-cross/musl-cross" => :build
  end

  def install
    # Ensure stable toolchain is installed and has required targets
    system "rustup", "toolchain", "install", "stable"

    # Determine rustup toolchain path based on architecture
    if Hardware::CPU.arm?
      toolchain_path = "#{ENV["HOME"]}/.rustup/toolchains/stable-aarch64-apple-darwin"
      linux_target = "aarch64-unknown-linux-musl"
      musl_prefix = "aarch64-linux-musl"
    else
      toolchain_path = "#{ENV["HOME"]}/.rustup/toolchains/stable-x86_64-apple-darwin"
      linux_target = "x86_64-unknown-linux-musl"
      musl_prefix = "x86_64-linux-musl"
    end

    cargo = "#{toolchain_path}/bin/cargo"
    rustc = "#{toolchain_path}/bin/rustc"

    # Build with CLI feature enabled using rustup's toolchain
    ENV["RUSTC"] = rustc
    system cargo, "install", "--features", "cli", *std_cargo_args

    if OS.mac?
      # Sign binary with hypervisor entitlements for MicroVM support
      system "codesign", "--entitlements", "entitlements.plist", "--force", "-s", "-", bin/"magikpod"

      # Cross-compile magikpod-vminit for Linux (runs inside MicroVM as PID 1)
      # Add Linux musl target for static linking
      system "rustup", "target", "add", linux_target

      # Build vminit for Linux with musl (static binary)
      ENV["CC_#{linux_target.gsub("-", "_")}"] = "#{musl_prefix}-gcc"
      ENV["CARGO_TARGET_#{linux_target.upcase.gsub("-", "_")}_LINKER"] = "#{musl_prefix}-gcc"

      system cargo, "build", "--release",
             "--target", linux_target,
             "--package", "magikpod-vminit"

      # Install the Linux binary to libexec (not in PATH, used by magikpod internally)
      (libexec/"vminit").install "target/#{linux_target}/release/magikpod-vminit"
    end
  end

  def caveats
    if OS.mac?
      <<~EOS
        magikpod-vminit (Linux binary for MicroVM) is installed at:
          #{libexec}/vminit/magikpod-vminit

        This binary runs inside MicroVMs as PID 1 and is automatically
        used by magikpod when launching microVM-based workloads.
      EOS
    end
  end

  test do
    # Basic version check
    assert_match version.to_s, shell_output("#{bin}/magikpod --version 2>&1", 1)

    # Verify vminit binary exists (macOS only)
    if OS.mac?
      assert_predicate libexec/"vminit/magikpod-vminit", :exist?
    end
  end
end
