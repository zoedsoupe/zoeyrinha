# PLACEHOLDER: replace with the vps's real hardware config
# (nixos-generate-config, or the one from nixos-anywhere on first provision)
{...}: {
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [];
}
