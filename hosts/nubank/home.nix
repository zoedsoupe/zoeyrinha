{pkgs, ...}: {
  home.username = "zoey.pessanha";
  home.homeDirectory = "/Users/zoey.pessanha";

  home.stateVersion = "22.11";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    # dev
    lvim # my neovim config
    # mnvim # my minimal neovim config

    # agda
    deno
    nodejs_18
    clojure
    leiningen
    stack
    elixir
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
