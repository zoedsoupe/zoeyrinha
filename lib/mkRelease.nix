# Phoenix release built in Nix from a plain source tree (the apps ship no
# flake package). The sandbox has no network, so the things the ecosystem
# downloads at build time are handled instead: esbuild/tailwind binaries point
# at store copies via env vars, rustler_precompiled and cc_precompiler NIFs
# are built from source with a Rust toolchain available.
{
  lib,
  beamPackages,
  rustc,
  cargo,
  pkg-config,
  esbuild,
  ...
}: let
  # apps need Elixir >= 1.19; nixpkgs' default beam scope carries 1.18, and
  # the beam override API has flip-flopped (.overrideScope vs .extend)
  override = packages: f:
    if packages ? overrideScope
    then packages.overrideScope f
    else packages.extend f;

  beam = override beamPackages (_final: prev: {
    elixir = prev.elixir_1_20 or prev.elixir_1_19;
  });
in
  {
    pname,
    version,
    src,
    mixHash,
    # rustler_precompiled NIFs present, build the crates from source
    rustler ? false,
    # pass nixpkgs tailwindcss when the app uses the tailwind hex wrapper
    tailwind ? null,
    nativeBuildInputs ? [],
    buildInputs ? [],
    env ? {},
    ...
  }:
    beam.mixRelease {
      inherit pname version src;

      mixFodDeps = beam.fetchMixDeps {
        pname = "${pname}-deps";
        inherit version src;
        hash = mixHash;
      };

      nativeBuildInputs =
        [pkg-config]
        ++ lib.optionals rustler [rustc cargo]
        ++ nativeBuildInputs;

      inherit buildInputs;

      env =
        {
          ESBUILD_BINARY_PATH = "${esbuild}/bin/esbuild";
          # exqlite/lazy_html: skip the precompiled artefact, build in-tree
          CC_PRECOMPILER_PRECOMPILE_ONLY_LOCAL = "true";
        }
        // lib.optionalAttrs rustler {
          RUSTLER_PRECOMPILED_FORCE_BUILD_ALL = "1";
        }
        // lib.optionalAttrs (tailwind != null) {
          TAILWIND_BINARY_PATH = "${tailwind}/bin/tailwindcss";
        }
        // env;

      postPatch = ''
              cat >> config/config.exs <<'EOF'

        # Injected by Nix (zoeyrinha): store binaries, sandbox blocks downloads
        if path = System.get_env("ESBUILD_BINARY_PATH"), do: config :esbuild, path: path
        if path = System.get_env("TAILWIND_BINARY_PATH"), do: config :tailwind, path: path, version_check: false
        EOF
      '';

      # assets are a prod step nixpkgs' mixRelease does not run; write them before
      # installPhase copies priv/static into the release
      postBuild = "mix assets.deploy";

      # the release script reads a cookie unconditionally; these are single nodes,
      # so distribution is off and the cookie only satisfies the script
      postInstall = ''
              for env in "$out"/releases/*/env.sh; do
                cat >> "$env" <<'EOF'

        # Set by the Nix build: single node, cookie only satisfies the script
        export RELEASE_DISTRIBUTION="none"
        export RELEASE_COOKIE="${pname}"
        EOF
              done
      '';

      meta = {
        description = "${pname}, a Phoenix release built from source";
        platforms = lib.platforms.linux;
      };
    }
