{pkgs, ...}:
# let
#   neovim = pkgs.callPackage ./neovim.nix {inherit (pkgs) mkNeovim;};
# in
{
  home.stateVersion = "22.11";
  home.homeDirectory = "/Users/zoedsoupe";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    wakatime-cli
    pinentry_mac
    # neovim # my custom config neovim

    gnupg
    gitAndTools.gh
    ngrok
    tmate

    # tools
    bat
    eza # exa fork
    fd
    silver-searcher
    exercism
    pass
    jq
    glow
    flyctl
    earthly
    croc
    ngrok
    tree
    git-filter-repo
    mise
    just

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
