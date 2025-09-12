{pkgs, ...}: {
  system.stateVersion = 5;
  system.primaryUser = "zoedsoupe";

  nix.enable = false;

  ids.gids.nixbld = 350;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    brews = [];
    casks = ["ghostty" "claude-code"];
  };

  users.users.zoedsoupe = {
    home = "/Users/zoedsoupe";
    name = "zoedsoupe";
    shell = pkgs.zsh;
  };
}
