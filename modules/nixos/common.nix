{pkgs, ...}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # join the tailnet manually once per host:
  #   tailscale up --login-server=https://hs.<domain>
  # (auth key management deferred until sops-nix lands)
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  users.users.zoedsoupe = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    shell = pkgs.zsh;
    # TODO: paste authorized key(s) here
    openssh.authorizedKeys.keys = [];
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
