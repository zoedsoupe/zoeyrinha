{
  description = "Zoey's personal config, aka dotfiles";

  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-25.05";
    nixpkgs-22.url = "flake:nixpkgs/nixos-22.11";
    unstable.url = "flake:nixpkgs/nixos-unstable";

    elixir-overlay.url = "github:zoedsoupe/elixir-overlay";

    wakatime-ls = {
      url = "github:mrnossiom/wakatime-ls?rev=c17ce1329c26772b3518599e32f0a1921a3a01f8";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-std.url = "github:chessai/nix-std";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # My custom NeoVim config
    # 26/09/2024 - using helix/zed
    # lvim.url = "github:zoedsoupe/lvim";
    # mnvim.url = "github:zoedsoupe/mnvim";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # need to solve this about fcitx-engines
    home-manager.url = "github:nix-community/home-manager?ref=release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Helix build from main
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    # TODO migrate ISO user to (lib.host.mkISO)
    inherit (nixpkgs.lib) nixosSystem;
    inherit (lib.host) mkDarwin;

    lib = import ./lib inputs;
  in {
    darwinConfigurations = {
      cloudwalk-mac = mkDarwin {
        host = "cloudwalk";
        user = "zoeypessanha";
        # neovim.enable = false;
      };
      zoedsoupe-mac = mkDarwin {
        host = "personal-mac";
        # neovim.enable = true;
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
