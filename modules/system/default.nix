{ pkgs, config, lib, ... }:

{
  imports = [
    ./base.nix
    ./boot.nix
    ./connectivity.nix
    ./graphical
    ./picom.nix
    ./screen.nix
    ./security.nix
    ./virtualisation.nix
    ./zram.nix
  ];
}
