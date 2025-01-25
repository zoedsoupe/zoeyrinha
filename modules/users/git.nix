{
  pkgs,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption types mkOption mkIf;
  cfg = custom-config.git;
in {
  options.git = {
    enable = mkEnableOption "Enables git home manager module";
    user = {
      name = mkOption {
        description = "Defines git user name";
        type = types.str;
        default = "Zoey de Souza Pessanha";
      };
      email = mkOption {
        description = "Defines git user email";
        type = types.str;
      };
    };
    signing = {
      key = mkOption {
        description = "Git GPG default signing key";
        type = types.nullOr types.str;
      };
      signByDefault = mkOption {
        description = "When to sign by default in git repositories";
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      inherit (cfg) enable;
      userName = cfg.user.name;
      userEmail = cfg.user.email;
      ignores = [
        "*.swp"
        "*.swo"
        ".nix-*"
        ".postgres"
        ".direnv"
        ".lexical"
        ".elixir-tools"
        ".envrc"
      ];
      lfs.enable = true;
      difftastic.enable = true;
      signing = {
        inherit (cfg.signing) key signByDefault;
      };
      includes = [
        {
          condition = "gitdir:~/dev/cloudwalk";
          contents = {
            signing = {};
            gpg.format = "ssh";
            user = {
              email = "zoey.spessanha@cloudwalk.io";
              name = "zoeypessanha";
              signingKey = "~/.ssh/cw-sign";
            };
          };
        }
      ];
      extraConfig = {
        gpg.format = "ssh";
        tag.gpgsign = true;
        commit.gpgsign = true;
        branch.sort = "-committerdate";
        column.ui = "auto";
        safe = {directory = "/opt/homebrew";};
        github = {user = "zoedsoupe";};
        grep = {linenumber = true;};
        merge = {log = true;};
        rebase = {autosquash = true;};
        fetch = {prune = true;};
        push = {default = "current";};
        apply = {whitespace = "nowarn";};
        help = {autocorrect = 0;};
        user = {username = "zoedsoupe";};
        init = {defaultBranch = "main";};
        pull = {rebase = false;};
        url = {
          "git@github.com" = {
            insteadOf = "git://github.com/";
          };
        };
        commit = {
          template = builtins.toString ./misc/gitmessage;
        };
        log = {
          follow = true;
          abbrevCommit = true;
        };
        core = {
          editor = "${pkgs.helix}/bin/hx";
          autocrlf = "input";
          whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        };
        color = {
          grep = "auto";
          branch = "auto";
          diff = "auto";
          status = "auto";
          showbranch = "auto";
          interactive = "auto";
          ui = "auto";
        };
      };
    };
  };
}
