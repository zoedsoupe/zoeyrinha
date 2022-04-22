{ pkgs, config, lib, ... }:

{
  imports = [
    ./core.nix
    ./desktop.nix
    ./user.nix
  ];
}
