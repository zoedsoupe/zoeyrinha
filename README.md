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
- `pesque` - self-hosted atproto PDS (native systemd release, from the pesque flake)
- `postgres` - one PostgreSQL 18 cluster shared by every service on the host
- `taina` - community private cloud (native systemd, tailnet-only, shares postgres)
- `phoenixApps` - personal Phoenix apps (zoeyrinha-web, palpite, paintbox, quintal), one module, public via cloudflare
- `glances` - system monitor, web UI + TUI
- `uptime-kuma` - uptime checks + status page
- `caddy` - tailnet-facing reverse proxy
- `cloudflared` - public ingress via cloudflare tunnel
- `niri` + `noctalia` - wayland session, off for now (enable together)
- `nextcloud` - off for now

Service state lives on per-service ZFS datasets, declared with `zfsDatasets`:

```nix
zfsDatasets = {
  "zroot/forgejo" = "/var/lib/forgejo";
  "zdata/pesque" = "/zdata/pesque";
  "zroot/anytype" = "/var/lib/anytype";
  "zdata/anytype" = "/zdata/anytype";
  "zdata/palpite" = "/zdata/palpite";
  "zroot/uptime-kuma" = "/var/lib/uptime-kuma";
};
```

Each entry is mounted via `fileSystems` and created on first boot if missing.
`zdata` is a second pool on the sda disk for bulk data, so it needs
`boot.zfs.extraPools = ["zdata"];` for systemd to import it at boot (only
`zroot` is forced by `forceImportRoot`).

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
(`cloudflared tunnel route dns yby <hostname>`). One tunnel covers hostnames in
different zones (the CNAMEs just have to live in zones on the same Cloudflare
account), so `zeetech.io` and `blog.br` ride the same tunnel. Origins are
loopback addresses; these apps bind dual-stack, so `localhost` reaches them.

### Personal apps (`phoenixApps`)

A handful of Phoenix apps (zoeyrinha-web, palpite, paintbox, quintal) run as
plain systemd services, built from source in Nix, all through one module and
reached only through the cloudflare tunnel:

```nix
phoenixApps.palpite = {
  enable = true;
  package = mkRelease {            # lib/mkRelease.nix
    pname = "palpite"; version = "0.1.0";
    src = inputs.palpite;
    mixHash = "sha256-...";        # fetchMixDeps FOD hash
  };
  host = "palpite.zeetech.io";     # PHX_HOST
  port = 4011;
  stateDir = "/zdata/palpite";     # sqlite/uploads live here; null if stateless
  environment.DATABASE_PATH = "/zdata/palpite/palpite.db";
  environmentFiles = ["/etc/phoenix/palpite.env"];
};
```

`lib/mkRelease.nix` wraps `beamPackages.mixRelease`: it wires esbuild/tailwind
to the nixpkgs binaries (the hex wrappers read `config :..., :path`, so a stanza
appended in the sandbox points them at the store), forces the rustler and
cc_precompiler NIFs to build from source, and runs the asset build. The
`mixHash` is the `fetchMixDeps` fixed-output hash; when an app's `mix.lock`
changes, the build fails with the new hash to paste in.

Secrets stay out of the store, one root-owned env file per app:

| app | file | required |
|---|---|---|
| zoeyrinha-web | `/etc/phoenix/zoeyrinha-web.env` | `SECRET_KEY_BASE` |
| palpite | `/etc/phoenix/palpite.env` | `SECRET_KEY_BASE`, `TMDB_TOKEN` |
| paintbox | `/etc/phoenix/paintbox.env` | `SECRET_KEY_BASE` |
| quintal | `/etc/phoenix/quintal.env` | `SECRET_KEY_BASE`, `QUINTAL_SESSION_KEY` |

```sh
sudo install -m600 /dev/null /etc/phoenix/palpite.env
# fill it in, then rebuild
```

ines (Cassets) is not wired yet: it holds real data on fly (sqlite + uploads)
and needs its own domain before it can move.

#### Migrating quintal off fly

quintal's only state is Postgres (no RLS, plain dump/restore). Dump, restore
into the shared cluster, and keep the keys so OAuth sessions survive:

```sh
fly proxy 5432 -a quintal-db &        # expose fly pg on localhost:5432
pg_dump -Fc "postgres://...@localhost:5432/quintal" > quintal.dump
scp quintal.dump yby:

# on yby, into the shared cluster (db and role `quintal` are ensured by the
# postgres module):
sudo -u postgres pg_restore -d quintal quintal.dump
```

Set `SECRET_KEY_BASE` and `QUINTAL_SESSION_KEY` in `/etc/phoenix/quintal.env` to
fly's values, or every OAuth session is invalidated on cutover. Then point
`quintal.blog.br` at the tunnel and flip the fly app off.

### taina (`services.taina`)

The community private-cloud server runs natively from the taina flake's own
module, tailnet-only behind caddy at `http://taina.yby` (plain http: the tailnet
is already wireguard-encrypted). `database.createLocally` reuses the shared
postgres cluster: it enables it, ensures the `taina` database, and bootstraps
the `taina_app` role through the release's own task. A first-boot oneshot
generates `/var/lib/taina/taina.env` (session key + db password, mode 0600).
Ybira storage and Nhaman backups live on the sda pool (`/zdata/ybira`,
`/zdata/backups`).

### anytype (`anytype`)

anytype has no nixpkgs module (the stack is ~5 Go services plus mongo, redis and
Garage), so this wraps the upstream
[`any-sync-dockercompose`](https://github.com/anyproto/any-sync-dockercompose)
stack in a systemd oneshot. `anytype.enable = true` brings in `docker` and the
unit; the compose file itself is cloned on the host, never vendored.

One-time setup, on the host:

```sh
sudo git clone https://github.com/anyproto/any-sync-dockercompose /var/lib/anytype
cd /var/lib/anytype
sudo cp .env.example .env
# publish the sync node on yby's tailnet IP so remote clients can reach it and
# keep bulk state off the nvme: point STORAGE_DIR straight at the zdata dataset
# (compose bind-mounts it and will not mkdir an absolute path for you)
sudo $EDITOR .env   # EXTERNAL_LISTEN_HOSTS="<yby tailnet IP>", STORAGE_DIR=/zdata/anytype
sudo make start     # generates ./etc/, starts every service
```

Note: the compose file uses bind mounts, not named volumes. `./etc` (config)
stays on `zroot/anytype`, while `${STORAGE_DIR}` (mongo, redis, garage blobs,
`anyStorage`, `networkStore`) lands wherever you point it. If that path is not a
real mount, docker silently writes to `zroot/root`; verify with
`findmnt /zdata/anytype` before `make start`.

Clients connect to the sync node directly on TCP 33010-33030, opened on
`tailscale0` only (no vhost, no public ingress). Upload `./etc/client.yml` to the
Anytype app to switch it onto this network.

The unit is gated on `/var/lib/anytype/docker-compose.yml`
(`ConditionPathExists`), so it stays inert until the clone above exists. After
that it starts with the rest of `multi-user.target` on every boot.

MongoDB 5+ needs AVX. On a CPU without it (check `grep -q avx /proc/cpuinfo`),
pin `mongo:4.4` in a `docker-compose.override.yml`.

### Monitoring (`glances`, `uptime-kuma`)

Two tailnet-only dashboards, both fronted by caddy:

- **`glances`** - system monitor with a web UI at `http://dash.yby`. Stateless,
  runs as a `DynamicUser`, binds loopback on `61208`.
- **`uptime-kuma`** - up/down checks, notifications and a status page at
  `http://status.yby`. State (sqlite + history) lives on the
  `zroot/uptime-kuma` dataset, so it survives rebuilds.

```nix
glances.enable = true;
uptime-kuma.enable = true;

caddy.apps = {
  "dash.yby" = "127.0.0.1:61208";
  "status.yby" = "127.0.0.1:3001";
};
```

Neither opens a port: the daemons bind loopback and only caddy (port 80 on
`tailscale0`) reaches them. The `dash.yby` / `status.yby` names resolve to yby's
tailnet IP like every other `*.yby` app (headscale split-horizon DNS, or
`/etc/hosts`). `glances` is also a TUI, so a quick glance needs no browser:
`ssh -t zoedsoupe@yby glances`.

uptime-kuma ships ~90 notification providers (email/SMTP, Telegram, Discord,
Slack, ntfy, Gotify, Pushover, webhooks…). Flip on the apprise CLI for the long
tail of others (Matrix, XMPP, Teams, PagerDuty, SMS gateways, Home Assistant…):

```nix
uptime-kuma.appriseSupport = true;
```

**Reaching the tailnet:** since caddy only listens on `tailscale0`, both yby and
the device you browse from must be on the same tailnet. yby already has
`services.tailscale.enable`; join it once:

```sh
sudo tailscale up     # official control plane
# later, against self-hosted headscale:
# sudo tailscale up --login-server=https://hs.<domain>
```

`dash.yby` / `status.yby` are not MagicDNS names (MagicDNS only resolves the
node, e.g. `yby`), so resolve them with a `/etc/hosts` line per client. Grab
yby's tailnet IP once:

```sh
tailscale ip -4            # on yby, e.g. 100.64.0.7
```

```
# /etc/hosts, on the client
100.64.0.7  git.yby dash.yby status.yby
```

The mac this repo manages can declare it instead of editing the file by hand:

```nix
networking.extraHosts = ''
  100.64.0.7  git.yby dash.yby status.yby
'';
```

Caveat: you can't edit `/etc/hosts` on iOS/Android, so phones fall back to
`tailscale serve` or the node name until headscale's split-horizon
`dns.extra_records` makes `*.yby` resolve everywhere.

### First accounts

`forgejo` registration is closed, so create the first admin from the CLI:

```sh
sudo -u forgejo forgejo admin user create \
  --admin --username zoedsoupe --email you@zeetech.io
```

`pesque` runs as a plain systemd service, not a container: `services.pesque`
comes from the pesque flake input, which builds the release in Nix and runs
`bin/pesque start`. State (sqlite, keys, blobs) lives on the `zdata/pesque`
dataset via `services.pesque.dataDir`. The operator tasks are oneshot units
against that directory, and the password stays out of nix in an env file:

```sh
install -m600 /dev/null /zdata/pesque/account.env
# fill in ACCOUNT_HANDLE, ACCOUNT_EMAIL, ACCOUNT_PASSWORD

sudo systemctl start pesque-account   # create an account
sudo systemctl start pesque-doctor     # federation preflight
```

