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
    awscli2
    awsebcli
    pass
    supabase-cli
    jq
    glow
    flyctl
    earthly
    croc
    ngrok
    tree
    git-filter-repo

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
