{
  pkgs,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = custom-config.zsh;

  # tmux + hx are on every host; whisper-cli only ships on darwin (whisper-cpp
  # in hosts/personal-mac/home.nix), so transcribe is darwin-only.
  transcribe = lib.optionalString pkgs.stdenv.isDarwin ''
    # transcribe [dir?] [lang?] -> all.txt from every *.opus in dir (default: cwd, auto lang)
    # examples:
    #   transcribe                 # *.opus in cwd
    #   transcribe ~/Downloads/audios pt
    transcribe() {
      local dir="''${1:-.}"
      local lang="''${2:-auto}"
      local model="$HOME/.local/share/whisper/ggml-base.bin"
      local out="$dir/all.txt"
      [[ -e "$out" ]] && rm "$out"
      local f
      for f in "$dir"/*.opus(N); do
        ffmpeg -y -i "$f" -ar 16000 -ac 1 -c:a pcm_s16le /tmp/w.wav -loglevel error
        whisper-cli -m "$model" -l "$lang" -f /tmp/w.wav -nt -otxt -of /tmp/w
        cat /tmp/w.txt >> "$out"
      done
    }
  '';
in {
  options.zsh = {
    enable = mkEnableOption "Enables ZSH config";
    sessionVariables = mkOption {
      description = "Set up environment variables";
      type = types.nullOr types.attrs;
    };
    profileExtra = mkOption {
      description = "Extra config to go on .zprofile";
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      inherit (cfg) enable sessionVariables profileExtra;
      initContent = ''
        PROMPT="$\{PROMPT\}"$'\n'
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin

        # dev <name?> <repl?> [extra-args...]  -> tmux session: editor + repl window (3 panes)
        # repl: iex (default) | clj | mix | shell | <raw command>
        # examples:
        #   dev                       # iex -S mix in $(basename PWD)
        #   dev myproj clj            # plain clj
        #   dev myproj clj -M:test    # clj -M:test
        #   dev . mix phx.server      # mix phx.server
        dev() {
          local name="''${1:-$(basename "$PWD" | tr '.' '-')}"
          local kind="''${2:-iex}"
          shift 2 2>/dev/null || shift $#
          local cmd
          case "$kind" in
            iex)   cmd="iex -S mix ''${*}" ;;
            clj)   cmd="clj ''${*}" ;;
            mix)   cmd="mix ''${*}" ;;
            shell) cmd="$SHELL" ;;
            *)     cmd="$kind ''${*}" ;;
          esac

          if tmux has-session -t "$name" 2>/dev/null; then
            tmux attach -t "$name"
            return
          fi

          tmux new-session  -d -s "$name" -c "$PWD" -n editor "hx ."
          tmux new-window   -t "$name:" -c "$PWD" -n repl "$cmd"
          tmux split-window -t "$name:repl" -h -c "$PWD"
          tmux split-window -t "$name:repl.2" -v -c "$PWD"
          tmux select-pane  -t "$name:repl.1"
          tmux select-window -t "$name:editor"

          if [[ -z "$TMUX" ]]; then
            tmux attach -t "$name"
          else
            tmux switch-client -t "$name"
          fi
        }
      ''
      + transcribe;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      enableVteIntegration = true;
      autocd = true;
      oh-my-zsh = {
        enable = true;
      };
      # nyxvamp-veil, matching the starship/ghostty/helix palettes. the old
      # catppuccin zsh theme conflicted with those; `theme` in custom.nix is gone.
      antidote = {
        enable = true;
        plugins = [
          "nyxvamp-theme/zsh path:nyxvamp-veil.zsh"
        ];
      };
      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreAllDups = true;
        ignoreDups = true;
        ignoreSpace = true;
      }
      // (cfg.history or {});
    };
  };
}