{
  custom-config,
  lib,
  ghostty-themes,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption strings;
  cfg = custom-config.ghostty;
in {
  options.ghostty = {
    enable = mkEnableOption "Enables Ghostty terminal";
    font-name = let
      monaspace-variants = map ["Argon" "Xenon" "Radon" "Neon" "Kryton"] (v: "Monaspace " + v);
    in
      mkOption {
        type = lib.types.enum (["MonoLisa"] ++ monaspace-variants);
      };
  };

  config = mkIf cfg.enable {
    # managed by homebrew
    # home.packages = [ghostty.packages.${system}.default];

    home.file = {
      ghostty-themes = {
        enable = true;
        target = ".config/ghostty/themes";
        source = ghostty-themes;
        recursive = true;
      };
      ghostty-config = let
        content = builtins.readFile ./ghostty/config;

        font =
          if cfg.font-name == "MonoLisa"
          then {
            name = cfg.font-name;
            features = ["ss01" "ss04" "ss07" "ss08" "ss10" "ss11" "ss13" "ss14" "ss15" "ss16" "ss17" "ss18"];
          }
          else {
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
