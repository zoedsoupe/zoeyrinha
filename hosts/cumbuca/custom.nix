{pkgs, ...}: {
  alacritty.enable = false;
  bat.enable = true;
  direnv.enable = true;
  fish.enable = false;
  fzf.enable = true;
  kitty.enable = false;
  gh.enable = true;
  presenterm.enable = true;
  starship.enable = true;
  xplr.enable = true;
  warp.enable = true;
  wezterm.enable = true;
  zellij.enable = true;
  zoxide.enable = true;
  helix = {
    enable = true;
    languages = {
      clojure.enable = false;
      html.enable = false;
      css.enable = true;
      json.enable = true;
      rust.enable = false;
      go.enable = false;
      zig.enable = false;
      nix.enable = true;
      nim.enable = true;
      typescript.enable = true;
      elixir = let
        inherit (pkgs.beam) packagesWith;
        inherit (pkgs.beam.interpreters) erlangR25;
        erlang = packagesWith erlangR25;
        package = erlang.elixir_1_13;
      in {
        inherit package erlang;
        enable = true;
      };
    };
  };
  git = {
    enable = true;
    user = {
      name = "Zoey de Souza Pessanha";
      email = "zoey.pessanha@cumbuca.com";
    };
    signing = {
      key = "D4AAFA7DF2BFE793";
      signByDefault = true;
      gpgPath = "${pkgs.gnupg}/bin/gpg";
    };
  };
  zsh = {
    enable = true;
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
    history = {
      ignorePatterns = ["git commit -m *" "git clone *" "mix test --only *" "mkdir *"];
    };
    theme = {
      enable = true;
      name = "catppuccin";
      flavour = "frappe";
    };
    sessionVariables = {
      GPG_TTY = "$(tty)";
      GITHUB_TOKEN = "";
      PATH = "$PATH:$HOME/.nix-profile/bin:/etc/profiles/per-user/zoeycumbuca/bin:/run/current-system/sw/bin";
      EDITOR = "${pkgs.helix}/bin/hx";
    };
    dirHashes = {
      zoeyrinha = "$HOME/dev/zoeyrinha";
    };
  };
}
