inputs: let
  inherit (inputs) nixpkgs nixos unstable darwin home-manager envoluntary;
  inherit (inputs) wakatime-ls ghostty-themes helix-themes bat-themes starship-themes expert-lsp;
  inherit (nixos.lib) nixosSystem;
  inherit (darwin.lib) darwinSystem;
  nixlib = nixpkgs.lib;

  # Helix ships ~300 tree-sitter grammars. Build only the ones languages.nix
  # actually maps to. heex/eex carry no `grammar` field upstream (only a
  # scope), but helix resolves grammar by scope, so they must ship alongside
  # elixir. The predicate receives the whole grammar attrset, not its name.
  #
  # Takes pkgs as an argument rather than closing over `make-pkgs`, since the
  # overlay below already has a real instance in scope. languages.nix only
  # touches pkgs inside formatter commands, so only `helix-names` is ever
  # forced -- but passing a real pkgs keeps that laziness an implementation
  # detail instead of a landmine.
  helix-grammars = pkgs:
    let
      langs = import ../modules/users/helix/languages.nix {
        inherit pkgs;
        lib = nixlib;
      };
      # lix 2.95 rejects the (f, set) argument order of builtins.attrValues
      names = builtins.map (name: langs.${name}.helix-names) (builtins.attrNames langs);
    in
    # flatten: the per-language lists must be merged into one flat list, or
    # `builtins.elem` below compares each grammar name against a list and
    # never matches, silently shipping zero grammars.
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
  }:
    let
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

  mkISO = {system ? "x86_64-linux"}:
    nixosSystem {
      inherit system;
      pkgs = make-pkgs {
        inherit system;
        source = nixos;
      };
      modules = [
        "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ../modules/iso/core.nix
        ../modules/iso/user.nix
        ../modules/iso/desktop.nix
      ];
    };

  mkHost = {
    host,
    user ? "zoedsoupe",
    system ? "x86_64-linux",
    desktop ? false,
  }:
    let
      pkgs = make-pkgs {
        inherit system;
        source = nixos;
      };
    in
      nixosSystem {
        inherit pkgs;
        modules =
          [
            (../hosts + /${host}/configuration.nix)
            ../modules/nixos/common.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules =
                  [
                    ../modules/users
                    envoluntary.homeModules.default
                  ]
                  ++ nixlib.optional desktop inputs.noctalia-shell.homeModules.default;
                users.${user} = mkHM {
                  inherit host system pkgs;
                  extraImports = nixlib.optional desktop ../modules/nixos/noctalia.nix;
                };
              };
            }
          ]
          ++ nixlib.optional desktop ../modules/nixos/desktop.nix;
      };
}
