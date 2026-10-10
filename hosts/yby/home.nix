{pkgs, ...}: {
  home.stateVersion = "26.05";
  home.homeDirectory = "/home/zoedsoupe";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  # no wayland shell on a headless box; flip on together with niri.enable
  # in configuration.nix when a monitor shows up
  noctalia.enable = false;

  home.packages = with pkgs; [
    (elixir-with-otp erlang_28).latest
    erlang_28

    gnupg

    # tools
    eza
    fd
    jq
    just
    zip
    unzip
    forgejo
    cloudflared
  ];
}
