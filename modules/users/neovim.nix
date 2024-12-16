{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.neovim.enable = mkEnableOption "Enables Neovim";

  config = {
    programs.nixvim = {
      enable = true;

      viAlias = true;
      vimAlias = true;

      withNodeJs = true;
      withPython3 = true;
      withRuby = true;

      performance.combinePlugins.enable = true;

      editorconfig.enable = true;
      colorschemes.one.enable = true;

      keymaps = [
        {
          action = "<cmd>Oil<cr>";
          key = "<space-f>";
        }
      ];

      # plugins
      plugins = {
        direnv.enable = true;
        oil.enable = true;
        zen-mode.enable = true;
        wakatime.enable = true;
        vim-css-color.enable = true;
        rainbow-delimiters.enable = true;
        neoscroll.enable = true;
        telescope = {
          enable = true;
          extensions = {
            fzf-native.enable = true;
          };
          keymaps."<space-F>".action = "fzf_native";
        };
        treesitter = {
          enable = true;
          grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            elixir
            markdown
            json
            html
            css
            rust
            clojure
            zig
            go
            nix
            toml
          ];
        };
        mini = {
          enable = true;
          mockDevIcons = true;
          modules = {
            completion = {};
            bufremove = {
              silent = true;
              set_vim_settings = true;
            };
            comment = {
              mappings = {
                comment_line = "crtl-c";
              };
            };
            cursorword = {};
            icons.style = "glyph";
            pairs.modes = {
              insert = true;
              command = true;
              terminal = true;
            };
            sessions = {
              autoread = true;
              autowrite = true;
              directory = "~";
              file = ".neovim.session";
            };
            statusline = {};
            starter = {};
            # yeah, same as helix
            surround.mappings = {
              add = "ms";
              delete = "md";
              find = "mf";
              find_left = "mF";
              highlight = "mh";
              replace = "mr";
            };
          };
        };
      };
    };
  };
}
