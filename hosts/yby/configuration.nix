{
  pkgs,
  inputs,
  lib,
  ...
}: let
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
  # the installer leaves the pool marked in-use (foreign hostid), so a plain
  # import is refused and boot dies in initrd; safe on a single-node headless host
  boot.zfs.forceImportRoot = true;
  # zdata lives on sda; without this only zroot is guaranteed to import, so
  # zdata's datasets never mount and the host drops into emergency mode
  boot.zfs.extraPools = ["zdata"];
  # cap ARC at 2GB: default is 50% of RAM and slow to release,
  # which on 8GB with mongodb running is an OOM waiting to happen
  boot.kernelParams = ["zfs.zfs_arc_max=2147483648"];

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  # intel igpu; kept headless for jellyfin/qsv transcoding later
  hardware.graphics.enable = true;

  # headless: SSH/tailnet only. flip niri on when a screen shows up, and set
  # noctalia.enable in home.nix with it
  niri.enable = false;
  nextcloud.enable = false;

  anytype.enable = true;

  # git forge: source of truth on the tailnet
  forgejo.enable = true;

  glances.enable = true;
  uptime-kuma.enable = false;

  # self-hosted atproto PDS, built from the release in the pesque flake
  services.pesque = {
    enable = true;
    hostname = "pds.zeetech.io";
    mode = "path_multi";
    identity = "plc";
    crawler = ["https://bsky.network"];

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

  # personal Phoenix apps fronted by the cloudflare tunnel below; secrets live
  # in /etc/phoenix/<name>.env (see the README), never in the store
  phoenixApps = {
    blog = {
      enable = true;
      package = inputs.zoeyrinha-web.packages.${pkgs.stdenv.hostPlatform.system}.default;
      host = "zoedsoupe.zeetech.io";
      port = 4010;
      environmentFiles = ["/etc/phoenix/blog.env"];
    };

    pitaco = {
      enable = true;
      package = mkRelease {
        pname = "pitaco";
        version = "0.1.0";
        src = inputs.pitaco;
        mixHash = "sha256-aJ3Qh3hUinW8y+zP0tVgVeTLp20ZXluYrAv2w5SESJY=";
      };
      host = "pitaco.zeetech.io";
      port = 4011;
      stateDir = "/zdata/pitaco";
      environment.DATABASE_PATH = "/zdata/pitaco/pitaco.db";
      environmentFiles = ["/etc/phoenix/pitaco.env"];
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

    # disabled: blog.br is registered at Registro.br, not a cloudflare zone, so
    # it can't be tunneled. move the zone (or pick another host) and flip back on
    quintal = {
      enable = false;
      package = mkRelease {
        pname = "quintal";
        version = "0.1.0";
        src = inputs.quintal;
        mixHash = "sha256-yB6JmDCagbRFk4BRkehlDW8kKmkO7ZxRTFs3IF60hMI=";
        # also needs a rustlerCache (like blog): its mdex_native NIF is
        # precompiled-only too
      };
      host = "quintal.blog.br";
      port = 4013;
      migrate = true;
      environment.DATABASE_URL = "ecto://quintal@127.0.0.1/quintal";
      environmentFiles = ["/etc/phoenix/quintal.env"];
    };
  };

  # app commits auto-deploy: the timer re-locks zoeyrinha-web and rebuilds the
  # host; host changes stay a deliberate, manual pull. one-time setup:
  #   sudo git clone https://github.com/zoedsoupe/zoeyrinha /var/lib/zoeyrinha
  selfDeploy = {
    enable = true;
    flake = "/var/lib/zoeyrinha";
    inputs = ["zoeyrinha-web"];
  };

  # taina, the community private-cloud server: tailnet-only. createLocally
  # reuses the shared postgres cluster (bootstraps the taina_app role)
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

  # warn before the sda data disk (spinning rust) dies; smartctl for manual checks
  services.smartd.enable = true;
  environment.systemPackages = with pkgs; [smartmontools];

  zfsDatasets = {
    "zroot/forgejo" = "/var/lib/forgejo";
    "zdata/pesque" = "/zdata/pesque";
    "zroot/anytype" = "/var/lib/anytype";
    # pitaco's sqlite db lives here, not on the nvme
    "zdata/pitaco" = "/zdata/pitaco";
    # taina: ybira blob storage and nhaman backups
    "zdata/ybira" = "/zdata/ybira";
    "zdata/backups" = "/zdata/backups";
    # bulk anytype state (mongo, redis, garage blobs, networkStore) sits here on
    # the sda pool; /var/lib/anytype/.env sets STORAGE_DIR=/zdata/anytype
    "zdata/anytype" = "/zdata/anytype";
  };

  # tailnet-facing reverse proxy
  caddy = {
    enable = true;
    apps = {
      "git.yby" = "127.0.0.1:3000";
      "dash.yby" = "127.0.0.1:61208";
      "taina.yby" = "127.0.0.1:4014";
    };
  };

  # public ingress tunneled through cloudflare: no inbound port, no home ip;
  # cloudflare terminates tls
  cloudflared = {
    enable = true;
    apps = {
      "pds.zeetech.io" = "http://localhost:4000";
      "zoedsoupe.zeetech.io" = "http://localhost:4010";
      "pitaco.zeetech.io" = "http://localhost:4011";
      "paintbox.zeetech.io" = "http://localhost:4012";
    };
  };

  system.stateVersion = "26.05";
}
