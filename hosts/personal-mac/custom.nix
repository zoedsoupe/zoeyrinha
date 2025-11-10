{pkgs, ...}: {
  alacritty = {
    enable = false;
    font-family = "Dank Mono";
    theme = "catppuccin-macchiato";
  };
  bat.enable = true;
  direnv.enable = true;
  envoluntary = {
    enable = true;
    entries = [
      # === Dashbit Projects ===
      {
        pattern = ".*/dev/dashbit/tidewave_javascript(/.*)?";
        flake_reference = "~/dev/nix/dashbit-node";
      }
      {
        pattern = ".*/dev/dashbit/tidewave_rails(/.*)?";
        flake_reference = "~/dev/nix/dashbit-ruby";
      }
      {
        pattern = ".*/dev/dashbit/tidewave_app(/.*)?";
        flake_reference = "~/dev/nix/dashbit-rust";
      }
      {
        pattern = ".*/dev/dashbit/tidewave_phoenix(/.*)?";
        flake_reference = "~/dev/nix/dashbit-elixir";
      }
      {
        pattern = ".*/dev/dashbit/tidewave_server(/.*)?";
        flake_reference = "~/dev/nix/dashbit-fullstack";
      }

      # === Supabase Projects (Elixir + PostgreSQL) ===
      {
        pattern = ".*/dev/supabase/.*";
        flake_reference = "~/dev/nix/supabase-elixir";
      }

      # === Taina Project (Elixir + PostgreSQL) ===
      {
        pattern = ".*/dev/taina/.*";
        flake_reference = "~/dev/nix/supabase-elixir";
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
    ];
  };
  fish.enable = false;
  fzf.enable = true;
  kitty = {
    enable = false;
    font-family = "Dank Mono";
    theme = "catppuccin-macchiato";
  };
  tmux.enable = true;
  ghostty = {
    enable = true;
    font-name = "MonaLisa";
  };
  gh.enable = true;
  starship = {
    enable = true;
    catppuccin-theme = "macchiato";
  };
  xplr.enable = true;
  wezterm.enable = false;
  zellij.enable = false;
  zoxide.enable = true;
  zed = {
    enable = true;
    theme = {
      dark = "NyxVamp Veil";
      light = "NyxVamp Radiance";
    };
    font = "MonoLisa";
  };
  helix = {
    enable = true;
    editor = {
      disable-line-numbers = true;
    };
    languages = {
      clojure.enable = false;
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
        lsp.enable = true;
        lsp.name = "expert-lsp";
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
            signingKey = "~/.ssh/personal";
          };
        };
      };

      zeetech-paths = map zeetech ["~/dev/personal" "~/dev/ccuenf" "~/dev/supabase" "~/dev/zeetech" "~/dev/oss" "~/dev/elixiremfoco" "~/dev/taina"];
    in
      [
        {
          condition = "gitdir:~/dev/dashbit/";
          contents = {
            user = {
              email = "zoey.spessanha@dashbit.co";
              name = "zoedsoupe";
              signingKey = "~/.ssh/dashbit";
            };
          };
        }
      ]
      ++ zeetech-paths;
  };
  zsh = {
    enable = true;
    # ${pkgs.krabby}/bin/krabby random 2> /dev/null pokemon sprites
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      alias ls='eza'
      alias tree='eza --tree --git-ignore'
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
      PATH = "$HOME/.nix-profile/bin:/etc/profiles/per-user/zoedsoupe/bin:/run/current-system/sw/bin:$HOME/google-cloud-sdk/bin:/opt/homebrew/opt/node@22/bin:$HOME/.local/bin:$PATH";
      EDITOR = "${pkgs.helix}/bin/hx";
      LDFLAGS = "-L/opt/homebrew/opt/node@22/lib";
      CPPFLAGS = "-I/opt/homebrew/opt/node@22/include";
    };
  };
}
