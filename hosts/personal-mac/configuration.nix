{pkgs, ...}: {
  system.stateVersion = 5;
  system.primaryUser = "zoedsoupe";

  nix.channel.enable = false;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
    persistent = true;
  };
  nix.optimise = {
    automatic = true;
    dates = "daily";
    persistent = true;
  };
  nix.settings.auto-optimise-store = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  ids.gids.nixbld = 30000;

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
    casks = ["ghostty"];
  };

  users.users.zoedsoupe = {
    home = "/Users/zoedsoupe";
    name = "zoedsoupe";
    shell = pkgs.zsh;
  };
}
