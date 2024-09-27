{
  pkgs,
  custom-config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = custom-config.alacritty;
in {
  options.alacritty = {
    enable = mkEnableOption "Enables Alacritty terminal emulator";
    font-family = mkOption {
      default = "Dank Mono";
      type = types.str;
      description = "Font familly to apply to the terminal";
    };
    theme = mkOption {
      default = "catppuccin-frappe";
      description = "Theme to apply to the terminal";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = let
      download-catppuccin = theme: let
        repo = {
          owner = "catppuccin";
          repo = "alacritty";
          rev = "HEAD";
          sha256 = "5MUWHXs8vfl2/u6YXB4krT5aLutVssPBr+DiuOdMAto=";
        };
      in
        builtins.readFile ((pkgs.fetchFromGitHub repo) + /${theme}.toml);

      # yeah i know...
      is-catppuccin = str:
        if lib.strings.match "catppuccin.+" str == null
        then false
        else true;

      theme-toml =
        if (is-catppuccin cfg.theme)
        then builtins.fromTOML (download-catppuccin cfg.theme)
        else {};
    in {
      enable = true;
      settings =
        {
          cursor = {
            style = {
              blinking = "Never";
            };
            blink_interval = 300;
          };
          window = {
            dynamic_title = true;
            dynamic_padding = false;
            decorations = "full";
            opacity = 1;
          };
          selection = {
            save_to_clipboard = false;
          };
          scrolling = {
            history = 50000;
            multiplier = 2;
          };
          font = {
            normal = {family = cfg.font-family;};
            bold = {family = cfg.font-family;};
            italic = {family = cfg.font-family;};
            offset = {
              x = 0;
              y = 0;
            };
            glyph_offset = {
              x = 0;
              y = 0;
            };
            size = 14;
          };
          colors.draw_bold_text_with_bright_colors = true;
        }
        // theme-toml;
    };
  };
}
