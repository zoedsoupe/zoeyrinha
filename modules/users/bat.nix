{ pkgs, config, lib, ... }:

let
  inherit (lib) mkIf mkOption types;
  cfg = config.zoedsoupe.bat;
in
{
  options.zoedsoupe.bat = {
    enable = mkOption {
      description = "Enable Bat";
      type = types.bool;
      default = false;
    };

    theme = {
      enable = mkOption {
        description = "Enable Bat themes";
        type = types.bool;
        default = true;
      };
      name = mkOption {
        description = "Bat theme style";
        type = types.enum [ "catppuccin" ];
        default = "catppuccin";
      };
      style = mkOption {
        description = "Bat theme style";
        type = types.enum [ "latte" "frappe" "macchiato" "mocha" ];
        default = "frappe";
      };
    };
  };

  config = mkIf (cfg.enable) {
    programs.bat =
      let
        themeFile = "Catppuccin-" + cfg.theme.style + ".tmTheme";
      in
      {
        inherit (cfg) enable;
        config = {
          theme = cfg.theme.name;
        };
        themes = mkIf (cfg.theme.enable) {
          catppuccin = builtins.readFile (pkgs.fetchFromGitHub
            {
              owner = "catppuccin";
              repo = "bat";
              rev = "HEAD";
              sha256 = "6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
            } + /${themeFile});
        };
      };
  };
}
