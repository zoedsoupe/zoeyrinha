{
  pkgs,
  lib,
  custom-config,
  unstable,
  next-ls,
  wakatime-ls,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  inherit (pkgs.nodePackages) prettier vscode-langservers-extracted typescript-language-server;
  vscode-lsp = vscode-langservers-extracted;
  ts-server = typescript-language-server;

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
  ocaml = cfg.languages.ocaml;
  typescript = cfg.languages.typescript;
  lua = cfg.languages.lua;
  python = cfg.languages.python;

  ocamlpkgs = pkgs.ocamlPackages;
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
      python.enabe = mkEnableOption "Enables Python Support";
      lua.enable = mkEnableOption "Enables Lua support";
      ocaml.enable = mkEnableOption "Enables OCaml support";
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
    programs.helix = {
      inherit (cfg) enable;
      settings = {
        theme = "nyxvamp-veil";
        editor = {
          auto-save = true;
          completion-replace = true;
          cursorline = true;
          color-modes = true;
          true-color = true;
          indent-guides = {
            render = false;
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
            command = "${next-ls}/bin/nextls";
            args = ["--stdio=true"];
            config = {
              extensions = {credo.enable = false;};
              experimental = {completions.enable = false;};
            };
          };
          typescript-language-server = mkIf typescript.enable {
            command = "${ts-server}/bin/typescript-language-server";
            args = ["--stdio"];
          };
          lua-language-server.command = mkIf lua.enable "${pkgs.lua-language-server}/bin/lua-language-server";
          ocamllsp.command = mkIf ocaml.enable "${ocamlpkgs.ocaml-lsp}/bin/ocamllsp";
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
              css = {
                validate = {enable = true;};
                lint = {unknownAtRules = "ignore";};
              };
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
          wakatime-lsp.command = "${wakatime-ls}/bin/wakatime-lsp";
          marksman.command = "${pkgs.marksman}/bin/marksman";
          ruff = mkIf python.enable {
            command = "${pkgs.ruff}/bin/ruff";
            args = ["server"];
          };
          tailwindcss-intellisense.command = "${pkgs.tailwindcss-language-server}/bin/tailwindcss-language-server";
        };

        language = let
          n = {
            formatter = {
              command = "${pkgs.alejandra}/bin/alejandra";
            };
          };

          ts = {
            formatter = mkIf typescript.enable {
              command = "${prettier}/bin/prettier";
            };
          };

          next = {
            name = "nextls";
            except-features = ["completion" "format"];
          };
        in [
          (mkIf ocaml.enable {
            name = "ocaml";
            auto-format = true;
            formatter = {
              command = "${ocamlpkgs.ocamlformat}/bin/ocamlformat";
            };
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
          {
            name = "markdown";
            language-servers = ["marksman" "wakatime-lsp"];
          }
          (mkIf elixir.enable {
            name = "elixir";
            auto-format = false;
            language-servers = [
              next
              "wakatime-lsp"
            ];
          })
          (mkIf elixir.enable {
            name = "heex";
            auto-format = false;
            language-servers = [next "emmet-ls" "tailwindcss-intellisense" "wakatime-lsp"];
          })
          (mkIf elixir.enable {
            name = "eex";
            auto-format = false;
            language-servers = [next "emmet-ls" "wakatime-lsp"];
          })
          (mkIf nix.enable {
            inherit (n) formatter;
            name = "nix";
            auto-format = true;
            language-servers = ["nil" "wakatime-lsp"];
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
          (mkIf python.enable {
            name = "python";
            auto-format = true;
            language-servers = [
              {
                name = "ruff";
                except-features = ["completion"];
              }
            ];
          })
        ];
      };
    };
  };
}
