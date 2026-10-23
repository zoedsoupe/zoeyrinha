# docker + docker compose. nothing depends on it by default; flip it on a host
# that needs to run an upstream compose stack.
#
# the daemon defaults to the journald log driver so container logs land in the
# systemd journal, where the alloy agent (alloy.nix) picks them up. no docker
# socket mounting, no second log pipeline.
#
# stacks are declared as oneshot units. each project needs its compose file on
# disk (cloned out of band, or a path in the store); the unit refuses to start
# until the file exists, so a fresh host does not fail the boot:
#   docker.composeProjects.foo.directory = "/srv/foo";   # docker-compose.yml inside
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.docker;

  mkProject = name: project: let
    directory =
      if project.directory != null
      then project.directory
      else "/var/lib/docker-compose/${name}";
    composeFile =
      if project.composeFile != null
      then project.composeFile
      else "${directory}/docker-compose.yml";
  in
    lib.nameValuePair "docker-compose-${name}" {
      description = "docker compose project ${name}";
      after = ["docker.service" "network-online.target"];
      requires = ["docker.service"];
      wants = ["network-online.target"];
      wantedBy = lib.optional project.autoStart "multi-user.target";
      unitConfig.ConditionPathExists = composeFile;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = directory;
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        TimeoutStartSec = "5min";
      };
    };
in {
  options.docker = {
    enable = mkEnableOption "docker + docker compose";

    dataRoot = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/zdata/docker";
      description = "Docker's storage root. null keeps the upstream default (/var/lib/docker).";
    };

    logDriver = mkOption {
      type = types.enum ["journald" "json-file" "local"];
      default = "journald";
      description = "Container log driver. journald feeds the alloy log pipeline.";
    };

    composeProjects = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          directory = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Project dir holding docker-compose.yml. Defaults to /var/lib/docker-compose/<name>.";
          };
          composeFile = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Compose file path, if not <directory>/docker-compose.yml.";
          };
          autoStart = mkOption {
            type = types.bool;
            default = true;
            description = "Start the stack on boot.";
          };
        };
      });
      default = {};
      description = "docker compose stacks, each run as a systemd oneshot unit.";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      inherit (cfg) logDriver;
      daemon.settings = lib.optionalAttrs (cfg.dataRoot != null) {
        data-root = cfg.dataRoot;
      };
    };

    environment.systemPackages = [pkgs.docker-compose];

    users.users.zoedsoupe.extraGroups = ["docker"];

    systemd.services = lib.mapAttrs' mkProject cfg.composeProjects;
  };
}
