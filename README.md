# Homebrew Tap for magikpod

Pod-native runtime on OCI containers, WebAssembly, and microVM isolation.

## Installation

```bash
brew tap magikrun/magikpod
brew install magikpod
```

## Formulae

| Formula | Description |
|---------|-------------|
| `magikpod` | Pod-native runtime on OCI containers, WebAssembly, and microVM isolation |

## Updating

```bash
brew update
brew upgrade magikpod
```

## From Source

If you prefer to install from crates.io:

```bash
cargo install magikpod
```

## Requirements

- macOS 11.0+ (for Hypervisor.framework support with libkrun)
- Rust toolchain (installed automatically via rustup dependency)

## License

Apache-2.0
