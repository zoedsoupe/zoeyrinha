{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.applications;
  agda = pkgs.agda.withPackages (p: [ p.standard-library ]);
in
{
  options.zoedsoupe.applications = {
    enable = mkOption {
      description = "Enable a set of common applications";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    xdg.configFile."nvim/coc-settings.json".source = pkgs.writeTextFile {
      name = "coc-settings.json";
      text = builtins.toJSON {
        "codeLens.enable" = true;
        "rust-client" = {
          "disableRustup" = true;
          "rlsPath" = "${pkgs.rls}/bin/rls";
        };
        "suggest" = {
          "noselect" = true;
          "removeDuplicateItems" = true;
        };
        "languageserver" = {
          "elixirLS" = {
            "command" = "${pkgs.elixir_ls}/bin/elixir-ls";
            "filetypes" = [ "elixir" "eexlixir" "heexlixir" ];
          };
          "rust" = {
            "command" = "${pkgs.rls}/bin/rls";
            "rootPatterns" = [ "Cargo.toml" ];
            "filetypes" = [ "rs" ];
          };
          "nix" = { "command" = "${pkgs.rnix-lsp}/bin/rnix-lsp"; "filetypes" = [ "nix" ]; };
          # FIX ME
          # "solargraph" = {
          #   "commandPath" = "${pkgs.solargraph}/bin";
          #   "filetypes" = [ "rb" "erb" ];
          # };
        };
        "coc.preferences" = {
          "useQuickfixForLocations" = true;
          "snippets.enable" = true;
          "extensionsUpdateCheck" = "never";
          "formatOnSaveFiletypes" = [
            "elixir"
            "rust"
            "nix"
          ];
        };
      };
    };

    programs = {
      home-manager.enable = true;
      command-not-found.enable = true;
    };

    home.packages = with pkgs; [
      # chat
      tdesktop
      discord
      slack-dark

      # office
      onlyoffice-bin

      # dev
      copper # my neovim config

      # agda
      # deno
      solargraph # remove me
      doctl
      google-cloud-sdk
      beekeeper-studio
      docker-compose_2
      insomnia
      gitAndTools.gh
      earthly
      awscli2
      ngrok
      flyctl
      nixpkgs-fmt
      tmux
      tmate
      # heroku

      # tools
      exercism
      # gitter
      qbittorrent
      exodus
      gcolor3
      t-rec
      # obsidian
      microsoft-edge-dev
      whatsapp-for-linux

      # audio
      spotify

      # text
      # jabref
      # texlive.combined.scheme-full

      # images
      peek
      flameshot
      imagemagick

      # others
      any-nix-shell
      bitwarden-cli
      zoom-us
      # arandr

      # audio & video
      mpv
      pavucontrol
      ffmpeg

      # image
      feh

      # others
      zathura
      inotify-tools
    ];
  };
}
