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
    lexical-lsp.url = "github:lexical-lsp/lexical";
    next-ls.url = "github:elixir-tools/next-ls?ref=v0.14.1";
    # Custom Helix package
    helix.url = "github:helix-editor/helix";
  };

  outputs = {
    nixpkgs,
    home-manager,
    darwin,
    ...
  } @ inputs: let
    inherit (nixpkgs.lib) nixosSystem;
    inherit (darwin.lib) darwinSystem;
  in {
    nixosConfigurations.cumbuca = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [inputs.helix.overlays.default];
        config.allowUnfree = true;
      };
    in
      nixosSystem {
        inherit pkgs;
        modules = [
          ./hosts/cumbuca/bootstrap.nix
          ./hosts/cumbuca/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;

              useUserPackages = true;
              extraSpecialArgs = {
                inherit (inputs) next-ls helix;
                custom-config = import ./hosts/cumbuca/custom.nix {inherit pkgs;};
              };
              users.zoedsoupe = {
                imports = [./hosts/cumbuca/home ./modules/users];
              };
            };
          }
        ];
      };

    darwinConfigurations = let
      pkgs = import nixpkgs rec {
        system = "aarch64-darwin";
        overlays = with inputs; [
          rust-overlay.overlays.default
          lvim.overlays."${system}".default
          helix.overlays.default
        ];
        config.allowUnfree = true;
      };
    in {
      zoedsoupe = darwinSystem rec {
        inherit pkgs;
        modules = let
          zoedsoupe.custom-config = import ./hosts/mac/custom.nix {inherit pkgs;};
          zoeycumbuca.custom-config = import ./hosts/cumbuca-darwin/custom.nix {inherit pkgs;};
        in [
          ./hosts/mac/configuration.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [./modules/users];

            home-manager.users = {
              zoeycumbuca = {
                _module.args = {inherit (inputs) next-ls helix; inherit (zoeycumbuca) custom-config;};
                imports = [./hosts/cumbuca-darwin/home.nix];
              };

              zoedsoupe = {
                _module.args = {inherit (inputs) next-ls helix; inherit (zoedsoupe) custom-config;};
                imports = [./hosts/mac/home.nix];
              };
            };
          }
        ];
      };
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
