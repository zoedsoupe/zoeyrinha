{ pkgs, config, lib, modulesPath, ... }:

{
  sound.enable = true;
  hardware.pulseaudio.enable = true;
}
