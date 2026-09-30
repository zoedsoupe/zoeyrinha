# anytype self-host: official any-sync-dockercompose stack, wrapped in systemd.
# nixpkgs has no module for it and repackaging 5 Go services is not worth it.
#
# setup (once, on yby):
#   sudo git clone https://github.com/anyproto/any-sync-dockercompose /var/lib/anytype
#   cd /var/lib/anytype && sudo make start   # generates .env.override on first run
#
# WARNING: mongodb >= 5 requires AVX. check with: grep -q avx /proc/cpuinfo
# if missing, pin mongo:4.4 in /var/lib/anytype/docker-compose.override.yml
{pkgs, ...}: {
  virtualisation.docker.enable = true;
  users.users.zoedsoupe.extraGroups = ["docker"];

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
}
