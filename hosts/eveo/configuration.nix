# minimal vps: headscale coordination server + stalwart personal mail.
{
  inputs,
  config,
  lib,
  ...
}: let
  # yby's tailnet ip, assigned by headscale. one place to change if the node
  # re-registers with a different address: eveo's caddy and the ssh relay dial
  # it directly (accept-dns is off on this host, so magic dns names don't
  # resolve here).
  ybyTailnetIp = "100.64.0.2";

  # keep the unprotected bootstrap/recovery listener off the public proxy.
  # complete the wizard through the ssh tunnel on host port 8081, then flip
  # this to true and redeploy to serve the webui, jmap and autodiscovery.
  stalwartPublicHttp = true;

  # caddy here is the public one (tls for headscale and the pds), bound to
  # 0.0.0.0:80/443, so a tailnet-only dashboard is gated by remote ip rather
  # than the firewall. without the gate, "Host: status.eveo" against the public
  # ip would reach it. loopback is allowed too so gatus can check the vhosts
  # locally. the log directive lands access logs in the journal, where alloy
  # ships them.
  tailnetVhost = upstream: ''
    @tailnet remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48 127.0.0.1/32 ::1/128
    handle @tailnet {
      reverse_proxy ${upstream}
    }
    handle {
      respond 403
    }
    log
  '';
in {
  imports = [
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
  ];

  networking.hostName = "eveo";

  # hypehost assigns a static address: its netplan runs no dhcp, so
  # networkmanager + dhcp never brings the nic up and, with no console, the box
  # just looks hung. pin the provider's address instead, matched by mac so the
  # kernel's interface name does not matter.
  networking.networkmanager.enable = false;
  networking.useDHCP = false;
  networking.useNetworkd = true;
  # adguard (this host) answers first, then a public fallback: adguard owns the
  # tailnet's records, so eveo itself can resolve *.yby and *.eveo (the gatus
  # checks use the names, not raw tailnet ips)
  networking.nameservers = ["127.0.0.1" "1.1.1.1" "2606:4700:4700::1111"];
  # useNetworkd pulls in systemd-resolved (mkDefault), and it hogs :53, which
  # adguard needs to own as the tailnet resolver. drop it: adguard owns DNS here.
  services.resolved.enable = false;
  systemd.network = {
    enable = true;
    networks."10-eveo" = {
      matchConfig.MACAddress = "52:54:00:a2:74:2a";
      address = [
        "212.38.89.221/24"
        "2a0c:9a40:8f40:0:212:38:89:221/48"
      ];
      routes = [
        {Gateway = "212.38.89.1";}
        {
          Gateway = "2a0e:b107:1ef0::1";
          GatewayOnLink = true;
        }
      ];
      dns = ["127.0.0.1" "1.1.1.1" "2606:4700:4700::1111"];
    };
  };

  # hardware-configuration.nix is empty (disko owns fileSystems), so the default
  # initrd module set ships without the vps disk's controller driver: the disk is
  # on qemu's scsi/virtio bus, so root never mounts and the box drops to
  # emergency with no network. normally nixos-generate-config adds these; add
  # them by hand (virtio-scsi plus the emulated hbas, to be safe).
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "scsi_mod"
    "sd_mod"
    "sr_mod"
    "ahci"
    "nvme"
    "mptspi"
    "mptsas"
    "megaraid_sas"
    "sym53c8xx"
    "qla2xxx"
  ];

  # hypecloud boots UEFI (OVMF), not legacy BIOS: the disk needs an EFI System
  # Partition and an EFI bootloader. systemd-boot writes both the NVRAM entry
  # and the fallback EFI/BOOT/BOOTX64.EFI, so it still boots if the provider
  # resets the firmware vars.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # disk layout for nixos-anywhere provisioning (UEFI/gpt). confirm the device
  # with `lsblk` on the vps; hypecloud presents it as /dev/sda
  disko.devices.disk.main = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          # systemd-boot keeps each generation's kernel + initrd here; 10 gens
          # (the default configurationLimit) needs ~1G, so 512M would overflow
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  networking.firewall = {
    enable = true;
    # stalwart: smtp, submissions, imaps, pop3s and managesieve. its http port
    # stays on loopback behind caddy. 2222 is the knot's ssh relay (see below)
    allowedTCPPorts = [22 25 80 443 465 587 993 995 2222 4190];
    # 41641/udp: tailscale wireguard
    allowedUDPPorts = [41641];
  };

  # eveo is the headscale server and also a node, so it can reach yby over the
  # tailnet and front the PDS. join once, same as any host:
  #   tailscale up --login-server=https://hs.zeetech.io
  # accept-dns off on purpose: this host serves hs.zeetech.io and its own
  # resolver is load-bearing, so the PDS front below dials yby by tailnet ip
  # instead of through magic dns
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = ["--accept-dns=false"];
  };

  services.fail2ban.enable = true;

  # --- ops node ---
  # gatus watches everything (its own services and yby's, over the tailnet): a
  # monitor has to outlive what it watches, and yby is the box that goes dark.
  # adguard is the tailnet resolver; loki + grafana collect and read logs. all
  # of it is tailnet-only behind caddy (status/dns/logs.eveo).
  gatus = {
    enable = true;
    email.to = "zoey.spessanha@icloud.com";
    endpoints = [
      # yby, reached over the tailnet through its caddy
      {
        name = "forgejo";
        group = "yby";
        url = "http://git.yby";
      }
      {
        name = "atuin";
        group = "yby";
        url = "http://atuin.yby/healthz";
      }
      # public edge
      {
        name = "knot";
        group = "public";
        url = "https://knot.zeetech.io";
      }
      {
        name = "headscale";
        group = "public";
        url = "https://hs.zeetech.io/health";
      }
      {
        name = "pds";
        group = "public";
        url = "https://pds.zeetech.io/xrpc/_health";
      }
      # eveo itself
      {
        name = "adguard";
        group = "eveo";
        url = "http://dns.eveo";
      }
      {
        name = "grafana";
        group = "eveo";
        url = "http://logs.eveo/api/health";
      }
      {
        name = "loki";
        group = "eveo";
        url = "http://127.0.0.1:3100/ready";
      }
    ];
  };

  adguard.enable = true;
  loki.enable = true;
  grafana.enable = true;

  # ship this host's journal to loki (local, so loopback)
  alloy = {
    enable = true;
    lokiUrl = "http://127.0.0.1:3100";
  };

  # docker for stalwart; the journald log driver (docker.nix) puts container
  # logs in the journal so alloy ships them too
  docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers.stalwart = {
      # follow 1.x fixes without crossing a major-version upgrade boundary
      image = "docker.io/stalwartlabs/stalwart:v1";
      extraOptions = ["--init"];
      ports = [
        "25:25"
        "465:465"
        "587:587"
        "993:993"
        "995:995"
        "4190:4190"
        # bootstrap/recovery and caddy's upstream; never expose this publicly.
        # host 8080 already belongs to headscale
        "127.0.0.1:8081:8080"
      ];
      volumes = [
        "/var/lib/stalwart/etc:/etc/stalwart"
        "/var/lib/stalwart/data:/var/lib/stalwart"
      ];
      environment = {
        STALWART_HOSTNAME = "mail.zeetech.io";
        STALWART_PUBLIC_URL = "https://mail.zeetech.io";
      };
      # optional bootstrap/recovery credential; remove it after setup
      environmentFiles = ["/etc/stalwart/stalwart.env"];
    };
  };

  # the official image runs as uid/gid 2000 and needs both directories to
  # persist: the first-boot wizard writes config.json for sqlite, while the
  # database holds mail and the rest of the configuration.
  systemd.tmpfiles.rules = [
    "d /etc/stalwart 0750 root root - -"
    "d /var/lib/stalwart 0750 2000 2000 - -"
    "d /var/lib/stalwart/etc 0750 2000 2000 - -"
    "d /var/lib/stalwart/data 0750 2000 2000 - -"
  ];

  systemd.services.docker-stalwart.serviceConfig.LimitNOFILE = 65536;

  # --- headscale ---
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 8080;
    settings = {
      server_url = "https://hs.zeetech.io";
      dns = {
        base_domain = "tail.zeetech.io";
        magic_dns = true;
        # adguard (on this host) is the tailnet's single source of truth for
        # records; headscale only forwards here and keeps serving the automatic
        # magic-dns node names. 1.1.1.1 is a failover for when adguard is down.
        nameservers.global = ["100.64.0.1" "1.1.1.1"];
        # extra records live in adguard now, added in its web UI:
        #   yby, git.yby, dash.yby   -> 100.64.0.2
        #   status.eveo, dns.eveo, logs.eveo    -> 100.64.0.1
        extra_records = [];
      };
    };
  };

  # --- caddy: public acme for headscale and the PDS front ---
  services.caddy = {
    enable = true;
    email = "zoey.spessanha@zeetech.io";
    virtualHosts =
      {
        "hs.zeetech.io".extraConfig = ''
          log
          reverse_proxy 127.0.0.1:8080
        '';
        # the PDS runs on yby (cgnat, no inbound), so this vps terminates tls and
        # reaches it over the tailnet; caddy holds the firehose websocket up so a
        # relay can crawl it without cloudflare in between. yby's tailnet ip, not
        # a magic dns name, since accept-dns is off above. no access log: the
        # firehose would flood loki
        "pds.zeetech.io".extraConfig = ''
          reverse_proxy http://${ybyTailnetIp}:4000
        '';
        "solaria.taina.dev.br".extraConfig = ''
          reverse_proxy http://${ybyTailnetIp}:4014
        '';
        # vaultwarden runs on yby; caddy terminates public tls and reaches it
        # over the tailnet, websockets included. no access log: notification
        # websocket urls carry a jwt in the access_token query parameter
        "vault.zeetech.io".extraConfig = ''
          reverse_proxy http://${ybyTailnetIp}:8222
        '';
        # the knot also runs on yby. caddy terminates tls here and reaches it over
        # the tailnet, websockets (/events) included; the ssh side is relayed by
        # the socket-proxyd unit below
        "knot.zeetech.io".extraConfig = ''
          log
          reverse_proxy http://${ybyTailnetIp}:5555
        '';

        # tailnet-only dashboards, gated by remote ip (see tailnetVhost above)
        "http://status.eveo".extraConfig = tailnetVhost "127.0.0.1:3001";
        "http://dns.eveo".extraConfig = tailnetVhost "127.0.0.1:3000";
        "http://logs.eveo".extraConfig = tailnetVhost "127.0.0.1:3002";
      }
      // lib.optionalAttrs stalwartPublicHttp {
        # stalwart terminates tls for the mail protocols itself. caddy owns 443,
        # so only its http endpoints are proxied; the backend is loopback-only.
        # the other names serve client discovery and the mta-sts policy.
        "mail.zeetech.io".extraConfig = ''
          reverse_proxy http://127.0.0.1:8081
        '';
        "autoconfig.zeetech.io".extraConfig = ''
          reverse_proxy http://127.0.0.1:8081
        '';
        "autodiscover.zeetech.io".extraConfig = ''
          reverse_proxy http://127.0.0.1:8081
        '';
        "mta-sts.zeetech.io".extraConfig = ''
          reverse_proxy http://127.0.0.1:8081
        '';
        "ua-auto-config.zeetech.io".extraConfig = ''
          reverse_proxy http://127.0.0.1:8081
        '';
      };
  };

  # --- tangled knot: git-over-ssh relay ---
  # the knot lives on yby for zfs snapshots, but yby is behind cgnat with no
  # inbound path, so this vps accepts the ssh endpoint and splices it over the
  # tailnet. 2222 is knot2's default ssh port; Tangled's ui assumes 22, so ssh
  # users need ssh://git@knot.zeetech.io:2222/... or an ssh config Port entry.
  systemd.sockets.knot-ssh-relay = {
    wantedBy = ["sockets.target"];
    listenStreams = ["2222"];
  };

  systemd.services.knot-ssh-relay = {
    description = "Forward git-over-ssh on 2222 to the knot on yby over the tailnet";
    serviceConfig = {
      ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min ${ybyTailnetIp}:2222";
      DynamicUser = true;
    };
  };

  system.stateVersion = "26.05";
}
