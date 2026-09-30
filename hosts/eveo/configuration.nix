# minimal vps: headscale coordination server + maddy personal smtp.
# TODO: replace example.com with the real domain everywhere below.
{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "eveo";

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # adjust to the vps disk
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 25 80 443 465 587 993];
    # 41641/udp: tailscale wireguard
    allowedUDPPorts = [41641];
  };

  services.fail2ban.enable = true;

  # --- headscale ---
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 8080;
    settings = {
      server_url = "https://hs.example.com";
      dns = {
        base_domain = "tail.example.com";
        magic_dns = true;
        nameservers.global = ["1.1.1.1" "9.9.9.9"];
      };
      # split-horizon: point service domains at yby's tailscale ip here, e.g.
      # dns.extra_records = [
      #   { name = "cloud.example.com"; type = "A"; value = "100.x.y.z"; }
      # ];
    };
  };

  # --- caddy: public acme for headscale ---
  services.caddy = {
    enable = true;
    email = "zoey.spessanha@zeetech.io";
    virtualHosts."hs.example.com".extraConfig = ''
      reverse_proxy 127.0.0.1:8080
    '';
  };

  # --- maddy: personal smtp ---
  # after first boot:
  #   - check /var/lib/maddy/dkim_keys/ and publish the DKIM dns record
  #   - set SPF + DMARC records for example.com
  services.maddy = {
    enable = true;
    primaryDomain = "example.com";
    hostname = "mail.example.com";
    # TODO: add accounts, e.g.
    # ensureAccounts = ["zoey@example.com"];
    # ensureCredentials."zoey@example.com".passwordFile = "/var/lib/maddy-secrets/zoey";
  };

  system.stateVersion = "26.05";
}
