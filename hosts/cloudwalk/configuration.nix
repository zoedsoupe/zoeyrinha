{pkgs, ...}: {
  system.stateVersion = 5;

  nix.configureBuildUsers = true;
  nix.optimise.automatic = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  ids.gids.nixbld = 350;

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
    brews = ["ncdu" "colima" "docker" "docker-compose" "docker-Buildx"];
    casks = ["warp"];
  };

  users.users.zoeypessanha = {
    home = "/Users/zoeypessanha";
    name = "zoeypessanha";
    shell = pkgs.zsh;
  };
}
