{
  pkgs,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = custom-config.helix;
in {
  options.helix = {
    enable = mkEnableOption "Enbales Helix Editor";
  };

  config = mkIf cfg.enable {
    programs.helix = {
      inherit (cfg) enable;
      settings = {
        theme = "catppuccin_latte";
        editor = {
          line-number = "relative";
          lsp.display-messages = true;
        };
        keys.normal = {
          esc = ["collapse_selection" "keep_primary_selection"];
        };
      };
      languages = {
        language-server = let
          erl = pkgs.beam.interpreters.erlang_25.overrideAttrs (old: {
            configureFlags = ["--disable-jit"] ++ old.configureFlags;
          });
          beam = pkgs.beam.packagesWith erl;
          vscode-lsp = pkgs.nodePackages.vscode-langservers-extracted;
        in {
          elixir-ls.command = "${beam.elixir-ls}/bin/elixir-ls";
          nil.command = "${pkgs.nil}/bin/nil";
          clojure-lsp.command = "${pkgs.clojure-lsp}/bin/clojure-lsp";

          vscode-html-language-server = {
            command = "${vscode-lsp}/bin/vscode-html-language-server";
            args = ["--stdio"];
          };
          vscode-css-language-server = {
            command = "${vscode-lsp}/bin/vscode-css-language-server";
            args = ["--stdio"];
          };
          vscode-json-language-server = {
            command = "${vscode-lsp}/bin/vscode-json-language-server";
            args = ["--stdio"];
          };
        };
      };
    };
  };
}
