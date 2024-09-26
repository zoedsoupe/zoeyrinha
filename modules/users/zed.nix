{
  lib,
  custom-config,
  unstable,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = custom-config.zed;

  settings = {
    theme = "One Dark";
    vim_mode = true;
    autosave = "on_focus_change";
    soft_wrap = "editor_width";
    tab_bar = {show = false;};
    vertical_scroll_margin = 10;
    scrollbar = {show = "never";};
    copilot = {
      disabled_globs = [".env"];
    };
    file_types = {
      CSS = ["scss" "css"];
    };
    vim = {
      use_system_clipboard = "never";
      use_multiline_find = true;
      use_smartcase_find = true;
    };
    buffer_font_size = 17;
    buffer_font_family = "Dank Mono";
    buffer_font_features = {
      ss01 = true;
      ss02 = true;
      ss03 = true;
      ss04 = true;
      ss05 = true;
      ss06 = true;
      ss07 = true;
      ss08 = true;
      calt = true;
      dlig = true;
    };
    preview_tabs = {
      enabled = true;
      enable_preview_from_file_finder = true;
      enable_preview_from_code_navigation = true;
    };
    languages = {
      Elixir = {
        language_servers = ["lexical" "!next-ls" "!elixir-ls"];
      };
      HEEX = {
        language_servers = ["lexical" "!next-ls" "!elixir-ls"];
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
in {
  options.zed = {
    enable = mkEnableOption "Enables zed configurations";
    elixir = {
      lsp = mkOption {
        default = "lexical";
        type = types.enum ["next_ls" "lexical"];
        description = "The LSP to use for Elixir lang";
      };
    };
  };

  config = mkIf cfg.enable {
    # home.packages = with pkgs; [zed-editor];
    home.file = {
      settings = {
        enable = true;
        target = ".config/zed/settings.json";
        text = builtins.toJSON settings;
      };
    };

    home.file = {
      keymap = {
        enable = true;
        target = ".config/zed/keymap.json";
        text = builtins.toJSON (builtins.readFile ./zed/keymap.json);
      };
    };
  };
}
