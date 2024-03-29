{
  system,
  pkgs,
  home-manager,
  lib,
  user,
  nixos,
  ...
}:
with builtins; {
  mkISO = {
    name,
    initrdMods,
    kernelMods,
    kernelParams,
    kernelPackage,
    systemConfig,
  }:
    lib.nixosSystem {
      inherit system;

      specialArgs = {};

      modules = [
        "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        {
          imports = [../modules/iso];

          networking.hostName = "${name}";
          networking.networkmanager.enable = true;
          networking.useDHCP = false;

          boot.initrd.availableKernelModules = initrdMods;
          boot.kernelModules = kernelMods;

          boot.kernelParams = kernelParams;
          boot.kernelPackages = kernelPackage;

          nixpkgs.pkgs = pkgs;
        }
      ];
    };

  mkHost = {
    name,
    NICs,
    initrdMods,
    kernelMods,
    kernelParams,
    kernelPackage,
    systemConfig,
    cpuCores,
    users,
    wifi ? [],
    cpuTempSensor ? null,
  }: let
    networkCfg = listToAttrs (map
      (n: {
        name = "${n}";
        value = {useDHCP = true;};
      })
      NICs);

    userCfg = {
      inherit name NICs systemConfig cpuCores cpuTempSensor;
    };

    sys_users = map (u: user.mkSystemUser u) users;

    usernames = map (u: u.name) users;
  in
    lib.nixosSystem {
      inherit system;

      modules = [
        {
          imports = [../modules/system] ++ sys_users;

          zoedsoupe = systemConfig;

          environment.etc = {
            "hmsystemdata.json".text = toJSON userCfg;
          };

          networking.hostName = "${name}";
          networking.interfaces = networkCfg;
          networking.wireless.interfaces = wifi;
          networking.useDHCP = false;
          networking.nameservers = ["8.8.8.8"];

          nixpkgs.config.allowUnfree = true;
          hardware.enableRedistributableFirmware = true;
          hardware.enableAllFirmware = true;
          hardware.cpu.intel.updateMicrocode = true;
          powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

          boot = {
            initrd.availableKernelModules = initrdMods;
            kernelModules = kernelMods;
            kernelParams = kernelParams;
            kernelPackages = kernelPackage;
            consoleLogLevel = 0;
            initrd.verbose = false;
            plymouth.enable = true;
            supportedFilesystems = ["ntfs" "btrfs"];
            cleanTmpDir = true;
            kernel.sysctl = {
              "vm.overcommit_memory" = "1";
              "vm.swappiness" = 100; # if you're using (z)swap and/or zram. if you aren't, you should.
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
            trustedUsers = ["@wheel"] ++ usernames;
            package = pkgs.nixFlakes;
            extraOptions = ''
              keep-outputs = true
              keep-derivations = true
              min-free = ${toString (1 * 1024 * 1024 * 1024)}
              max-free = ${toString (10 * 1024 * 1024 * 1024)}
              experimental-features = nix-command flakes
            '';
          };

          system.stateVersion = "21.05";
        }
      ];
    };
}
