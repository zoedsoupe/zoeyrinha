{ pkgs, config, lib, ... }:

with lib;

{
  config.zoedsoupe.graphical = {
    wayland = {
      enable = mkDefault false;
      desktop-environment = mkDefault null;

      background = {
        enable = mkDefault false;
        image = mkDefault /home/zoedsoupe/documents/privy/zoeyrinha/wallpapers/syscalls.png;
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
