# nextcloud, native module. nginx listens on localhost only;
# caddy (services/caddy.nix) proxies the tailnet-facing domain to it.
# TODO: replace cloud.example.com with the real domain
{pkgs, ...}: {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = "cloud.example.com";
    https = false; # tailnet only; wireguard already encrypts
    database.createLocally = true;
    configureRedis = true;
    maxUploadSize = "4G";
    config = {
      dbtype = "pgsql";
      adminuser = "zoedsoupe";
      # create before first boot: sudo install -m 600 /dev/null /var/lib/nextcloud-admin-pass
      # then write the password into it
      adminpassFile = "/var/lib/nextcloud-admin-pass";
    };
    settings = {
      default_phone_region = "BR";
      overwriteprotocol = "http";
      trusted_domains = ["yby"];
    };
  };

  # pin nginx to localhost; caddy owns the external interface
  services.nginx.virtualHosts."cloud.example.com".listen = [
    {
      addr = "127.0.0.1";
      port = 8080;
    }
  ];
}
