{ system, pkgs, home-manager, lib, user, ... }:

with builtins;

{
  mkHost = { name, NICs, initrdMods, kernelMods, kernelParams, kernelPackage,
    systemConfig, cpuCores, users, wifi ? [], cpuTempSensor ? null
  }:
  let
    networkCfg = listToAttrs (map (n: {
      name = "${n}";
      value = { useDHCP = true; };
    }) NICs);

    userCfg = {
      inherit name NICs systemConfig cpuCores cpuTempSensor;
    };

    sys_users = (map (u: user.mkSystemUser u) users);

    usernames = map (u: u.username) users;
  in lib.nixosSystem {
    inherit system;

    modules = [
      imports = [ ../modules/system ] ++ sys_users;

      zoedsoupe = systemConfig;

      environment.etc = {
        "hmsystemdata.json".text = toJSON userCfg;
      };

      networking.hostName = "${name}";
      networking.interfaces = networkCfg;
      networking.wireless.interfaces = wifi;

      networking.networkmanager.enable = true;
      networking.useDHCP = false;

      boot = {
        initrd.availableKernelModules = initrdMods;
        kernelModules = kernelMods;
        kernelParams = kernelParams;
        kernelPackages = kernelPackage;
        consoleLogLevel = 0;
        initrd.verbose = false;
        plymouth.enable = true;
        supportedFilesystems = [ "ntfs" "btrfs" ];
        cleanTmpDir = true;
        kernel.sysctl = {
          "vm.overcommit_memory" = "1";
          "vm.swappiness" = 100; # if you're using (z)swap and/or zram. if you aren't, you should.
        };
        loader = {
          timeout = 0;
          grub.enable = true;
          grub.version = 2;
          grub.efiSupport = true;
          grub.device = "nodev"; # or "nodev" for efi only
          grub.splashImage = ./boot_wallpaper.jpg;
          grub.useOSProber = true;
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot/efi";
          };
        };
      };

      nixpkgs.pkgs = pkgs;
      nix = {
        maxJobs = lib.mkDefault cpuCores;
        autoOptimiseStore = true;
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
        trustedUsers = [ "@wheel" ] ++ usernames;
        package = pkgs.nixFlakes;
        extraOptions = ''
          keep-outputs = true
          keep-derivations = true
          min-free = ${toString (1  * 1024*1024*1024)}
          max-free = ${toString (10 * 1024*1024*1024)}
          experimental-features = nix-command flakes
        '';
      };

      system.stateVersion = "21.05";
    ];
  };
}
