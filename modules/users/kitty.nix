{ pkgs, config, lib, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf;
  inherit (lib.types) enum;

  cfg = config.zoedsoupe.kitty;

  omni = {
    foreground = "#e1e1e6";
    background = "#191622";
    selection_foreground = "#44475a";
    selection_background = "#f8f8f2";
    url_color = "#ffb86c";
    # black
    color0 = "#000000";
    color8 = "#4d4d4d";
    # red
    color1 = "#ff5555";
    color9 = "#ff6e67";
    # green
    color2 = "#50fa7b";
    color10 = "#5af78e";
    # yellow
    color3 = "#effa78";
    color11 = "#eaf08d";
    # blue
    color4 = "#bd93f9";
    color12 = "#caa9fa";
    # magenta
    color5 = "#ff79c6";
    color13 = "#ff92d0";
    # cyan
    color6 = "#8d79ba";
    color14 = "#aa91e3";
    # white
    color7 = "#bfbfbf";
    color15 = "#e6e6e6";
    # Cursor colors
    cursor = "#f8f8f2";
    cursor_text_color = "background";
    # Tab bar colors
    active_tab_foreground = "#191631";
    active_tab_background = "#e6e6e6";
    inactive_tab_foreground = "#44476f";
    inactive_tab_background = "#6272a4";
  };

  rose-pine = {
    foreground = "#e0def4";
    background = "#191724";
    selection_foreground = "#e0def4";
    selection_background = "#403d52";
    url_color = "#c4a7e7";
    # black
    color0 = "#26233a";
    color8 = "#6e6a86";
    # red
    color1 = "#eb6f92";
    color9 = "#eb6f92";
    # green
    color2 = "#31748f";
    color10 = "#31748f";
    # yellow
    color3 = "#f6c177";
    color11 = "#f6c177";
    # blue
    color4 = "#9ccfd8";
    color12 = "#9ccfd8";
    # magenta
    color5 = "#c4a7e7";
    color13 = "#c4a7e7";
    # cyan
    color6 = "#ebbcba";
    color14 = "#ebbcba";
    # white
    color7 = "#e0def4";
    color15 = "#e0def4";
    # Cursor colors
    cursor = "#524f67";
    cursor_text_color = "#e0def4";
    # Tab bar colors
    active_tab_foreground = "#e0def4";
    active_tab_background = "#26233a";
    inactive_tab_foreground = "#6e6a86";
    inactive_tab_background = "#191724";
  };
in
{
  options.zoedsoupe.kitty = {
    enable = mkEnableOption "Enable Kitty";

    theme = mkOption {
      description = "Whioch kitty theme to use";
      default = "omni";
      type = enum [ "omni" "rose-pine" ];
    };
  };

  config = mkIf (cfg.enable) {
    programs.kitty = {
      inherit (cfg) enable;
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
      } // (if cfg.theme == "omni" then omni else rose-pine);
    };
  };
}
