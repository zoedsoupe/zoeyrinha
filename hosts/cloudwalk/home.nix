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
    aider-chat
    eza # exa fork
    fd
    silver-searcher
    jq
    glow
    ngrok
    tree
    git-filter-repo
    slides

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
