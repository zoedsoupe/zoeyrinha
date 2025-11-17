{
  pkgs,
  lib,
  custom-config,
  wakatime-ls,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = custom-config.zed;
in {
  options.zed = {
    enable = mkEnableOption "Enables zed configurations";
    theme = {
      dark = mkOption {
        type = types.nullOr types.str;
        description = "The dark theme name to use";
        default = null;
      };
      light = mkOption {
        type = types.nullOr types.str;
        description = "The light theme name to use";
        default = null;
      };
    };
    font = mkOption {
      type = types.str;
      description = "The font to use on buffer and UI";
      default = "MonoLisa";
    };
    elixir = {
      lsp = mkOption {
        default = "lexical";
        type = types.enum ["next-ls" "lexical"];
        description = "The LSP to use for Elixir lang";
      };
    };
  };

  config = mkIf cfg.enable {
    home.sessionPath = ["${wakatime-ls}/bin/wakatime-lsp"];
    programs.zed-editor = {
      inherit (cfg) enable;
      package = pkgs.emptyDirectory;
      extensions = ["elixir" "html" "nix" "nyxvamp-theme" "wakatime" "catppuccin-icons"];
      userSettings = {
        tab_size = 2;
        load_direnv = "shell_hook";
        agent = {
          enabled = true;
          dock = "right";
          default_model = {
            provider = "zed.dev";
            model = "claude-opus-4";
          };
        };
        theme = {
          mode = "system";
          light = cfg.theme.light;
          dark = cfg.theme.dark;
        };
        icon_theme = {
          mode = "system";
          light = "Catppuccin Latte";
          dark = "Catppuccin Macchiato";
        };
        vim_mode = true;
        autosave = "on_focus_change";
        auto_update = true;
        cursor_blink = false;
        soft_wrap = "editor_width";
        tab_bar.show = false;
        vertical_scroll_margin = 10;
        scrollbar.show = "never";
        file_types = {
          CSS = ["scss" "css"];
        };
        git.inline_blame = {
          enabled = true;
        };
        vim = {
          # default_mode = "helix_normal";
          scrollbar.show = "never";
          use_system_clipboard = "on_yank";
          use_smartcase_find = true;
          toggle_relative_line_numbers = true;
          vertical_scroll_margin = 99;
        };
        buffer_font_size = 17;
        buffer_font_family = cfg.font;
        buffer_font_features = null;
        ui_font_family = cfg.font;
        ui_font_features = null;
        preview_tabs = {
          enabled = true;
          enable_preview_from_file_finder = true;
          enable_preview_from_code_navigation = true;
        };
        languages = {
          Elixir = {
            language_servers = [
              "expert"
              "!lexical"
              "!next-ls"
              "!elixir-ls"
              "wakatime"
            ];
          };
          HEEX = {
            language_servers = [
              "expert"
              "!lexical"
              "!next-ls"
              "!elixir-ls"
              "wakatime"
            ];
          };
          EEX = {
            language_servers = [
              "!lexical"
              "!next-ls"
              "!elixir-ls"
              "wakatime"
            ];
          };
        };
      };
    };
  };
}
