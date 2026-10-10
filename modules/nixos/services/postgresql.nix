# One shared cluster for the host: services get a database and a role, never
# their own instance (saves RAM for the BEAM and ZFS ARC); same-host apps use
# peer auth over the unix socket, so no password lands in the store.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.postgres;
in {
  options.postgres = {
    enable = lib.mkEnableOption "a single shared PostgreSQL cluster for the host";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.postgresql_18;
      description = "PostgreSQL version for the cluster. 18 matches Taina's RLS work; older services are happy on it too.";
    };

    databases = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Databases created on first boot. Each service owns one, sharing the cluster.";
    };

    users = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Role name. With peer auth, the OS user of the same name connects as it.";
          };
          ensureDBOwnership = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Make the role own the database with the same name (nixpkgs only supports same-name ownership).";
          };
        };
      });
      default = [];
      description = "Roles created on first boot.";
    };

    maxConnections = lib.mkOption {
      type = lib.types.ints.positive;
      default = 20;
      description = "Connection ceiling for the whole cluster. Taina's pool math assumes 20 on this box.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      inherit (cfg) package;
      ensureDatabases = cfg.databases;
      ensureUsers = cfg.users;

      # Sized down for a box also running the BEAM, docker/mongo and a 2GB ARC
      settings = {
        max_connections = cfg.maxConnections;
        shared_buffers = "256MB";
        effective_cache_size = "1GB";
        work_mem = "4MB";
        maintenance_work_mem = "64MB";
      };

      # No auth config here: peer auth (the nixpkgs default) covers same-host apps
    };
  };
}
