{
  pkgs,
  home-manager,
  lib,
  system,
  overlays,
  ...
}:
with builtins; {
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
          inherit overlays;
          config.allowUnfree = true;
        };

        systemd.user.startServices = true;

        home = {
          inherit username;
          stateVersion = "21.05";
          homeDirectory = "/Users/${username}";
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
