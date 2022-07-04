{ pkgs, config, lib, ... }:

let
  gtk-omni = pkgs.fetchFromGitHub {
    owner = "getomni";
    repo = "gtk";
    rev = "HEAD";
    sha256 = "sha256-NSZjkG+rY6h8d7FYq5kipPAjMDAgyaYAgOOOJlfqBCI=";
  };
in
{
  config = {
    home.packages = with pkgs; [
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
        package = pkgs.numix-icon-theme-circle;
        name = "Numix-Icon-Circle";
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
