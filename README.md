<h1 align="center">
  <br />
  <img src="./assets/logo.png" alt="Zoey's Logo" width="300">
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
  <a href="#programs">Programs</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="https://github.com/zoedsoupe/copper" target="_blank">Neovim</a> •
  <a href="#how-to-use">How to use</a>
</p>

This repo is a fresh start from old config [nixnad](https://github.com/zoedsoupe/nixnad).

<a id="programs" />

## You'll be installing...
**TODO**

## Screenshots
**TODO**

## How to use

To build the home configuration you can run:

```sh dark
nix build <flake-url>#homeManagerConfigurations.zoedsoupe.activationPackage
```

If you want to build a bootable ISO, with minimal NixOS config, run:

```sh dark
nix build <flake-url>#installMedia.minimal.config.system.build.isoImage
```

> If you're building locally, `<flake-url>` will be `.`!
