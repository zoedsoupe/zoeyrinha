# rustler_precompiled rejects a source build here (its cargo deps are not
# vendored) and cannot download at build time (the sandbox has no network). It
# does reuse an artifact already in its cache, so fetch the precompiled tarballs
# as fixed-output derivations and lay them out the way it expects: flat, named
# exactly as in the dependency's checksum file, pointed at by
# RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH.
{
  lib,
  fetchurl,
  runCommand,
}: {
  # [ { url = "<release base>"; files = { "<archive name>" = "<sri sha256>"; }; } ]
  deps,
}:
runCommand "rustler-precompiled-cache" {} (
  lib.concatStringsSep "\n" (
    ["mkdir -p $out"]
    ++ lib.concatMap (dep:
      lib.mapAttrsToList (name: hash: "ln -s ${
        fetchurl {
          url = "${dep.url}/${name}";
          inherit hash;
        }
      } $out/${name}")
      dep.files)
    deps
  )
)
