{ pkgs, config, lib, ... }:

{
  imports = [
    ./config.nix
    ./wayland.nix
  ];
}
