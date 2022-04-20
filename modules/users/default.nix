{ pkgs, config, lib, ... }:

{
  imports = [
    ./alacritty
    ./applications
    ./clipmenu
    ./direnv
    ./dunst
    ./fish
    ./fzf
    ./git.nix
    ./graphical
    ./kitty
    ./starship
    ./udiskie
    ./vscodium
  ];
}
