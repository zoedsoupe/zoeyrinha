inputs: let
  inherit (builtins) tryEval fromJSON readFile;
  inherit (inputs) system;
  inherit (inputs) home-manager nixpkgs unstable nixpkgs-22;

  pkgs = import nixpkgs {
    inherit system;
    overlays = with inputs; [
      rust-overlay.overlays.default
      helix.overlays.default
    ];
    # ngrok
    config.allowUnfree = true;
  };

  pkgs-u = import unstable {
    inherit system;
    overlays = with inputs; [helix.overlays.default];
    # ngrok
    config.allowUnfree = true;
  };

  pkgs-22 = import nixpkgs-22 {
    inherit system;
    overlays = with inputs; [helix.overlays.default];
    # ngrok
    config.allowUnfree = true;
  };
in rec {
  mkDarwinHost = host: let
    config = ../hosts + /${host}/custom.nix;
  in {
    inherit pkgs-22 host;
    inherit (inputs) next-ls helix;
    theme = import ./theme.nix {inherit pkgs;};
    nix-std = inputs.nix-std.lib;
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
        imports = [(../hosts + /${host}/home.nix)];
      };
    };
  };

  mkHMUser = {
    userConfig,
    username,
  }:
    home-manager.lib.homeManagerConfiguration {
      inherit system username pkgs;
      stateVersion = "21.05";
      configuration = let
        trySettings = tryEval (fromJSON (readFile /etc/hmsystemdata.json));
        machineData =
          if trySettings.success
          then trySettings.value
          else {};

        machineModule = {
          pkgs,
          config,
          lib,
          ...
        }: {
          options.machineData = lib.mkOption {
            default = {};
            description = "Settings passed from nixos system configuration. If not present will be empty";
          };

          config = {inherit machineData;};
        };
      in {
        zoedsoupe = userConfig;

        nixpkgs = {
          inherit (inputs) overlays;
          config.allowUnfree = true;
        };

        systemd.user.startServices = true;

        home = {
          inherit username;
          stateVersion = "21.05";
          homeDirectory = "/Users/${username}";
          # activation.link-apps = hm.dag.entryAfter ["linkGeneration"] ''
          #   new_nix_apps="${config.home.homeDirectory}/Applications/Nix"
          #   rm -rf "$new_nix_apps"
          #   mkdir -p "$new_nix_apps"
          #   find -H -L "$newGenPath/home-files/Applications" -maxdepth 1 -name "*.app" -type d -print | while read -r app; do
          #     real_app=$(readlink -f "$app")
          #     app_name=$(basename "$app")
          #     target_app="$new_nix_apps/$app_name"
          #     echo "Alias '$real_app' to '$target_app'"
          #     ${pkgs.mkalias}/bin/mkalias "$real_app" "$target_app"
          #   done
          # '';
        };

        imports = [../modules/users machineModule];
      };
      homeDirectory = "/Users/${username}";
    };

  mkSystemUser = {
    name,
    groups,
    uid,
    shell,
  }: {
    users.users."${name}" = {
      inherit name uid shell;
      isNormalUser = true;
      isSystemUser = false;
      extraGroups = groups;
      initialPassword = "nixos";
    };
  };
}
