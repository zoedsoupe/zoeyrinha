{
  description = "Zoey's eprsonal config, aka dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    latest.url = "github:nixos/nixpkgs/nixos-unstable";

    nixlib.url = "github:nix-community/nixpkgs.lib";

    # My custom NeoVim config
    copper.url = "github:zoedsoupe/copper";

    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixlib";
  };

  outputs =
    { self
    , nixlib
    , nixpkgs
    , home-manager
    , latest
    , ...
    }@inputs:
    let
      lib = { nixosSystem = nixpkgs.lib.nixosSystem; } // nixlib.lib;
      util = import ./lib {
        inherit system pkgs home-manager lib;
        nixos = nixpkgs;
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
        inherit system lib scripts inputs;
      }) overlays;
    in
    {
      homeManagerConfigurations = {
        zoedsoupe = user.mkHMUser {
          username = "zoedsoupe";
          userConfig = {
            alacritty.enable = true;
            applications.enable = true;
            clipmenu.enable = false;
            direnv.enable = true;
            dunst.enable = false;
            fzf.enable = true;
            vscode.enable = false;
            kitty = {
              enable = true;
              theme = "rose-pine";
            };
            starship.enable = true;
            udiskie.enable = false;
            git = {
              enable = true;
              userName = "Zoey de Souza Pessanha";
              userEmail = "zoey.spessanha@outlook.com";
              lfs.enable = true;
              delta.enable = true;
              ignores = [ "*.swp" "*.swo" ".nix-*" ".postgres" ".direnv" ];
            };
            graphical = {
              enable = true;
              gtk.enable = false;
            };
            fish = {
              enable = true;
              aliases = {
                lg = "lazygit";
                ps = "procs";
                top = "ytop";
                ls = "exa -l";
                cheat = "tldr $argv";
                prettyjson = "python -m json.tool | bat";
                d = "rm -rf $argv";
                please = "sudo $argv";
                "..." = "cd ../../";
              };
            };
          };
        };
      };

      nixosConfigurations = {
        work = host.mkHost {
          name = "work";
          NICs = [ "enp4s0" "wlp0s20f3" ];
          kernelPackage = pkgs.linuxPackages_zen;
          initrdMods = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
          kernelMods = [ "kvm-intel" "iwlwifi" ];
          kernelParams = [
            "vt.default_red=0x4c,0xff,0xa3,0xdb,0x5c,0xb9,0x27,0xff,0x63,0xf9,0x4f,0xdb,0x69,0xb9,0x70,0xff"
            "vt.default_grn=0x4c,0x6c,0xdf,0xee,0xb6,0x81,0xc3,0xff,0x83,0x54,0xda,0xee,0xc3,0x81,0x97,0xff"
            "vt.default_blu=0x4c,0x6c,0x4c,0x77,0x4f,0xf4,0xff,0xff,0xa7,0x6d,0xee,0x77,0x5c,0xf4,0xff,0xff"
            "quiet"
            "splash"
            "udev.log_priority=3"
          ];
          cpuCores = 8;
          users = [{
            name = "zoedsoupe";
            groups = [ "wheel" "networkmanager" "video" "audio" "docker" "libvirtd" ];
            uid = 1000;
            shell = pkgs.zsh;
          }];
          systemConfig = {
            base.enable = true;
            boot = "efi";
            picom.enable = false;
            screen.enable = true;
            security.enable = true;
            virtualisation.enable = true;
            zram.enable = true;
            graphical = {
              xorg.enable = true;
              wayland = {
                desktop-environment = "gnome";
                enable = false;
                swaylock-pam = false;
              };
            };
            connectivity = {
              bluetooth.enable = true;
              sound.enable = true;
              printing.enable = true;
              firewall.enable = true;
              wifi.enable = true;
            };
          };
        };
      };

      installMedia = {
        minimal = host.mkISO {
          name = "nixos";
          kernelPackage = pkgs.linuxPackages_latest;
          initrdMods = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "nvme" "usbhid" ];
          kernelMods = [ "kvm-intel" "iwlwifi" ];
          kernelParams = [ ];
          systemConfig = { };
        };
      };
    };
}
