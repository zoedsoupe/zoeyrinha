{pkgs, ...}: {
  alacritty.enable = false;
  bat.enable = true;
  direnv.enable = true;
  fish.enable = false;
  fzf.enable = true;
  kitty.enable = false;
  starship.enable = true;
  xplr.enable = true;
  warp.enable = true;
  zellij.enable = true;
  zoxide.enable = true;
  helix = {
    enable = true;
    languages = {
      clojure.enable = false;
      html.enable = false;
      css.enable = true;
      json.enable = true;
      rust.enable = false;
      nix.enable = true;
      typescript.enable = true;
      elixir = {
        enable = true;
        erlang = pkgs.beam.packages.erlangR24;
      };
    };
  };
  git = {
    enable = true;
    user = {
      name = "Zoey de Souza Pessanha";
      email = "zoey.pessanha@cumbuca.com";
    };
    signing = {
      key = "D4AAFA7DF2BFE793";
      signByDefault = true;
      gpgPath = "${pkgs.gnupg}/bin/gpg";
    };
  };
  zsh = {
    enable = true;
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
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
      GPG_TTY = "$(tty)";
      GITHUB_TOKEN = "";
      PATH = "$PATH:$HOME/.nix-profile/bin:/etc/profiles/per-user/zoeycumbuca/bin:/run/current-system/sw/bin";
      EDITOR = "${pkgs.helix}/bin/hx";
    };
    dirHashes = {
      zoeyrinha = "$HOME/dev/zoeyrinha";
    };
  };
}