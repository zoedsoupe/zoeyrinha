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

  outputs = {
    nixpkgs,
    home-manager,
    lvim,
    darwin,
    ...
  }: let
    inherit (nixpkgs.lib) nixosSystem;
    inherit (darwin.lib) darwinSystem;
  in {
    darwinConfigurations.nubank = darwinSystem rec {
      pkgs = import nixpkgs rec {
        system = "aarch64-darwin";
        overlays = [lvim.overlays."${system}".default];
        config.allowUnfree = true;
      };
      modules = [
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            custom-config = import ./hosts/nubank/custom.nix {inherit pkgs;};
          };
          home-manager.users.zoey.pessanha = {
            imports = [
              ./hosts/nubank/home.nix
              ./modules/users/bat.nix
              ./modules/users/fzf.nix
              ./modules/users/git.nix
              ./modules/users/zsh.nix
              ./modules/users/direnv.nix
              ./modules/users/starship.nix
            ];
          };
        }
      ];
    };

    darwinConfigurations.zoedsoupe = darwinSystem rec {
      pkgs = import nixpkgs rec {
        system = "aarch64-darwin";
        overlays = [lvim.overlays."${system}".default];
        config.allowUnfree = true;
      };
      modules = [
        ./hosts/mac/configuration.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            custom-config = import ./hosts/mac/custom.nix {inherit pkgs;};
          };
          home-manager.users.zoedsoupe = {
            imports = [
              ./hosts/mac/home.nix
              ./modules/users/bat.nix
              ./modules/users/fzf.nix
              ./modules/users/git.nix
              ./modules/users/zsh.nix
              ./modules/users/direnv.nix
              ./modules/users/starship.nix
            ];
          };
        }
      ];
    };

    installMedia = {
      minimal = let
        system = "x86_64-linux";
      in
        nixosSystem {
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.allowBroken = true;
          };
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./modules/iso/core.nix
            ./modules/iso/user.nix
            ./modules/iso/desktop.nix
          ];
        };
    };
  };
}
