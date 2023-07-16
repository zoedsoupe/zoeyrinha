{pkgs, ...}: {
  home.stateVersion = "22.11";
  home.homeDirectory = "/Users/zoedsoupe";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    # dev
    lvim # my neovim config
    # mnvim # my minimal neovim config

    gnupg
    elixir
    gitAndTools.gh
    ngrok
    tmate
    alejandra

    # tools
    bat
    exa
    fd
    silver-searcher

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
