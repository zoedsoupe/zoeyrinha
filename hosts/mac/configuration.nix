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

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    brews = ["asdf"];
  };

  users.users.zoedsoupe = {
    home = "/Users/zoedsoupe";
    name = "zoedsoupe";
    shell = pkgs.zsh;
  };

  users.users.zoeycumbuca = {
    home = "/Users/zoeycumbuca";
    name = "zoeycumbuca";
    shell = pkgs.zsh;
  };
}
