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
        set -g default-terminal "tmux-256color"
        set -ag terminal-overrides ",xterm-256color:RGB"
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

        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'y' send -X copy-selection

        unbind -T copy-mode-vi MouseDragEnd1Pane

        # auto-rename windows: dir basename if shell, else running command
        set -g automatic-rename on
        set -g automatic-rename-format '#{?#{==:#{pane_current_command},zsh},#{b:pane_current_path},#{pane_current_command}}'
        set -g allow-rename on
        set -g status-interval 5
        set -g base-index 1
        setw -g pane-base-index 1
        set -g renumber-windows on

        # nyxvamp - veil palette (local port)
        # bg #1E1E2E  fg #D9E0EE  surface #2E2E3E  inactive-bg #1E1E2E
        # pink #F28FAD  rose #F5C2E7  blue #96CDFB  green #ABE9B3
        # cyan #8BD5CA  peach #F8BD96  lavender #C9CBFF  comment #6E6A86
        set -g status on
        set -g status-position bottom
        set -g status-justify left
        set -g status-style "fg=#D9E0EE,bg=#2E2E3E"
        set -g status-left-length 40
        set -g status-right-length 80

        set -g status-left "#[fg=#1E1E2E,bg=#F28FAD,bold] #S #[fg=#F28FAD,bg=#2E2E3E,nobold] "
        set -g status-right "#[fg=#C9CBFF,bg=#2E2E3E] #{tmux_mode_indicator} #[fg=#96CDFB]%H:%M #[fg=#6E6A86]· #[fg=#F5C2E7]%Y-%m-%d "

        set -g window-status-separator ""
        set -g window-status-format "#[fg=#6E6A86,bg=#2E2E3E] #I #[fg=#D9E0EE]#W "
        set -g window-status-current-format "#[fg=#2E2E3E,bg=#F5C2E7]#[fg=#1E1E2E,bg=#F5C2E7,bold] #I #W #[fg=#F5C2E7,bg=#2E2E3E,nobold]"
        set -g window-status-activity-style "fg=#F8BD96,bg=#2E2E3E"
        set -g window-status-bell-style "fg=#F28FAD,bg=#2E2E3E,bold"

        set -g pane-border-style "fg=#6E6A86"
        set -g pane-active-border-style "fg=#F28FAD"

        set -g message-style "fg=#D9E0EE,bg=#2E2E3E"
        set -g message-command-style "fg=#F5C2E7,bg=#2E2E3E"

        set -g mode-style "fg=#1E1E2E,bg=#F5C2E7,bold"
        set -g clock-mode-colour "#F28FAD"

        set -g @mode_indicator_prefix_prompt " WAIT "
        set -g @mode_indicator_prefix_mode_style "bg=#F28FAD,fg=#1E1E2E,bold"
        set -g @mode_indicator_copy_prompt " COPY "
        set -g @mode_indicator_copy_mode_style "bg=#ABE9B3,fg=#1E1E2E,bold"
        set -g @mode_indicator_sync_prompt " SYNC "
        set -g @mode_indicator_sync_mode_style "bg=#F8BD96,fg=#1E1E2E,bold"
        set -g @mode_indicator_empty_prompt " TMUX "
        set -g @mode_indicator_empty_mode_style "bg=#96CDFB,fg=#1E1E2E,bold"
      '';
      plugins = with plugins; [
        yank
        sensible
        vim-tmux-navigator
        {
          plugin = continuum;
          extraConfig = "set -g @continuum-restore 'on'";
        }
        {
          plugin = resurrect;
          extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
        }
        mode-indicator
      ];
    };
  };
}
