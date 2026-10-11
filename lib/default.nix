inputs: let
  inherit (inputs) nixpkgs nixos unstable darwin home-manager envoluntary;
  inherit (inputs) wakatime-ls ghostty-themes helix-themes bat-themes starship-themes expert-lsp;
  inherit (nixos.lib) nixosSystem;
  inherit (darwin.lib) darwinSystem;
  nixlib = nixpkgs.lib;

  # build only the tree-sitter grammars languages.nix maps to. heex/eex carry
  # no `grammar` field upstream (only a scope), but helix resolves grammar by
  # scope, so they must ship alongside elixir. takes pkgs as an argument
  # rather than closing over make-pkgs, since the overlay below already has a
  # real instance in scope.
  helix-grammars = pkgs: let
    langs = import ../modules/users/helix/languages.nix {
      inherit pkgs;
      lib = nixlib;
    };
    # lix 2.95 rejects the (f, set) argument order of builtins.attrValues
    names = builtins.map (name: langs.${name}.helix-names) (builtins.attrNames langs);
  in
    # flattened: otherwise builtins.elem below compares each grammar name
    # against a list and never matches, shipping zero grammars
    nixlib.flatten names ++ ["bash" "Dockerfile" "zsh" "toml" "yaml"];

  overlays = with inputs; [
    rust-overlay.overlays.default
    helix.overlays.default
    (_: prev: {
      helix = prev.helix.override {
        includeGrammarIf = g: builtins.elem g.name (helix-grammars prev);
      };
    })
    elixir-overlay.overlays.default
    uwu-colors.overlays.default
    envoluntary.overlays.default
    (_: final: {expert-lsp = expert-lsp.packages.${final.system}.default;})
  ];

  make-pkgs = {
    system,
    source,
  }:
    import source {
      inherit system overlays;
      config.allowUnfree = true;
    };

  # shared home-manager wiring for both darwin and nixos builders
  mkHM = {
    host,
    system,
    pkgs,
    extraImports ? [],
  }: {
    _module.args = {
      inherit ghostty-themes helix-themes bat-themes starship-themes;
      unstable = make-pkgs {
        inherit system;
        source = unstable;
      };
      wakatime-ls = wakatime-ls.packages.${system}.default;
      custom-config = import (../hosts + /${host}/custom.nix) {
        inherit pkgs;
      };
    };
    imports =
      [(../hosts + /${host}/home.nix)]
      ++ extraImports;
  };
in {
  inherit make-pkgs;

  mkDarwin = {
    host ? "personal-mac",
    user ? "zoedsoupe",
    system ? "aarch64-darwin",
  }: let
    pkgs = make-pkgs {
      inherit system;
      source = nixpkgs;
    };
  in
    darwinSystem {
      inherit pkgs;
      modules = [
        (../hosts + /${host}/configuration.nix)
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [
              ../modules/users
              envoluntary.homeModules.default
            ];
            users.${user} = mkHM {inherit host system pkgs;};
          };
        }
      ];
    };

  mkISO = {
    system ? "x86_64-linux",
    host ? null,
  }:
    nixosSystem {
      inherit system;
      pkgs = make-pkgs {
        inherit system;
        source = nixos;
      };
      # host is null for the minimal ISO; modules/iso/host.nix reads it back
      specialArgs = {inherit host;};
      modules =
        [
          "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ../modules/iso/core.nix
          ../modules/iso/user.nix
          ../modules/iso/desktop.nix
        ]
        ++ nixlib.optional (host != null) ../modules/iso/host.nix;
    };

  # compositor and service modules are gated behind their own `enable`
  # options, flipped from each host's config (noctalia from the host's
  # home.nix)
  mkHost = {
    host,
    user ? "zoedsoupe",
    system ? "x86_64-linux",
  }: let
    pkgs = make-pkgs {
      inherit system;
      source = nixos;
    };
  in
    nixosSystem {
      inherit pkgs;
      # hosts reach the app sources to build their releases (lib/mkRelease.nix)
      specialArgs = {inherit inputs;};
      modules = [
        (../hosts + /${host}/configuration.nix)
        ../modules/nixos/common.nix
        ../modules/nixos/niri.nix
        ../modules/nixos/zfs-datasets.nix
        ../modules/nixos/services
        # pesque's upstream module (services.pesque), gated by its own enable
        inputs.pesque.nixosModules.pesque
        # taina's upstream module (services.taina), same shape
        inputs.taina.nixosModules.taina
        # tangled's knot-rs module (services.tangled.knot-rs), same shape
        inputs.tangled.nixosModules.knot-rs
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [
              ../modules/users
              envoluntary.homeModules.default
              inputs.noctalia-shell.homeModules.default
            ];
            users.${user} = mkHM {
              inherit host system pkgs;
              extraImports = [../modules/nixos/noctalia.nix];
            };
          };
        }
      ];
    };
}
