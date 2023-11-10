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
    pinentry_mac
    neovim # my custom config neovim

    gnupg
    elixir_1_15
    gitAndTools.gh
    ngrok
    tmate
    presenterm

    # tools
    bat
    eza # exa fork
    fd
    silver-searcher

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
