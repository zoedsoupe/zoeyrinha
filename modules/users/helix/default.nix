{
  pkgs,
  lib,
  custom-config,
  helix-themes,
  wakatime-ls,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = custom-config.helix;

  language-defaults = import ./languages.nix {inherit pkgs lib;};
  helpers = import ./lib.nix {inherit lib custom-config;};
  lsp-servers = import ./lsp-servers.nix {
    inherit pkgs lib custom-config wakatime-ls;
  };
  editor-config = import ./editor.nix {inherit lib custom-config;};

  languageType = types.submodule ({config, ...}: {
    options = {
      enable = mkEnableOption "language support";

      wakatime = {
        enable = mkEnableOption "WakaTime tracking";
      };

      lsp = mkOption {
        type = types.submodule {
          options = {
            enable = mkEnableOption "LSP support";
            name = mkOption {
              type = types.str;
              default = "";
              description = "Primary LSP server name";
            };
            except-features = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "LSP features to disable";
            };
          };
        };
        default = {};
      };
    };
  });

  build-special-language-configs = {
    elixir = mkIf cfg.languages.elixir.enable {
      name = "elixir";
      auto-format = false;
      formatter = language-defaults.elixir.formatter;
      language-servers = helpers.with-wakatime "elixir" [
        {
          name = cfg.languages.elixir.lsp.name or "lexical-lsp";
        }
      ];
    };

    go = mkIf cfg.languages.go.enable {
      name = "go";
      auto-format = true;
      language-servers = helpers.with-wakatime "go" [
        {
          name = "gopls";
          except-features = ["inlay-hints"];
        }
      ];
    };

    typescript = mkIf cfg.languages.typescript.enable {
      name = "typescript";
      auto-format = true;
      formatter = language-defaults.typescript.formatter;
      language-servers = helpers.with-wakatime "typescript" [
        {
          name = "typescript-language-server";
          except-features = ["inlay-hints"];
        }
        "vscode-eslint-language-server"
        "uwu-colors"
      ];
    };

    javascript = mkIf cfg.languages.typescript.enable {
      name = "javascript";
      auto-format = true;
      formatter = language-defaults.typescript.formatter;
      language-servers = helpers.with-wakatime "typescript" [
        {
          name = "typescript-language-server";
          except-features = ["inlay-hints"];
        }
        "vscode-eslint-language-server"
        "uwu-colors"
      ];
    };

    python = mkIf cfg.languages.python.enable {
      name = "python";
      auto-format = true;
      language-servers = helpers.with-wakatime "python" [
        {
          name = "ruff";
          except-features = ["completion"];
        }
      ];
    };
  };
in {
  options.helix = {
    enable = mkEnableOption "Helix Editor";

    editor = editor-config.options.helix.editor;

    languages = lib.mapAttrs (name: _: languageType) language-defaults;
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
      settings = editor-config.helix-settings;

      languages = {
        language-server = lsp-servers.language-server;

        language =
          (helpers.build-language-configs language-defaults {})
          ++ (lib.attrValues build-special-language-configs);
      };
    };
  };
}
