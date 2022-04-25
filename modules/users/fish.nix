{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.fish;

  base = ''
    ### PROMPT ###
    starship init fish | source

    any-nix-shell fish --info-right | source

    set -x GPG_TTY (tty)

    set -x STARSHIP_CONFIG ~/.config/starship.toml

    set fish_greeting # suppress fish initital greeting

    set HISTCONTROL ignoreboth # ignore commands with initial space and duplicates
    '';

    functions = ''
    ### FUNCTIONS ###
    function tre
    command tree -aC \
    -I '.git|.github|node_modules|deps|_build|.elixir_ls|.nix-hex|.nix-mix|.postgres|.direnv' \
    --dirsfirst $argv | bat
    end

    function cd
    builtin cd $argv && ls -a .
    end

    function ls
    command exa
    end

    function mkd
    command mkdir -p $argv && cd $argv
    end

    function clean_node_modules
    command find . -name "node_modules" -type d -prune -exec rm -rf '{}' +
    end
    '';
in {
  options.zoedsoupe.fish = {
    enable = mkOption {
      description = "Enable Fish";
      type = types.bool;
      default = false;
    };

    aliases = mkOption {
      description = "Shell aliases";
      type = types.attrs;
      default = {};
    };
  };

  config = mkIf (cfg.enable) {
    programs.fish = {
      inherit (cfg) enable;
      shellInit = (base + functions);
      shellAliases = cfg.aliases;
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
