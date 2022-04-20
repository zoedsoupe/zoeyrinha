{ pkgs, config, lib, ... }:

{
  imports = [
    ./alacritty
    ./dunst
    ./fish
    ./git.nix
    ./kitty
    ./starship
  ];
}
