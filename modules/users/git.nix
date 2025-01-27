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
    includes = mkOption {
      description = "Apply custom git config depending of the path/folder/conditions";
      type = types.listOf types.attrs;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      inherit (cfg) enable includes;
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
      extraConfig = {
        gpg.format = "ssh";
        gpg.ssh.allowedsignersfile = "~/.config/git/allowed-signers";
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
