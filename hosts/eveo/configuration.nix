# minimal vps: headscale coordination server (maddy personal smtp off for now).
{
  inputs,
  config,
  ...
}: let
  # yby's tailnet ip, assigned by headscale. one place to change if the node
  # re-registers with a different address: eveo's caddy and the ssh relay dial
  # it directly (accept-dns is off on this host, so magic dns names don't
  # resolve here).
  ybyTailnetIp = "100.64.0.2";
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
  networking.nameservers = ["8.8.8.8" "1.1.1.1" "2606:4700:4700::1111"];
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
      dns = ["8.8.8.8" "1.1.1.1" "2606:4700:4700::1111"];
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
    # 25/465/587/993 (smtp/imap) come back with maddy below. 2222 is the knot's
    # ssh relay (see below)
    allowedTCPPorts = [22 80 443 2222];
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
        nameservers.global = ["1.1.1.1" "9.9.9.9"];
      };
      # split-horizon: point service domains at yby's tailscale ip here, e.g.
      dns.extra_records = [
        {
          name = "yby";
          type = "A";
          value = ybyTailnetIp;
        }
        {
          name = "taina.yby";
          type = "A";
          value = ybyTailnetIp;
        }
        {
          name = "git.yby";
          type = "A";
          value = ybyTailnetIp;
        }
        {
          name = "dash.yby";
          type = "A";
          value = ybyTailnetIp;
        }
      ];
    };
  };

  # --- caddy: public acme for headscale and the PDS front ---
  services.caddy = {
    enable = true;
    email = "zoey.spessanha@zeetech.io";
    virtualHosts = {
      "hs.zeetech.io".extraConfig = ''
        reverse_proxy 127.0.0.1:8080
      '';
      # the PDS runs on yby (cgnat, no inbound), so this vps terminates tls and
      # reaches it over the tailnet; caddy holds the firehose websocket up so a
      # relay can crawl it without cloudflare in between. yby's tailnet ip, not
      # a magic dns name, since accept-dns is off above
      "pds.zeetech.io".extraConfig = ''
        reverse_proxy http://${ybyTailnetIp}:4000
      '';
      # the knot also runs on yby. caddy terminates tls here and reaches it over
      # the tailnet, websockets (/events) included; the ssh side is relayed by
      # the socket-proxyd unit below
      "knot.zeetech.io".extraConfig = ''
        reverse_proxy http://${ybyTailnetIp}:5555
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

  # --- maddy: personal smtp ---
  # off for now: port 25 outbound is blocked by default on most vps providers,
  # so it needs an unblock request + rDNS/PTR before it is worth enabling.
  # re-enable the mail firewall ports above when this flips to true.
  # after first boot:
  #   - check /var/lib/maddy/dkim_keys/ and publish the DKIM dns record
  #   - set SPF + DMARC records for the real domain
  services.maddy = {
    enable = false;
    primaryDomain = "example.com";
    hostname = "mail.example.com";
    # TODO: add accounts, e.g.
    # ensureAccounts = ["zoey@example.com"];
    # ensureCredentials."zoey@example.com".passwordFile = "/var/lib/maddy-secrets/zoey";
  };

  system.stateVersion = "26.05";
}
