{
  custom-config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = custom-config.kitty;
in {
  options.kitty = {
    enable = mkEnableOption "Enables Kitty Terminal";
    font-family = mkOption {
      default = "Dank Mono";
      type = types.str;
      description = "Font familly to apply to the terminal";
    };
    theme = mkOption {
      default = "catppuccin-frappe";
      description = "Theme to apply to the terminal";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      # theme = "Catppuccin-Macchiato";
      font = {
        name = cfg.font-family;
        size = 16;
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
        initial_window_height = 30;
        initial_window_width = 90;
        term = "xterm-256color";
        allow_remote_control = "yes";
        strip_trailing_spaces = "always";
        tab_bar_style = "powerline";
        tab_bar_min_tabs = 1;
        tab_bar_edge = "bottom";
        window_padding_width = 12;
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
        font_features = "#{cfg.font-family} +cv02 +cv05 +cv09 +cv14 +ss04 +cv16 +cv31 +cv25 +cv26 +cv32 +cv28 +ss10 +zero +onum";
      };
    };
  };
}
