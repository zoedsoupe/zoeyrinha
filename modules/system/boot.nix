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
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
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
        device = "/dev/disk/by-uuid/fa9faaf3-53a3-4089-812c-710adc959e4b";
        fsType = "btrfs";
        options = [ "subvol=system" ];
      };

      fileSystems."/boot/efi" =
        {
          device = "/dev/disk/by-uuid/83FB-9CE3";
          fsType = "vfat";
        };

        swapDevices = [];
      };
    }
