{
  pkgs,
  inputs,
  lib,
  ...
}: let
  # builds each app's release from its source (see lib/mkRelease.nix)
  mkRelease = pkgs.callPackage ../../lib/mkRelease.nix {};
in {
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
  # the bulk-data pool lives on the sda disk, zroot on the nvme. without this
  # only zroot is guaranteed to import at boot, so zdata's datasets never mount
  # and the host drops into emergency mode.
  boot.zfs.extraPools = ["zdata"];
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
  uptime-kuma.enable = false;

  # self-hosted atproto PDS: a plain systemd service built from the release in
  # the pesque flake (no container runtime), published on loopback and fronted
  # by the cloudflare tunnel below
  services.pesque = {
    enable = true;
    hostname = "pds.zeetech.io";
    mode = "path_multi";
    identity = "plc";

    # whole server state (sqlite, keys, blobs) on the sda pool, not the nvme
    dataDir = "/zdata/pesque";
  };

  # one Postgres for the whole host; each service gets a database and a role in
  # this cluster, never its own instance. taina lands here later.
  postgres = {
    enable = true;
    databases = ["quintal"];
    users = [
      {
        name = "quintal";
        ensureDBOwnership = true;
      }
    ];
  };

  # quintal connects over loopback TCP; its role is let in without a password
  # (loopback only, single host). everything else stays on the peer/md5 default.
  services.postgresql.authentication = lib.mkBefore ''
    host all quintal 127.0.0.1/32 trust
    host all quintal ::1/128 trust
  '';

  # personal Phoenix apps, built from source by lib/mkRelease.nix and fronted by
  # the cloudflare tunnel below. Secrets live in /etc/phoenix/<name>.env (see the
  # README), never in the store.
  phoenixApps = {
    zoeyrinha-web = {
      enable = true;
      package = mkRelease {
        pname = "zoeyrinha-web";
        version = "0.1.0";
        src = inputs.zoeyrinha-web;
        mixHash = "sha256-9PPLaKDiSMSjcBGwE8jp56kh06VpRe7SR/SPob5bYCk=";
        rustler = true;
        tailwind = pkgs.tailwindcss_4;
      };
      host = "zoedsoupe.zeetech.io";
      port = 4010;
      environmentFiles = ["/etc/phoenix/zoeyrinha-web.env"];
    };

    palpite = {
      enable = true;
      package = mkRelease {
        pname = "palpite";
        version = "0.1.0";
        src = inputs.palpite;
        mixHash = "sha256-aJ3Qh3hUinW8y+zP0tVgVeTLp20ZXluYrAv2w5SESJY=";
      };
      host = "palpite.zeetech.io";
      port = 4011;
      stateDir = "/zdata/palpite";
      environment.DATABASE_PATH = "/zdata/palpite/palpite.db";
      environmentFiles = ["/etc/phoenix/palpite.env"];
    };

    paintbox = {
      enable = true;
      package = mkRelease {
        pname = "paintbox";
        version = "0.1.0";
        src = inputs.paintbox;
        mixHash = "sha256-LE21sKdjAXoi4KjPtPmU9dbHeqClmf4H2biNydkzX60=";
      };
      host = "paintbox.zeetech.io";
      port = 4012;
      environmentFiles = ["/etc/phoenix/paintbox.env"];
    };

    # deferred: blog.br is registered at Registro.br, not a Cloudflare zone yet,
    # so it cannot be tunneled. Move the zone to Cloudflare (or pick another
    # hostname) and flip this back on.
    quintal = {
      enable = false;
      package = mkRelease {
        pname = "quintal";
        version = "0.1.0";
        src = inputs.quintal;
        mixHash = "sha256-yB6JmDCagbRFk4BRkehlDW8kKmkO7ZxRTFs3IF60hMI=";
        rustler = true;
      };
      host = "quintal.blog.br";
      port = 4013;
      migrate = true;
      environment.DATABASE_URL = "ecto://quintal@127.0.0.1/quintal";
      environmentFiles = ["/etc/phoenix/quintal.env"];
    };
  };

  # taina, the community private-cloud server: native systemd from the taina
  # flake, tailnet-only. createLocally reuses the shared postgres cluster (it
  # only enables it and bootstraps the taina_app role); state and backups land on
  # the sda pool.
  services.taina = {
    enable = true;
    hostname = "taina.yby";
    port = 4014;
    urlScheme = "http";
    urlPort = 80;
    database.createLocally = true;
    storageDir = "/zdata/ybira";
    backupDir = "/zdata/backups";
  };

  # warn before the sda data disk (spinning rust) dies; smartd reads its
  # self-tests, smartctl is here for a manual look
  services.smartd.enable = true;
  environment.systemPackages = with pkgs; [smartmontools];

  # one dataset per service: mounted via fileSystems, created on first boot
  zfsDatasets = {
    "zroot/forgejo" = "/var/lib/forgejo";
    "zdata/pesque" = "/zdata/pesque";
    "zroot/anytype" = "/var/lib/anytype";
    # palpite's sqlite db lives here, not on the nvme
    "zdata/palpite" = "/zdata/palpite";
    # taina: ybira blob storage and nhaman backups
    "zdata/ybira" = "/zdata/ybira";
    "zdata/backups" = "/zdata/backups";
    # bulk anytype state (mongo, redis, garage blobs, networkStore) sits here on
    # the sda pool; /var/lib/anytype/.env sets STORAGE_DIR=/zdata/anytype
    "zdata/anytype" = "/zdata/anytype";
    # "zroot/uptime-kuma" = "/var/lib/uptime-kuma";
  };

  # tailnet-facing reverse proxy
  caddy = {
    enable = true;
    apps = {
      "git.yby" = "127.0.0.1:3000";
      "dash.yby" = "127.0.0.1:61208";
      "taina.yby" = "127.0.0.1:4014";
      # "status.yby" = "127.0.0.1:3001";
    };
  };

  # public ingress, tunneled through cloudflare (no inbound port, no home ip).
  # cloudflare terminates tls; the origin is pesque on loopback.
  cloudflared = {
    enable = true;
    apps = {
      "pds.zeetech.io" = "http://localhost:4000";
      "zoedsoupe.zeetech.io" = "http://localhost:4010";
      "palpite.zeetech.io" = "http://localhost:4011";
      "paintbox.zeetech.io" = "http://localhost:4012";
    };
  };

  system.stateVersion = "26.05";
}
