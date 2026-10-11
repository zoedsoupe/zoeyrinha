# minimal vps: headscale coordination server (maddy personal smtp off for now).
{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
  ];

  networking.hostName = "eveo";

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
    # 25/465/587/993 (smtp/imap) come back with maddy below
    allowedTCPPorts = [22 80 443];
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
      # dns.extra_records = [
      #   { name = "taina.yby"; type = "A"; value = "100.x.y.z"; }
      # ];
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
        reverse_proxy http://100.107.145.79:4000
      '';
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
