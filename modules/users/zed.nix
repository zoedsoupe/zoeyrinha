{
  pkgs,
  lib,
  custom-config,
  unstable,
  wakatime-ls,
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
      description = "The theme name to use";
      default = "NyxVamp Veil";
    };
    font = mkOption {
      type = types.str;
      description = "The font to use on buffer and UI";
      default = "MonoLisa";
    };
    elixir = {
      lsp = {
        enabled = mkEnableOption "Enables LSP support for Elixir";
        name = mkOption {
          default = "lexical";
          type = types.enum ["next-ls" "lexical"];
          description = "The LSP to use for Elixir lang";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.sessionPath = let
      elixir-lsp-path =
        if elixir.lsp.name == "lexical"
        then "${unstable.lexical}/bin"
        else "${unstable.next-ls}/bin";
      elixir-lsp =
        if elixir.lsp.enabled
        then [elixir-lsp-path]
        else [];
    in
      ["${wakatime-ls}/bin/wakatime-ls"] ++ elixir-lsp;
    programs.zed-editor = {
      inherit (cfg) enable;
      package = pkgs.emptyDirectory;
      extensions = ["elixir" "html" "nix" "nyxvamp-theme" "wakatime"];
      userSettings = {
        tab_size = 2;
        load_direnv = "shell_hook";
        assistant.enabled = false;
        theme = {
          mode = "system";
          light = "One Light";
          dark = cfg.theme;
        };
        vim_mode = true;
        autosave = "on_focus_change";
        auto_update = true;
        cursor_blink = false;
        soft_wrap = "editor_width";
        tab_bar.show = false;
        vertical_scroll_margin = 10;
        scrollbar.show = "never";
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
          toggle_relative_line_numbers = true;
          default_mode = "helix_normal";
        };
        buffer_font_size = 18;
        buffer_font_family = cfg.font;
        buffer_font_features = true;
        ui_font_family = cfg.font;
        ui_font_features = true;
        preview_tabs = {
          enabled = true;
          enable_preview_from_file_finder = true;
          enable_preview_from_code_navigation = true;
        };
        languages = let
          elixir-lsp =
            if elixir.lsp.enabled
            then elixir.lsp.name
            else "!${elixir.lsp.name}";
        in {
          Elixir = {
            enable_language_server = elixir.lsp.enabled;
            language_servers = [
              elixir-lsp
              "!elixir-ls"
              "wakatime"
            ];
          };
          HEEX = {
            enable_language_server = elixir.lsp.enabled;
            language_servers = [
              elixir-lsp
              "!elixir-ls"
              "wakatime"
            ];
          };
          EEX = {
            enable_language_server = elixir.lsp.enabled;
            language_servers = [
              elixir-lsp
              "!elixir-ls"
              "wakatime"
            ];
          };
        };
        lsp = {
          next-ls = {
            initialization_options = {
              extensions = {
                credo.enable = true;
              };
              experimental = {
                completions.enable = false;
              };
            };
          };
        };
      };
    };
  };
}
