{
  pkgs,
  lib,
  next-ls,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.helix;
  elixir = cfg.languages.elixir;
  rust = cfg.languages.rust;
  clojure = cfg.languages.clojure;
  nix = cfg.languages.nix;
  html = cfg.languages.html;
  css = cfg.languages.css;
  json = cfg.languages.json;
  lexical-lsp = pkgs.beam.packages.erlangR26.callPackage ../../custom/lexical-lsp.nix {};
  vscode-lsp = pkgs.nodePackages.vscode-langservers-extracted;
in {
  options.helix = {
    enable = mkEnableOption "Enbales Helix Editor";
    languages = {
      elixir.enable = mkEnableOption "Enables Elixir Support";
      nix.enable = mkEnableOption "Enables Nix Support";
      rust.enable = mkEnableOption "Enables Rust Support";
      clojure.enable = mkEnableOption "Enables Clojure Support";
      html.enable = mkEnableOption "Enables HTML Support";
      css.enable = mkEnableOption "Enables CSS Support";
      json.enable = mkEnableOption "Enables JSON Support";
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      inherit (cfg) enable;
      settings = {
        theme = "catppuccin_frappe";
        editor = {
          cursorline = true;
          color-modes = true;
          line-number = "relative";
          lsp.display-messages = true;
          indent-guides.render = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
        };
        keys.normal = {
          esc = ["collapse_selection" "keep_primary_selection"];
        };
      };

      languages = {
        language-server = {
          nextls = mkIf elixir.enable {
            command = "${next-ls.packages."${pkgs.system}".default}/bin/nextls";
            args = ["--stdio=true"];
          };
          nil.command = mkIf nix.enable "${pkgs.nil}/bin/nil";
          lexical-lsp.command = mkIf elixir.enable "${lexical-lsp}/bin/lexical";
          # elixir-ls.command = mkIf elixir.enable "${beam.elixir-ls}/bin/elixir-ls";
          clojure-lsp.command = mkIf clojure.enable "${pkgs.clojure-lsp}/bin/clojure-lsp";
          rust-analyzer.command = mkIf rust.enable "${pkgs.rust-analyzer}bin/rust-analyzer";
          vscode-css-language-server = mkIf css.enable {
            command = "${vscode-lsp}/bin/vscode-css-language-server";
            args = ["--stdio"];
            config = {
              provideFormatter = true;
              css = {validate = {enable = true;};};
            };
          };
          vscode-html-language-server = mkIf html.enable {
            command = "${vscode-lsp}/bin/vscode-css-language-server";
            args = ["--stdio"];
            config = {
              provideFormatter = true;
              html = {validate = {enable = true;};};
            };
          };
          vscode-json-language-server = mkIf json.enable {
            command = "${vscode-lsp}/bin/vscode-css-language-server";
            args = ["--stdio"];
            config = {
              provideFormatter = true;
              json = {validate = {enable = true;};};
            };
          };
        };

        language = let
          mix = {
            formatter = {
              command = "mix";
              args = ["format" "-"];
            };
          };
        in [
          (mkIf elixir.enable {
            inherit (mix) formatter;
            name = "elixir";
            auto-format = true;
            language-servers = ["lexical-lsp" "nextls"];
          })
          (mkIf elixir.enable {
            inherit (mix) formatter;
            name = "heex";
            auto-format = true;
          })
          (mkIf elixir.enable {
            inherit (mix) formatter;
            name = "eex";
            auto-format = true;
          })
          (mkIf nix.enable {
            name = "nix";
            auto-format = true;
            formatter = {command = "${pkgs.alejandra}/bin/alejandra";};
          })
        ];
      };
    };
  };
}
