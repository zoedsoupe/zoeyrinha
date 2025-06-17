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
    enable = true;
    font-name = "MonaLisa";
  };
  gh.enable = true;
  presenterm.enable = true;
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
    font = "MonoLisa";
    elixir.lsp = "next-ls";
  };
  helix = {
    enable = true;
    editor = {
      disable-line-numbers = true;
    };
    languages = {
      clojure.enable = false;
      html.enable = true;
      css.enable = true;
      json.enable = true;
      rust.enable = true;
      go.enable = true;
      nix.enable = true;
      nim.enable = false;
      zig.enable = true;
      typescript.enable = true;
      gleam.enable = true;
      ocaml.enable = true;
      lua.enable = true;
      python.enable = false;
      elixir = {
        enable = true;
        # except lsp features
        # lsp-features = ["completion" "format" "code-action"];
        lsp-features = [];
      };
    };
  };
  git = {
    enable = true;
    includes = [
      {
        condition = "gitdir:~/dev/**";
        contents = {
          user = {
            email = "zoey.spessanha@zeetech.io";
            name = "Zoey Pessanha";
            signingKey = "~/.ssh/personal-sign";
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
      PATH = "$HOME/.nix-profile/bin:/etc/profiles/per-user/zoedsoupe/bin:/run/current-system/sw/bin:$HOME/google-cloud-sdk/bin:$PATH";
      EDITOR = "${pkgs.helix}/bin/hx";
    };
  };
}
