{
  pkgs,
  unstable,
  ...
}: {
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
  wezterm.enable = false;
  zellij.enable = false;
  zoxide.enable = true;
  zed = {
    enable = true;
    elixir = let
      inherit (unstable.beam) packagesWith;
      inherit (unstable.beam.interpreters) erlang_27;
      erlang = packagesWith erlang_27;
      package = erlang.elixir_1_17;
    in {
      inherit package erlang;
      lsp = "lexical";
    };
  };
  helix = {
    enable = true;
    languages = {
      clojure.enable = false;
      html.enable = true;
      css.enable = true;
      json.enable = true;
      rust.enable = true;
      go.enable = true;
      nix.enable = true;
      nim.enable = false;
      zig.enable = false;
      typescript.enable = false;
      elixir.enable = true;
    };
  };
  git = {
    enable = true;
    user = {
      name = "Zoey de Souza Pessanha";
      email = "zoey.spessanha@zeetech.io";
    };
    signing = {
      key = "0A26DE75F59B488C74D4FA408536E6F53A918170";
      signByDefault = true;
      gpgPath = "${pkgs.gnupg}/bin/gpg";
    };
  };
  zsh = {
    enable = true;
    profileExtra = ''
      echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> $${ZDOTDIR:-~}/.zshrc
      eval "$(/opt/homebrew/bin/brew shellenv)"
      ${pkgs.pokemon-colorscripts-mac}/bin/pokemon-colorscripts -r
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
      DIRENV_LOG_FORMAT = "";
      GPG_TTY = "$(tty)";
      GITHUB_TOKEN = "";
      PATH = "$PATH:$HOME/.nix-profile/bin:/etc/profiles/per-user/zoedsoupe/bin:/run/current-system/sw/bin";
      EDITOR = "${pkgs.helix}/bin/hx";
    };
  };
}
