{
  pkgs,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.wezterm;
in {
  options.wezterm.enable = mkEnableOption "Enables Wezterm emulator";

  config = mkIf cfg.enable {
    programs.wezterm = {
      inherit (cfg) enable;
      enableZshIntegration = true;
      extraConfig = ''
        local wezterm = require("wezterm");

        return {
          check_for_updates = false,
          automatically_reload_config = true,
          selection_word_boundary = " \t\n{}[]()\"'`,;:@│┃*…$",
          exit_behavior = "Close",
          window_close_confirmation = "NeverPrompt",
          font = wezterm.font("Monaspace Neon"),
          font_size = 16.0,
          color_scheme = "OneDark (base16)",
          hide_tab_bar_if_only_one_tab = true
        }
      '';
    };
  };
}
