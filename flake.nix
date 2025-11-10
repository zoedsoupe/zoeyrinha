{
  description = "Zoey's personal config, aka dotfiles";

  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixpkgs-25.05-darwin";

    elixir-overlay.url = "github:zoedsoupe/elixir-overlay";
    # next-ls.url = "github:elixir-tools/next-ls";

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

    envoluntary = {
      url = "github:dfrankland/envoluntary";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
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
    inherit (lib) mkDarwin mkISO;
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
