{pkgs, ...}: {
  bat.enable = true;
  direnv.enable = false;
  fzf.enable = true;
  tmux.enable = true;
  gh.enable = false;
  xplr.enable = false;
  zoxide.enable = true;
  ghostty.enable = false;
  zed.enable = false;
  envoluntary.enable = false;

  starship.enable = true;

  helix = {
    enable = false;
    # highlighting only: grammars are compiled into the editor, so no language
    # servers (or their packages) on a headless vps
    lsp = false;
    editor = {
      disable-line-numbers = true;
    };
    languages = {
      nix = {
        enable = true;
        wakatime.enable = false;
      };
      json.enable = true;
      toml.enable = true;
      yaml.enable = true;
      ini.enable = true;
    };
  };

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
      # helix is off here; vim keeps EDITOR pointing at something that exists
      EDITOR = "${pkgs.vim}/bin/vim";
    };
  };
}
