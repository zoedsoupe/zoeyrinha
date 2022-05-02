{ pkgs, config, lib, ... }:

{
  imports = [
    ./alacritty.nix
    ./applications.nix
    ./clipmenu.nix
    ./direnv.nix
    ./dunst.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./graphical
    ./kitty.nix
    ./starship.nix
    ./udiskie.nix
    ./vscode.nix
  ];
}
