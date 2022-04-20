{ pkgs, home-manager, lib, system, overlays, ... }:

with builtins;

{
  mkHMUser = {};

  mkSystemUser = { name, groups, uid, shell }: {
    users.users."${name}" = {
      inherit name uid shell;
      isNormalUser = true;
      isSystemUser = false;
      extraGroups = groups;
      initialPassword = "nixos";
    };
  }
}
