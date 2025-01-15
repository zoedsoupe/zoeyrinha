{
  pkgs,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.tmux;
  plugins = pkgs.tmuxPlugins;
in {
  options.tmux.enable = mkEnableOption "Enables tmux";

  config = mkIf cfg.enable {
    programs.tmux = {
      inherit (cfg) enable;
      mouse = true;
      keyMode = "vi";
      newSession = true;
      disableConfirmationPrompt = true;
      aggressiveResize = true;
      escapeTime = 10;
      extraConfig = ''
        set -g default-shell /bin/zsh
        set -g mouse on

        unbind C-b
        set -g prefix C-Space
        bind-key C-Space send-prefix

        unbind %
        bind | split-window -h
        bind | split-window -h -c "#{pane_current_path}"

        unbind '"'
        bind - split-window -v
        bind - split-window -v -c "#{pane_current_path}"

        unbind r
        bind r source-file ~/.tmux.conf

        bind j resize-pane -D 5
        bind k resize-pane -U 5
        bind l resize-pane -R 5
        bind h resize-pane -L 5

        bind -r m resize-pane -Z

        bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
        bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"

        unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode when dragging with mouse
      '';
      plugins = with plugins; [
        yank
        sensible
        vim-tmux-navigator
        {
          plugin = catppuccin;
          extraConfig = "set -g @catppuccin_flavor 'mocha'";
        }
        {
          plugin = continuum;
          extraConfig = "set -g @continuum-restore 'on'";
        }
        {
          plugin = resurrect;
          extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
        }
        {
          plugin = mode-indicator;
          extraConfig = "set -g status-right '#{tmux_mode_indicator}'";
        }
      ];
    };
  };
}
