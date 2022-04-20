{ pkgs, config, lib, ... }:

{
  imports = [
    ./alacritty
    ./applications
    ./clipmenu
    ./dunst
    ./fish
    ./git.nix
    ./kitty
    ./starship
    ./udiskie
  ];
}
