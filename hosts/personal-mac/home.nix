{
  pkgs,
  unstable,
  ...
}:
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

    # tools
    bat
    eza # exa fork
    fd
    silver-searcher
    pass
    jq
    flyctl
    ngrok
    tree
    git-filter-repo
    just
    unstable.claude-code

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
