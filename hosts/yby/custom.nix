{pkgs, ...}: {
  bat.enable = true;
  direnv.enable = false;
  fzf.enable = true;
  tmux.enable = true;
  gh.enable = true;
  xplr.enable = true;
  zoxide.enable = true;

  ghostty.enable = false;
  starship.enable = true;

  envoluntary.enable = false;

  helix = {
    enable = true;
    lsp = false;
    editor = {
      disable-line-numbers = true;
    };
    languages = {
      nix = {
        enable = true;
        wakatime.enable = false;
      };
      elixir = {
        enable = true;
        wakatime.enable = false;
      };
      json.enable = true;
      toml.enable = true;
      yaml.enable = true;
      ini.enable = true;
    };
  };

  git = {
    enable = true;
    includes = [
      {
        condition = "gitdir:~/code/";
        contents = {
          user = {
            email = "zoey.spessanha@zeetech.io";
            name = "Zoey Pessanha";
          };
        };
      }
    ];
  };

  zsh = {
    enable = true;
    fancy = false;
    devHelpers = false;
    profileExtra = ''
      alias ls='eza'
      alias tree='eza --tree --git-ignore'
    '';
    history = {
      ignorePatterns = ["git commit -m *" "git clone *" "mkdir *"];
    };
    sessionVariables = {
      EDITOR = "${pkgs.helix}/bin/hx";
    };
  };
}
