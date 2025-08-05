inputs: let
  inherit (inputs) system;
  inherit (inputs) home-manager nixpkgs unstable wakatime-ls ghostty-themes helix-themes;
  inherit (home-manager.lib) hm;

  pkgs = import nixpkgs {
    inherit system;
    overlays = with inputs; [
      rust-overlay.overlays.default
      helix.overlays.default
      elixir-overlay.overlays.default
      uwu-colors.overlays.default
    ];
    # ngrok
    config.allowUnfree = true;
  };

  pkgs-u = import unstable {
    inherit system;
    overlays = with inputs; [helix.overlays.default elixir-overlay.overlays.default];
    # ngrok
    config.allowUnfree = true;
  };
in rec {
  mkDarwinHost = host: let
    config = ../hosts + /${host}/custom.nix;
  in {
    inherit host system ghostty-themes helix-themes;
    inherit (inputs) helix;
    wakatime-ls = wakatime-ls.packages.${system}.default;
    theme = import ./theme.nix {inherit pkgs;};
    unstable = pkgs-u;
    custom-config = import config {
      inherit pkgs;
      unstable = pkgs-u;
    };
  };

  mkDarwinUser = {
    host,
    user,
  }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [../modules/users];

      users.${user} = {
        _module.args = mkDarwinHost host;
        home.activation.link-apps = hm.dag.entryAfter ["linkGeneration"] ''
          new_nix_apps="/Users/${user}/Applications/Nix"
          rm -rf "$new_nix_apps"
          mkdir -p "$new_nix_apps"
          find -H -L "$newGenPath/home-files/Applications" -maxdepth 1 -name "*.app" -type d -print | while read -r app; do
            real_app=$(readlink -f "$app")
            app_name=$(basename "$app")
            target_app="$new_nix_apps/$app_name"
            echo "Alias '$real_app' to '$target_app'"
            ${pkgs.mkalias}/bin/mkalias "$real_app" "$target_app"
          done
        '';
        imports = [(../hosts + /${host}/home.nix)];
      };
    };
  };
}
