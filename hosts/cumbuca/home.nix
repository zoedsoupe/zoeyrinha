{pkgs, ...}: let
  elixir_1_15 = pkgs.beam.packages.erlang_26.elixir_1_15;
in {
  home.stateVersion = "22.11";
  home.homeDirectory = "/Users/zoeycumbuca";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    pinentry_mac
    gnupg
    ngrok
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
