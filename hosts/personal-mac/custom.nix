{pkgs, ...}: {
  bat.enable = true;
  direnv.enable = false;
  envoluntary = let
    elixir-only =
      map (p: {
        pattern = ".*/dev/${p}(/.*)?";
        flake_reference = "~/dev/nix#elixir";
      })
      ["taina" "supabase" "oss/peri" "oss/exlings" "oss/proto_rune"];
  in {
    enable = false;
    entries =
      [
        {
          pattern = ".*/dev/oss/lucide_icons(/.*)?";
          flake_reference = "~/dev/nix#elixir-node";
        }
      ]
      ++ elixir-only;
  };
  fzf.enable = true;
  tmux.enable = true;
  ghostty = {
    enable = true;
    font-name = "Berkeley Mono";
  };
  gh.enable = true;
  starship.enable = true;
  xplr.enable = true;
  zoxide.enable = true;
  zed = {
    enable = false;
    theme = {
      dark = "NyxVamp Veil";
      light = "NyxVamp Veil";
    };
    font = "MonoLisa Variable";
  };
  helix = {
    enable = true;
    editor = {
      disable-line-numbers = true;
    };
    languages = {
      clojure.enable = true;
      html = {
        enable = true;
        wakatime.enable = true;
      };
      css = {
        enable = true;
        wakatime.enable = true;
      };
      json = {
        enable = true;
        wakatime.enable = true;
      };
      toml = {
        enable = true;
        wakatime.enable = true;
      };
      rust = {
        enable = true;
        wakatime.enable = true;
      };
      go = {
        enable = true;
        wakatime.enable = true;
      };
      nix = {
        enable = true;
        wakatime.enable = true;
      };
      nim.enable = false;
      zig = {
        enable = true;
        wakatime.enable = true;
      };
      typescript = {
        enable = true;
        wakatime.enable = true;
      };
      gleam.enable = false;
      ocaml.enable = false;
      lua.enable = false;
      python.enable = false;
      elixir = {
        enable = true;
        wakatime.enable = true;
      };
      swift.enable = true;
      dart.enable = true;
    };
  };
  git = {
    enable = true;
    includes = let
      zeetech = path: {
        condition = "gitdir:${path}/";
        contents = {
          user = {
            email = "zoey.spessanha@zeetech.io";
            name = "Zoey Pessanha";
          };
        };
      };

      zeetech-paths = map zeetech ["~/dev/personal" "~/dev/ccuenf" "~/dev/supabase" "~/dev/zeetech" "~/dev/oss" "~/dev/elixiremfoco" "~/dev/taina"];
    in
      zeetech-paths;
  };
  zsh = {
    enable = true;
    profileExtra = ''
      ${pkgs.krabby}/bin/krabby random 2> /dev/null pokemon sprites
      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval "$(atuin init zsh)"
      alias ls='eza'
      alias tree='eza --tree --git-ignore'
      source <(command fx --init)
    '';
    history = {
      ignorePatterns = ["git commit -m *" "git clone *" "mix test --only *" "mkdir *"];
    };
    sessionVariables = {
      GPG_TTY = "$(tty)";
      PATH = "$(dirname $(xcrun --find swift-format 2>/dev/null) 2>/dev/null):/opt/homebrew/lib/ruby/gems/4.0.0/bin:$HOME/dev/.flutter/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/zoedsoupe/bin:/run/current-system/sw/bin:$HOME/google-cloud-sdk/bin:/opt/homebrew/opt/node@22/bin:$HOME/.local/bin:$PATH";
      EDITOR = "${pkgs.helix}/bin/hx";
      LDFLAGS = "-L/opt/homebrew/opt/node@22/lib";
      CPPFLAGS = "-I/opt/homebrew/opt/node@22/include";
    };
  };
}
