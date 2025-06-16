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
  <a href="https://github.com/zoedsoupe/copper" target="_blank">Neovim</a> •
  <a href="#how-to-use">How to use</a> •
  <a href="#utilities">Utilities</a>
</p>

This repo is a fresh start from old config [nixnad](https://github.com/zoedsoupe/nixnad).

<a id="features" />

## Features

- **macOS Support**: Full Darwin/nix-darwin configuration with automatic app linking
- **Modular Configuration**: Each program has its own toggleable module
- **Multiple Terminal Emulators**: Ghostty, Alacritty, Kitty, Rio, Wezterm configured
- **Development Tools**: Helix, Neovim, Zed editors with custom configurations
- **Shell Setup**: Fish and Zsh with Starship prompt
- **CLI Utilities**: fzf, zoxide, bat, xplr, direnv, and more
- **ISO Builder**: Create minimal NixOS installation media

## How to use

### Quick Build Script

The easiest way to build configurations is using the `nix-build` script:

```sh
./nix-build personal   # Build personal Mac configuration
./nix-build cloudwalk  # Build CloudWalk Mac configuration  
./nix-build iso        # Build minimal ISO
```

### Manual Build Commands

#### macOS (Darwin) Configuration

```sh
darwin-rebuild switch --flake .#cloudwalk-mac  # For CloudWalk machine
darwin-rebuild switch --flake .#zoedsoupe-mac  # For personal machine
```

#### Minimal ISO

```sh
nix build .#installMedia.minimal.config.system.build.isoImage
```

The ISO will be available at `./result/iso/`.
