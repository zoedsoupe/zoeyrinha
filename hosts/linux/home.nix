{pkgs, ...}: {
  home.username = "zoey.pessanha";
  home.homeDirectory = "/home/zoey.pessanha";

  home.stateVersion = "22.11";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    # chat
    tdesktop
    discord
    slack-dark

    # office
    onlyoffice-bin

    # dev
    lvim # my neovim config

    # agda
    deno
    nodejs_18
    clojure
    leiningen
    stack
    doctl
    elixir_1_14
    rustc
    cargo
    google-cloud-sdk
    beekeeper-studio
    insomnia
    gitAndTools.gh
    earthly
    awscli2
    ngrok
    flyctl
    nixpkgs-fmt

    # tools
    exercism
    # gitter
    qbittorrent
    t-rec
    obsidian
    microsoft-edge
    exa
    ripgrep
    fd

    # audio
    spotify

    # images
    peek
    flameshot
    imagemagick

    # others
    any-nix-shell
    # bitwarden-cli
    zoom-us
    arandr

    # audio & video
    mpv
    pavucontrol
    ffmpeg

    # image
    feh

    # others
    zathura
    inotify-tools
  ];
}
