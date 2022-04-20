{ pkgs, config, lib, ... }:

{
  imports = [
    ./shared.nix
    ./wayland.nix
    ./xorg.nix
  ];
}
