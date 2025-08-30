{lib, ...}: let
  inherit (lib) types mkOption;
in rec {
  formatterType = types.submodule {
    options = {
      command = mkOption {
        type = types.str;
        description = "The formatter command to run";
      };
      args = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Arguments to pass to the formatter";
      };
    };
  };

  lspServerType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Name of the language server";
      };
      except-features = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "LSP features to disable for this server";
      };
    };
  };

  languageConfigType = types.submodule ({config, ...}: {
    options = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable this language configuration";
      };

      helix-names = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Helix language identifiers this config applies to";
      };

      auto-format = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable auto-formatting";
      };

      formatter = mkOption {
        type = types.nullOr formatterType;
        default = null;
        description = "Formatter configuration";
      };

      language-servers = mkOption {
        type = types.listOf (types.either types.str lspServerType);
        default = [];
        description = "List of language servers to use";
      };

      extra-servers = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = {};
        description = "Additional servers per Helix language name";
      };

      wakatime = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Whether to enable WakaTime tracking for this language";
        };
      };

      lsp = {
        enable = mkOption {
          type = types.bool;
          default = config.enable;
          description = "Whether to enable LSP support";
        };

        primary = mkOption {
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
  });
}
