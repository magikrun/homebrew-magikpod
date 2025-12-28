# Homebrew Tap for magikrun

Unified OCI runtime for containers, WebAssembly, and microVMs.

## Installation

```bash
brew tap magikrun/magikrun
brew install magikrun
```

## Formulae

| Formula | Description |
|---------|-------------|
| `magikrun` | Unified OCI runtime for containers, WASM, and microVMs |

## Updating

```bash
brew update
brew upgrade magikrun
```

## From Source

If you prefer to install from crates.io:

```bash
cargo install magikrun
```

## Requirements

- macOS 11.0+ (for Hypervisor.framework support)
- Linux with KVM (for native container and MicroVM support)

## License

Apache-2.0
