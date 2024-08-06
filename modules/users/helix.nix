{
  pkgs,
  lib,
  config,
  next-ls,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.helix;
  elixir = cfg.languages.elixir;
  rust = cfg.languages.rust;
  go = cfg.languages.go;
  clojure = cfg.languages.clojure;
  nix = cfg.languages.nix;
  html = cfg.languages.html;
  css = cfg.languages.css;
  json = cfg.languages.json;
  zig = cfg.languages.zig;
  nim = cfg.languages.nim;
  typescript = cfg.languages.typescript;
  vscode-lsp = pkgs.nodePackages.vscode-langservers-extracted;

  inherit (pkgs.beam) packagesWith;
  inherit (pkgs.beam.interpreters) erlangR26;
  beam = packagesWith erlangR26;
in {
  options.helix = {
    enable = mkEnableOption "Enbales Helix Editor";
    languages = {
      elixir.enable = mkEnableOption "Enables Elixir Support";
      nim.enable = mkEnableOption "Enables Nim support";
      nix.enable = mkEnableOption "Enables Nix Support";
      rust.enable = mkEnableOption "Enables Rust Support";
      clojure.enable = mkEnableOption "Enables Clojure Support";
      html.enable = mkEnableOption "Enables HTML Support";
      css.enable = mkEnableOption "Enables CSS Support";
      json.enable = mkEnableOption "Enables JSON Support";
      typescript.enable = mkEnableOption "Enables Typescript Support";
      go.enable = mkEnableOption "Enables Go support";
      zig.enable = mkEnableOption "Enables Zig support";
    };
  };

  config = mkIf cfg.enable {
    home.file.${config.xdg.configHome} = {
      enable = true;
      target = "./.config/helix/themes";
      source = ./helix/themes;
      recursive = true;
    };

    programs.helix = {
      inherit (cfg) enable;
      settings = {
        theme = "melange-dark";
        editor = {
          auto-save = true;
          completion-replace = true;
          cursorline = true;
          color-modes = true;
          line-number = "relative";
          statusline.center = ["position-percentage"];
          indent-guides.render = false;
          soft-wrap.enable = true;
          whitespace = {
            render = "none";
            characters = {
              newline = "↴";
              tab = "⇥";
            };
          };
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          lsp = {
            display-messages = true;
            display-inlay-hints = true;
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
          lexical-lsp.command = mkIf (elixir.enable) "${pkgs.lexical}/bin/lexical";
          elixir-ls.command = mkIf elixir.enable "${beam.elixir-ls}/bin/elixir-ls";
          zls.command = mkIf zig.enable "${pkgs.zls}/bin/zls";
          nimlsp.command = mkIf nim.enable "${pkgs.nimlsp}/bin/nimlsp";
          clojure-lsp.command = mkIf clojure.enable "${pkgs.clojure-lsp}/bin/clojure-lsp";
          rust-analyzer.command = mkIf rust.enable "${pkgs.rust-analyzer}/bin/rust-analyzer";
          gopls.command = mkIf go.enable "${pkgs.gopls}/bin/gopls";
          tailwindcss-intellisense = mkIf css.enable {
            command = "${pkgs.tailwindcss-language-server}/bin/tailwindcss-language-server";
            args = ["--stdio"];
          };
          vscode-css-language-server = mkIf css.enable {
            command = "${vscode-lsp}/bin/vscode-css-language-server";
            args = ["--stdio"];
            config = {
              provideFormatter = true;
              css = {validate = {enable = true;};};
            };
          };
          vscode-html-language-server = mkIf html.enable {
            command = "${vscode-lsp}/bin/vscode-html-language-server";
            args = ["--stdio"];
            config = {
              provideFormatter = true;
              html = {validate = {enable = true;};};
            };
          };
          vscode-json-language-server = mkIf json.enable {
            command = "${vscode-lsp}/bin/vscode-json-language-server";
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
          (mkIf css.enable {
            name = "css";
            auto-format = true;
            language-servers = ["tailwindcss-intellisense" "vscode-css-language-server"];
          })
          (mkIf css.enable {
            name = "scss";
            auto-format = true;
            language-servers = ["tailwindcss-intellisense" "vscode-css-language-server"];
          })
          (mkIf nim.enable {
            name = "nim";
            auto-format = true;
            language-servers = ["nimlsp"];
          })
          (mkIf elixir.enable {
            inherit (mix) formatter;
            name = "elixir";
            auto-format = false;
            language-servers = ["nextls" "lexical-lsp"];
            # language-servers = ["elixir-ls"];
          })
          (mkIf elixir.enable {
            inherit (mix) formatter;
            name = "heex";
            auto-format = false;
          })
          (mkIf elixir.enable {
            inherit (mix) formatter;
            name = "eex";
            auto-format = false;
          })
          (mkIf nix.enable {
            inherit (n) formatter;
            name = "nix";
            auto-format = true;
          })
          (mkIf go.enable {
            name = "go";
            auto-format = true;
            language-servers = [
              {
                name = "gopls";
                except-features = ["inlay-hints"];
              }
            ];
          })
          (mkIf typescript.enable {
            inherit (ts) formatter;
            name = "typescript";
            auto-format = true;
            language-servers = [
              {
                name = "typescript-language-server";
                except-features = ["inlay-hints"];
              }
              "vscode-eslint-language-server"
            ];
          })
          (mkIf typescript.enable {
            inherit (ts) formatter;
            name = "javascript";
            auto-format = true;
            language-servers = [
              {
                name = "typescript-language-server";
                except-features = ["inlay-hints"];
              }
              "vscode-eslint-language-server"
            ];
          })
        ];
      };
    };
  };
}
