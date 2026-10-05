{
  custom-config,
  lib,
  pkgs,
  ghostty-themes,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types strings;
  cfg = custom-config.ghostty;
in {
  options.ghostty = {
    enable = mkEnableOption "Enables Ghostty terminal";
    font-name = mkOption {
      description = "Font family ghostty renders with";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # darwin: managed by homebrew
    home.packages = lib.optional pkgs.stdenv.isLinux pkgs.ghostty;

    home.file = {
      ghostty-themes = {
        enable = true;
        target = ".config/ghostty/themes";
        source = ghostty-themes;
        recursive = true;
      };
      ghostty-config = let
        content = builtins.readFile ./ghostty/config;

        font = {
          name = cfg.font-name;
          features = ["calt" "ss01" "ss02" "ss03" "ss04" "ss05" "ss06" "ss07" "ss08" "ss09" "liga"];
        };

        font-config = ''

          font-family = "${font.name}"
          font-feature = ${strings.concatStringsSep "," font.features}
        '';

        text = strings.concatStrings [content font-config];
      in {
        inherit text;
        enable = true;
        target = ".config/ghostty/config";
        recursive = true;
      };
    };
  };
}
