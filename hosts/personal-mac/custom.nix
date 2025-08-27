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
  ghostty = {
    enable = true;
    font-name = "MonaLisa";
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
    enable = true;
    theme = {
      dark = "NyxVamp Veil";
      light = "NyxVamp Radiance";
    };
    font = "MonoLisa";
  };
  helix = {
    enable = true;
    editor = {
      disable-line-numbers = true;
    };
    languages = {
      clojure.enable = false;
      html = {
        enable = true;
        wakatime.enable = true;
      };
      css = {
        enable = true;
        wakatime.enable = true;
      };
      json = {
        enable = true;
        wakatime.enable = true;
      };
      toml = {
        enable = true;
        wakatime.enable = true;
      };
      rust.enable = false;
      go.enable = false;
      nix = {
        enable = true;
        wakatime.enable = true;
      };
      nim.enable = false;
      zig.enable = false;
      typescript = {
        enable = true;
        wakatime.enable = true;
      };
      gleam.enable = false;
      ocaml.enable = false;
      lua.enable = false;
      python.enable = false;
      elixir = {
        enable = true;
        wakatime.enable = true;
        lsp.enable = true;
        lsp.name = "lexical-lsp";
      };
    };
  };
  git = {
    enable = true;
    includes = let
      zeetech = path: {
        condition = "gitdir:${path}/";
        contents = {
          user = {
            email = "zoey.spessanha@zeetech.io";
            name = "Zoey Pessanha";
            signingKey = "~/.ssh/personal-sign";
          };
        };
      };

      zeetech-paths = map zeetech ["~/dev/personal" "~/dev/ccuenf" "~/dev/supabase" "~/dev/zeetech" "~/dev/oss" "~/dev/elixiremfoco"];
    in
      [
        {
          condition = "gitdir:~/dev/dashbit/";
          contents = {
            user = {
              email = "zoey.spessanha@dashbit.co";
              name = "zoedsoupe";
              signingKey = "~/.ssh/dashbit";
            };
          };
        }
      ]
      ++ zeetech-paths;
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
      PATH = "$HOME/.nix-profile/bin:/etc/profiles/per-user/zoedsoupe/bin:/run/current-system/sw/bin:$HOME/google-cloud-sdk/bin:$PATH";
      EDITOR = "${pkgs.helix}/bin/hx";
    };
  };
}
