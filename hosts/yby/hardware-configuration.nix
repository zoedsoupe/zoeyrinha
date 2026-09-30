# PLACEHOLDER: replace with the file generated on the target machine by
#   nixos-generate-config --root /mnt
# during install, then commit the real one.
{...}: {
  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  swapDevices = [];
}
