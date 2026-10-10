# A single PostgreSQL cluster shared by every service on the host: one server,
# one data directory, N databases and N roles. On a small box (8GB, tailnet
# only) a second cluster buys isolation nothing here needs and costs RAM the
# BEAM and the ZFS ARC want back. A service adds a database and a role, never an
# instance.
#
# Native apps on the same host reach it over the unix socket with peer auth:
# the OS user and the DB role share a name, so no password ever touches the
# Nix store. Nothing listens off-box.
#
#   postgres = {
#     enable = true;
#     databases = ["taina"];
#     users = [{ name = "taina"; ensureDBOwnership = true; }];
#   };
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

      # Explicit and modest: the box also runs the BEAM, docker/mongo and a 2GB
      # ARC, so leave headroom instead of taking Postgres defaults sized for a
      # dedicated machine.
      settings = {
        max_connections = cfg.maxConnections;
        shared_buffers = "256MB";
        effective_cache_size = "1GB";
        work_mem = "4MB";
        maintenance_work_mem = "64MB";
      };

      # Local peer auth (the nixpkgs default) is all a native app on the same
      # host needs. No host/trust rules: nothing off-box should reach the port.
    };
  };
}
