# anytype self-host: official any-sync-dockercompose stack, wrapped in systemd.
# nixpkgs has no module for it and repackaging 5 Go services is not worth it.
#
# setup (once, on the host), while `anytype.enable = true`:
#   sudo git clone https://github.com/anyproto/any-sync-dockercompose /var/lib/anytype
#   cd /var/lib/anytype && sudo make start   # generates .env.override on first run
# then set the stack's external address to this host's tailnet IP so clients
# can reach it, and open the sync ports on tailscale0 (see below).
#
# WARNING: mongodb >= 5 requires AVX. check with: grep -q avx /proc/cpuinfo
# if missing, pin mongo:4.4 in /var/lib/anytype/docker-compose.override.yml
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.anytype;
in {
  options.anytype.enable = mkEnableOption "anytype self-hosted sync stack";

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    # listOf merges (concat) with modules/nixos/common.nix, which owns the base set
    users.users.zoedsoupe.extraGroups = ["docker"];

    # clients hit the sync node directly (33010+), no vhost needed; expose
    # them on the tailnet only
    networking.firewall.interfaces.tailscale0.allowedTCPPortRanges = [
      {
        from = 33010;
        to = 33030;
      }
    ];

    systemd.services.anytype = {
      description = "Anytype self-hosted sync stack";
      after = ["docker.service" "network-online.target"];
      requires = ["docker.service"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = "/var/lib/anytype";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        TimeoutStartSec = "5min";
      };
      # only start if the stack has been cloned and configured
      unitConfig.ConditionPathExists = "/var/lib/anytype/docker-compose.yml";
    };
  };
}
