{
  pkgs,
  lib,
  custom-config,
  unstable,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
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
  gleam = cfg.languages.gleam;
  typescript = cfg.languages.typescript;
  vscode-lsp = pkgs.nodePackages.vscode-langservers-extracted;

  fetch-theme = {
    path,
    repo,
    owner,
    sha256,
    rev,
  }:
    pkgs.fetchFromGitHub {inherit repo owner sha256 rev;} + path;
in {
  options.helix = {
    enable = mkEnableOption "Enbales Helix Editor";
    editor = {
      disable-line-numbers = mkOption {
        type = types.bool;
        required = false;
        default = true;
      };
    };
    languages = {
      elixir = {
        enable = mkEnableOption "Enables Elixir Support";
        lsp-features = mkOption {
          required = true;
          type = types.listOf types.str;
        };
      };
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
      gleam.enable = mkEnableOption "Enables Gleam support";
    };
  };

  config = mkIf cfg.enable {
    home.file = {
      "darkvoid.toml" = {
        enable = true;
        target = ".config/helix/themes/darkvoid.toml";
        source = fetch-theme {
          path = /darkvoid.toml;
          owner = "zoedsoupe";
          repo = "dark-void-helix";
          rev = "a181a2e";
          sha256 = "zVXtBoTobtsP4VbE+9SpYHTYsvYg8IjIfaLSKwqM1Xs=";
        };
      };
    };

    programs.helix = {
      inherit (cfg) enable;
      settings = {
        theme = "darkvoid";
        editor = {
          auto-save = true;
          completion-replace = true;
          cursorline = true;
          color-modes = true;
          true-color = true;
          indent-guides = {
            render = true;
            skip-levels = 1;
            character = "┊";
          };
          soft-wrap.enable = true;
          # disable line numbers
          gutters = ["diagnostics" "spacer" "diff"];
          statusline = {
            separator = "|";
            left = ["mode" "file-name" "file-modification-indicator"];
            center = [];
            right = ["diagnostics" "version-control" "register" "position"];
          };
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
            enable = true;
            display-messages = false;
            display-inlay-hints = true;
          };
          inline-diagnostics = {
            cursor-line = "warning";
            other-lines = "warning";
          };
          end-of-line-diagnostics = "hint";
        };
        keys.normal = {
          esc = ["collapse_selection" "keep_primary_selection"];
        };
      };

      languages = {
        language-server = {
          gleam = mkIf gleam.enable {
            command = "${unstable.gleam}/bin/gleam";
          };
          nextls = mkIf elixir.enable {
            command = "${unstable.next-ls}/bin/nextls";
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
          lexical-lsp.command = mkIf elixir.enable "${unstable.lexical}/bin/lexical";
          zls.command = mkIf zig.enable "${pkgs.zls}/bin/zls";
          nimlsp.command = mkIf nim.enable "${pkgs.nimlsp}/bin/nimlsp";
          clojure-lsp.command = mkIf clojure.enable "${pkgs.clojure-lsp}/bin/clojure-lsp";
          rust-analyzer.command = mkIf rust.enable "${pkgs.rust-analyzer}/bin/rust-analyzer";
          gopls.command = mkIf go.enable "${pkgs.gopls}/bin/gopls";
          emmet-ls = mkIf html.enable {
            command = "${pkgs.emmet-ls}/bin/emmet-ls";
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
              command = "${unstable.elixir}/bin/mix";
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
            language-servers = ["lexical-lsp"];
            # language-servers = [
            #   {
            #     name = "lexical-lsp";
            #     only-features = elixir.lsp-features;
            #   }
            # ];
          })
          (mkIf elixir.enable {
            inherit (mix) formatter;
            name = "heex";
            auto-format = false;
            language-servers = ["emmet-ls" "tailwindcss-intellisense"];
          })
          (mkIf elixir.enable {
            inherit (mix) formatter;
            name = "eex";
            auto-format = false;
            language-servers = ["emmet-ls"];
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
          (mkIf html.enable {
            name = "html";
            auto-format = true;
            language-servers = ["emmet-ls" "vscode-html-language-server"];
          })
          (mkIf typescript.enable {
            inherit (ts) formatter;
            name = "typescript";
            auto-format = true;
            language-servers = [
              {
                name = "typescript-language-server";
                # except-features = ["inlay-hints"];
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
