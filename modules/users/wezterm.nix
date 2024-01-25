{
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
          -- ligatures from https://monaspace.githubnext.com/
          harfbuzz_features = {"ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08", "calt", "dlig"},
          check_for_updates = false,
          automatically_reload_config = true,
          selection_word_boundary = " \t\n{}[]()\"'`,;:@│┃*…$",
          exit_behavior = "Close",
          window_close_confirmation = "NeverPrompt",
          font = wezterm.font("Dank Mono"),
          font_size = 17.5,
          color_scheme = "OneDark (base16)",
          hide_tab_bar_if_only_one_tab = true
        }
      '';
    };
  };
}
