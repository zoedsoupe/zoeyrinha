# declarative zfs datasets on top of the root pool. each entry is mounted
# through fileSystems (legacy mountpoint, like zroot/root) and created on first
# boot if missing, so a fresh install never drops into emergency mode.
#
#   zfsDatasets = {
#     "zroot/forgejo" = "/var/lib/forgejo";
#     "zroot/pesque" = "/var/lib/pesque";
#   };
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.zfsDatasets;

  # /var/lib/pesque -> var-lib-pesque (systemd mount unit escaping)
  escape = mountpoint: lib.replaceStrings ["/"] ["-"] (lib.removePrefix "/" mountpoint);
in {
  options.zfsDatasets = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    example = {"zroot/forgejo" = "/var/lib/forgejo";};
    description = "ZFS dataset -> mountpoint. Each is mounted via fileSystems and created on first boot if missing.";
  };

  config = {
    fileSystems = lib.mapAttrs' (dataset: mountpoint:
      lib.nameValuePair mountpoint {
        device = dataset;
        fsType = "zfs";
      })
    cfg;

    systemd.services = lib.mapAttrs' (dataset: mountpoint:
      lib.nameValuePair "zfs-${escape mountpoint}" {
        description = "Create the ${dataset} dataset if missing";
        # default deps would add After=basic.target/sysinit.target, and since this
        # unit runs before the mount which runs before local-fs.target, while
        # systemd-tmpfiles-setup is After=local-fs.target, that closes an ordering
        # cycle. systemd breaks it by deleting the tmpfiles-setup job, so no
        # tmpfiles rule runs and every dataset root stays root:root. opt out of
        # default deps: ordering is fully pinned by zfs-import.target/<mount>.mount
        unitConfig.DefaultDependencies = false;
        after = ["zfs-import.target"];
        before = ["${escape mountpoint}.mount"];
        requiredBy = ["${escape mountpoint}.mount"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${pkgs.zfs}/bin/zfs list ${dataset} >/dev/null 2>&1 || \
            ${pkgs.zfs}/bin/zfs create -o mountpoint=legacy ${dataset}
        '';
      })
    cfg;
  };
}
