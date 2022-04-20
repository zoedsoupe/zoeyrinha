{ pkgs, scripts, system, lib, ... }:

{
  overlays = [ scripts.overlay ];
}
