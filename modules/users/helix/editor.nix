{
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkOption types mkIf;
  cfg = custom-config.helix;
in {
  options.helix.editor = {
    disable-line-numbers = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to disable line numbers in the gutter";
    };
  };

  helix-settings = mkIf cfg.enable {
    theme = "nyxvamp-veil";
    editor = {
      scrolloff = 99;
      rainbow-brackets = true;
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
    };
    keys.normal = {
      esc = ["collapse_selection" "keep_primary_selection"];
    };
  };
}
