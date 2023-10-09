{pkgs, ...}: {
  config = {
    programs.zellij = {
      enable = true;
      enableZshIntegration = false;
      settings = {
        default_shell = "${pkgs.zsh}/bin/zsh";
        scrollback_editor = "${pkgs.helix}/bin/hx";
        ui.pane_frames.rounded_corners = true;
      };
    };
  };
}
