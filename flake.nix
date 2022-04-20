{
  description = "Zoey's eprsonal config, aka dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    latest.url = "github:nixos/nixpkgs/nixos-unstable";

    nixlib.url = "github:nix-community/nixpkgs.lib";

    # My custom NeoVim config
    copper.url = "github:zoedsoupe/copper";

    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixlib";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  }:

  outputs =
    { self
    , nixlib
    , nixpkgs
    , latest
    , home-manager
    , flake-utils-plus
    , ...
    }@inputs:
    let
      inherit (nixlib) lib;

      util = import .lib {
        inherit system pkgs home-manager lib; overlays = (pkgs.overlays);
      };

      inherit (util) user;
      inherit (util) host;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [];
      };

      system = "x86_64-linux";
    in {
      homeManagerConfigurations = {
        zoedsoupe = user.mkHMUser {};
      };

      nixosConfigurations = {
      };
    };
  }
