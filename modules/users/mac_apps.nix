{ pkgs, ... }:

{
  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    # dev
    copper # my neovim config

    # agda
    deno
    nodejs-16_x
    clojure
    leiningen
    stack
    elixir_1_14
    rustc
    cargo
    gitAndTools.gh
    earthly
    ngrok
    nixpkgs-fmt
    tmate

    # tools
    exercism
    exa
    ripgrep
    fd

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
