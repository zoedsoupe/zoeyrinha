{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.git;
in {
  options.zoedsoupe.git = {
    enable = mkOption {
      description = "Enable git";
      type = types.bool;
      default = false;
    };

    userName = mkOption {
      description = "Name for git";
      type = types.str;
      default = "";
    };

    userEmail = mkOption {
      description = "Email for git";
      type = types.str;
      default = "";
    };

    lfs.enable = mkOption {
      description = "Enable LFS module";
      type = types.bool;
      default = false;
    };

    delta.enable = mkOption {
      description = "Enable delta diff visualizaton";
      type = types.bool;
      default = false;
    };

    ignores = mkOption {
      description = "List of files to be global ignored";
      type = types.listOf types.str;
      default = [];
    };
  };

  config = mkIf (cfg.enable) {
    programs.git = {
      inherit (cfg) enable userName userEmail ignores;
      lfs.enable = cfg.lfs.enable;
      delta.enable = cfg.delta.enable;
      signing = {
        gpgPath = "${pkgs.gnupg}/bin/gpg2";
        key = "EAA1 51DB 472B 0122 109A  CB17 1E1E 889C DBD6 A315";
        signByDefault = true;
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
        github = { user = "zoedsoupe"; };
        grep = { linenumber = true; };
        merge = { log = true; };
        rebase = { autosquash = true; };
        fetch = { prune = true; };
        push = { default = "current"; };
        apply = { whitespace = "nowarn"; };
        help = { autocorrect = 0; };
        user = { username = "zoedsoupe"; };
        init = { defaultBranch = "main"; };
        pull = { rebase = false; };
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
