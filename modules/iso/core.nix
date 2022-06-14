{ pkgs, config, lib, modulesPath, ... }:

{
  system.stateVersion = "21.11";

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    gc = {
      automatic = true;
      options = "--delete-older-than 5d";
    };
    package = pkgs.nixFlakes;
  };

  # Make this config a iso config
  imports = [ "${modulesPath}/installer/cd-dvd/iso-image.nix" ];

  networking.wireless.enable = false;
  networking.networkmanager.enable = true;
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [
    wget
    pciutils
    curl
    bind
    killall
    dmidecode
    neofetch
    bat
    unzip
    file
    zip
    p7zip
    strace
    ltrace
    exa
    silver-searcher
    neovim

    git
    git-crypt

    scripts.setupTools

    gptfdisk
    zsh
    iotop
    nvme-cli
    nix-index
    pstree
    acpi
  ];
}
