{
  pkgs,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.warp;

  theme-source = {
    path,
    owner,
    repo,
    sha256,
  }:
    builtins.readFile (pkgs.fetchFromGitHub {
        inherit owner repo sha256;
        rev = "HEAD";
      }
      + path);

  catppuccin = theme:
    theme-source {
      path = /dist/catppuccin_${theme}.yml;
      owner = "catppuccin";
      repo = "warp";
      sha256 = "s2DIO5ZKHL5od3EUyuvAUqSxvQHvDvgepP24z+Sb1As=";
    };

  ayu = theme:
    theme-source {
      path = /themes/ayu_${theme}.yaml;
      owner = "wkei";
      repo = "ayu-warp";
      sha256 = "2CCfjbR/0A9Q13ATPukQbejIQHl1KdAzdXyjXgns/8M=";
    };

  melange = theme:
    theme-source {
      path = /dist/melange_${theme}.yml;
      repo = "melange-warp";
      owner = "zoedsoupe";
      sha256 = "YzuqgfUA4986ZO+gPk3CjtaIjDhL15+iICcizZr96Hc=";
    };

  warp-themes = theme:
    theme-source {
      path = /base16/base16_${theme}.yaml;
      repo = "themes";
      owner = "warpdotdev";
      sha256 = "YDk3lKSuPPfia9hdxBUPuBg2VJLbp/EdRPRkRsdmXDA=";
    };
in {
  options.warp = {
    enable = mkEnableOption "Enables warp configurations";
  };

  config = mkIf cfg.enable {
    home.file = {
      catppuccin-frappe-theme = {
        enable = true;
        target = ".warp/themes/catppuccin-frappe.yml";
        text = catppuccin "frappe";
      };

      catppuccin-latte-theme = {
        enable = true;
        target = ".warp/themes/catppuccin-latte.yml";
        text = catppuccin "latte";
      };

      ayu-mirage-theme = {
        enable = true;
        target = ".warp/themes/ayu-mirage.yml";
        text = ayu "mirage";
      };

      challenger-deep-theme = {
        enable = true;
        target = ".warp/themes/challenger-deep.yml";
        text = ''
          accent: '#fbfcfc'
          foreground: '#cbe3e7'
          background: '#1e1c31'
          details: darker
          terminal_colors:
            normal:
              black: '#565575'
              red: '#ff8080'
              green: '#95ffa4'
              yellow: '#ffe9aa'
              blue: '#91ddff'
              magenta: '#c991e1'
              cyan: '#aaffe4'
              white: '#cbe3e7'
            bright:
              black: '#100e23'
              red: '#ff5458'
              green: '#62d196'
              yellow: '#ffb378'
              blue: '#65b2ff'
              magenta: '#906cff'
              cyan: '#63f2f1'
              white: '#a6b3cc'
        '';
      };

      papercolor-light-theme = {
        enable = true;
        target = ".warp/themes/papercolor-light.yml";
        text = warp-themes "papercolor_light";
      };

      melange-dark-theme = {
        enable = true;
        target = ".warp/themes/melange-dark.yml";
        text = melange "dark";
      };

      melange-light-theme = {
        enable = true;
        target = ".warp/themes/melange-light.yml";
        text = melange "light";
      };
    };
  };
}
