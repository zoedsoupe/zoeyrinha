{pkgs, ...}: {
  bat.enable = true;
  direnv.enable = true;
  envoluntary = {
    enable = true;
    entries = [
      # === Supabase Projects (Elixir + PostgreSQL) ===
      {
        pattern = ".*/dev/supabase/.*";
        flake_reference = "~/dev/nix/supabase-elixir";
      }

      # === Taina Project (Elixir + PostgreSQL) ===
      {
        pattern = ".*/dev/taina/.*";
        flake_reference = "~/dev/nix/taina";
      }

      # === OSS Elixir Projects ===
      {
        pattern = ".*/dev/oss/nexus(/.*)?";
        flake_reference = "~/dev/nix/oss-elixir";
      }
      {
        pattern = ".*/dev/oss/soundscape(/.*)?";
        flake_reference = "~/dev/nix/oss-elixir";
      }
      {
        pattern = ".*/dev/oss/peri(/.*)?";
        flake_reference = "~/dev/nix/oss-elixir";
      }
      {
        pattern = ".*/dev/oss/exlings(/.*)?";
        flake_reference = "~/dev/nix/oss-elixir";
      }
      {
        pattern = ".*/dev/oss/proto_rune(/.*)?";
        flake_reference = "~/dev/nix/oss-elixir";
      }

      # === Elixir + Node Projects ===
      {
        pattern = ".*/dev/oss/lucide_icons(/.*)?";
        flake_reference = "~/dev/nix/elixir-node";
      }

      # === Zig Projects ===
      {
        pattern = ".*/dev/personal/slimes(/.*)?";
        flake_reference = "~/dev/nix/zig";
      }
      {
        pattern = ".*/dev/personal/ziglings(/.*)?";
        flake_reference = "~/dev/nix/zig";
      }
      {
        pattern = ".*/dev/personal/morpho(/.*)?";
        flake_reference = "~/dev/nix/zig";
      }
    ];
  };
  fzf.enable = true;
  tmux.enable = true;
  ghostty = {
    enable = true;
    font-name = "Maple Mono NF Regular";
  };
  gh.enable = true;
  starship.enable = true;
  xplr.enable = true;
  zoxide.enable = true;
  zed = {
    enable = true;
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
    # ${pkgs.krabby}/bin/krabby random 2> /dev/null pokemon sprites
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      alias ls='eza'
      alias tree='eza --tree --git-ignore'
      source <(command fx --init)
    '';
    history = {
      ignorePatterns = ["git commit -m *" "git clone *" "mix test --only *" "mkdir *"];
    };
    sessionVariables = {
      DIRENV_LOG_FORMAT = "";
      GPG_TTY = "$(tty)";
      GITHUB_TOKEN = "";
      PATH = "$HOME/.nix-profile/bin:/etc/profiles/per-user/zoedsoupe/bin:/run/current-system/sw/bin:$HOME/google-cloud-sdk/bin:/opt/homebrew/opt/node@22/bin:$HOME/.local/bin:$PATH";
      EDITOR = "${pkgs.helix}/bin/hx";
      LDFLAGS = "-L/opt/homebrew/opt/node@22/lib";
      CPPFLAGS = "-I/opt/homebrew/opt/node@22/include";
    };
  };
}
