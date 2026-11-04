{
  pkgs,
  inputs,
  lib,
  ...
}: let
  beamToolchain = pkgs.beam-overlay.mkToolchain {
    elixir.version = "1.20.5";
    erlang-otp.version = "29";
  };

  phoenixReleaseDefaults = {
    toolchain = beamToolchain;
    tailwindcss = null;
    nativeBuildInputs = [pkgs.pkg-config];
    env.CC_PRECOMPILER_PRECOMPILE_ONLY_LOCAL = "true";
    preConfigure = ''
      cat >> config/config.exs <<'EOF'
      config :elixir_make, force_build: [exqlite: true, lazy_html: true]
      EOF
    '';
  };

  pitacoRelease = pkgs.beam-overlay.mkPhoenixRelease (phoenixReleaseDefaults
    // {
      pname = "pitaco";
      version = "0.1.1";
      src = inputs.pitaco;
      mixDepsHash = "sha256-2/ZKd90+p0kYyEg/eLps7h2ijBW8m7FVYOjTahlkWfw=";
    });

  paintboxRelease = pkgs.beam-overlay.mkPhoenixRelease (phoenixReleaseDefaults
    // {
      pname = "paintbox";
      version = "0.1.0";
      src = inputs.paintbox;
      mixDepsHash = "sha256-LE21sKdjAXoi4KjPtPmU9dbHeqClmf4H2biNydkzX60=";
    });

  # the pesque account that owns the knot. the first admin is the owner the
  # knot advertises to the appview, and Tangled's registration checks it, so it
  # has to be the account's real did:plc
  knotOwnerDid = "did:plc:4rt5dyqvarrbolr7qmfcbcsm";
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
  boot.zfs.forceImportRoot = false;
  # zdata lives on sda; without this only zroot is guaranteed to import, so
  # zdata's datasets never mount and the host drops into emergency mode
  boot.zfs.extraPools = ["zdata"];
  # cap ARC at 2GB: default is 50% of RAM and slow to release,
  # which on 8GB with mongodb running is an OOM waiting to happen
  boot.kernelParams = ["zfs.zfs_arc_max=2147483648"];

  # kexec a crash kernel at boot and force a panic on hard/soft lockups, so a
  # freeze lands in a dump-capture kernel with /proc/vmcore instead of hanging
  # dark. only fires on panics/lockups, never on a clean poweroff, and the
  # capture kernel drops to systemd rescue, so pulling the dump needs console.
  boot.crashDump = {
    enable = true;
    reservedMemory = "256M";
  };

  # headless: a phantom/shorted front-panel power switch must not take the host
  # down. a short press now does nothing (a >5s firmware hold still cuts power),
  # so shut down deliberately with `sudo poweroff` instead.
  services.logind.settings.Login.HandlePowerKey = "ignore";

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  # intel igpu; kept headless for jellyfin/qsv transcoding later
  hardware.graphics.enable = true;

  # headless: SSH/tailnet only. flip niri on when a screen shows up, and set
  # noctalia.enable in home.nix with it
  niri.enable = false;
  nextcloud.enable = false;

  # git forge: source of truth on the tailnet
  forgejo.enable = true;

  glances.enable = true;

  # ship this host's journal (services, docker, caddy access logs) to loki on
  # eveo
  alloy = {
    enable = true;
    lokiUrl = "http://100.64.0.1:3100";
  };

  # docker for upstream compose stacks; state on the sda pool, container logs to
  # the journal for alloy
  docker = {
    enable = true;
    dataRoot = "/zdata/docker";
    composeProjects.atuin = {
      directory = ./atuin;
      preStart = ''
        ${pkgs.coreutils}/bin/mkdir -p /zdata/atuin/config
        ${pkgs.coreutils}/bin/chown 1000:1000 /zdata/atuin/config
        ${pkgs.coreutils}/bin/chmod 0750 /zdata/atuin/config
      '';
    };
  };

  # self-hosted atproto PDS, built from the release in the pesque flake
  services.beam.containers.pesque = {
    enable = true;
    image = "ghcr.io/zeeetech/pesque:1.15.7";
    uid = 991;
    gid = 989;
    dataDir = "/zdata/pesque";
    requiredMounts = ["/zdata"];
    port = 4000;
    listenAddress = "100.64.0.2";
  };

  services.pesque = {
    mode = "multi";
    crawler = ["https://bsky.network"];
    scheme = "https";
    hostname = "pds.zeetech.io";
    settings.blob_upload_limit = "104857600";
    settings.admin_dids = knotOwnerDid;
  };

  # self-hosted tangled knot: a git server whose auth layer is the atproto
  # social graph. state (repos + sealed keys) on the sda pool for zfs
  # snapshots, which the vps has none of. yby has no inbound path, so caddy on
  # eveo fronts the http api and a tcp relay there carries git-over-ssh.
  services.tangled.knot-rs = {
    enable = true;
    stateDir = "/zdata/knot";
    # eveo is the only thing that reaches it, and only over the tailnet
    openFirewall = false;
    environmentFile = "/etc/knot/knot.env";
    settings = {
      server = {
        hostname = "knot.zeetech.io";
        admins = [knotOwnerDid];
        # wildcard bind: the unit runs under PrivateUsers, which cannot bind a
        # specific address. the firewall keeps this tailnet-only regardless
        listen_addr = "[::]:5555";
        # knot2's default ssh port; the eveo relay republishes it publicly
        ssh_listen_addr = "[::]:2222";
      };
      contact.email = "zoey.spessanha@zeetech.io";
      atproto.plc_directory = "https://plc.directory";
      # eveo is the only trusted proxy, and it connects from the tailnet cgnat
      # range; anything else is rate-limited by its real address
      xrpc = {
        trusted_proxy_header = "x-forwarded-for";
        trusted_proxies = ["100.64.0.0/10"];
      };
      # github and forgejo are sha1, and sha1/sha256 repos cannot push or fetch
      # between each other, so stay sha1 or the mirror plan breaks
      git.object_format = "sha1";
      # lfs on, same as forgejo
      lfs.store_path = "/zdata/knot/lfs";
      # no tls on the knot itself: caddy terminates it. a plain tcp frontend
      # can't proxy quic, so http3 would just bind an unreachable udp port
      tls.http3 = false;
    };
  };

  # one Postgres for the whole host; each service gets a database and a role in
  # this cluster, never its own instance.
  postgres.enable = false;

  # personal Phoenix apps fronted by the cloudflare tunnel below; secrets live
  # in /etc/phoenix/<name>.env (see the README), never in the store
  services.beam.containers.zoeyrinha-web = {
    enable = true;
    image = "ghcr.io/zoedsoupe/zoeyrinha-web:0.1.0";
    uid = 993;
    gid = 993;
    port = 4010;
    environmentFiles = ["/etc/phoenix/blog.env"];
  };
  services.zoeyrinha-web.hostname = "zoedsoupe.zeetech.io";

  services.beam.apps = {
    pitaco = {
      enable = true;
      package = pitacoRelease;
      command = "bin/server";
      stateDir = "/zdata/pitaco";
      environment = {
        PHX_SERVER = "true";
        PHX_HOST = "pitaco.zeetech.io";
        PORT = "4011";
        DATABASE_PATH = "/zdata/pitaco/pitaco.db";
        RELEASE_DISTRIBUTION = "none";
        RELEASE_COOKIE = "pitaco";
        RELEASE_NODE = "palpite@127.0.0.1";
      };
      environmentFiles = ["/etc/phoenix/pitaco.env"];
    };

    paintbox = {
      enable = true;
      package = paintboxRelease;
      command = "bin/server";
      environment = {
        PHX_SERVER = "true";
        PHX_HOST = "paintbox.zeetech.io";
        PORT = "4012";
        RELEASE_DISTRIBUTION = "none";
        RELEASE_COOKIE = "paintbox";
        RELEASE_NODE = "paintbox@127.0.0.1";
      };
      environmentFiles = ["/etc/phoenix/paintbox.env"];
    };
  };

  # The shared OCI image carries the release and its native dependencies. The
  # public hostname still needs a Cloudflare zone before ingress can be enabled.
  services.beam.containers.quintal = {
    enable = false;
    image = "ghcr.io/zoedsoupe/quintal:1.0.0";
    port = 4013;
    uid = 992;
    gid = 992;
    dataDir = "/zdata/quintal";
    requiredMounts = ["/zdata" "/zdata/backups"];
    environmentFiles = ["/etc/phoenix/quintal.env"];
  };
  services.quintal.hostname = "quintal.blog.br";

  # taina, the community private-cloud server: tailnet-only. the sqlite db
  # lives on the sda pool; blobs and backups stay on their own datasets. the
  # session key lives outside the data dataset, in a root-owned env file like
  # knot's and the phoenix apps' secrets (/etc/taina/taina.env, see README).
  services.taina = {
    enable = true;
    hostname = "solaria.taina.dev.br";
    port = 4014;
    urlScheme = "https";
    bindIp = "0.0.0.0";
    urlPort = 443;
    dataDir = "/zdata/taina";
    storageDir = "/zdata/ybira";
    backupDir = "/zdata/backups";
    environmentFile = "/etc/taina/taina.env";
    backup.enable = true;
  };

  # warn before the sda data disk (spinning rust) dies; smartctl for manual checks
  services.smartd.enable = true;
  environment.systemPackages = with pkgs; [smartmontools];

  zfsDatasets = {
    "zroot/forgejo" = "/var/lib/forgejo";
    "zdata/pesque" = "/zdata/pesque";
    "zdata/pitaco" = "/zdata/pitaco";
    # "zdata/quintal" = "/zdata/quintal";
    "zdata/taina" = "/zdata/taina";
    "zdata/ybira" = "/zdata/ybira";
    "zdata/backups" = "/zdata/backups";
    "zdata/knot" = "/zdata/knot";
    "zdata/docker" = "/zdata/docker";
    "zdata/atuin" = "/zdata/atuin";
  };

  # tailnet-facing reverse proxy
  caddy = {
    enable = true;
    apps = {
      "git.yby" = "127.0.0.1:3000";
      "dash.yby" = "127.0.0.1:61208";
      "atuin.yby" = "127.0.0.1:8888";
    };
  };

  # eveo (public vps) terminates tls for the PDS and reaches it here over the
  # tailnet, since this host is behind cgnat with no inbound path; that gives a
  # relay a stable firehose connection off cloudflare. open the pds port to the
  # tailnet only. 5555/2222 are the knot's http api and ssh, also reached
  # through eveo (caddy + a tcp relay), never directly
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [4000 5555 2222];

  # public ingress tunneled through cloudflare: no inbound port, no home ip;
  # cloudflare terminates tls. the pds is not here: cloudflare's edge drops the
  # firehose websocket, so caddy on eveo fronts it directly instead
  cloudflared = {
    enable = true;
    apps = {
      "zoedsoupe.zeetech.io" = "http://localhost:4010";
      "pitaco.zeetech.io" = "http://localhost:4011";
      "paintbox.zeetech.io" = "http://localhost:4012";
    };
  };

  system.stateVersion = "26.05";
}
