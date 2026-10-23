# bring-up

order: eveo up -> dns -> headscale -> yby -> self-host apps -> ops.

## 1. eveo

```sh
nixos-anywhere --flake .#eveo root@212.38.89.221
sudo nixos-rebuild switch --flake github:zoedsoupe/zoeyrinha#eveo
```

static ip (hypehost runs no dhcp; the nic comes up on the pinned address).

## 2. dns (cloudflare, grey cloud = dns only)

```
hs.zeetech.io     A   212.38.89.221 # headscale
# can add any other public service here, same ip
```

not orange-cloud: caddy issues certs over TLS-ALPN (needs direct `:443`), and cloudflare drops the pds firehose websocket.

## 3. headscale + join

```sh
sudo headscale users create zoey

sudo tailscale up --login-server=https://hs.zeetech.io --accept-dns=false   # eveo (serves its own login)
sudo tailscale up --login-server=https://hs.zeetech.io                      # yby, laptop, phone

sudo headscale nodes register --user zoey --key <nodekey>
```

tailnet names live in adguard (`http://dns.eveo` -> Filters -> DNS rewrites), no rebuild:

```
yby, git.yby, dash.yby, taina.yby   ->  <yby tailnet ip, 100.64.0.2 default>
status.eveo, dns.eveo, logs.eveo    ->  100.64.0.1
```

## 4. yby

```sh
sudo nixos-rebuild switch --flake github:zoedsoupe/zoeyrinha#yby
```

## 5. pesque (pds account)

```sh
sudo install -m600 /dev/null /zdata/pesque/account.env
sudo -e /zdata/pesque/account.env      # ACCOUNT_HANDLE, ACCOUNT_EMAIL, ACCOUNT_PASSWORD
sudo -u pesque pesque account
sudo -u pesque pesque doctor
```

the account's `did:plc:...` is the knot owner. a custom handle on your own domain also needs `_atproto.<handle>` TXT -> DID.

## 6. knot

`knotOwnerDid` (`hosts/yby/configuration.nix`) is the pesque did. generate the master key once and back it up off-host:

```sh
sudo install -d -m 755 /etc/knot
printf 'KNOT_MASTER_KEY=%s\n' "$(openssl rand -base64 32)" \
  | sudo tee /etc/knot/knot.env > /dev/null
sudo chmod 600 /etc/knot/knot.env
```

rebuild yby, then register in tangled settings (needs eveo caddy up). clone over ssh on 2222:

```sh
git clone ssh://git@knot.zeetech.io:2222/did:plc:<you>/<repo>
# ~/.ssh/config:  Host knot.zeetech.io   ->   Port 2222
```

## 7. taina

```sh
sudo install -d -m700 /etc/taina
printf 'SECRET_KEY_BASE=%s\n' "$(openssl rand -base64 48)" \
  | sudo tee /etc/taina/taina.env > /dev/null
sudo chmod 600 /etc/taina/taina.env
```

ui at `http://taina.yby`, create the community there (setup wizard).

## 8. forgejo admin

```sh
sudo -u forgejo forgejo admin user create \
  --admin --username zoedsoupe --email zoey.spessanha@zeetech.io
```

## 9. phoenix + tunnel

```sh
sudo install -m600 /dev/null /etc/phoenix/blog.env      # SECRET_KEY_BASE
sudo install -m600 /dev/null /etc/phoenix/pitaco.env    # + TMDB_TOKEN
sudo install -m600 /dev/null /etc/phoenix/paintbox.env

cloudflared tunnel login
cloudflared tunnel create yby
sudo install -d -m700 /var/lib/cloudflared
sudo install -m600 ~/.cloudflared/<uuid>.json /var/lib/cloudflared/credentials.json
cloudflared tunnel route dns yby zoedsoupe.zeetech.io
cloudflared tunnel route dns yby pitaco.zeetech.io
cloudflared tunnel route dns yby paintbox.zeetech.io
```

## 10. ops (eveo)

```sh
# gatus email (icloud app-specific password)
sudo install -d -m 750 /etc/gatus
printf 'GATUS_SMTP_PASSWORD=%s\n' '<app-specific-password>' \
  | sudo tee /etc/gatus/gatus.env > /dev/null
sudo chmod 600 /etc/gatus/gatus.env

# grafana
sudo install -d -m 750 /etc/grafana
printf '%s\n' "$(openssl rand -base64 18)" | sudo tee /etc/grafana/admin-password > /dev/null
printf '%s\n' "$(openssl rand -hex 32)"    | sudo tee /etc/grafana/secret-key > /dev/null
sudo chown grafana:grafana /etc/grafana/admin-password /etc/grafana/secret-key
sudo chmod 600 /etc/grafana/admin-password /etc/grafana/secret-key
```
