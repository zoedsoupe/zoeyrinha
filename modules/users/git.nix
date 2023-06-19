{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Zoey de Souza Pessanha";
    userEmail = "zoey.spessanha@gmail.com";
    ignores = ["*.swp" "*.swo" ".nix-*" ".postgres" ".direnv"];
    lfs.enable = true;
    delta.enable = true;
    signing = {
      key = null;
      gpgPath = "${pkgs.gnupg}/bin/gpg";
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
}
