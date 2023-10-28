{
  pkgs,
  custom-config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.kitty;
in {
  options.kitty.enable = mkEnableOption "Enables Kitty Terminal";
  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        package = pkgs.iosevka;
        name = "Iosevka Term";
        size = 15;
      };
      keybindings = {
        # windows
        "super+w" = "new_tab";
        "super+q" = "close_tab";
        "super+f" = "next_tab";
        "super+d" = "previous_tab";
      };
      settings = {
        disable_ligatures = "never";
        cursor_shape = "block";
        cursor_blink_interval = 0;
        open_url_modifiers = "ctrl";
        initial_window_height = 300;
        initial_window_width = 300;
        term = "xterm-256color";
        allow_remote_control = "yes";
        strip_trailing_spaces = "always";
        tab_bar_style = "hidden";
      };
    };
  };
}
