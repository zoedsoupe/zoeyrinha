# minimal niri session: compositor + greeter + portals + fonts.
# headless hosts (no monitor/keyboard) leave this off and admin over SSH.
#
# the niri nixos module already enables xdg.portal (gnome+gtk) and
# gnome-keyring, which is what a browser needs for file dialogs.
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.niri;
in {
  options.niri.enable = mkEnableOption "niri wayland session";

  config = mkIf cfg.enable {
    programs.niri.enable = true;
    # nautilus is only pulled in for the portal FileChooser; skip it
    programs.niri.useNautilus = false;

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user = "greeter";
      };
    };

    # ui + mono
    fonts.packages = with pkgs; [
      ibm-plex
      mononoki
    ];
  };
}
