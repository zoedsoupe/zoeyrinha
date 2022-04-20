{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.dunst;
in {
  options.zoedsoupe.dunst = {
    enable = mkOption {
      description = "Enable Dunst";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    services.dunst = {
      enable = true;
      iconTheme = {
        name = "arc-icon-theme";
        package = pkgs.arc-icon-theme;
      };
      settings = {
        global = {
          monitor = 0;
          follow = "keyboard";
          geometry = "250x10-30+20";
          indicate_hidden = "yes";
          shrink = "no";
          transparency = 10;
          notification_height = 0;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          frame_width = 3;
          frame_color = "#aaaaaa";
          separator_color = "auto";
          sort = "yes";
          font = "JetBrainsMono 10";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>i\\n%b";
          alignment = "center";
          show_age_threshold = 60;
          word_wrap = "yes";
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";
          icon_position = "left";
          max_icon_size = 32;
          sticky_history = "yes";
          history_length = 20;
          title = "Dunst";
          class = "dunst";
          startup_notification = false;
          verbosity = "mesg";
          corner_radius = 5;
          force_xinerama = false;
          mouse_left_click = "do_action";
          mouse_middle_click = "close_all";
          mouse_right_click = "close_current";
        };
        experimental = { per_monitor_dpi = false; };
        shortcuts = {
          close = "ctrl+space";
          close_all = "ctrl+shift+space";
          history = "ctrl+grave";
          context = "ctrl+shift+period";
        };
        urgency_low = {
          background = "#2b2b2b";
          foreground = "#ffffff";
          timeout = 2;
        };
        urgency_normal = {
          background = "#2b2b2b";
          foreground = "#ffffff";
          timeout = 2;
        };
        urgency_critical = {
          background = "#900000";
          foreground = "#ffffff";
          frame_color = "#ff0000";
          timeout = 3;
        };
      };
    };
  };
}
