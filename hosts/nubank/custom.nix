{pkgs, ...}: {
  git = {
    enable = true;
    user = {
      name = "Zoey Pessanha";
      email = "zoey.pessanha@nubank.com.br";
    };
    signing = {
      key = "A227728F4E3B4365";
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
    history = {
      ignorePatterns = ["nu *" "nu-br *"];
    };
    sessionVariables = {
      DOCKER_HOST = "unix:///Users/zoey.pessanha/.docker/run/docker.sock";
      NODE_OPTIONS = "--openssl-legacy-provider";
      GPG_TTY = "$(tty)";
      NU_COUNTRY = "br";
      NU_HOME = "$HOME/dev/nu";
      NUCLI_HOME = "$HOME/dev/nu/nucli";
      GOPATH = "$HOME/go";
      GITHUB_TOKEN = "";
      MONOREPO_ROOT = "$HOME/dev/nu/mini-meta-repo";
      FLUTTER_SDK_HOME = "$HOME/sdk-flutter";
      FLUTTER_ROOT = "$HOME/sdk-flutter";
      JAVA_HOME = "$(/usr/libexec/java_home -v 11.0)";
      CPPFLAGS = "-I/opt/homebrew/opt/openjdk@11/include";
      PATH = "$PATH:$MONOREPO_ROOT/monocli/bin:/opt/homebrew/bin:/opt/homebrew/opt/openjdk@11/bin:$HOME/.cargo/bin:$NUCLI_HOME:$GO_PATH:$FLUTTER_SDK_HOME/bin:$HOME/dev/nu/.pub-cache/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:/etc/profiles/per-user/zoey.pessanha/bin:/nix/var/nix/profiles/default/bin";
    };
    dirHashes = {
      metarepo = "$HOME/dev/nu/mini-meta-repo";
      zoeyrinha = "$HOME/dev/zoeyrinha";
    };
  };
}
