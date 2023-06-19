{pkgs, ...}: {
  git = {
    enable = true;
    user = {
      name = "Zoey de Souza Pessanha";
      email = "zoey.spessanha@gmail.com";
    };
    signing = {
      key = "80973361457F1AA6";
      signByDefault = true;
      gpgPath = "${pkgs.gnupg}/bin/gpg";
    };
  };
  zsh = {
    enable = true;
    theme = {
      enable = true;
      name = "catppuccin";
      flavour = "frappe";
    };
    sessionVariables = {
      GPG_TTY = "$(tty)";
      GITHUB_TOKEN = "";
      PATH = "$PATH:$HOME/.nix-profile/bin:/etc/profiles/per-user/zoedsoupe/bin";
    };
    dirHashes = {
      zoeyrinha = "$HOME/dev/personal/zoeyrinha";
      lvim = "$HOME/dev/personal/lvim";
      pescarte = "$HOME/dev/pescarte/pescarte-plataforma";
    };
  };
}
