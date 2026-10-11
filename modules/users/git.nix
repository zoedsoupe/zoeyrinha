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
    programs.difftastic = {inherit (cfg) enable;};

    programs.git = {
      inherit (cfg) enable;
      includes = cfg.includes or [];
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
      settings = {
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
        # signingKey lives here, not per-repo: gpgsign is global above, so a host
        # without it cannot commit at all.
        user = {
          username = "zoedsoupe";
          signingKey = "~/.ssh/personal";
        };
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
          # vim when the host turns helix off, so a bare server does not pull
          # the editor into the closure just for git's EDITOR
          editor =
            if custom-config.helix.enable
            then "${pkgs.helix}/bin/hx"
            else "${pkgs.vim}/bin/vim";
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
