{
  pkgs,
  lib,
  custom-config,
  unstable,
  wakatime-ls,
  helix-themes,
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
    enable = mkEnableOption "Enables Helix Editor";
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
        lsp.enable = mkEnableOption "Enables Elixir LSP support";
        lsp.name = mkOption {
          required = false;
          default = "lexical-lsp";
          type = types.str;
        };
        lsp.except-features = mkOption {
          required = false;
          type = types.listOf types.str;
          default = ["completion" "format"];
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
    home.file = {
      helix-themes = {
        enable = true;
        target = ".config/helix/themes";
        source = pkgs.runCommand "helix-themes-filtered" {} ''
          mkdir -p $out
          find ${helix-themes} -name "*.toml" -exec cp {} $out/ \;
        '';
        recursive = true;
      };
    };

    programs.helix = {
      inherit (cfg) enable;
      settings = {
        theme = "nyxvamp-transparent";
        editor = {
          scrolloff = 99;
          rainbow-brackets = true;
          auto-save.focus-lost = true;
          completion-replace = true;
          cursorline = true;
          color-modes = true;
          true-color = true;
          indent-guides = {
            render = false;
            skip-levels = 1;
            character = "┊";
          };
          soft-wrap = {
            enable = true;
            wrap-at-text-width = true;
          };
          continue-comments = false;
          preview-completion-insert = true;
          line-number = "relative";
          # disable line numbers
          gutters = ["diagnostics" "spacer" "diff"];
          statusline = {
            separator = "|";
            left = ["mode" "file-name" "file-modification-indicator"];
            center = [];
            right = ["diagnostics" "version-control" "register" "position"];
          };
          whitespace.render = "none";
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
          typescript-language-server = mkIf typescript.enable {
            command = "${ts-server}/bin/typescript-language-server";
            args = ["--stdio"];
          };
          next-ls = mkIf elixir.enable {
            command = "${pkgs.next-ls}/bin/nextls";
          };
          lua-language-server = mkIf lua.enable {
            command = "${pkgs.lua-language-server}/bin/lua-language-server";
          };
          ocamllsp = mkIf ocaml.enable {
            command = "${ocamlpkgs.ocaml-lsp}/bin/ocamllsp";
          };
          nil = mkIf nix.enable {
            command = "${pkgs.nil}/bin/nil";
          };
          zls = mkIf zig.enable {
            command = "${pkgs.zls}/bin/zls";
          };
          nimlsp = mkIf nim.enable {
            command = "${pkgs.nimlsp}/bin/nimlsp";
          };
          clojure-lsp = mkIf clojure.enable {
            command = "${pkgs.clojure-lsp}/bin/clojure-lsp";
          };
          rust-analyzer = mkIf rust.enable {
            command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          };
          gopls = mkIf go.enable {
            command = "${pkgs.gopls}/bin/gopls";
          };
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
          wakatime-ls = {
            command = "${wakatime-ls}/bin/wakatime-ls";
          };
          marksman.command = "${pkgs.marksman}/bin/marksman";
          ruff = mkIf python.enable {
            command = "${pkgs.ruff}/bin/ruff";
            args = ["server"];
          };
          tailwindcss-intellisense = mkIf css.enable {
            command = "${pkgs.tailwindcss-language-server}/bin/tailwindcss-language-server";
          };
          vscode-eslint-language-server = mkIf typescript.enable {
            command = "${vscode-lsp}/bin/vscode-eslint-language-server";
            args = ["--stdio"];
          };
          uwu-colors = {
            command = "${pkgs.uwu-colors}/bin/uwu_colors";
            args = ["--named-completions-mode" "full" "--color-collection" "colorhexa" "--variable-completions"];
          };
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

          ex = {
            formatter = mkIf elixir.enable {
              command = "mix";
              args = [
                "format"

                "--stdin-filename"
                "%{buffer_name}"
              ];
            };
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
            language-servers = ["marksman" "wakatime-ls" "uwu-colors"];
          }
          (mkIf elixir.enable {
            inherit (ex) formatter;
            name = "elixir";
            auto-format = false;
            language-servers = [
              "wakatime-ls"
              {
                name = "next-ls";
                except-features = ["completion"];
              }
            ];
          })
          (mkIf elixir.enable {
            inherit (ex) formatter;
            name = "heex";
            auto-format = false;
            language-servers = [
              "emmet-ls"
              "tailwindcss-intellisense"
              "wakatime-ls"
              "uwu-colors"
              {
                name = "next-ls";
                except-features = ["completion"];
              }
            ];
          })
          (mkIf elixir.enable {
            inherit (ex) formatter;
            name = "eex";
            auto-format = false;
            language-servers = [
              "emmet-ls"
              "wakatime-ls"
              "uwu-colors"
            ];
          })
          (mkIf nix.enable {
            inherit (n) formatter;
            name = "nix";
            auto-format = true;
            language-servers = ["nil" "wakatime-ls" "uwu-colors"];
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
            language-servers = ["emmet-ls" "vscode-html-language-server" "uwu-colors"];
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
              "uwu-colors"
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
              "uwu-colors"
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
          {
            name = "json";
            language-servers = ["vscode-json-language-server" "uwu-colors"];
          }
          {
            name = "toml";
            language-servers = ["uwu-colors"];
          }
        ];
      };
    };
  };
}
