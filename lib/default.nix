inputs: let
  inherit (inputs) nixpkgs darwin home-manager;
  inherit (inputs) unstable wakatime-ls ghostty-themes helix-themes bat-themes starship-themes;
  inherit (nixpkgs.lib) nixosSystem;
  inherit (darwin.lib) darwinSystem;

  overlays = with inputs; [
    rust-overlay.overlays.default
    helix.overlays.default
    elixir-overlay.overlays.default
    uwu-colors.overlays.default
    (_: final: {next-ls = next-ls.packages.${final.system}.default;})
    (_: final: {
      nodejs = final.nodejs_20;
      nodejs_24 = final.nodejs_20;
    })
  ];

  make-pkgs = {
    system,
    source,
  }:
    import source {
      inherit system overlays;
      config.allowUnfree = true;
    };
in {
  inherit make-pkgs;

  mkDarwin = {
    host ? "personal-mac",
    user ? "zoedsoupe",
    system ? "aarch64-darwin",
  }:
    darwinSystem {
      pkgs = make-pkgs {
        inherit system;
        source = nixpkgs;
      };
      modules = [
        (../hosts + /${host}/configuration.nix)
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [
              ../modules/users
            ];
            users.${user} = let
              pkgs = make-pkgs {
                inherit system;
                source = nixpkgs;
              };
            in {
              _module.args = {
                inherit host system ghostty-themes helix-themes bat-themes starship-themes;
                inherit (inputs) helix lexical-lsp;
                wakatime-ls = wakatime-ls.packages.${system}.default;
                unstable = make-pkgs {
                  inherit system;
                  source = unstable;
                };
                custom-config = import (../hosts + /${host}/custom.nix) {
                  inherit pkgs;
                  unstable = make-pkgs {
                    inherit system;
                    source = unstable;
                  };
                };
              };
              imports = [(../hosts + /${host}/home.nix)];
            };
          };
        }
      ];
    };

  mkISO = {system ? "x86_64-linux"}:
    nixosSystem {
      inherit system;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowBroken = true;
      };
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ../modules/iso/core.nix
        ../modules/iso/user.nix
        ../modules/iso/desktop.nix
      ];
    };
}
