{mkNeovim}: let
  config = {
    lvim = {
      autopair.enable = true;
      comments.enable = true;
      completion = {
        enable = true;
        buffer.enable = true;
        cmdline.enable = false;
        lsp = {
          enable = true;
          lspkind.enable = true;
        };
        path.enable = true;
        snippets = {
          enable = true;
          source = "luasnip";
        };
      };
      filetree = {
        enable = false;
        vinegar-style.enable = true;
      };
      git = {
        enable = true;
        gitsigns.enable = true;
      };
      lsp = {
        enable = true;
        clojure.enable = true;
        css.enable = false;
        dart.enable = true;
        elixir.enable = false;
        nix = {
          enable = true;
          nil.enable = true;
          nixd.enable = false;
        };
        rust.enable = false;
        typescript.enable = false;
        null-ls.enable = true;
        trouble.enable = true;
        rename.enable = true;
      };
      statusline = {
        enable = true;
        theme = "auto";
      };
      surround.enable = true;
      telescope = {
        enable = true;
        file_browser.enable = false;
      };
      theme = {
        enable = true;
        name = "catppuccin";
        flavour = {
          light = "latter";
          dark = "frappe";
        };
      };
      treesitter = {
        enable = true;
        autotag.enable = true;
        context.enable = false;
        rainbow.enable = true;
        grammars = [
          "clojure"
          "dart"
          "dockerfile"
          "graphql"
          "html"
          "json"
          "markdown"
          "nix"
          "toml"
          "yaml"
        ];
      };
      ui = {
        enable = true;
        word_highlight.enable = true;
        semantic_highlightment.enable = true;
        matchup.enable = false;
        which_key.enable = true;
        legendary.enable = false;
        noice.enable = false;
        tabout.enable = false;
      };
      visuals = {
        icons.enable = true;
        cursorWordline.enable = true;
        indentBlankline = {
          enable = true;
        };
      };
    };
  };
in
  mkNeovim {inherit config;}
