{
  pkgs,
  custom-config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.zellij;
in {
  options.zellij.enable = mkEnableOption "Enables zellij multiplexer";

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableZshIntegration = false;
      settings = {
        default_shell = "${pkgs.zsh}/bin/zsh";
        scrollback_editor = "${pkgs.helix}/bin/hx";
        ui.pane_frames.rounded_corners = true;
      };
    };
  };
}
