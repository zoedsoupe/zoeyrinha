# Grafana Alloy as the log shipper: one agent per host reading the systemd
# journal and pushing to loki. promtail is gone from nixpkgs; alloy replaces it
# with the same pipeline.
#
# everything lands in the journal already, so a single journal source covers
# all three sources we care about:
#   - service logs        _SYSTEMD_UNIT=<service>.service
#   - docker containers   the docker daemon's journald log driver (see docker.nix)
#   - caddy access logs   the `log` directive in a caddy site block
# the relabel rules lift those journal fields into loki labels so grafana can
# filter by unit/container/host/level.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.alloy;
in {
  options.alloy = {
    enable = mkEnableOption "Grafana Alloy, shipping the journal to loki";

    lokiUrl = mkOption {
      type = types.str;
      example = "http://100.64.0.1:3100";
      description = "Base URL of the loki server to push to (no trailing slash).";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra alloy (river) config appended to config.alloy, e.g. custom sources.";
    };
  };

  config = mkIf cfg.enable {
    services.alloy.enable = true;

    environment.etc."alloy/config.alloy".text = ''
      // lift journal fields into loki labels (the __journal_* ones are dropped
      // before shipping, so they must be relabeled to survive)
      loki.relabel "journal" {
        forward_to = []

        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }

        rule {
          source_labels = ["__journal_container_name"]
          target_label  = "container"
        }

        rule {
          source_labels = ["__journal__hostname"]
          target_label  = "host"
        }

        rule {
          source_labels = ["__journal_priority_keyword"]
          target_label  = "level"
        }
      }

      loki.source.journal "journal" {
        forward_to    = [loki.write.default.receiver]
        relabel_rules = loki.relabel.journal.rules
        labels        = {job = "systemd-journal"}
      }

      loki.write "default" {
        endpoint {
          url = "${cfg.lokiUrl}/loki/api/v1/push"
        }
      }

      ${cfg.extraConfig}
    '';
  };
}
