{
  pkgs,
  lib,
  ...
}: {
  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 60;
  };

  hardware.bluetooth = {
    enable = true;
    setting = {
      General = {
        Name = "zoey-cumbuca";
        DiscoverableTimeout = 0;
        AlwaysPairable = true;
        FasConnectable = true;
      };
      Policy = {
        AutoEnable = true;
        ReconnectAttempts = 5;
        ReconnectIntervals = "1,2,4,8,16";
      };
    };
  };

  environment = {
    variables = {
      EDITOR = "hx";
      TERMINAL = "wezterm";
      GC_INITIAL_HEAP_SIZE = "32M";
    };
    systemPackages = with pkgs; [
      neofetch
      wget
      unzip
      unrar
      iw
      curl
      ncdu
      jq
      git
      gh
      ag

      # audio & video
      mpv
      ffmpeg

      # image
      feh

      # documents
      zathura

      # others
      inotify-tools
    ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    consoleLogLevel = 0;
    initrd.verbose = false;
    plymouth.enable = true;
    cleanTmpDir = true;
    supportedFilesystems = ["ntfs" "btrfs" "ext4"];
    kernel.sysctl = {
      "vm.overcommit_memory" = "1";
      "vm.swappiness" = 100;
    };
    loader = {
      timeout = 0;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        enable = true;
        version = 2;
        efiSupport = true;
        device = "nodev";
        splashImage = ./boot_wallpaper.jpg;
        useOSProber = true;
      };
    };
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome];
  };
}
