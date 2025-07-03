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
  tmux.enable = false;
  neovim.enable = false;
  ghostty = {
    enable = true;
    font-name = "Monaspace Neon";
  };
  gh.enable = true;
  starship = {
    enable = true;
    catppuccin-theme = "macchiato";
  };
  xplr.enable = true;
  wezterm.enable = false;
  zellij.enable = false;
  zoxide.enable = true;
  zed = {
    enable = false;
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
        lsp.enable = false;
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
      export DOCKER_HOST=$(docker context inspect | jq '.[] | select(.Name == "'$(docker context show)'") | .Endpoints.docker.Host' -r)
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
      PATH = "$PATH:$HOME/.nix-profile/bin:/etc/profiles/per-user/zoeypessanha/bin:/run/current-system/sw/bin:$HOME/google-cloud-sdk/bin:$HOME/.pub-cache/bin:$HOME/flutter/bin";
      EDITOR = "${pkgs.helix}/bin/hx";
      FLUTTER_ROOT = "$HOME/flutter";
    };
  };
}
