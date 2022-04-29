{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.applications;
  agda = pkgs.agda.withPackages (p: [ p.standard-library ]);
in {
  options.zoedsoupe.applications = {
    enable = mkOption {
      description = "Enable a set of common applications";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
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
      agda

      # tools
      beekeeper-studio
      exercism
      docker-compose
      docker-compose_2
      insomnia
      qbittorrent
      gitAndTools.gh
      exodus
      earthly
      awscli2
      ngrok
      flyctl
      gcolor3
      t-rec
      heroku
      obsidian
      gitter
      doctl

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
      arandr
    ];
  };
}
