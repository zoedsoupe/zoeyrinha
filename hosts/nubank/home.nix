{pkgs, ...}: let
  neovim = pkgs.callPackage ./neovim.nix {inherit (pkgs) mkNeovim;};
in {
  home.homeDirectory = "/Users/zoey.pessanha";

  home.stateVersion = "22.11";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    # dev
    neovim # my neovim config

    alejandra
    nodejs_18
    clojure
    leiningen
    elixir
    gitAndTools.gh
    ngrok
    tmate

    # tools
    bat
    exa
    ripgrep
    fd

    # others
    any-nix-shell
  ];
}
