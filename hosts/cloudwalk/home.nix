{pkgs, ...}: {
  home.stateVersion = "22.11";
  home.homeDirectory = "/Users/zoeypessanha";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    gitAndTools.gh

    # tools
    eza
    fd
    silver-searcher
    jq
    glow
    ngrok
    tree
    git-filter-repo
    ripgrep

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
