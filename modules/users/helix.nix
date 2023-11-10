{
  pkgs,
  lib,
  next-ls,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = custom-config.helix;
  elixir = cfg.languages.elixir;
  rust = cfg.languages.rust;
  clojure = cfg.languages.clojure;
  nix = cfg.languages.nix;
  html = cfg.languages.html;
  css = cfg.languages.css;
  json = cfg.languages.json;
  typescript = cfg.languages.typescript;
  lexical-lsp = elixir.erlang.callPackage ../../custom/lexical-lsp.nix {};
  vscode-lsp = pkgs.nodePackages.vscode-langservers-extracted;
in {
  options.helix = {
    enable = mkEnableOption "Enbales Helix Editor";
    languages = {
      elixir = {
        enable = mkEnableOption "Enables Elixir Support";
        erlang = mkOption {
          default = pkgs.beam.packages.erlangR26;
          optional = true;
          type = types.package;
          description = "The Erlang pkg used to build both next-ls and lexical-lsp";
        };
      };
      nix.enable = mkEnableOption "Enables Nix Support";
      rust.enable = mkEnableOption "Enables Rust Support";
      clojure.enable = mkEnableOption "Enables Clojure Support";
      html.enable = mkEnableOption "Enables HTML Support";
      css.enable = mkEnableOption "Enables CSS Support";
      json.enable = mkEnableOption "Enables JSON Support";
      typescript.enable = mkEnableOption "Enables Typescript Support";
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      inherit (cfg) enable;
      settings = {
        theme = "onedark";
        editor = {
          cursorline = true;
          color-modes = true;
          line-number = "relative";
          lsp.display-messages = true;
          true-color = true;
          statusline.center = ["position-percentage"];
          whitespace.characters = {
            newline = "↴";
            tab = "⇥";
          };
          indent-guides = {
            render = true;
            rainbow-option = "dim";
          };
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
          typescript-language-server = let
            ts-server = pkgs.nodePackages.typescript-language-server;
          in
            mkIf typescript.enable {
              command = "${ts-server}/bin/typescript-language-server";
              args = ["--stdio"];
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
              command = "${pkgs.elixir}/bin/mix";
              args = ["format" "-"];
            };
          };

          n = {
            formatter = {
              command = "${pkgs.alejandra}/bin/alejandra";
            };
          };

          ts = {
            formatter = {
              command = "${pkgs.nodePackages.prettier}/bin/prettier";
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
            inherit (n) formatter;
            name = "nix";
            auto-format = true;
          })
          (mkIf typescript.enable {
            inherit (ts) formatter;
            name = "typescript";
            auto-format = true;
          })
        ];
      };
    };
  };
}
