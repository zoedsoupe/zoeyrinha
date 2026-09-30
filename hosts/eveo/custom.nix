{pkgs, ...}: {
  bat.enable = true;
  direnv.enable = true;
  fzf.enable = true;
  tmux.enable = true;
  gh.enable = false;
  xplr.enable = false;
  zoxide.enable = true;
  zellij.enable = false;
  wezterm.enable = false;
  kitty.enable = false;
  alacritty.enable = false;
  fish.enable = false;
  ghostty.enable = false;
  zed.enable = false;
  envoluntary.enable = false;

  starship = {
    enable = true;
    catppuccin-theme = "macchiato";
  };

  helix = {
    enable = true;
    editor = {
      disable-line-numbers = true;
    };
    languages = {
      nix.enable = true;
      toml.enable = true;
      json.enable = true;
    };
  };

  git.enable = true;

  zsh = {
    enable = true;
    profileExtra = ''
      alias ls='eza'
    '';
    history = {
      ignorePatterns = ["git commit -m *" "mkdir *"];
    };
    theme = {
      enable = true;
      name = "catppuccin";
      flavour = "frappe";
    };
    sessionVariables = {
      DIRENV_LOG_FORMAT = "";
      EDITOR = "${pkgs.helix}/bin/hx";
    };
  };
}
