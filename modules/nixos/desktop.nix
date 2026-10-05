{pkgs, ...}: {
  programs.niri.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
      user = "greeter";
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  fonts.packages = with pkgs; [
    maple-mono.NF
    monaspace
    nerd-fonts.symbols-only
  ];

  # ghostty comes from home-manager (modules/users/ghostty.nix);
  # wl-clipboard is in hosts/yby/home.nix. xwayland-satellite gives niri X11
  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
}
