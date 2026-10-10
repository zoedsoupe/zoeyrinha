# A Phoenix release run as a plain systemd service. Every personal app here
# shares one contract, so one module covers them all:
#
#   PHX_SERVER=true PHX_HOST=<host> PORT=<port>  ->  $out/bin/server
#
# Secrets (SECRET_KEY_BASE, DATABASE_URL, ...) come from a root-owned
# EnvironmentFile the operator writes on the host, not from the store, same as
# pesque's account.env. Each app runs as its own system user; SQLite/state dirs
# live on a ZFS dataset the host mounts. Stateless apps get a systemd-managed
# StateDirectory as a writable working directory.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf types;

  appType = types.submodule ({name, ...}: {
    options = {
      enable = mkEnableOption "this Phoenix app";

      package = mkOption {
        type = types.package;
        description = "The release to run (its bin/server).";
      };

      host = mkOption {
        type = types.str;
        description = "PHX_HOST: the public hostname. Drives generated URLs and, for quintal, OAuth.";
      };

      port = mkOption {
        type = types.port;
        description = "Loopback port the app binds; the tunnel/reverse proxy points here.";
      };

      stateDir = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Writable state dir (sqlite, uploads) on a mounted dataset. null for stateless apps.";
      };

      environment = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Non-secret environment.";
      };

      environmentFiles = mkOption {
        type = types.listOf types.path;
        default = [];
        description = "Root-owned env files holding secrets (SECRET_KEY_BASE, ...).";
      };

      migrate = mkOption {
        type = types.bool;
        default = false;
        description = "Run bin/migrate before start, for apps that do not migrate at boot.";
      };

      extraServiceConfig = mkOption {
        type = types.attrs;
        default = {};
        description = "Extra systemd service settings.";
      };
    };
  });

  enabled = lib.filterAttrs (_: app: app.enable) config.phoenixApps;
in {
  options.phoenixApps = mkOption {
    type = types.attrsOf appType;
    default = {};
    description = "Phoenix releases to run, keyed by app name.";
  };

  config = {
    users.users = lib.mapAttrs' (name: app:
      lib.nameValuePair name {
        isSystemUser = true;
        group = name;
        home =
          if app.stateDir != null
          then app.stateDir
          else "/var/lib/${name}";
        description = "${name} service user";
      })
    enabled;

    users.groups = lib.mapAttrs' (name: _: lib.nameValuePair name {}) enabled;

    # stateDir on a dataset: the mount is root-owned, hand it to the app user
    systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList (name: app:
      lib.optional (app.stateDir != null) "d '${app.stateDir}' 0700 ${name} ${name} -")
    enabled);

    systemd.services = lib.mapAttrs' (name: app:
      lib.nameValuePair name {
        description = "${name} (Phoenix)";
        wantedBy = ["multi-user.target"];
        after = ["network-online.target"];
        wants = ["network-online.target"];
        # stateDir is usually its own dataset; wait for it instead of writing to
        # the empty mountpoint on root
        unitConfig.RequiresMountsFor = lib.optional (app.stateDir != null) app.stateDir;

        environment =
          {
            PHX_SERVER = "true";
            PHX_HOST = app.host;
            PORT = toString app.port;
            LANG = "C.UTF-8";
          }
          // app.environment;

        serviceConfig =
          {
            Type = "exec";
            User = name;
            Group = name;
            # a writable cwd even for stateless apps
            StateDirectory = name;
            WorkingDirectory =
              if app.stateDir != null
              then app.stateDir
              else "/var/lib/${name}";
            EnvironmentFile = app.environmentFiles;
            ExecStart = "${app.package}/bin/server";
            ExecStartPre = lib.optional app.migrate "${app.package}/bin/migrate";
            Restart = "on-failure";
            RestartSec = 5;
            KillSignal = "SIGTERM";
            TimeoutStopSec = 30;
            # LiveView holds a socket per client
            LimitNOFILE = 65536;

            # hardening; MemoryDenyWriteExecute stays off (the BEAM JIT needs w+x)
            NoNewPrivileges = true;
            PrivateTmp = true;
            PrivateDevices = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_UNIX"
            ];
            ReadWritePaths = lib.optional (app.stateDir != null) app.stateDir;
          }
          // app.extraServiceConfig;
      })
    enabled;
  };
}
