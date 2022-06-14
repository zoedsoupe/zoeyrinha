{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.boot;
in
{
  options.zoedsoupe.boot = mkOption {
    description = "Type of boot. Default encrypted-efi";
    default = "efi";
    type = types.enum [ "efi" ];
  };

  config = mkIf (cfg == "efi") {
    boot.loader = {
      timeout = 0;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
        splashImage = ./misc/boot_wallpaper.jpg;
        version = 2;
        extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Power off" {
            halt
          }
        '';
      };
    };

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/30d680e4-5a0e-4a4b-8e6d-afeabe12be09";
        fsType = "btrfs";
        options = [ "subvol=nixos" ];
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-uuid/BF28-A1B6";
        fsType = "vfat";
      };

    swapDevices = [ ];
  };
}

