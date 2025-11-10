{
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = custom-config.envoluntary;
in {
  options.envoluntary = {
    enable = mkEnableOption "Enables envoluntary nix config loader";
    entries = mkOption {
      description = "The envoluntary config pattern based entries";
      default = [];
      type = types.listOf (types.submodule {
        options = {
          pattern = mkOption {
            type = types.str;
            description = "Regex pattern to match directory paths";
          };
          pattern_adjacent = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Optional regex pattern to match adjacent files/directories";
          };
          flake_reference = mkOption {
            type = types.str;
            description = "Flake reference to load (path, github, etc)";
          };
          impure = mkOption {
            type = types.bool;
            default = false;
            description = "Whether the flake is impure";
          };
        };
      });
    };
  };

  config = mkIf cfg.enable {
    programs.envoluntary = {
      enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = false;

      config = {inherit (cfg) entries;};
    };
  };
}
