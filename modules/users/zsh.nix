{
  pkgs,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = custom-config.zsh;
in {
  options.zsh = {
    enable = mkEnableOption "Enables ZSH config";
    sessionVariables = mkOption {
      description = "Set up environment variables";
      type = types.nullOr types.attr;
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
      '';
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      enableVteIntegration = true;
      autocd = true;
      oh-my-zsh = {
        enable = true;
      };
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
      };
    };
  };
}
