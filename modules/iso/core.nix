{
  pkgs,
  lib,
  modulesPath,
  ...
}: {
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
  imports = ["${modulesPath}/installer/cd-dvd/iso-image.nix"];

  networking.hostName = "nixos";
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "sd_mod" "nvme" "usbhid"];
  boot.kernelModules = ["kvm-intel" "iwlwifi"];
  boot.kernelParams = [];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [
    wget
    pciutils
    httpie
    bind
    killall
    neofetch
    bat
    unzip
    file
    zip
    eza
    silver-searcher
    git
    gptfdisk
    nvme-cli
    nix-index
    acpi
  ];
}
