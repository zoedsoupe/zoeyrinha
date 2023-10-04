{
  pkgs,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.helix;
  erl = pkgs.beam.interpreters.erlang_25.overrideAttrs (old: {
    configureFlags = ["--disable-jit"] ++ old.configureFlags;
  });
  beam = pkgs.beam.packagesWith erl;
  vscode-lsp = pkgs.nodePackages.vscode-langservers-extracted;
in {
  options.helix = {
    enable = mkEnableOption "Enbales Helix Editor";
  };

  config = mkIf cfg.enable {
    home.packages = [beam.elixir-ls pkgs.clojure-lsp pkgs.nil vscode-lsp];
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
    };
  };
}
