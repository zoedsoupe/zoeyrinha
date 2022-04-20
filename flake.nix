{
  description = "Zoey's eprsonal config, aka dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    latest.url = "github:nixos/nixpkgs/nixos-unstable";

    nixlib.url = "github:nix-community/nixpkgs.lib";

    # My custom NeoVim config
    copper.url = "github:zoedsoupe/copper";

    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixlib";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    { self
    , nixlib
    , nixpkgs
    , latest
    , home-manager
    , flake-utils-plus
    , ...
    }@inputs:
    let
      inherit (nixlib) lib;

      util = import .lib {
        inherit system pkgs home-manager lib;
        overlays = (pkgs.overlays);
      };

      inherit (util) user;
      inherit (util) host;

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      system = "x86_64-linux";

      scripts = import ./scripts {
        inherit pkgs lib;
      };

      inherit (import ./overlays {
        inherit system pkgs lib scripts;
      }) overlays;
    in {
      homeManagerConfigurations = {
        zoedsoupe = user.mkHMUser {
          username = "zoedsoupe";
          userConfig = {
            alacritty.enable = false;
            applications.enable = true;
            clipmenu.enable = true;
            direnv.enable = true;
            dunst.enable = true;
            fish.enable = true;
            fzf.enable = true;
            vscodium.enable = true;
            kitty.enable = true;
            starship.enable = true;
            udiskie = true;
            git = {
              enable = true;
              userName = "Zoey de Souza Pessanha";
              userEmail = "zoey.spessanha@outlook.com";
              lfs.enable = true;
              delta.enable = true;
              ignores = [ "*.swp" "*.swo" ".nix-*" ".postgres" ".direnv" ];
            };
            graphical = {
              wayland = {
                enable = true;
                desktop-environment = "sway";
                background.enable = true;
                statusbar.enable = true;
                screenlock.enable = true;
              };
              xorg = {
                enable = false;
                screenlock.enable = true;
              };
            };
          };
        };
      };

      nixosConfigurations = {
        work = host.mkHost {
          name = "work";
          NICs = [ "enp4s0" "wlp0s20f3" ];
          kernelPackage = pkgs.linuxPackages;
          initrdMods = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
          kernelMods = [ "kvm-intel" ];
          kernelParams = [
            "vt.default_red=0x4c,0xff,0xa3,0xdb,0x5c,0xb9,0x27,0xff,0x63,0xf9,0x4f,0xdb,0x69,0xb9,0x70,0xff"
            "vt.default_grn=0x4c,0x6c,0xdf,0xee,0xb6,0x81,0xc3,0xff,0x83,0x54,0xda,0xee,0xc3,0x81,0x97,0xff"
            "vt.default_blu=0x4c,0x6c,0x4c,0x77,0x4f,0xf4,0xff,0xff,0xa7,0x6d,0xee,0x77,0x5c,0xf4,0xff,0xff"
            "quiet"
            "splash"
            "udev.log_priority=3"
          ];
          systemConfig = {};
          cpuCores = 8;
          users = [{
            name = "zoedsoupe";
            groups = [ "wheel" "networkmanager" "video" "audio" "docker" "libvirtd" ];
            uid = 1000;
            shell = pkgs.fish;
          }];
          systemConfig = {
            base.enable = true;
            boot.enable = true;
            picom.enable = true;
            screen.enable = true;
            security.enable = true;
            virtualisation = true;
            zram = true;
            graphical = {
              xorg.enable = false;
              wayland = {
                enable = true;
                swaylock-pam = true;
              };
            };
            connectivity = {
              networkmanager.enable = true;
              bluetooth.enable = true;
              sound.enable = true;
              printing.enable = true;
              firewall.enable = true;
            };
          };
        };
      };
    };
  }
