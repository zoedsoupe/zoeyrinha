{ pkgs, config, lib, ... }:

{
  imports = [
    ./config.nix
    ./shared.nix
    ./wayland.nix
  ];
}
