{pkgs, ...}: {
  nix.configureBuildUsers = true;

  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '';

  services.nix-daemon.enable = true;

  fonts.fontDir.enable = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  users.users."zoey.pessanha" = {
    home = "/Users/zoey.pessanha";
    name = "zoey.pessanha";
    shell = pkgs.zsh;
  };
}
