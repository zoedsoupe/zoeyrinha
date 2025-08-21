{
  pkgs,
  unstable,
  ...
}: {
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
    glow

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
