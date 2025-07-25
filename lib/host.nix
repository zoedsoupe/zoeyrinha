inputs: let
  inherit (inputs) system;
  inherit (inputs) nixpkgs darwin;
  inherit (inputs) home-manager;
  inherit (inputs.user) mkDarwinUser;
  inherit (nixpkgs.lib) nixosSystem;
  inherit (darwin.lib) darwinSystem;

  unstable = import inputs.unstable {inherit system;};

  nodejs-overlay = _: _: {
    nodejs = unstable.nodejs_24;
  };

  pkgs = import nixpkgs {
    inherit system;
    overlays = with inputs; [
      rust-overlay.overlays.default
      helix.overlays.default
      elixir-overlay.overlays.default
      nodejs-overlay
    ];
    # ngrok
    config.allowUnfree = true;
  };
in {
  mkDarwin = {
    host ? "personal-mac",
    user ? "zoedsoupe",
  }:
    darwinSystem {
      inherit pkgs;
      modules = [
        (../hosts + /${host}/configuration.nix)
        home-manager.darwinModules.home-manager
        (mkDarwinUser {inherit user host;})
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
