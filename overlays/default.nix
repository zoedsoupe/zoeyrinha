{ scripts, system, lib, inputs, ... }:

let
  inherit (inputs) copper;
in
{
  overlays = [
    inputs.copper.overlays.default
    scripts.overlay
  ];
}
