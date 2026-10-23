# zoeyrinha

personal nixos + nix-darwin config.

| host | system | is |
|---|---|---|
| `yby` | nixos, zfs | tailnet + homelab |
| `eveo` | nixos, ext4 | reverse proxy + headscale brain |
| `personal-mac` | darwin | my laptop |

## build & deploy

```sh
./nix-build yby                # build only (personal | iso | yby-iso | yby | eveo)
./nix-build eveo
sudo nixos-rebuild switch --flake github:zoedsoupe/zoeyrinha#yby
sudo nixos-rebuild switch --flake github:zoedsoupe/zoeyrinha#eveo
darwin-rebuild switch --flake .#zoedsoupe-mac
```

first install: [BRINGUP.md](BRINGUP.md).

## add a tailnet service

bind loopback, front with caddy, add the name in adguard.

```nix
# hosts/yby/configuration.nix
caddy.apps."foo.yby" = "127.0.0.1:PORT";
```

adguard (`http://dns.eveo`) -> Filters -> DNS rewrites: `foo.yby -> 100.64.0.2`. reach it at `http://foo.yby`.

## add a public service

direct tls (eveo caddy):

```nix
# hosts/eveo/configuration.nix, services.caddy.virtualHosts
"foo.zeetech.io".extraConfig = ''
  log
  reverse_proxy http://${ybyTailnetIp}:PORT
'';
```

cloudflare dns: A -> `212.38.89.221`, grey cloud. tunneled instead (no inbound port):

```nix
# hosts/yby/configuration.nix
cloudflared.apps."foo.zeetech.io" = "http://localhost:PORT";
```

## add a phoenix app (yby)

```nix
phoenixApps.foo = {
  enable = true;
  package = mkRelease { pname = "foo"; version = "0.1.0"; src = inputs.foo; mixHash = "sha256-..."; };
  host = "foo.zeetech.io";
  port = 4015;
  environmentFiles = ["/etc/phoenix/foo.env"];
};
```

+ `cloudflared.apps` + an env file (see secrets). `mixHash` is the fetchMixDeps FOD the build prints when `mix.lock` changes.

## add a monitor

```nix
gatus.endpoints = [{ name = "foo"; group = "yby"; url = "http://foo.yby"; }];
```

## logs

alloy ships the journal (services, docker, caddy) to loki already, nothing to add per service. for caddy access logs on a site, put `log` in its block.

## docker

```nix
docker = { enable = true; dataRoot = "/zdata/docker"; };
docker.composeProjects.foo.directory = "/srv/foo";
```

## dns

adguard on eveo is the tailnet resolver; headscale forwards to it and keeps magic dns node names. records live in the adguard UI (`http://dns.eveo`), not nix.
