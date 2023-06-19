{pkgs, ...}: {
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

    alejandra
    nodejs_18
    clojure
    leiningen
    elixir
    gitAndTools.gh
    ngrok
    tmate

    # tools
    exa
    ripgrep
    fd

    # others
    any-nix-shell
  ];
}
