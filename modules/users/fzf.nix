{pkgs, ...}: {
  programs.fzf = {
    enable = true;
    enableFishIntegration = false;
    enableZshIntegration = true;
  };
}
