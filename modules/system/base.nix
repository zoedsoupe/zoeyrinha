{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.base;
in
{
  options.zoedsoupe.base.enable = mkOption {
    description = "Enable base programs";
    type = types.bool;
    default = false;
  };

  config = mkIf (cfg.enable) {
    i18n.defaultLocale = "en_CA.UTF-8";
    console.useXkbConfig = true;
    time.timeZone = "America/Sao_Paulo";

    location = {
      provider = "manual";
      latitude = -21.7629877;
      longitude = -41.296212;
    };

    fonts.fonts = with pkgs; [
      cantarell-fonts
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

    programs = {
      steam.enable = true;
      command-not-found.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryFlavor = "curses";
      };
    };

    services = {
      fstrim = {
        enable = true;
        interval = "weekly";
      };

      logind = {
        extraConfig = ''
          LidSwitchIgnoreInhibited=no
        '';
        #lidSwitch = "ignore";
      };

      # see https://github.com/NixOS/nixpkgs/issues/30336
      flatpak.enable = true;

      openssh.enable = true;

      upower.enable = true;

      dbus.enable = true;

      openvpn.servers = {
        solfacilVPN = {
          autoStart = false;
          config = "config /etc/openvpn/config.ovpn";
        };
      };

      getty.helpLine = ''
        [0;34;40m ███    ██ ██ ██   ██  ██████  ███████ 
        [0;34;40m ████   ██ ██  ██ ██  ██    ██ ██      
        [0;34;40m ██ ██  ██ ██   ███   ██    ██ ███████ 
        [0;34;40m ██  ██ ██ ██  ██ ██  ██    ██      ██ 
        [0;34;40m ██   ████ ██ ██   ██  ██████  ███████ 
        [0;37;40m
      '';
    };

    environment = {
      variables = {
        EDITOR = "nvim";
        TERMINAL = "kitty";
        GC_INITIAL_HEAP_SIZE = "32M";
        CM_LAUNCHER = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop";
      };
      systemPackages = with pkgs; [
        # terminal & tools
        neofetch
        procs
        wget
        unzip
        exa
        pciutils
        unrar
        psmisc
        bat
        cmatrix
        iw
        curl
        ncdu
        lazygit
        glow
        fd
        nnn
        jq
        tldr
        git
        acpi
        silver-searcher

        # window manager
        # moc
        pamixer
        screenkey
        # wirelesstools
        # betterlockscreen

        # editor
        vim

        # tools
        gparted

        # games
        steamcmd

        numix-icon-theme-circle
        numix-cursor-theme
      ];
    };
  };
}
