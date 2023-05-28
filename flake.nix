{
  description = "Zoey's personal config, aka dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # My custom NeoVim config
    lvim.url = "github:zoedsoupe/lvim";
    mnvim.url = "github:zoedsoupe/mnvim";

    # need to solve this about fcitx-engines
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, lvim, mnvim, ... }:
    let
      inherit (nixpkgs.lib) nixosSystem;# maybe I'll bought a linux machine????
      # inherit (darwin.lib) darwinSystem; I'll use only when I bought my own mac
      inherit (home-manager.lib) homeManagerConfiguration;
    in
    {
      homeManagerConfigurations.zoedsoupe = homeManagerConfiguration {
        pkgs = import nixpkgs rec {
          system = "aarch64-darwin";
          overlays = [
            lvim.overlays."${system}".default
            mnvim.overlays."${system}".default
          ];
          config.allowUnfree = true;
        };
        modules = [
          ./hosts/mac/home.nix
          ./modules/users/bat.nix
          ./modules/users/fzf.nix
          ./modules/users/git.nix
          ./modules/users/zsh.nix
          ./modules/users/direnv.nix
          ./modules/users/starship.nix
        ];
      };

      installMedia = {
        minimal = let system = "x86_64-linux"; in nixosSystem {
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.allowBroken = true;
          };
          modules =
            [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              ./modules/iso/core.nix
              ./modules/iso/user.nix
              ./modules/iso/desktop.nix
            ];
        };
      };
    };
}
