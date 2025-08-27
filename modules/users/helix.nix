{
  pkgs,
  lib,
  custom-config,
  unstable,
  wakatime-ls,
  helix-themes,
  lexical-lsp,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  inherit (pkgs.nodePackages) prettier vscode-langservers-extracted typescript-language-server;
  vscode-lsp = vscode-langservers-extracted;
  ts-server = typescript-language-server;

  cfg = custom-config.helix;
  ocamlpkgs = pkgs.ocamlPackages;

  language-configs = {
    elixir = {
      nix-option-name = "elixir";
      helix-names = ["elixir" "heex" "eex"];
      default-language-servers = ["next-ls"];
      formatter = {
        command = "mix";
        args = ["format" "--stdin-filename" "%{buffer_name}"];
      };
      auto-format = false;
      extra-servers = {
        heex = ["emmet-ls" "tailwindcss-intellisense" "uwu-colors"];
        eex = ["emmet-ls" "uwu-colors"];
      };
      lsp-config = {
        enable = mkEnableOption "Enables Elixir LSP support";
        name = mkOption {
          required = false;
          default = "lexical-lsp";
          type = types.str;
        };
        except-features = mkOption {
          required = false;
          type = types.listOf types.str;
          default = ["completion" "format"];
        };
      };
    };

    nix = {
      nix-option-name = "nix";
      helix-names = ["nix"];
      default-language-servers = ["nil"];
      formatter = {command = "${pkgs.alejandra}/bin/alejandra";};
      extra-servers.nix = ["uwu-colors"];
    };

    typescript = {
      nix-option-name = "typescript";
      helix-names = ["typescript" "javascript"];
      default-language-servers = ["typescript-language-server"];
      formatter = {command = "${prettier}/bin/prettier";};
      extra-servers = {
        typescript = ["vscode-eslint-language-server" "uwu-colors"];
        javascript = ["vscode-eslint-language-server" "uwu-colors"];
      };
    };

    python = {
      nix-option-name = "python";
      helix-names = ["python"];
      default-language-servers = ["ruff"];
    };

    rust = {
      nix-option-name = "rust";
      helix-names = ["rust"];
      default-language-servers = ["rust-analyzer"];
    };

    go = {
      nix-option-name = "go";
      helix-names = ["go"];
      default-language-servers = ["gopls"];
    };

    html = {
      nix-option-name = "html";
      helix-names = ["html"];
      default-language-servers = ["emmet-ls" "vscode-html-language-server"];
      extra-servers.html = ["uwu-colors"];
    };

    css = {
      nix-option-name = "css";
      helix-names = ["css" "scss"];
      default-language-servers = ["vscode-css-language-server"];
      extra-servers = {
        scss = ["tailwindcss-intellisense"];
      };
    };

    json = {
      nix-option-name = "json";
      helix-names = ["json"];
      default-language-servers = ["vscode-json-language-server"];
      extra-servers.json = ["uwu-colors"];
    };

    # Special languages without Nix options but used in Helix
    markdown = {
      helix-names = ["markdown"];
      default-language-servers = ["marksman"];
      extra-servers.markdown = ["uwu-colors"];
    };

    toml = {
      nix-option-name = "toml";
      helix-names = ["toml"];
      default-language-servers = [];
      extra-servers.toml = ["uwu-colors"];
    };

    # Other languages with minimal config
    ocaml = {
      nix-option-name = "ocaml";
      helix-names = ["ocaml"];
      default-language-servers = ["ocamllsp"];
      formatter = {command = "${ocamlpkgs.ocamlformat}/bin/ocamlformat";};
    };

    nim = {
      nix-option-name = "nim";
      helix-names = ["nim"];
      default-language-servers = ["nimlsp"];
    };

    zig = {
      nix-option-name = "zig";
      helix-names = ["zig"];
      default-language-servers = ["zls"];
    };

    gleam = {
      nix-option-name = "gleam";
      helix-names = ["gleam"];
      default-language-servers = ["gleam"];
    };

    lua = {
      nix-option-name = "lua";
      helix-names = ["lua"];
      default-language-servers = ["lua-language-server"];
    };

    clojure = {
      nix-option-name = "clojure";
      helix-names = ["clojure"];
      default-language-servers = ["clojure-lsp"];
    };
  };

  languages-with-nix-options = lib.filterAttrs (_: lang: lang ? nix-option-name) language-configs;

  get-lang-config = name: cfg.languages.${name} or {};

  with-wakatime = lang-name: servers: let
    lang-cfg = get-lang-config lang-name;
  in
    if (lang-cfg.wakatime or {}).enable or false
    then servers ++ ["wakatime-ls"]
    else servers;

  any-wakatime-enabled = lib.any (
    name: let
      lang-cfg = get-lang-config name;
    in
      (lang-cfg.wakatime or {}).enable or false
  ) (lib.attrNames languages-with-nix-options);

  mk-helix-lang = lang-config: helix-name: let
    nix-name = lang-config.nix-option-name or null;
    lang-cfg =
      if nix-name != null
      then get-lang-config nix-name
      else {};
    enabled =
      if nix-name != null
      then lang-cfg.enable or false
      else true;

    base-servers = lang-config.default-language-servers or [];
    extra-servers = lang-config.extra-servers.${helix-name} or [];
    all-servers = base-servers ++ extra-servers;
    final-servers =
      if nix-name != null
      then with-wakatime nix-name all-servers
      else
        all-servers
        ++ (
          if any-wakatime-enabled
          then ["wakatime-ls"]
          else []
        );
  in
    mkIf enabled {
      name = helix-name;
      auto-format = lang-config.auto-format or true;
      language-servers = final-servers;
    }
    // (lib.optionalAttrs (lang-config ? formatter) {formatter = lang-config.formatter;});
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
    languages = lib.mapAttrs (name: lang-config:
      {
        enable = mkEnableOption "Enables ${name} Support";
        wakatime.enable = mkEnableOption "Enables WakaTime tracking for ${name}";
      }
      // (
        if lang-config ? lsp-config
        then {lsp = lang-config.lsp-config;}
        else {}
      ))
    languages-with-nix-options;
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
        theme = "nyxvamp-veil";
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
          gleam = mkIf (get-lang-config "gleam").enable {
            command = "${unstable.gleam}/bin/gleam";
          };
          typescript-language-server = mkIf (get-lang-config "typescript").enable {
            command = "${ts-server}/bin/typescript-language-server";
            args = ["--stdio"];
          };
          next-ls = mkIf (get-lang-config "elixir").enable {
            command = "${pkgs.next-ls}/bin/nextls";
          };
          lua-language-server = mkIf (get-lang-config "lua").enable {
            command = "${pkgs.lua-language-server}/bin/lua-language-server";
          };
          ocamllsp = mkIf (get-lang-config "ocaml").enable {
            command = "${ocamlpkgs.ocaml-lsp}/bin/ocamllsp";
          };
          nil = mkIf (get-lang-config "nix").enable {
            command = "${pkgs.nil}/bin/nil";
          };
          zls = mkIf (get-lang-config "zig").enable {
            command = "${pkgs.zls}/bin/zls";
          };
          nimlsp = mkIf (get-lang-config "nim").enable {
            command = "${pkgs.nimlsp}/bin/nimlsp";
          };
          clojure-lsp = mkIf (get-lang-config "clojure").enable {
            command = "${pkgs.clojure-lsp}/bin/clojure-lsp";
          };
          rust-analyzer = mkIf (get-lang-config "rust").enable {
            command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          };
          gopls = mkIf (get-lang-config "go").enable {
            command = "${pkgs.gopls}/bin/gopls";
          };
          emmet-ls = mkIf (get-lang-config "html").enable {
            command = "${pkgs.emmet-ls}/bin/emmet-ls";
            args = ["--stdio"];
          };
          vscode-css-language-server = mkIf (get-lang-config "css").enable {
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
          vscode-html-language-server = mkIf (get-lang-config "html").enable {
            command = "${vscode-lsp}/bin/vscode-html-language-server";
            args = ["--stdio"];
            config = {
              provideFormatter = true;
              html = {validate = {enable = true;};};
            };
          };
          vscode-json-language-server = mkIf (get-lang-config "json").enable {
            command = "${vscode-lsp}/bin/vscode-json-language-server";
            args = ["--stdio"];
            config = {
              provideFormatter = true;
              json = {validate = {enable = true;};};
            };
          };
          wakatime-ls = mkIf any-wakatime-enabled {
            command = "${wakatime-ls}/bin/wakatime-ls";
          };
          marksman.command = "${pkgs.marksman}/bin/marksman";
          ruff = mkIf (get-lang-config "python").enable {
            command = "${pkgs.ruff}/bin/ruff";
            args = ["server"];
          };
          tailwindcss-intellisense = mkIf (get-lang-config "css").enable {
            command = "${pkgs.tailwindcss-language-server}/bin/tailwindcss-language-server";
          };
          vscode-eslint-language-server = mkIf (get-lang-config "typescript").enable {
            command = "${vscode-lsp}/bin/vscode-eslint-language-server";
            args = ["--stdio"];
          };
          uwu-colors = {
            command = "${pkgs.uwu-colors}/bin/uwu_colors";
            args = ["--named-completions-mode" "full" "--color-collection" "colorhexa" "--variable-completions"];
          };
          lexical-lsp = let
            inherit (pkgs.beam.packages) erlang_26;
            inherit (pkgs) elixir-with-otp;
            inherit (lexical-lsp.lib) mkLexical;
            elixir = (elixir-with-otp erlang_26)."1.18.4";
            lexical =
              (mkLexical {
                erlang = erlang_26 // {inherit elixir;};
              }).overrideAttrs (oldAttrs: {
                mixFodDeps = erlang_26.fetchMixDeps {
                  pname = "lexical";
                  version = "development";
                  src = lexical-lsp;
                  sha256 = "sha256-g6BZGJ33oBDXmjbb/kBfPhart4En/iDlt4yQJYeuBzw=";
                };
              });
          in
            mkIf (get-lang-config "elixir").enable {
              command = "${lexical}/bin/start_lexical.sh";
            };
        };

        language =
          lib.flatten (
            lib.mapAttrsToList (
              lang-name: lang-config:
                map (helix-name: mk-helix-lang lang-config helix-name) lang-config.helix-names
            )
            language-configs
          )
          ++ [
            (mkIf (get-lang-config "elixir").enable {
              name = "elixir";
              auto-format = false;
              formatter = language-configs.elixir.formatter;
              language-servers = with-wakatime "elixir" [
                {
                  name = "lexical-lsp";
                  # except-features = ["completion"];
                }
              ];
            })
            (mkIf (get-lang-config "go").enable {
              name = "go";
              auto-format = true;
              language-servers = with-wakatime "go" [
                {
                  name = "gopls";
                  except-features = ["inlay-hints"];
                }
              ];
            })
            (mkIf (get-lang-config "typescript").enable {
              name = "typescript";
              auto-format = true;
              formatter = language-configs.typescript.formatter;
              language-servers = with-wakatime "typescript" [
                {
                  name = "typescript-language-server";
                  except-features = ["inlay-hints"];
                }
                "vscode-eslint-language-server"
                "uwu-colors"
              ];
            })
            (mkIf (get-lang-config "typescript").enable {
              name = "javascript";
              auto-format = true;
              formatter = language-configs.typescript.formatter;
              language-servers = with-wakatime "typescript" [
                {
                  name = "typescript-language-server";
                  except-features = ["inlay-hints"];
                }
                "vscode-eslint-language-server"
                "uwu-colors"
              ];
            })
            (mkIf (get-lang-config "python").enable {
              name = "python";
              auto-format = true;
              language-servers = with-wakatime "python" [
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
