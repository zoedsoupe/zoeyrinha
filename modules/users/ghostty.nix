{
  custom-config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.ghostty;
in {
  options.ghostty.enable = mkEnableOption "Enables Ghostty terminal";

  config = mkIf cfg.enable {
    # managed by homebrew
    # home.packages = [ghostty.packages.${system}.default];

    home.file.ghostty = {
      enable = true;
      target = ".config/ghostty";
      source = ./ghostty;
      recursive = true;
    };
  };
}
