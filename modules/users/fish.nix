{pkgs, ...}: let
  base = ''
     ### PROMPT ###
     set -x PATH $PATH /usr/local/opt/curl/bin /opt/homebrew/sbin /usr/local/sbin /usr/local/bin /opt/homebrew/bin /opt/homebrew/bin /Users/zoey.pessanha/.nix-profile/bin /nix/var/nix/profiles/default/bin

     starship init fish | source
     any-nix-shell fish --info-right | source
     set -x GPG_TTY (tty)
     set -x STARSHIP_CONFIG ~/.config/starship.toml
     set fish_greeting # suppress fish initital greeting
     fish_config theme choose "Rosé Pine Moon"
     set HISTCONTROL ignoreboth # ignore commands with initial space and duplicates

    # Nuabank related
    # Generated for envman. Do not edit.
    [ -s "$HOME/.config/envman/load.fish" ] && source "$HOME/.config/envman/load.fish"
    set -U -x NU_HOME "$HOME/dev/nu"
    set -U -x NUCLI_HOME "$NU_HOME/nucli"

    set -x PATH $NUCLI_HOME $PATH
  '';
in {
  programs.fish = {
    enable = true;
    shellInit = base;
    plugins = [
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "HEAD";
          sha256 = "+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
        };
      }
      {
        name = "omni";
        src = pkgs.fetchFromGitHub {
          owner = "getomni";
          repo = "fish";
          rev = "v1.0.0";
          sha256 = "wEwYrIED3vootteL/x8SQqtkUMSFPrv+il7VWf/O39s=";
        };
      }
      {
        name = "rose-pine";
        src = pkgs.fetchFromGitHub {
          owner = "rose-pine";
          repo = "fish";
          rev = "main";
          sha256 = "bSGGksL/jBNqVV0cHZ8eJ03/8j3HfD9HXpDa8G/Cmi8=";
        };
      }
      {
        name = "fzf.fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "v8.1";
          sha256 = "uqYVbRdrcO6StaIim9S8xmb9P67CmXnLEywSeILn4yQ=";
        };
      }
    ];
  };
}
