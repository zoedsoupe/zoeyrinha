{
  pkgs,
  lib,
  custom-config,
  lexical-lsp,
  next-ls,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types mkDefault;
  cfg = custom-config.zed;
  elixir = cfg.elixir;

  inherit (pkgs.beam.interpreters) erlangR26;
  inherit (pkgs.beam.interpreters.erlang_26) elixir_1_16;

  inherit (lexical-lsp.lib) mkLexical;
  erlang = elixir.erlang.extend (_: _: {elixir = elixir.package;});
  lexical = mkLexical {inherit erlang;};

  next = next-ls.packages."${pkgs.system}".default;

  config_dir = ".config/zed/settings.json";

  settings = {
    theme = "One Dark";
    vim_mode = true;
    autosave = "on_focus_change";
    soft_wrap = "editor_width";
    tab_bar = {show = false;};
    copilot = {
      disabled_globs = [".env"];
    };
    file_types = {
      CSS = ["scss" "css"];
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
        language_servers = ["lexical" "next-ls" "!elixir-ls"];
      };
      format_on_save = {
        external = {
          command = "${elixir.package}/bin/mix";
          arguments = ["format" "--stdin-filename" "{buffer_path}" "-"];
        };
      };
    };
    lsp = {
      lexical = {
        path = "${lexical}/bin/lexical";
        arguments = [];
      };
      next-ls = {
        path = "${next}/bin/nextls";
        arguments = ["--stdio"];
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
      erlang = mkOption {
        default = mkDefault erlangR26;
        type = types.package;
        description = "The Erlang pkg used to build both next-ls and lexical-lsp";
      };
      package = mkOption {
        default = mkDefault elixir_1_16;
        type = types.package;
        description = "The Elixir pkg used to build both next-ls and lexical-lsp";
      };
    };
  };

  config = mkIf cfg.enable {
    # home.packages = with pkgs; [zed-editor];
    home.file = {
      settings = {
        enable = true;
        target = config_dir;
        text = builtins.toJSON settings;
      };
    };
  };
}
