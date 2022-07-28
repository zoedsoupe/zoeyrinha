{ pkgs, config, lib, ... }:

let
  gtk-omni = pkgs.fetchFromGitHub {
    owner = "getomni";
    repo = "gtk";
    rev = "e81b3fbebebf53369cffe1fb662abc400edb04f7";
    sha256 = "NSZjkG+rY6h8d7FYq5kipPAjMDAgyaYAgOOOJlfqBCI=";
  };
in
{
  config = {
    home.packages = with pkgs; [
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.application-volume-mixer
      gnomeExtensions.switcher
      gnomeExtensions.pop-shell
      gnome.gnome-screenshot
      gnomeExtensions.github-notifications
    ];

    gtk = {
      enable = true;
      theme = {
        package = pkgs.rose-pine-gtk-theme;
        name = "Rose-Pine";
      };
      iconTheme = {
        package = pkgs.numix-icon-theme-circle;
        name = "Numix-Circle-Light";
      };
      cursorTheme = {
        package = pkgs.numix-cursor-theme;
        name = "Numix-Cursor-Light";
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };
  };
}
