{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.vscodium;

  marketplace = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "vsc-material-theme";
      publisher = "Equinusocio";
      version = "33.4.0";
      sha256 = "sha256-BthKoGzj0XeZINAmgkHPArvm2gIzDaOaAnkoWVqOkoY=";
    }
    {
      name = "gc-excelviewer";
      publisher = "GrapeCity";
      version = "4.2.54";
      sha256 = "sha256-uMfCPk3ZwNCiHLVle7Slxw6n/FiIrlMR2T/jCggtK+s=";
    }
    {
      name = "path-intellisense";
      publisher = "christian-kohler";
      version = "2.8.0";
      sha256 = "sha256-VPzy9o0DeYRkNwTGphC51vzBTNgQwqKg+t7MpGPLahM=";
    }
    {
      name = "vscode-phoenix-snippets";
      publisher = "jamilabreu";
      version = "1.2.0";
      sha256 = "sha256-iMrO+HiD7bf2TV7J/KpxvYmLkxHAlS/PSK9Evge7HoI=";
    }
    {
      name = "surface";
      publisher = "msaraiva";
      version = "0.7.0";
      sha256 = "sha256-9ps0gN/NcokAryZcc+EPqP8M3qypZqh9dB/kSckFtfg=";
    }
  ];
in {
  options.zoedsoupe.vscodium = {
    enable = mkOption {
      description = "Enable VSCodium";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.vscode = {
      inherit (cfg) enable;
      package = pkgs.vscodium;
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
