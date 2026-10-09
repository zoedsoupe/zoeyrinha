# Per-host installer additions. Imported by `mkISO { host = "..."; }`, which
# passes the host name through specialArgs.
#
# It deliberately does NOT import the host's configuration.nix: that describes
# the installed system (ZFS root, systemd-boot, services) and would fight the
# live environment. Instead the whole flake is embedded read-only so the target
# can be installed with:
#
#   nixos-install --flake /etc/zoeyrinha#<host>
{
  config,
  lib,
  pkgs,
  host,
  ...
}: let
  # Repo root as a store path. Skip VCS/tooling dirs; the wallpapers submodule
  # is empty in this checkout and nothing in the flake references it.
  flakeSrc = builtins.path {
    path = ../..;
    name = "zoeyrinha";
    filter = path: _type: let
      base = baseNameOf (toString path);
    in
      !(builtins.elem base [".git" ".direnv" "result" "wallpapers"]);
  };
in {
  # distinct artifact name + boot label so a yby ISO does not collide with
  # minimal-iso (both would otherwise be nixos-minimal-<label>-<system>.iso).
  # mkForce: the iso module assigns image.baseName at normal priority.
  image.baseName = lib.mkForce "nixos-${host}-installer-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
  isoImage.appendToMenuLabel = " ${host} Installer";

  # booted live env exposes the flake here, read-only
  environment.etc."zoeyrinha".source = flakeSrc;

  # yby roots on ZFS (zroot/root), so the live env needs the zfs userspace and
  # kernel module to create the pool before nixos-install. gptfdisk/nvme-cli
  # come from core.nix.
  boot.supportedFilesystems = ["zfs"];
  # no zfs root in the live env; silences the 26.11 default-change warning
  boot.zfs.forceImportRoot = false;
  environment.systemPackages = with pkgs; [zfs];

  # quick reference once you are logged in
  environment.etc."install-note".text = ''
    Installer ISO for host: ${host}
    Flake embedded read-only at /etc/zoeyrinha

      1. partition + create the pool, mount it at /mnt
         (zroot/root as /, vfat label BOOT as /boot, per the placeholder
          hardware-configuration.nix)
      2. nixos-generate-config --root /mnt
      3. copy the flake somewhere writable and drop in the real hw config:
           cp -r /etc/zoeyrinha /tmp/zoeyrinha && chmod -R u+w /tmp/zoeyrinha
           cp /mnt/etc/nixos/hardware-configuration.nix \
              /tmp/zoeyrinha/hosts/${host}/hardware-configuration.nix
      4. nixos-install --flake /tmp/zoeyrinha#${host}
      5. commit the real hardware-configuration.nix back to the repo
  '';
}
