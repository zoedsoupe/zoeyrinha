{
  pkgs,
  lib,
  ...
}: {
  # ssh clients running ghostty/kitty/alacritty/... set TERM to their own name;
  # without the matching terminfo the login shell spams "can't find terminal
  # definition for xterm-ghostty". installs terminfo for the common terminals.
  environment.enableAllTerminfo = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # default, not forced: a host with a static ip (eveo) opts out and drives
  # the nic with systemd-networkd instead
  networking.networkmanager.enable = lib.mkDefault true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # join the tailnet manually once per host, against our own headscale (eveo):
  #   tailscale up --login-server=https://hs.zeetech.io
  # then approve the node on eveo:
  #   headscale users create zoey
  #   headscale nodes register --user zoey --key <nodekey>
  # (declarative auth keys deferred until sops-nix lands; extraUpFlags only
  #  takes effect alongside services.tailscale.authKeyFile)
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  users.users.zoedsoupe = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeJxOV+YaD2ILOGT9PAiJ2qEXD6jNGPFOGSj2pYA7Dh zoey.spessanha@zeetech.io"
    ];
  };

  programs.zsh.enable = true;

  # only what root needs before home-manager lands;
  # user tools (helix, git, eza...) come from modules/users + home.nix
  environment.systemPackages = with pkgs; [
    git
    wget
    htop
  ];
}
