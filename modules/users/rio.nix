{
  pkgs,
  lib,
  custom-config,
  nix-std,
  ...
}: let
  theme = import ../../lib/theme.nix {inherit pkgs;};
  inherit (theme) mk-nyxvamp-for;
  inherit (nix-std.serde) toTOML;
  inherit (lib) mkIf mkEnableOption;

  cfg = custom-config.rio;
in {
  options.rio = {
    enable = mkEnableOption "Enables rio terminal config";
  };

  config = mkIf cfg.enable {
    home.file = {
      nyxvamp = {
        enable = true;
        target = ".config/rio/themes/nyxvamp-radiance.toml";
        text = builtins.readFile (mk-nyxvamp-for {
          tool = "rio";
          format = "toml";
          variant = "radiance";
        });
      };
      settings-rio = {
        enable = true;
        target = ".config/rio/config.toml";
        text = let
          config = {
            line-height = 1.2;
            padding-x = 12.0;
            theme = "nyxvamp-radiance";
            cursor = {
              shape = "beam";
              blinking = false;
            };
            fonts = let
              family = "MonoLisa";
            in {
              size = 17.0;
              regular = {inherit family;};
              bold = {inherit family;};
              italic = {inherit family;};
              bold-italic = {inherit family;};
              features = ["ss01" "ss04" "ss07" "ss08" "ss10" "ss11" "ss13" "ss14" "ss15" "ss16" "ss17" "ss18"];
            };
          };
        in
          toTOML config;
      };
    };
  };
}
