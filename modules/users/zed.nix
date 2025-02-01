{
  pkgs,
  lib,
  custom-config,
  unstable,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = custom-config.zed;
  elixir = cfg.elixir;
in {
  options.zed = {
    enable = mkEnableOption "Enables zed configurations";
    theme = mkOption {
      type = types.str;
      description = "The theme name to use, null for the default one (zed-one-dark)";
      default = null;
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
    programs.zed-editor = {
      inherit (cfg) enable;
      package = pkgs.emptyDirectory;
      extensions = ["HTML" "Elixir" "nyxvamp" "Nix"];
      userKeymaps = builtins.fromJSON (builtins.readFile ./zed/keymap.json);
      userSettings = {
        tab_size = 2;
        load_direnv = "shell_hook";
        assistant.enabled = true;
        theme = cfg.theme;
        vim_mode = true;
        autosave = "on_focus_change";
        auto_update = true;
        cursor_blink = false;
        soft_wrap = "editor_width";
        tab_bar = {
          show = false;
        };
        vertical_scroll_margin = 10;
        scrollbar = {
          show = "never";
        };
        copilot = {
          enabled = true;
          disabled_globs = [".env"];
        };
        file_types = {
          CSS = ["scss" "css"];
        };
        git.inline_blame = true;
        vim = {
          use_system_clipboard = "never";
          use_multiline_find = true;
          use_smartcase_find = true;
        };
        buffer_font_size = 17;
        buffer_font_family = cfg.font;
        buffer_font_features = true;
        ui_font_family = cfg.font;
        ui_font_features = true;
        preview_tabs = {
          enabled = true;
          enable_preview_from_file_finder = true;
          enable_preview_from_code_navigation = true;
        };
        languages = {
          Elixir = {
            language_servers = [
              (
                if elixir.lsp == "lexical"
                then elixir.lsp
                else "!lexical"
              )
              (
                if elixir.lsp == "next-ls"
                then elixir.lsp
                else "!next-ls"
              )
              "!elixir-ls"
            ];
          };
          HEEX = {
            language_servers = [
              (
                if elixir.lsp == "lexical"
                then elixir.lsp
                else "!lexical"
              )
              (
                if elixir.lsp == "next-ls"
                then elixir.lsp
                else "!next-ls"
              )
              "!elixir-ls"
            ];
          };
        };
        lsp = {
          lexical = {
            binary = {
              path = "${unstable.lexical}/bin/lexical";
            };
          };
          next-ls = {
            binary = {
              path = "${unstable.next-ls}/bin/nextls";
              arguments = ["--stdio"];
            };
            initialization_options = {
              extensions = {
                credo.enable = false;
              };
              experimental = {
                completions.enable = true;
              };
            };
          };
        };
      };
    };
  };
}
