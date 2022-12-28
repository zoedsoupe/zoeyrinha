{ scripts, system, lib, inputs, ... }:

let
  inherit (inputs) copper;
in
{
  overlays = [
    scripts.overlay
    copper.overlays.default
  ];
}
