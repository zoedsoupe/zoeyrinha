inputs: let
  inherit (inputs) nixpkgs nixos unstable darwin home-manager envoluntary;
  inherit (inputs) wakatime-ls ghostty-themes helix-themes bat-themes starship-themes expert-lsp;
  inherit (nixos.lib) nixosSystem;
  inherit (darwin.lib) darwinSystem;
  nixlib = nixpkgs.lib;

  # nixpkgs' helix splits the editor (helix-unwrapped, a plain cached rust
  # build) from the grammars (one derivation each). overriding lockedGrammars
  # keeps helix-unwrapped cached and only realises the grammar derivations a
  # host needs, instead of the from-source helix-flake build carrying every
  # grammar. the default set is read from nixpkgs so a name never drifts from
  # what the package actually ships.
  default-helix-grammars = pkgs:
    builtins.fromJSON (builtins.readFile (pkgs.path + "/pkgs/by-name/he/helix/grammars.json"));

  # helix-names double as tree-sitter grammar names, so the enabled languages
  # map straight onto lockedGrammars keys. bash/dockerfile/toml/yaml are always
  # kept: shell, docker and those config formats are wanted even without a
  # language block. the intersect in helix-overlay drops any name nixpkgs does
  # not ship, keeping the package's grammar-count check consistent.
  helix-grammar-names = pkgs: host: let
    cfg = import (../hosts + /${host}/custom.nix) {inherit pkgs;};
    langs = import ../modules/users/helix/languages.nix {
      inherit pkgs;
      lib = nixlib;
    };
    enabled = name: (cfg.helix.languages.${name} or {}).enable or false;
    wanted =
      nixlib.concatMap (
        name:
          if enabled name
          then langs.${name}.helix-names or []
          else []
      )
      (builtins.attrNames langs);
  in
    wanted ++ ["bash" "dockerfile" "toml" "yaml"];

  # per-host: a host with helix off realises no grammars, one with a handful of
  # languages realises only those
  helix-overlay = host: _final: prev: {
    helix = prev.helix.override {
      lockedGrammars = nixlib.filterAttrs (
        name: _: builtins.elem name (helix-grammar-names prev host)
      ) (default-helix-grammars prev);
    };
  };

  overlays = with inputs; [
    rust-overlay.overlays.default
    elixir-overlay.overlays.default
    uwu-colors.overlays.default
    envoluntary.overlays.default
    (_: final: {expert-lsp = expert-lsp.packages.${final.system}.default;})
  ];

  make-pkgs = {
    system,
    source,
    extraOverlays ? [],
  }:
    import source {
      inherit system;
      overlays = overlays ++ extraOverlays;
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
      extraOverlays = [(helix-overlay host)];
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
      extraOverlays = [(helix-overlay host)];
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
