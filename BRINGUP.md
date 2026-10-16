# Bring-up

Bring-up order for the two-server setup. The repo wires all the plumbing; this
file is the set of **one-time, out-of-band steps** that can't live in git:
secrets, accounts, DNS, and tailnet membership. `nixos-rebuild switch` applies
config, it does **not** do any of these.

```
eveo (public edge + headscale)
  └─ DNS A records → eveo ip
      └─ headscale user + join eveo
          └─ switch yby + join yby to the tailnet
              └─ PDS account → knot key + register → taina → tunnel
```

eveo must be up first: it terminates TLS, relays to yby over the tailnet, and is
the tailnet control plane. Nothing on yby is reachable until eveo + DNS are live.

## Roles

| host | what it runs | reachable from |
|---|---|---|
| **eveo** | headscale, caddy (public TLS), knot ssh relay | internet |
| **yby** | pesque (PDS), tangled knot, taina, forgejo, glances, phoenix apps, cloudflared, caddy (tailnet) | tailnet (except what eveo fronts) |

## Access model

| name | path | from |
|---|---|---|
| `hs.zeetech.io` | eveo headscale | internet |
| `pds.zeetech.io` | eveo caddy → yby:4000 | internet |
| `knot.zeetech.io` (`443`) | eveo caddy → yby:5555 | internet |
| `knot.zeetech.io:2222` (ssh) | eveo socket-proxyd → yby:2222 | internet |
| `zoedsoupe` / `pitaco` / `paintbox.zeetech.io` | yby cloudflared tunnel | internet |
| `git.yby`, `dash.yby`, `taina.yby` | yby caddy, port 80 on `tailscale0` | **tailnet only** |

Two caddy layers:

- **eveo caddy** terminates public TLS and reverse-proxies the PDS and knot-http
  to yby over the tailnet (plus headscale). knot **ssh** is not caddy, it's the
  `systemd-socket-proxyd` relay on `:2222`.
- **yby caddy** serves the tailnet names over plain http on `tailscale0`.

---

## 1. Install eveo

First install (provisions the disk with disko, UEFI):

```sh
nixos-anywhere --flake .#eveo root@212.38.89.221
```

Later updates, on eveo (the repo is public, so the flake can be fetched):

```sh
sudo nixos-rebuild switch --flake github:zoedsoupe/zoeyrinha#eveo
```

eveo pins its address statically (`hosts/eveo/configuration.nix`) because
HypeHost runs no DHCP; the NIC comes up on the pinned ip, matched by MAC.

## 2. DNS (Cloudflare, DNS-only)

Create **A** records → `212.38.89.221`, all **grey cloud (DNS only)**:

```
hs.zeetech.io     A   212.38.89.221
pds.zeetech.io    A   212.38.89.221
knot.zeetech.io   A   212.38.89.221
```

Do **not** orange-cloud these. caddy issues its own certificates over
TLS-ALPN-01 (needs a direct `:443`), and Cloudflare's proxy drops the PDS
firehose websocket. That is exactly why the PDS is not on the tunnel.

## 3. Headscale: user, join, split-horizon DNS

Create the user once (on eveo):

```sh
sudo headscale users create zoey
sudo headscale users list
```

Join each node. eveo is also a node, and serves its own login server, so it
joins itself with `accept-dns` off:

```sh
# on eveo
sudo tailscale up --login-server=https://hs.zeetech.io --accept-dns=false

# on yby and any client (laptop, phone)
sudo tailscale up --login-server=https://hs.zeetech.io
```

Each `tailscale up` prints a node key / login URL. Approve the node on eveo:

```sh
sudo headscale nodes list
sudo headscale nodes register --user zoey --key <nodekey>
```

This is manual on purpose: declarative auth keys are deferred until sops-nix
lands (`modules/nixos/common.nix`).

Then publish the tailnet names. MagicDNS only resolves node names (`yby`), not
`taina.yby`, and phones can't edit `/etc/hosts`, so use headscale's
split-horizon records. Grab yby's tailnet ip once (`tailscale ip -4` on yby),
then set it in `hosts/eveo/configuration.nix`:

```nix
settings.dns.extra_records = [
  { name = "yby";       type = "A"; value = "<yby tailnet ip>"; }
  { name = "taina.yby"; type = "A"; value = "<yby tailnet ip>"; }
  { name = "git.yby";   type = "A"; value = "<yby tailnet ip>"; }
  { name = "dash.yby";  type = "A"; value = "<yby tailnet ip>"; }
];
```

Rebuild eveo after editing.

## 4. Switch yby

```sh
# on yby (the repo is public, so the flake can be fetched)
sudo nixos-rebuild switch --flake github:zoedsoupe/zoeyrinha#yby
```

yby joins the tailnet (step 3) and its services become reachable over it.

## 5. PDS account (pesque)

The password never enters nix. Create the env file, fill it, then run the
oneshot units (on yby):

```sh
sudo install -m600 /dev/null /zdata/pesque/account.env
sudo -e /zdata/pesque/account.env
#   ACCOUNT_HANDLE=...
#   ACCOUNT_EMAIL=...
#   ACCOUNT_PASSWORD=...

sudo systemctl start pesque-account   # create the account
sudo systemctl start pesque-doctor     # federation preflight
```

The account's `did:plc:...` is the knot owner (step 6). Resolve it any time with:

```sh
curl -s 'https://pds.zeetech.io/xrpc/com.atproto.identity.resolveHandle?handle=<handle>' | jq -r .did
```

For a custom handle on your own domain (`@zoey.zeetech.io`), the handle domain
also needs `_atproto.<handle>` TXT → your DID, or a `/.well-known/atproto-did`
response. A reachable PDS is not enough on its own.

## 6. Knot (tangled)

`knotOwnerDid` in `hosts/yby/configuration.nix` is already set to the pesque
account's DID. Generate the master key that unseals the per-repo signing keys,
and keep a copy **off the host**:

```sh
# the knot runs as the `knot` user and reads /etc/knot/config.toml (written by
# the module), so the dir must be traversable by it; the env file stays 600
# (systemd reads EnvironmentFile as root before dropping privileges)
sudo install -d -m 755 /etc/knot
printf 'KNOT_MASTER_KEY=%s\n' "$(openssl rand -base64 32)" \
  | sudo tee /etc/knot/knot.env > /dev/null
sudo chmod 600 /etc/knot/knot.env
```

Losing that key leaves the repos readable as plain git but strips the knot of
the ability to prove atproto ownership. Back it up together with the sealed key
store it unseals (`/zdata/knot/sealed-keys`).

Rebuild yby, then register the knot in Tangled settings. The knot verifies over
its http vhost, so **eveo's caddy must be up first** (steps 1–2).

Cloning is over ssh on `2222`, not `22`, so Tangled's copy-paste url assumes a
port that isn't there:

```sh
git clone ssh://git@knot.zeetech.io:2222/did:plc:<you>/<repo>

# ~/.ssh/config, to keep the short form working
#   Host knot.zeetech.io
#       Port 2222
```

knot2's ssh server is publickey-only (no password path) and authenticates by the
ssh key published on a member's PDS. Membership is `settings.acl.admission =
"closed"` plus the DIDs you admit.

## 7. Taina

The session key lives in a root-owned env file, never in the store (on yby):

```sh
sudo install -d -m700 /etc/taina
printf 'SECRET_KEY_BASE=%s\n' "$(openssl rand -base64 48)" \
  | sudo tee /etc/taina/taina.env > /dev/null
sudo chmod 600 /etc/taina/taina.env
```

Reach the UI on the tailnet at `http://taina.yby` and create the community there
(the setup wizard). It's plain http on purpose: the tailnet is already
WireGuard-encrypted.

## 8. Forgejo first admin

Registration is closed, so create the first admin from the CLI (on yby):

```sh
sudo -u forgejo forgejo admin user create \
  --admin --username zoedsoupe --email zoey.spessanha@zeetech.io
```

## 9. Phoenix apps + Cloudflare tunnel

Secrets live in root-owned env files, never in the store (on yby):

```sh
sudo install -m600 /dev/null /etc/phoenix/blog.env      # SECRET_KEY_BASE
sudo install -m600 /dev/null /etc/phoenix/pitaco.env    # SECRET_KEY_BASE, TMDB_TOKEN
sudo install -m600 /dev/null /etc/phoenix/paintbox.env  # SECRET_KEY_BASE
```

One-time tunnel setup (the public phoenix apps only; `zeetech.io` must be a
Cloudflare zone):

```sh
cloudflared tunnel login
cloudflared tunnel create yby
sudo install -d -m700 /var/lib/cloudflared
sudo install -m600 ~/.cloudflared/<uuid>.json /var/lib/cloudflared/credentials.json

cloudflared tunnel route dns yby zoedsoupe.zeetech.io
cloudflared tunnel route dns yby pitaco.zeetech.io
cloudflared tunnel route dns yby paintbox.zeetech.io
```

`route dns` creates the proxied CNAMEs Cloudflare terminates TLS on. Origins are
loopback (`http://localhost:401x`).

## 10. (optional) anytype

Enabled on yby, inert until its compose file exists (the unit is gated on
`/var/lib/anytype/docker-compose.yml`):

```sh
sudo git clone https://github.com/anyproto/any-sync-dockercompose /var/lib/anytype
cd /var/lib/anytype
sudo cp .env.example .env
# EXTERNAL_LISTEN_HOSTS="<yby tailnet ip>", STORAGE_DIR=/zdata/anytype
sudo -e .env
sudo make start
```

---

## Cheat sheet

```sh
# eveo install / update
nixos-anywhere --flake .#eveo root@212.38.89.221
sudo nixos-rebuild switch --flake github:zoedsoupe/zoeyrinha#eveo

# yby update
sudo nixos-rebuild switch --flake github:zoedsoupe/zoeyrinha#yby

# tailnet
sudo headscale users create zoey
sudo tailscale up --login-server=https://hs.zeetech.io
sudo headscale nodes register --user zoey --key <nodekey>

# secrets
openssl rand -base64 32                      # KNOT_MASTER_KEY (knot)
sudo -e /zdata/pesque/account.env            # PDS account
# taina.env is generated on first boot
```

## Notes / gotchas

- **No console on HypeHost.** eveo is debugged blind, over ssh only. A host that
  doesn't answer is either not booting or not networking; the pinned static ip
  (`hosts/eveo/configuration.nix`) rules out the DHCP case.
- **Reboot after a reinstall** changes the ssh host key: `ssh-keygen -R
  212.38.89.221` before reconnecting.
- **A rebuild is not a bring-up.** Switching applies config; steps 2–9 are
  out-of-band and survive rebuilds, but must be done once.
