# glances, a small system monitor with both a web UI and a TUI. tailnet-only:
# the daemon binds loopback, never the firewall; caddy fronts it, so reach it at
#   caddy.apps."dash.yby" = "127.0.0.1:61208";
# the same binary is the TUI: `ssh -t zoedsoupe@yby glances`.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.glances;
in {
  options.glances = {
    enable = mkEnableOption "Glances, a small system monitor (web + TUI)";

    port = mkOption {
      type = types.port;
      default = 61208;
      description = "Loopback port the glances web server listens on.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = ["--webserver" "--bind" "127.0.0.1"];
      description = "Extra glances CLI arguments.";
    };
  };

  config = mkIf cfg.enable {
    services.glances = {
      enable = true;
      inherit (cfg) port extraArgs;
      # binds loopback; reach it through caddy on the tailnet, not a public port
      openFirewall = false;
    };
  };
}
