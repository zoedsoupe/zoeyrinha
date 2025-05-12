inputs: let
  inherit (builtins) toJSON listToAttrs;
  inherit (inputs) system;
  inherit (inputs) nixpkgs darwin;
  inherit (inputs) home-manager lix-module;
  inherit (inputs.user) mkSystemUser mkDarwinUser;
  inherit (nixpkgs.lib) nixosSystem;
  inherit (darwin.lib) darwinSystem;

  unstable = import inputs.unstable {inherit system;};

  nodejs-overlay = _: _: {
    nodejs = unstable.nodejs_24;
  };

  pkgs = import nixpkgs {
    inherit system;
    overlays = with inputs; [
      rust-overlay.overlays.default
      helix.overlays.default
      nodejs-overlay
    ];
    # ngrok
    config.allowUnfree = true;
  };
in {
  mkDarwin = {
    host ? "personal-mac",
    user ? "zoedsoupe",
  }:
    darwinSystem {
      inherit pkgs;
      modules = [
        (../hosts + /${host}/configuration.nix)
        lix-module.nixosModules.default
        home-manager.darwinModules.home-manager
        (mkDarwinUser {inherit user host;})
      ];
    };

  mkISO = {
    system,
    name,
    initrdMods,
    kernelMods,
    kernelParams,
    kernelPackage,
    systemConfig,
  }:
    nixosSystem {
      inherit system;

      specialArgs = {};

      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ../modules/iso/core.nix
        ../modules/iso/user.nix
        ../modules/iso/desktop.nix
      ];
    };

  mkHost = {
    system,
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
    inherit (nixpkgs.lib) mkDefault;

    networkCfg = listToAttrs (map
      (n: {
        name = "${n}";
        value = {useDHCP = true;};
      })
      NICs);

    userCfg = {
      inherit name NICs systemConfig cpuCores cpuTempSensor;
    };

    sys_users = map (u: mkSystemUser u) users;

    usernames = map (u: u.name) users;
  in
    nixosSystem {
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
          powerManagement.cpuFreqGovernor = mkDefault "powersave";

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
            maxJobs = mkDefault cpuCores;
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
