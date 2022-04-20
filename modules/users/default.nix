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
    ./kitty
    ./starship
    ./udiskie
  ];
}
