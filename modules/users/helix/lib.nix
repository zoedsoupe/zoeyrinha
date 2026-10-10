{
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkIf flatten;
  cfg = custom-config.helix;
  lspEnabled = cfg.lsp or true;
in rec {
  with-wakatime = lang-name: servers: let
    lang-cfg = cfg.languages.${lang-name} or {};
  in
    if lang-cfg.wakatime.enable or false
    then servers ++ ["wakatime-ls"]
    else servers;

  mk-helix-lang = lang-config: helix-name: let
    lang-cfg = cfg.languages.${lang-config.name or helix-name} or {};
    enabled = lang-cfg.enable or false;

    base-servers = lang-config.language-servers or [];
    extra-servers = lang-config.extra-servers.${helix-name} or [];
    all-servers =
      if lspEnabled
      then base-servers ++ extra-servers
      else [];

    # server entries are either a bare name or an attrset; normalise to attrset
    # and apply the language-level except-features to each one
    except = lang-config.except-features or [];
    final-servers = map (server: {
      name =
        if builtins.isAttrs server
        then server.name
        else server;
      except-features = (server.except-features or []) ++ except;
    }) (with-wakatime (lang-config.name or helix-name) all-servers);
  in
    mkIf enabled ({
        name = helix-name;
        auto-format = lang-config.auto-format or true;
        language-servers = final-servers;
      }
      // (lib.optionalAttrs (lang-config ? formatter) {
        formatter = lang-config.formatter;
      }));

  build-language-configs = languages:
    flatten (
      lib.mapAttrsToList (
        lang-name: lang-config:
          map (helix-name: mk-helix-lang (lang-config // {name = lang-name;}) helix-name)
          (lang-config.helix-names or [])
      )
      languages
    );
}
