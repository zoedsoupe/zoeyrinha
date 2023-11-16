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
    lexical-lsp.url = "github:zoedsoupe/lexical?rev=1eeb7715e2eb2a21795801cb002798f055ade3aa";
    next-ls.url = "github:elixir-tools/next-ls?ref=v0.15.0";
    # Custom Helix package
    helix.url = "github:helix-editor/helix?ref=HEAD";

    presenterm.url = "github:mfontanini/presenterm";
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
          zoeycumbuca.custom-config = import ./hosts/cumbuca/custom.nix {inherit pkgs;};
        in [
          ./hosts/mac/configuration.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [./modules/users];

            home-manager.users = let
              args = host: {
                inherit (inputs) lexical-lsp next-ls helix presenterm;
                inherit (host) custom-config;
              };
            in {
              zoeycumbuca = {
                _module.args = args zoeycumbuca;
                imports = [./hosts/cumbuca/home.nix];
              };

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
