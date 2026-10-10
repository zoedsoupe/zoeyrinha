# pesque, a self-hosted atproto PDS, run as an OCI container. configured
# through pesque's own PDS_* env vars (env wins over pesque.conf), so nothing
# is hand-edited on the host. the container listens on 4000 and is published on
# loopback, meant to sit behind a reverse proxy (cloudflared, caddy).
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types filterAttrs;
  cfg = config.pesque;
in {
  options.pesque = {
    enable = mkEnableOption "pesque, a self-hosted atproto PDS";

    image = mkOption {
      type = types.str;
      default = "ghcr.io/zeeetech/pesque:latest";
      description = "Container image; pin a version tag for reproducibility.";
    };

    pull = mkOption {
      type = types.enum ["always" "missing" "never"];
      default = "always";
      description = "Image pull policy. always re-pulls on every (re)start, so a new :latest lands without a rebuild; missing only pulls when absent locally. newer is podman-only and invalid on the docker backend.";
    };

    hostname = mkOption {
      type = types.str;
      example = "pds.zeetech.io";
      description = "Domain clients use to reach the PDS. Its public identity.";
    };

    mode = mkOption {
      type = types.enum ["conformant_single" "path_multi"];
      default = "conformant_single";
      description = "conformant_single serves one account as the server; path_multi gives each account its own handle.";
    };

    identity = mkOption {
      type = types.nullOr (types.enum ["web" "plc"]);
      default = null;
      description = "DID method. null lets pesque pick (web under conformant_single, plc under path_multi).";
    };

    handleDomain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Domain accounts get handles under. Defaults to the hostname.";
    };

    registration = mkOption {
      type = types.enum ["open" "closed"];
      default = "closed";
    };

    crawler = mkOption {
      type = types.str;
      default = "https://bsky.network";
      description = "Relay to announce to at boot; empty announces to nobody.";
    };

    port = mkOption {
      type = types.port;
      default = 4000;
      description = "Host loopback port the PDS is published on.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/pesque";
      description = "Host path for the PDS data (sqlite + blobs), mounted at /data.";
    };

    extraEnvironment = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {PDS_BLOB_UPLOAD_LIMIT = "10485760";};
      description = "Extra PDS_* env vars.";
    };
  };

  config = mkIf cfg.enable {
    # the image is a plain OCI image; docker is the backend (shared with anytype)
    virtualisation.docker.enable = true;

    virtualisation.oci-containers = {
      backend = "docker";
      containers.pesque = {
        image = cfg.image;
        pull = cfg.pull;
        environment =
          filterAttrs (_: v: v != null) {
            PDS_DATA_DIR = "/data";
            PDS_PORT = "4000";
            PDS_HOSTNAME = cfg.hostname;
            PDS_MODE = cfg.mode;
            PDS_IDENTITY = cfg.identity;
            PDS_HANDLE_DOMAIN = cfg.handleDomain;
            PDS_REGISTRATION = cfg.registration;
            PDS_CRAWLER = cfg.crawler;
          }
          // cfg.extraEnvironment;
        volumes = ["${cfg.dataDir}:/data"];
        ports = ["127.0.0.1:${toString cfg.port}:4000"];
      };
    };

    # the image runs as uid 1000 (its alpine `pesque` user); the bind mount must
    # be writable by it
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 1000 1000 - -"
    ];
  };
}
