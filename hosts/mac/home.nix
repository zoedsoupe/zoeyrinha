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
    ripgrep
    fd

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
