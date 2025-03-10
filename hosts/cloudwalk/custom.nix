{pkgs, ...}: {
  alacritty = {
    enable = false;
    font-family = "Dank Mono";
    theme = "catppuccin-macchiato";
  };
  bat.enable = true;
  direnv.enable = true;
  fish.enable = false;
  fzf.enable = true;
  kitty = {
    enable = false;
    font-family = "Dank Mono";
    theme = "catppuccin-macchiato";
  };
  tmux.enable = true;
  neovim.enable = false;
  rio.enable = false;
  ghostty = {
    enable = false;
    font-name = "Monaspace Neon";
  };
  gh.enable = true;
  presenterm.enable = false;
  starship = {
    enable = true;
    catppuccin-theme = "macchiato";
  };
  xplr.enable = true;
  wezterm.enable = false;
  zellij.enable = false;
  zoxide.enable = true;
  zed = {
    enable = true;
    theme = "NyxVamp Veil";
    font = "Monaspace Neon";
    elixir.lsp = "next-ls";
  };
  helix = {
    enable = true;
    editor = {
      disable-line-numbers = true;
    };
    languages = {
      clojure.enable = false;
      html.enable = false;
      css.enable = false;
      json.enable = true;
      rust.enable = true;
      go.enable = true;
      nix.enable = true;
      nim.enable = false;
      zig.enable = false;
      typescript.enable = true;
      gleam.enable = false;
      ocaml.enable = false;
      lua.enable = false;
      python.enable = true;
      elixir = {
        enable = true;
        # except lsp features
        lsp-features = [];
      };
    };
  };
  git = {
    enable = true;
    includes = [
      {
        condition = "gitdir:~/dev/cloudwalk/**";
        contents = {
          user = {
            email = "zoey.spessanha@cloudwalk.io";
            name = "Zoey Pessanha";
            signingKey = "~/.ssh/cw-sign";
          };
        };
      }
      {
        condition = "gitdir:~/dev/zoey/**";
        contents = {
          user = {
            email = "zoey.spessanha@zeetech.io";
            name = "Zoey Pessanha";
            signingKey = "~/.ssh/zoedsoupe";
          };
        };
      }
    ];
  };
  zsh = {
    enable = true;
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      ${pkgs.krabby}/bin/krabby random 2> /dev/null
    '';
    history = {
      ignorePatterns = ["git commit -m *" "git clone *" "mix test --only *" "mkdir *"];
    };
    theme = {
      enable = true;
      name = "catppuccin";
      flavour = "frappe";
    };
    sessionVariables = {
      DIRENV_LOG_FORMAT = "";
      GPG_TTY = "$(tty)";
      GITHUB_TOKEN = "";
      PATH = "$PATH:$HOME/.nix-profile/bin:/etc/profiles/per-user/zoeypessanha/bin:/run/current-system/sw/bin:$HOME/google-cloud-sdk/bin:$HOME/flutter/bin";
      EDITOR = "${pkgs.helix}/bin/hx";
    };
  };
}
