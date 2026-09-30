{pkgs, ...}: {
  home.stateVersion = "26.05";
  home.homeDirectory = "/home/zoedsoupe";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    (elixir-with-otp erlang_28).latest
    erlang_28
    go

    gnupg

    # tools
    eza
    fd
    silver-searcher
    jq
    just
    glow
    ffmpeg
    zip
    unzip

    # wayland desktop bits
    wl-clipboard
    chafa
  ];
}
