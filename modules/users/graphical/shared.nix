{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.graphical;
  systemCfg = config.machineData.systemConfig;

  gtk-omni = pkgs.fetchFromGitHub {
    owner = "getomni";
    repo = "gtk";
    rev = "HEAD";
    sha256 = "sha256-NSZjkG+rY6h8d7FYq5kipPAjMDAgyaYAgOOOJlfqBCI=";
  };
in {
  config = mkIf (cfg.wayland.enable) {
    home.packages = with pkgs; [
      pavucontrol
      lxappearance
      numix-cursor-theme
    ];

    gtk = {
      enable = true;
      theme = {
        package = gtk-omni;
        name = "Omni";
      };
      iconTheme = {
        package = pkgs.arc-icon-theme;
        name = "arc-icon";
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };
  };
}
