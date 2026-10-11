{pkgs, ...}: {
  home.stateVersion = "26.05";
  home.homeDirectory = "/home/zoedsoupe";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    eza
    fd
    jq
    zip
    unzip
  ];
}
