# Pull-based self deploy. A timer re-locks the listed flake inputs in a checkout
# of this repo and rebuilds the host, so app commits land without editing the
# host config. Only the listed inputs float; the checkout itself is advanced by
# hand, which keeps host changes deliberate.
#
# One-time setup, on the host:
#   sudo git clone https://github.com/zoedsoupe/zoeyrinha /var/lib/zoeyrinha
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) concatMapStringsSep mkEnableOption mkIf mkOption types;
  cfg = config.selfDeploy;

  relock = concatMapStringsSep " " (name: "nix flake update ${name}") cfg.inputs;

  script = pkgs.writeShellScript "self-deploy" ''
    set -euo pipefail
    cd ${cfg.flake}

    # start from the committed lock each run so only the listed inputs float;
    # host changes stay a deliberate, manual pull
    if [ -d .git ]; then
      git checkout -- flake.lock
    fi

    nix flake update ${relock}

    # skip the rebuild when the applied inputs did not move
    if [ -f "$STATE_DIRECTORY/flake.lock" ] && cmp -s flake.lock "$STATE_DIRECTORY/flake.lock"; then
      echo "inputs unchanged since last deploy"
      exit 0
    fi

    nixos-rebuild switch --flake ${cfg.flake}#${cfg.attr}
    cp flake.lock "$STATE_DIRECTORY/flake.lock"
  '';
in {
  options.selfDeploy = {
    enable = mkEnableOption "pull-based self deploy on a timer";

    flake = mkOption {
      type = types.str;
      description = "Absolute path to a checkout of this repo (holds flake.lock).";
      example = "/var/lib/zoeyrinha";
    };

    attr = mkOption {
      type = types.str;
      default = "yby";
      description = "nixosConfigurations attribute to switch to.";
    };

    inputs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Flake inputs to re-lock each run; empty re-locks every input.";
    };

    onCalendar = mkOption {
      type = types.str;
      default = "hourly";
      description = "systemd calendar expression for the deploy timer.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.self-deploy = {
      description = "re-lock app inputs and rebuild the host";
      wants = ["network-online.target"];
      after = ["network-online.target"];
      path = [pkgs.coreutils pkgs.git pkgs.nix config.system.build.nixos-rebuild];
      serviceConfig = {
        Type = "oneshot";
        # writable state for the applied lock; inert until the checkout exists
        StateDirectory = "self-deploy";
        ConditionPathExists = "${cfg.flake}/flake.nix";
        ExecStart = script;
      };
    };

    systemd.timers.self-deploy = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.onCalendar;
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };
  };
}
