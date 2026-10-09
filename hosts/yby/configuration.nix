{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/services/anytype.nix
    ../../modules/nixos/services/nextcloud.nix
    ../../modules/nixos/services/caddy.nix
  ];

  networking.hostName = "yby";
  # zfs requires a hostid. changing this after first boot re-imports the pool
  # as a new dataset, so generate once: head -c4 /dev/urandom | od -An -tx1 | tr -d ' '
  networking.hostId = "3a5048f5";

  # wired only: yby has no wifi in use, so keep the 802.11 stack from loading.
  # NetworkManager (common.nix) still owns the wired NIC.
  boot.blacklistedKernelModules = ["cfg80211" "mac80211" "iwlwifi"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  # cap ARC at 2GB: default is 50% of RAM and slow to release,
  # which on 8GB with mongodb running is an OOM waiting to happen
  boot.kernelParams = ["zfs.zfs_arc_max=2147483648"];

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  # intel igpu
  hardware.graphics.enable = true;

  system.stateVersion = "26.05";
}
