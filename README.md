<h1 align="center">
  <br />
  Zoey's Dotfiles
  <br />
</h1>

<div align="center">
  <strong>Zoey's dotfiles config! Everything you need to have a productive environment for web developing and some hackings!</strong>
</div>

<div align="center">
  <strong>Powered by</strong>
  <br>
  <img src="https://img.shields.io/badge/-NixOS-informational?style=for-the-badge&logo=NixOS&logoColor=white&color=5277C3" alt="NixOS" />
</div>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#how-to-use">How to use</a> •
  <a href="#utilities">Utilities</a>
</p>

This repo is a fresh start from old config [nixnad](https://github.com/zoedsoupe/nixnad).

<a id="features" />

## Features

- **macOS Support**: Full Darwin/nix-darwin configuration with automatic app linking
- **Modular Configuration**: Each program has its own toggleable module
- **Terminal**: Ghostty, configured from the host's `custom.nix`
- **Development Tools**: Helix and Zed, both nyxvamp-themed
- **Shell Setup**: Zsh with Starship prompt
- **CLI Utilities**: fzf, zoxide, bat, xplr, direnv, and more
- **Helix grammars**: only the tree-sitter grammars the enabled languages need
  are built, not all ~300 Helix ships
- **ISO Builder**: minimal install media, plus per-host installers (`yby-iso`) that carry the flake + ZFS tooling

## How to use

### Quick Build Script

The easiest way to build configurations is using the `nix-build` script:

```sh
./nix-build personal   # Build personal Mac configuration
./nix-build iso        # Build minimal ISO
./nix-build yby-iso    # Build yby installer ISO (carries the flake + ZFS tools)
./nix-build yby        # Build yby (homelab) without activating
./nix-build eveo       # Build eveo (vps) without activating
```

### Manual Build Commands

#### macOS (Darwin) Configuration

```sh
darwin-rebuild switch --flake .#zoedsoupe-mac  # For personal machine
```

#### Minimal ISO

```sh
nix build .#nixosConfigurations.minimal-iso.config.system.build.isoImage
```

The ISO will be available at `./result/iso/`.

#### yby installer ISO

```sh
nix build .#nixosConfigurations.yby-iso.config.system.build.isoImage
```

The ISO lands at `./result/iso/nixos-yby-installer-*.iso`. It boots the minimal
installer with the whole flake embedded read-only at `/etc/zoeyrinha` and ZFS
tooling in the live env.

##### Disk layout (manual, ZFS)

`hosts/yby/hardware-configuration.nix` expects a pool named `zroot` with a
`zroot/root` dataset on `/`, and a vfat ESP labelled `BOOT` on `/boot`. For a
single disk (`/dev/nvme0n1` — adjust to your device):

```sh
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary 512MiB 100%

mkfs.vfat -n BOOT /dev/nvme0n1p1

zpool create -o ashift=12 -o altroot=/mnt \
  -O compression=lz4 -O xattr=sa -O acltype=posixacl \
  zroot /dev/nvme0n1p2
zfs create -o mountpoint=legacy zroot/root
mount -t zfs zroot/root /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot
```

##### Install

```sh
nixos-generate-config --root /mnt
cp -r /etc/zoeyrinha /tmp/zoeyrinha && chmod -R u+w /tmp/zoeyrinha
cp /mnt/etc/nixos/hardware-configuration.nix \
   /tmp/zoeyrinha/hosts/yby/hardware-configuration.nix
nixos-install --flake /tmp/zoeyrinha#yby

# hand the pool cleanly to the installed system; without this the first boot
# refuses to import zroot (forceImportRoot now covers it, but exporting is
# the correct thing to do)
umount -R /mnt
zpool export zroot
```

`/etc/install-note` on the live system repeats these steps.

## Homelab (yby)

`yby` is a headless NixOS host (SSH/tailnet only). Its services are toggleable
modules, flipped from `hosts/yby/configuration.nix`:

- `anytype` - anytype self-hosted sync stack (docker)
- `forgejo` - git forge (sqlite, LFS, daily dump)
- `pesque` - self-hosted atproto PDS (OCI container)
- `caddy` - tailnet-facing reverse proxy
- `cloudflared` - public ingress via cloudflare tunnel
- `niri` + `noctalia` - wayland session, off for now (enable together)
- `nextcloud` - off for now

Service state lives on per-service ZFS datasets, declared with `zfsDatasets`:

```nix
zfsDatasets = {
  "zroot/forgejo" = "/var/lib/forgejo";
  "zroot/pesque" = "/var/lib/pesque";
};
```

Each entry is mounted via `fileSystems` and created on first boot if missing.

### Tailnet apps (`caddy`)

Anything only your devices need gets a domain -> upstream entry. Served over
plain HTTP on purpose: the tailnet is already wireguard-encrypted, so TLS inside
it buys nothing until a service goes public.

```nix
caddy = {
  enable = true;
  apps = {
    "git.yby" = "127.0.0.1:3000";   # forgejo
    # "proj.yby" = "127.0.0.1:3000";
  };
};
```

The domain must resolve to yby's tailnet IP: headscale's split-horizon
`dns.extra_records`, or `/etc/hosts` on a client until that lands.

### Public apps (`cloudflared`)

For services the internet must reach. Custom domains work here (unlike Tailscale
Funnel). The tunnel is outbound-only: no inbound port, no exposed home IP, and
it works behind CGNAT. Cloudflare terminates TLS and can read the traffic, so
keep this to public, non-sensitive services.

One-time tunnel setup, off-host:

```sh
cloudflared tunnel login
cloudflared tunnel create yby
install -m 600 ~/.cloudflared/<uuid>.json /var/lib/cloudflared/credentials.json
cloudflared tunnel route dns yby pds.zeetech.io
```

Then declare the ingress in `hosts/yby/configuration.nix`:

```nix
cloudflared = {
  enable = true;
  apps = {
    "pds.zeetech.io" = "http://localhost:4000";   # pesque
  };
};
```

Add more apps by appending entries and routing each hostname
(`cloudflared tunnel route dns yby <hostname>`). Origins are loopback
addresses, so the app must listen on `127.0.0.1` (pesque does).

### First accounts

`forgejo` registration is closed, so create the first admin from the CLI:

```sh
sudo -u forgejo forgejo admin user create \
  --admin --username zoedsoupe --email you@zeetech.io
```

`pesque` likewise (password stays out of nix):

```sh
docker exec \
  -e PDS_SERVE=false \
  -e ACCOUNT_HANDLE=pds.zeetech.io \
  -e ACCOUNT_EMAIL=you@zeetech.io \
  -e ACCOUNT_PASSWORD='…' \
  pesque /app/bin/pesque eval \
  'Pesque.Release.boot!(); case Pesque.Release.create_account_from_env() do :ok -> :ok; :error -> System.halt(1) end'
```

Then `docker exec pesque /app/bin/pesque eval 'Pesque.Doctor.run()'` for the
federation preflight.

