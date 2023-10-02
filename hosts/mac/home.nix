{pkgs, ...}: let
  neovim = pkgs.callPackage ./neovim.nix {inherit (pkgs) mkNeovim;};
  elixir_1_15 = pkgs.beam.packages.erlang_26.elixir_1_15;
in {
  home.stateVersion = "22.11";
  home.homeDirectory = "/Users/zoedsoupe";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    neovim # my custom config neovim

    gnupg
    elixir_1_15
    gitAndTools.gh
    ngrok
    tmate
    alejandra

    # tools
    bat
    # flyctl
    exa
    fd
    silver-searcher

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
