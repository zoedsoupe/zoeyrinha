{
  pkgs,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.fish;
  base = ''
    ### PROMPT ###
    starship init fish | source
    any-nix-shell fish --info-right | source
    set -x GPG_TTY (tty)
    set -x STARSHIP_CONFIG ~/.config/starship.toml
    set fish_greeting # suppress fish initital greeting
    fish_config theme choose "Rosé Pine Moon"
    set HISTCONTROL ignoreboth # ignore commands with initial space and duplicates
  '';
in {
  options.fish.enable = mkEnableOption "Enables Fish shell";
  config = mkIf cfg.enable {
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
  };
}
