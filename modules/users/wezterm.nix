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
    home.file = {
      "wezterm.luz" = {
        inherit (cfg) enable;
        target = ".config/wezterm/wezterm.lua";
        text = ''
          local wezterm = require("wezterm");

          local config = wezterm.config_builder()

          local feats = {
            "ss01",
            "ss04",
            "ss07",
            "ss08",
            "ss10",
            "ss11",
            "ss13",
            "ss14",
            "ss15",
            "ss16",
            "ss17",
            "ss18",
          }

          config = {
            font = wezterm.font("MonoLisa"),
            automatically_reload_config = true,
            exit_behavior = "Close",
            window_close_confirmation = "NeverPrompt",
            font_size = 17,
            color_scheme = "OneDark (base16)",
            hide_tab_bar_if_only_one_tab = false,
            harfbuzz_features = feats,
            window_decorations = "INTEGRATED_BUTTONS|RESIZE",
            window_background_opacity = 0.8,
            macos_window_background_blur = 10,
            default_cursor_style = "SteadyBar",
            native_macos_fullscreen_mode = true,
            pane_focus_follows_mouse = true,
            mouse_bindings = {
              -- Open URLs with CMD+Click
              {
                event = { Up = { streak = 1, button = 'Left' } },
                mods = 'CMD',
                action = wezterm.action.OpenLinkAtMouseCursor,
              }
            },
            keys = {
              -- Show tab navigator
              {
                key = 'p',
                mods = 'CMD',
                action = wezterm.action.ShowTabNavigator
              },
              -- Show launcher menu
              {
                key = 'P',
                mods = 'CMD|SHIFT',
                action = wezterm.action.ShowLauncher
              },
              -- Rename current tab
              {
                key = 'E',
                mods = 'CMD|SHIFT',
                action = wezterm.action.PromptInputLine {
                  description = 'Enter new name for tab',
                  action = wezterm.action_callback(
                    function(window, _, line)
                      if line then
                        window:active_tab():set_title(line)
                      end
                    end
                  ),
                },
              },
            }
          }

          return config
        '';
      };
    };
  };
}
