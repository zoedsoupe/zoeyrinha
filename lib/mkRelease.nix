# Build a Phoenix/Elixir release from a plain source tree. These personal apps
# ship no flake package, so we take the raw repo and build the release in Nix,
# the same shape as pesque's nix/package.nix but shared by all of them.
#
# The sandbox has no network, so the three things the ecosystem normally
# downloads at build time are pointed at nixpkgs instead:
#   * esbuild/tailwind: the hex wrappers read `config :..., :path`; a stanza
#     appended to the store copy of config.exs makes them read the store
#     binaries. No app repo is edited.
#   * rustler_precompiled NIFs (mdex_native, makeup_syntect): forced to compile
#     from source, with a Rust toolchain available.
#   * cc_precompiler NIFs (exqlite, lazy_html): forced to build locally instead
#     of fetching a precompiled .so.
{
  lib,
  beamPackages,
  rustc,
  cargo,
  pkg-config,
  esbuild,
  ...
}: let
  # these apps need Elixir >= 1.19; nixpkgs' default beam scope carries 1.18.
  # nixpkgs has flip-flopped the beam override API (.overrideScope vs .extend),
  # so pick whichever this scope carries.
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
    # rustler_precompiled NIFs present: build the crates from source
    rustler ? false,
    # tailwind hex wrapper used (build the CSS step): pass nixpkgs tailwindcss
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

        # Injected by Nix (zoeyrinha): use the esbuild/tailwind from the store instead
        # of the ones the hex wrappers download, which the sandbox blocks.
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

        # Set by the Nix build. Single node, so distribution is off and the cookie
        # exists only because the release script reads it unconditionally.
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
