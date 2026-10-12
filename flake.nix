{
  description = "Zoey's personal config, aka dotfiles";

  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixpkgs-26.05-darwin";
    nixos.url = "flake:nixpkgs/nixos-26.05";
    unstable.url = "flake:nixpkgs/nixpkgs-unstable";

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixos";
    };

    elixir-overlay.url = "github:zoedsoupe/elixir-overlay";

    # declarative disk partitioning, consumed by nixos-anywhere to provision
    # the eveo vps (debian -> nixos)
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos";
    };

    # pesque ships a native NixOS module (services.pesque): the release runs
    # as a plain systemd service, so consume that instead of a container
    pesque = {
      url = "github:zeeetech/pesque";
      inputs.nixpkgs.follows = "nixos";
      inputs.elixir-overlay.follows = "elixir-overlay";
      inputs.zig-overlay.inputs.nixpkgs.follows = "nixos";
    };

    # taina ships its native module (services.taina) the same way
    taina = {
      url = "github:taina-labs/taina";
      inputs.nixpkgs.follows = "nixos";
      inputs.elixir-overlay.follows = "elixir-overlay";
    };

    # tangled ships the knot-rs NixOS module (services.tangled.knot-rs), so the
    # knot runs native like pesque and taina, not the docker image. pinned by DID
    # (the repo's stable identity) rather than its handle.
    tangled = {
      url = "git+https://tangled.org/did:plc:j5hmlfdrwkvtxm7cjmu7j2is";
      inputs.nixpkgs.follows = "nixos";
    };

    # zoeyrinha-web ships its own release derivation (packages.default)
    zoeyrinha-web = {
      url = "github:zoedsoupe/zoeyrinha-web";
      inputs.nixpkgs.follows = "nixos";
    };

    pitaco = {
      url = "github:zoedsoupe/pitaco";
      flake = false;
    };

    paintbox = {
      url = "github:zoedsoupe/paintbox";
      flake = false;
    };

    quintal = {
      url = "github:zoedsoupe/quintal";
      flake = false;
    };

    wakatime-ls = {
      url = "github:mrnossiom/wakatime-ls";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    envoluntary = {
      url = "github:dfrankland/envoluntary";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    expert-lsp.url = "github:elixir-lang/expert";

    # colorize hex colors on helix (lsp)
    uwu-colors.url = "github:q60/uwu_colors";

    # nyxvamp themes
    ghostty-themes = {
      url = "github:nyxvamp-theme/ghostty";
      flake = false;
    };

    helix-themes = {
      url = "github:nyxvamp-theme/helix";
      flake = false;
    };

    bat-themes = {
      url = "github:nyxvamp-theme/bat";
      flake = false;
    };

    starship-themes = {
      url = "github:nyxvamp-theme/starship";
      flake = false;
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    lib = import ./lib inputs;
    inherit (lib) mkDarwin mkHost mkISO;
  in {
    darwinConfigurations = {
      zoedsoupe-mac = mkDarwin {
        host = "personal-mac";
      };
    };

    nixosConfigurations = {
      minimal-iso = mkISO {
        system = "x86_64-linux";
      };

      yby-iso = mkISO {
        system = "x86_64-linux";
        host = "yby";
      };

      yby = mkHost {
        host = "yby";
      };

      eveo = mkHost {
        host = "eveo";
      };
    };

    devShells.aarch64-darwin.default = let
      pkgs = lib.make-pkgs {
        system = "aarch64-darwin";
        source = nixpkgs;
      };
    in
      pkgs.mkShell {
        name = "zoeyrinha";
        packages = [pkgs.alejandra];
      };
  };
}
