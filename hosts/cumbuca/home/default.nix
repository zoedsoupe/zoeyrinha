{pkgs, ...}: {
  imports = [./wezterm.nix];

  home = {
    username = "zoedsoupe";
    homeDirectory = "/home/zoedsoupe";
    stateVersion = "23.11";
    extraOutputsToInstall = ["doc" "devdoc"];
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    tdesktop
    libnotify
    xdg-utils
    obsidian
    gnupg
    elixir_1_15
    gitAndTools.gh
    ngrok
    tmate
    any-nix-shell
    docker-compose
    earthly
    flyctl
    insomnia
    peek
  ];

  services = {
    gnome.gnome-keyring.enable = true;

    xserver = {
      desktopManager.gnome.enable = true;

      displayManager.gdm = {
        enable = true;
        wayland = false;
      };
    };
  };
}
