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
      elixir.enable = true;
      elixir.erlang = pkgs.beam.packages.erlangR26;
      clojure.enable = false;
      html.enable = true;
      css.enable = true;
      json.enable = true;
      rust.enable = true;
      nix.enable = true;
      typescript.enable = false;
    };
  };
  git = {
    enable = true;
    user = {
      name = "Zoey de Souza Pessanha";
      email = "zoey.spessanha@zeetech.io";
    };
    signing = {
      key = "E9C743148106E2C3";
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
      PATH = "$PATH:$HOME/.nix-profile/bin:/etc/profiles/per-user/zoedsoupe/bin:/run/current-system/sw/bin";
      EDITOR = "${pkgs.helix}/bin/hx";
    };
    dirHashes = {
      zoeyrinha = "$HOME/dev/personal/zoeyrinha";
      lvim = "$HOME/dev/personal/lvim";
      pescarte = "$HOME/dev/pescarte/pescarte-plataforma";
    };
  };
}
