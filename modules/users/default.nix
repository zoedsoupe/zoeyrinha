{ pkgs, config, lib, ... }:

{
  imports = [
    ./alacritty.nix
    ./applications.nix
    ./bat.nix
    ./clipmenu.nix
    ./direnv.nix
    ./dunst.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./graphical.nix
    ./kitty.nix
    ./starship.nix
    ./udiskie.nix
    ./vscode.nix
    ./zsh.nix
  ];

  targets.genericLinux.enable = false;
}
