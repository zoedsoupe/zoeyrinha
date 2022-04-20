{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.vscodium;

  marketplace = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "vsc-material-theme";
      publisher = "Equinusocio";
      version = "33.4.0";
      sha256 = "";
    }
    {
      name = "gc-excelviewer";
      publisher = "GrapeCity";
      version = "4.2.54";
      sha256 = "";
    }
    {
      name = "path-intellisense";
      publisher = "christian-kohler";
      version = "2.8.0";
      sha256 = "";
    }
    {
      name = "vscode-phoenix-snippets";
      publisher = "jamilabreu";
      version = "1.2.0";
      sha256 = "";
    }
    {
      name = "surface";
      publisher = "msaraiva";
      version = "0.7.0";
      sha256 = "";
    }
  ];
in {
  options.zoedsoupe.vscodium = {
    enable = mkIf {
      description = "Enable VSCodium";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    programs.vscode = {
      inherit (cfg) enable;
      package = pkgs.vscodium;
      haskell.enable = true;
      userSettings = {
        editor = {
          linkedEditing = true;
          minimap.enabled = true;
          fontLigatures = true;
          fontSize = 20;
          wordWrap = "wordWrapColumn";
          tabSize = 2;
          formatOnPaste = true;
          formatOnSave = true;
          formatOnType = true;
        };
        files.autoSave = "onWindowChange";
        emmet.triggerExpansionOnTab = true;
      };
      keybindings = [];
      extensions = with pkgs.vscode-extensions; marketplace ++ [
        naumovs.color-highlight
        mikestead.dotenv
        dracula-theme.theme-dracula
        github.vscode-pull-request-github
        eamodio.gitlens
        davidanson.vscode-markdownlint
        pkief.material-icon-theme
        esbenp.prettier-vscode
        jakebecker.elixir-ls
      ];
    };
  };
}
