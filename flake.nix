{
  description = "Zoey's personal config, aka dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # My custom NeoVim config
    lvim.url = "github:zoedsoupe/lvim";
    mnvim.url = "github:zoedsoupe/mnvim";

    # need to solve this about fcitx-engines
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # LSP elixir
    next-ls.url = "github:elixir-tools/next-ls";
    helix.url = "github:helix-editor/helix";
  };

  outputs = {
    nixpkgs,
    home-manager,
    rust-overlay,
    next-ls,
    helix,
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
        ./hosts/nubank/configuration.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            custom-config = import ./hosts/nubank/custom.nix {inherit pkgs;};
          };
          home-manager.users."zoey.pessanha" = {
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

    darwinConfigurations.zoedsoupe = let
      pkgs = import nixpkgs rec {
        system = "aarch64-darwin";
        overlays = [
          rust-overlay.overlays.default
          lvim.overlays."${system}".default
          helix.overlays.default
        ];
        config.allowUnfree = true;
      };
    in
      darwinSystem rec {
        inherit pkgs;
        modules = [
          ./hosts/mac/configuration.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit next-ls helix;
              custom-config = import ./hosts/mac/custom.nix {inherit pkgs;};
            };
            home-manager.users.zoedsoupe = {
              imports = [
                ./hosts/mac/home.nix
                ./modules/users/bat.nix
                ./modules/users/fzf.nix
                ./modules/users/git.nix
                ./modules/users/helix.nix
                ./modules/users/direnv.nix
                # ./modules/users/nnn.nix
                ./modules/users/starship.nix
                ./modules/users/zellij.nix
                ./modules/users/zoxide.nix
                ./modules/users/zsh.nix
                ./modules/users/xplr.nix
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
