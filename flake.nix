{
  description = "Zoey's personal config, aka dotfiles";

  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-24.05";
    nixpkgs-22.url = "flake:nixpkgs/nixos-22.05";
    unstable.url = "flake:nixpkgs/nixos-unstable";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "unstable";
    };

    # My custom NeoVim config
    # 26/09/2024 - using helix/zed
    # lvim.url = "github:zoedsoupe/lvim";
    # mnvim.url = "github:zoedsoupe/mnvim";

    # need to solve this about fcitx-engines
    home-manager.url = "github:nix-community/home-manager?ref=release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Helix build from main
    helix.url = "github:helix-editor/helix?ref=HEAD";

    presenterm.url = "github:mfontanini/presenterm?ref=HEAD";
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
    darwinConfigurations = let
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        overlays = with inputs; [
          rust-overlay.overlays.default
          helix.overlays.default
        ];
        config.allowUnfree = true;
      };

      unstable = import inputs.unstable {
        system = "aarch64-darwin";
        overlays = [inputs.helix.overlays.default];
        config.allowUnfree = true;
      };

      pkgs-22 = import inputs.nixpkgs-22 {
        system = "aarch64-darwin";
        overlays = [inputs.helix.overlays.default];
        config.allowUnfree = true;
      };
    in {
      zoedsoupe = darwinSystem rec {
        inherit pkgs;
        modules = let
          zoedsoupe.custom-config = import ./hosts/mac/custom.nix {
            inherit pkgs unstable;
          };
          # zoeycumbuca.custom-config = import ./hosts/cumbuca/custom.nix {inherit pkgs;};
        in [
          ./hosts/mac/configuration.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [./modules/users];

            home-manager.users = let
              args = host: {
                inherit pkgs-22 unstable;
                inherit (inputs) next-ls helix presenterm;
                inherit (host) custom-config;
              };
            in {
              # using single user
              # zoeycumbuca = {
              #   _module.args = args zoeycumbuca;
              #   imports = [./hosts/cumbuca/home.nix];
              # };

              zoedsoupe = {
                _module.args = args zoedsoupe;
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
