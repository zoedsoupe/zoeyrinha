{pkgs, ...}: {
  bat.enable = true;
  direnv.enable = false;
  fzf.enable = true;
  tmux.enable = true;
  gh.enable = false;
  xplr.enable = false;
  zoxide.enable = true;
  ghostty.enable = false;
  envoluntary.enable = false;
  starship.enable = true;
  helix.enable = false;
  git.enable = true;

  zsh = {
    enable = true;
    fancy = false;
    devHelpers = false;
    profileExtra = ''
      alias ls='eza'
    '';
    history = {
      ignorePatterns = ["git commit -m *" "mkdir *"];
    };
    sessionVariables = {
      EDITOR = "${pkgs.vim}/bin/vim";
    };
  };
}
