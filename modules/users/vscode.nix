{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.vscode;

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
  options.zoedsoupe.vscode = {
    enable = mkOption {
      description = "Enable VSCode";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.vscode = {
      inherit (cfg) enable;
      userSettings = {
        editor = {
          suggest = {
            maxVisibleSuggestions = 10;
            localityBonus = true;
          };
          linkedEditing = true;
          minimap.enabled = true;
          fontLigatures = true;
          fontSize = 20;
          wordWrap = "wordWrapColumn";
          tabSize = 2;
          formatOnPaste = true;
          formatOnSave = true;
          formatOnType = true;
          renderLineHighlight = "gutter";
          cursorBlinking = "smooth";
          cursorSmoothCaretAnimation = true;
          smoothScrolling = true;
          suggestSelection = "recentlyUsedByPrefix";
          quickSuggestionsDelay = 0;
          fontWeight = "300";
        };
        workbench = {
          editor = {
            highlightModifiedTabs = true;
            labelFormat = "short";
          };
          iconTheme = "material-icon-theme";
          colorTheme = "Material Theme";
        };
        window = {
          closeWhenEmpty = true;
          doubleClickIconToClose = true;
          menuBarVisibility = "toggle";
          openFoldersInNewWindow = true;
          zoomLevel = 0;
        };
        files = {
          autoSave = "onWindowChange";
          trimFinalNewlines = true;
          autoSaveDelay = 10;
          insertFinalNewline = false;
          simpleDiaalog.enable = true;
          trimTrailingWhitespace = true;
        };
        explorer = {
          confirmDelete = false;
          incrementalNaming = "smart";
          confirmDragAndDrop = false;
          compactFolders = false;
        };
        material-icon-theme.folders.associations = {
          infra = "app";
          entities = "class";
          schemas = "class";
          typeorm = "database";
          repositories = "mappings";
          http = "container";
          migrations = "tools";
          modules = "components";
          implementations = "core";
          dtos = "typescript";
          fakes = "mock";
          websockets = "pipe";
          protos = "pipe";
          grpc = "pipe";
          useCases = "controller";
        };
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
