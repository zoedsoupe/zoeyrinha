{pkgs, ...}: {
  programs.zsh = let
    fileName = "catppuccin_macchiato-zsh-syntax-highlighting";
    catppuccinThemePath = builtins.readFile (pkgs.fetchFromGitHub
      {
        owner = "catppuccin";
        repo = "zsh-syntax-highlighting";
        rev = "HEAD";
        sha256 = "Q7KmwUd9fblprL55W0Sf4g7lRcemnhjh4/v+TacJSfo=";
      }
      + /themes/${fileName}.zsh);
  in {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    enableVteIntegration = true;
    autocd = true;
    initExtraFirst = catppuccinThemePath;
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      ignorePatterns = ["nu *" "nu-br *"];
    };
    sessionVariables = {
      DOCKER_HOST = "unix:///Users/zoey.pessanha/.docker/run/docker.sock"; # for personal mac, might improve it
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
      PATH = "$PATH:$MONOREPO_ROOT/monocli/bin:/opt/homebrew/bin:/opt/homebrew/opt/openjdk@11/bin:$HOME/.cargo/bin:$HOME/.nix-profile/bin:$NUCLI_HOME:$GO_PATH:$FLUTTER_SDK_HOME/bin:$HOME/dev/nu/.pub-cache/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:/etc/profiles/per-user/zoedsoupe/bin";
    };
    dirHashes = {
      nu = "$HOME/dev/nu";
      nunos-bff = "$HOME/dev/nu/nunos-bff";
      pescarte = "$HOME/dev/pescarte";
      pescarte-api = "$HOME/dev/pescarte/pescarte-api";
      pescarte-plataforma = "$HOME/dev/pescarte/pescarte-plataforma";
      pescarte-ds = "$HOME/dev/pescarte/pescarte-ds";
      zoey = "$HOME/dev/zoey";
      zoeyrinha = "$HOME/dev/zoey/zoeyrinha";
      copper = "$HOME/dev/zoey/copper";
    };
  };
}
