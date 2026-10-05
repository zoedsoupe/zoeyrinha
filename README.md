<h1 align="center">
  <br />
  Zoey's Dotfiles
  <br />
</h1>

<div align="center">
  <strong>Zoey's dotfiles config! Everything you need to have a productive environment for web developing and some hackings!</strong>
</div>

<div align="center">
  <strong>Powered by</strong>
  <br>
  <img src="https://img.shields.io/badge/-NixOS-informational?style=for-the-badge&logo=NixOS&logoColor=white&color=5277C3" alt="NixOS" />
</div>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#how-to-use">How to use</a> •
  <a href="#utilities">Utilities</a>
</p>

This repo is a fresh start from old config [nixnad](https://github.com/zoedsoupe/nixnad).

<a id="features" />

## Features

- **macOS Support**: Full Darwin/nix-darwin configuration with automatic app linking
- **Modular Configuration**: Each program has its own toggleable module
- **Terminal**: Ghostty, configured from the host's `custom.nix`
- **Development Tools**: Helix and Zed, both nyxvamp-themed
- **Shell Setup**: Zsh with Starship prompt
- **CLI Utilities**: fzf, zoxide, bat, xplr, direnv, and more
- **Helix grammars**: only the tree-sitter grammars the enabled languages need
  are built, not all ~300 Helix ships
- **ISO Builder**: Create minimal NixOS installation media

## How to use

### Quick Build Script

The easiest way to build configurations is using the `nix-build` script:

```sh
./nix-build personal   # Build personal Mac configuration
./nix-build iso        # Build minimal ISO
./nix-build yby        # Build yby (homelab) without activating
./nix-build eveo       # Build eveo (vps) without activating
```

### Manual Build Commands

#### macOS (Darwin) Configuration

```sh
darwin-rebuild switch --flake .#zoedsoupe-mac  # For personal machine
```

#### Minimal ISO

```sh
nix build .#nixosConfigurations.minimal-iso.config.system.build.isoImage
```

The ISO will be available at `./result/iso/`.
