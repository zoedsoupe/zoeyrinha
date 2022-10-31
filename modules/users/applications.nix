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
      # onlyoffice-bin

      # dev
      copper # my neovim config

      # agda
      # deno
      solargraph # required by coc-nvim (see copper)
      doctl
      # google-cloud-sdk
      beekeeper-studio
      docker-compose_2
      # insomnia
      gitAndTools.gh
      # earthly
      awscli2
      ngrok
      flyctl
      nixpkgs-fmt
      # tmux
      tmate
      # heroku

      # tools
      # exercism
      # gitter
      # qbittorrent
      # exodus
      # gcolor3
      # t-rec
      # obsidian
      # microsoft-edge
      # whatsapp-for-linux

      # audio
      spotify

      # text
      # jabref
      # texlive.combined.scheme-full

      # images
      peek
      # flameshot
      imagemagick

      # others
      any-nix-shell
      # bitwarden-cli
      zoom-us
      # arandr

      # audio & video
      # mpv
      # pavucontrol
      ffmpeg

      # image
      # feh

      # others
      # zathura
      inotify-tools
    ];
  };
}
