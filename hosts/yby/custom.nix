{pkgs, ...}: {
  bat.enable = true;
  direnv.enable = true;
  fzf.enable = true;
  tmux.enable = true;
  gh.enable = true;
  xplr.enable = true;
  zoxide.enable = true;

  ghostty = {
    enable = true;
    font-name = "Monaspace Argon";
  };
  starship.enable = true;
  zed.enable = false;

  envoluntary = {
    enable = true;
    entries = [
      {
        pattern = ".*/dev/taina/.*";
        flake_reference = "~/dev/nix/taina";
      }
      {
        pattern = ".*/dev/oss/.*";
        flake_reference = "~/dev/nix/oss-elixir";
      }
    ];
  };

  helix = {
    enable = true;
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
      toml.enable = true;
      json.enable = true;
      html.enable = true;
      css.enable = true;
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
          };
        };
      };
    in
      map zeetech ["~/dev/personal" "~/dev/oss" "~/dev/taina" "~/dev/zeetech"];
  };

  zsh = {
    enable = true;
    profileExtra = ''
      alias ls='eza'
      alias tree='eza --tree --git-ignore'
    '';
    history = {
      ignorePatterns = ["git commit -m *" "git clone *" "mkdir *"];
    };
    sessionVariables = {
      DIRENV_LOG_FORMAT = "";
      EDITOR = "${pkgs.helix}/bin/hx";
    };
  };
}
