{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "yby";
  # zfs requires a hostid. changing this after first boot re-imports the pool
  # as a new dataset, so generate once: head -c4 /dev/urandom | od -An -tx1 | tr -d ' '
  networking.hostId = "3a5048f5";

  # wired only: yby has no wifi in use, so keep the 802.11 stack from loading.
  # NetworkManager (common.nix) still owns the wired NIC.
  boot.blacklistedKernelModules = ["cfg80211" "mac80211" "iwlwifi"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = ["zfs"];
  # force the root pool import. after installing from the live env the pool is
  # still marked in-use by the installer (foreign hostid, never exported), so a
  # non-forced import is refused and boot dies in initrd. on a single-node pool
  # this is safe, and yby is headless: a failed boot means attaching a monitor.
  boot.zfs.forceImportRoot = true;
  # cap ARC at 2GB: default is 50% of RAM and slow to release,
  # which on 8GB with mongodb running is an OOM waiting to happen
  boot.kernelParams = ["zfs.zfs_arc_max=2147483648"];

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  # intel igpu; kept headless for jellyfin/qsv transcoding later
  hardware.graphics.enable = true;

  # --- feature flags ---
  # headless for now: SSH/tailnet only, no monitor or keyboard. flip niri on
  # when a screen shows up, and set noctalia.enable in home.nix with it.
  niri.enable = false;
  nextcloud.enable = false;

  anytype.enable = true;

  # git forge: source of truth on the tailnet
  forgejo.enable = true;

  # monitoring: glances web/TUI + an uptime/status page, both behind caddy
  glances.enable = true;
  uptime-kuma.enable = true;

  # self-hosted atproto PDS, published on loopback and fronted by the
  # cloudflare tunnel below
  pesque = {
    enable = true;
    hostname = "pds.zeetech.io";
    mode = "path_multi";
    identity = "plc";
  };

  # one dataset per service: mounted via fileSystems, created on first boot
  zfsDatasets = {
    "zroot/forgejo" = "/var/lib/forgejo";
    "zroot/pesque" = "/var/lib/pesque";
    "zroot/anytype" = "/var/lib/anytype";
    "zroot/uptime-kuma" = "/var/lib/uptime-kuma";
  };

  # tailnet-facing reverse proxy
  caddy = {
    enable = true;
    apps = {
      "git.yby" = "127.0.0.1:3000";
      "dash.yby" = "127.0.0.1:61208";
      "status.yby" = "127.0.0.1:3001";
    };
  };

  # public ingress, tunneled through cloudflare (no inbound port, no home ip).
  # cloudflare terminates tls; the origin is pesque on loopback.
  cloudflared = {
    enable = true;
    apps = {
      "pds.zeetech.io" = "http://localhost:4000";
    };
  };

  system.stateVersion = "26.05";
}
