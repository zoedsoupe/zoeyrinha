{
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkOption types mkIf optionalAttrs;
  cfg = custom-config.helix;
in {
  options.helix.editor = {
    disable-line-numbers = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to disable line numbers in the gutter";
    };

    # left off: the key only exists on helix master, so any tagged build in
    # nixpkgs (25.07.1 today) rejects the whole editor table. turn it on only
    # against a master build.
    rainbow-brackets = mkOption {
      type = types.bool;
      default = false;
      description = "Render rainbow colors for matching brackets (helix master only)";
    };
  };

  helix-settings = mkIf cfg.enable {
    theme = "nyxvamp-veil";
    editor =
      {
        scrolloff = 99;
        auto-save.focus-lost = true;
        completion-replace = true;
        cursorline = true;
        color-modes = true;
        true-color = true;
        indent-guides = {
          render = false;
          skip-levels = 1;
          character = "┊";
        };
        soft-wrap = {
          enable = true;
          wrap-at-text-width = true;
        };
        continue-comments = false;
        preview-completion-insert = true;
        line-number = "relative";
        gutters =
          if cfg.editor.disable-line-numbers
          then ["diagnostics" "spacer" "diff"]
          else ["diagnostics" "spacer" "diff" "line-numbers"];
        statusline = {
          separator = "|";
          left = ["mode" "file-name" "file-modification-indicator"];
          center = [];
          right = ["diagnostics" "version-control" "register" "position"];
        };
        whitespace.render = "none";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        lsp = {
          enable = true;
          display-messages = false;
          display-inlay-hints = true;
        };
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "warning";
        };
        end-of-line-diagnostics = "hint";
      }
      // optionalAttrs (cfg.editor.rainbow-brackets or false) {rainbow-brackets = true;};
    keys.normal = {
      esc = ["collapse_selection" "keep_primary_selection"];
      space.e.e = ":pipe-to tmux-pipe %{language}";
    };
  };
}
