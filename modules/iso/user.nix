{
  lib,
  pkgs,
  ...
}: {
  programs.zsh.enable = true;
  users.users.nixos = {
    name = "nixos";
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    uid = 1000;
    # the installer profile sets initialHashedPassword = "" for passwordless
    # login; force it off so only initialPassword is set (kills the warning)
    initialHashedPassword = lib.mkForce null;
    initialPassword = "helloworld!";
    shell = pkgs.zsh;
  };
}
