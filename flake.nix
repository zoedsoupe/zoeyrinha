{
  description = "Zoey's personal config, aka dotfiles";

  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-25.05";
    unstable.url = "flake:nixpkgs/nixos-unstable";

    elixir-overlay.url = "github:zoedsoupe/elixir-overlay";

    wakatime-ls = {
      url = "github:mrnossiom/wakatime-ls";
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

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty-themes = {
      url = "github:nyxvamp-theme/ghostty";
      flake = false;
    };

    helix-themes = {
      url = "github:nyxvamp-theme/helix";
      flake = false;
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    inherit (lib.host) mkDarwin mkISO;

    lib = import ./lib inputs;
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
    };
  };
}
