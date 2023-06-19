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
      gpgPath = mkOption {
        description = "The GPG executable path";
        type = types.str;
        default = "${pkgs.gnupg}/bin/gpg";
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
      ignores = ["*.swp" "*.swo" ".nix-*" ".postgres" ".direnv"];
      lfs.enable = true;
      delta.enable = true;
      signing = {
        key = cfg.signing.key;
        gpgPath = cfg.signing.gpgPath;
        signByDefault = cfg.signing.signByDefault;
      };
      aliases = {
        p = "push";
        s = "status";
        c = "commit";
        co = "checkout";
        aa = "add -p";
        st = "stash";
        br = "branch";
        lg = "log --graph --oneline --decorate --abbrev-commit";
      };
      extraConfig = {
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
          editor = "nvim";
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
