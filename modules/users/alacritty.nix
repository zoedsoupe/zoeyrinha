{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.alacritty;
in
{
  options.zoedsoupe.alacritty = {
    enable = mkOption {
      description = "Enable Alacritty";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.alacritty = {
      inherit (cfg) enable;
      settings = {
        cursor = {
          style = {
            blinking = "Never";
            blink_interval = 300;
          };
        };
        window = {
          dynamic_title = true;
          dynamic_padding = false;
          decorations = "full";
        };
        selection = { save_to_clipboard = true; };
        scrolling = {
          history = 50000;
          multiplier = 2;
        };
        key_bindings = [
          {
            key = "V";
            mods = "Control|Shift";
            action = "Paste";
          }
          {
            key = "C";
            mods = "Control|Shift";
            action = "Copy";
          }
        ];
        font = {
          normal = { family = "JetBrainsMono Nerd Font Mono"; };
          bold = { family = "JetBrainsMono Nerd Font Mono"; };
          italic = { family = "JetBrainsMono Nerd Font Mono"; };
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
        colors = {
          primary = {
            background = "0x191622";
            foreground = "0xe1e1e6";
          };
          cursor = {
            text = "0x191622";
            cursor = "0xf8f8f2";
          };
          normal = {
            black = "0x000000";
            red = "0xff5555";
            green = "0x50fa7b";
            yellow = "0xeffa78";
            blue = "0xbd93f9";
            magenta = "0xff79c6";
            cyan = "0x8d79ba";
            white = "0xbfbfbf";
          };
          bright = {
            black = "0x4d4d4d";
            red = "0xff6e67";
            green = "0x5af78e";
            yellow = "0xeaf08d";
            blue = "0xcaa9fa";
            magenta = "0xff92d0";
            cyan = "0xaa91e3";
            white = "0xe6e6e6";
          };
          dim = {
            black = "0x000000";
            red = "0xa90000";
            green = "0x049f2b";
            yellow = "0xa3b106";
            blue = "0x530aba";
            magenta = "0xbb006b";
            cyan = "0x433364";
            white = "0x5f5f5f";
          };
        };
        draw_bold_text_with_bright_colors = true;
        background_opacity = 1;
      };
    };
  };
}
