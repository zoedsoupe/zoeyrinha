{
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkIf flatten;
  cfg = custom-config.helix;
in rec {
  with-wakatime = lang-name: servers: let
    lang-cfg = cfg.languages.${lang-name} or {};
  in
    if lang-cfg.wakatime.enable or false
    then servers ++ ["wakatime-ls"]
    else servers;

  any-wakatime-enabled = lib.any (
    name: let
      lang-cfg = cfg.languages.${name} or {};
    in
      lang-cfg.wakatime.enable or false
  ) (lib.attrNames cfg.languages);

  mk-helix-lang = lang-config: helix-name: let
    lang-cfg = cfg.languages.${lang-config.name or helix-name} or {};
    enabled = lang-cfg.enable or false;

    base-servers = lang-config.language-servers or [];
    extra-servers = lang-config.extra-servers.${helix-name} or [];
    all-servers = base-servers ++ extra-servers;
    final-servers = with-wakatime (lang-config.name or helix-name) all-servers;
  in
    mkIf enabled ({
        name = helix-name;
        auto-format = lang-config.auto-format or true;
        language-servers = final-servers;
      }
      // (lib.optionalAttrs (lang-config ? formatter) {
        formatter = lang-config.formatter;
      }));

  process-language-overrides = lang-name: overrides: let
    base-config = import ./languages.nix {
      inherit lib;
      pkgs = null;
    };
    lang-config = base-config.${lang-name} or {};
  in
    lang-config // overrides;

  build-language-configs = languages: language-overrides:
    flatten (
      lib.mapAttrsToList (
        lang-name: lang-config: let
          final-config =
            if language-overrides ? ${lang-name}
            then process-language-overrides lang-name language-overrides.${lang-name}
            else lang-config;
        in
          map (helix-name: mk-helix-lang (final-config // {name = lang-name;}) helix-name)
          (final-config.helix-names or [])
      )
      languages
    );

  merge-lsp-configs = configs:
    lib.foldl' (acc: cfg: acc // cfg) {} configs;
}
