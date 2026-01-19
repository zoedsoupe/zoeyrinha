{pkgs, ...}: {
  home.stateVersion = "22.11";
  home.homeDirectory = "/Users/zoedsoupe";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    (elixir-with-otp erlang_28).latest
    erlang_28

    wakatime-cli
    pinentry_mac

    gnupg

    # tools
    bat
    felix-fm
    chafa
    eza # exa fork
    fd
    silver-searcher
    pass
    jq
    flyctl
    ngrok
    git-filter-repo
    just
    glow
    wakatime-cli

    # others
    any-nix-shell

    # audio & video
    ffmpeg

    # docker
    colima
    docker
    docker-compose
  ];
}
