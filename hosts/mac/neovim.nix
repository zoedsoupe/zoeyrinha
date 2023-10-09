{mkNeovim}: let
  config = {
    lvim = {
      zen-mode = {
        enable = true;
        goyo.enable = true;
        limelight.enable = true;
        true-zen.enable = false;
      };
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
        clojure.enable = false;
        css.enable = true;
        dart.enable = false;
        elixir.enable = true;
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
        name = "melange";
      };
      treesitter = {
        enable = true;
        autotag.enable = true;
        context.enable = false;
        rainbow.enable = true;
        grammars = [
          "css"
          "dockerfile"
          "eex"
          "elixir"
          "graphql"
          "heex"
          "html"
          "json"
          "markdown"
          "nix"
          "scss"
          "toml"
          "yaml"
        ];
      };
      ui = {
        enable = true;
        word_highlight.enable = true;
        semantic_highlightment.enable = true;
        which_key.enable = true;
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
