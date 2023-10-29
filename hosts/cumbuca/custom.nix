{pkgs, ...}: {
  alacritty.enable = false;
  bat.enable = true;
  direnv.enable = true;
  fish.enable = false;
  fzf.enable = true;
  kitty.enable = false;
  starship.enable = true;
  xplr.enable = true;
  zellij.enable = true;
  zoxide.enable = true;
  helix = {
    enable = true;
    languages = {
      elixir.enable = true;
      clojure.enable = false;
      html.enable = false;
      css.enable = false;
      json.enable = true;
      rust.enable = false;
      nix.enable = true;
    };
  };
  git = {
    enable = true;
    user = {
      name = "Zoey de Souza Pessanha";
      email = "zoey.pessanha@cumbuca.com";
    };
    signing = {
      key = "";
      signByDefault = true;
      gpgPath = "${pkgs.gnupg}/bin/gpg";
    };
  };
  zsh = {
    enable = true;
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
  };
}
