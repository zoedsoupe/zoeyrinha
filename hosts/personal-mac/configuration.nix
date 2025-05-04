{pkgs, ...}: {
  system.stateVersion = 5;

  nix.configureBuildUsers = true;
  nix.optimise.automatic = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  fonts.packages = with pkgs; [scientifica];

  ids.gids.nixbld = 30000;

  services.nix-daemon.enable = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    brews = ["ncdu"];
    casks = ["warp"];
  };

  users.users.zoedsoupe = {
    home = "/Users/zoedsoupe";
    name = "zoedsoupe";
    shell = pkgs.zsh;
  };
}
