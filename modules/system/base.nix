{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.base;
in {
  options.zoedsoupe.base.enable = mkOption {
    description = "Enable base programs";
    type = types.bool;
    default = false;
  };

  config = mkIf (cfg.enable) {
    environment = {
      variables = {
        EDITOR = "nvim";
        TERMINAL = "kitty";
        GC_INITIAL_HEAP_SIZE = "32M";
      };
      systemPackages = with pkgs; [
        # terminal & tools
        neofetch procs wget
        unzip exa pciutils
        unrar psmisc bat
        cmatrix iw curl
        ncdu lazygit glow
        fd nnn jq tldr
        git alacritty acpi
        ag

        # window manager
        moc pamixer
        screenkey
        wirelesstools
        betterlockscreen

        # editor/ide
        vim neovim

        # browser
        google-chrome

        # dev
        google-cloud-sdk gcc tree-sitter

        # tools
        gparted

        # audio & video
        mpv
        pavucontrol
        ffmpeg

        # image
        feh

        # others
        zathura
        inotify-tools

        # xorg
        xorg.xrandr
        xclip

        # games
        steamcmd

        numix-icon-theme-circle
        numix-cursor-theme
      ];
    };
  };
}
