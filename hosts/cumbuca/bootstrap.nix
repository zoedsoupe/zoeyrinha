{pkgs, ...}: {
  i18n.defaultLocale = "en_CA.UTF-8";
  console.useXkbConfig = true;
  time.timeZone = "America/Sao_Paulo";

  fonts = {
    packages = with pkgs; [
      font-awesome_4
      material-design-icons
      corefonts
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "Iosevka"
          "JetBrainsMono"
          "Monofur"
        ];
      })
    ];
  };

  programs = {
    dconf.enable = true;
    command-not-found.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "curses";
    };
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  hardware.pulseaudio.enable = false;
  sound.enable = false;

  security = {
    apparmor.enable = true;
    polkit.enable = true;
    rtkit.enable = true;
    sudo = {
      enable = true;
      configFile = ''
        Defaults insults
        Defaults lecture=always
        Defaults lecture_file=${../../modules/users/misc/groot.txt}
      '';
    };
  };

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    trustedUsers = ["zoedsoupe" "@wheel"];
    package = pkgs.nixFlakes;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      min-free = ${toString (1 * 1024 * 1024 * 1024)}
      max-free = ${toString (10 * 1024 * 1024 * 1024)}
      experimental-features = nix-command flakes
    '';
  };

  users = {
    users.root = {
      shell = pkgs.zsh;
      initialPassword = "root";
    };
    users.zoedsoupe = {
      isNormalUser = true;
      shell = pkgs.zsh;
      initialPassword = "nixos";
      extraGroups = [
        "wheel"
        "audio"
        "libvirtd"
        "networkmanager"
        "docker"
      ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  networking.networkmanager.enable = true;

  location = {
    provider = "manual";
    latitude = -21.7629877;
    longitude = -41.296212;
  };

  services = {
    openssh.enable = true;
    blueman.enable = true;
    thermald.enable = true;
    upower.enable = true;
    printing = {
      enable = true;
      drivers = [pkgs.hplipWithPlugin];
    };
    redshift = {
      enable = true;
      brightness = {
        day = "1";
        night = "1";
      };
      temperature = {
        day = 5500;
        night = 3700;
      };
    };
    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "ctrl:swapcaps";
      xkbVariant = "intl";
      libinput = {
        enable = true;
        touchpad = {
          tapping = true;
          disableWhileTyping = true;
          naturalScrolling = true;
        };
      };
      desktopManager.xterm.enable = false;
      updateDbusEnvironment = true;
      serverFlagsSection = ''
        Option "BlankTime" "180"
        Option "StandbyTime" "45"
        Option "SuspendTime" "45"
        Option "OffTime" "180"
      '';
    };
    picom = {
      enable = true;
      inactiveOpacity = 0.8;
      backend = "glx";
      shadow = true;
      shadowOpacity = 0.5;
      shadowOffsets = [(-60) (-25)];
      opacityRules = [
        "90:class_g = 'wezterm'"
      ];
      settings = {
        shadow = {radius = 5;};
        blur = {
          background = true;
          backgroundFrame = true;
          backgroundFixed = true;
          kern = "3x3box";
          strength = 10;
        };
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      media-session.config.bluez-monitor.rules = [
        {
          # Matches all cards
          matches = [{"device.name" = "~bluez_card.*";}];
          actions = {
            "update-props" = {
              "bluez5.reconnect-profiles" = ["hfp_hf" "hsp_hs" "a2dp_sink"];
              # mSBC is not expected to work on all headset + adapter combinations.
              "bluez5.msbc-support" = true;
            };
          };
        }
        {
          matches = [
            # Matches all sources
            {"node.name" = "~bluez_input.*";}
            # Matches all outputs
            {"node.name" = "~bluez_output.*";}
          ];
          actions = {
            "node.pause-on-idle" = false;
          };
        }
      ];
    };
  };
}
