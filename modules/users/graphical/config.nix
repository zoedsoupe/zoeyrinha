{ pkgs, config, lib, ... }:

with lib;

{
  config.zoedsoupe.graphical = {
    wayland = {
      enable = mkDefault false;
      desktop-environment = mkDefault null;

      # correct wallpaper
      # /home/zoedsoupe/documents/privy/zoeyrinha/wallpapers/syscalls.png;

      background = {
        enable = mkDefault false;
        image = mkDefault ../../system/misc/boot_wallpaper.jpg;
        mode = mkDefault "fill";
        pkg = mkDefault pkgs.swaybg;
      };

      statusbar = {
        enable = mkDefault false;
        pkg = mkDefault pkgs.waybar;
      };

      screenlock = {
        enable = mkDefault false;
      };
    };
  };
}
