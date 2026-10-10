# zoeyrinha-web (the blog). Its markdown and syntax-highlighting NIFs
# (mdex_native, makeup_syntect) are published only as precompiled artifacts, so
# seed rustler_precompiled's cache with them (see lib/rustlerCache.nix). Bump
# the versions/hashes together when mix.lock changes.
{
  lib,
  fetchurl,
  runCommand,
  stdenv,
  tailwindcss_4,
  mkRelease,
  src,
}: let
  target =
    {
      x86_64-linux = "x86_64-unknown-linux-gnu";
      aarch64-darwin = "aarch64-apple-darwin";
    }
    .${
      stdenv.hostPlatform.system
    }
    or (throw "zoeyrinha-web: no precompiled NIFs pinned for ${stdenv.hostPlatform.system}");

  mdex_native = {
    "x86_64-unknown-linux-gnu" = {
      "libmdex_native_nif-v0.2.8-nif-2.15-x86_64-unknown-linux-gnu.so.tar.gz" = "sha256-ljI4QU6lprtFRZhsCcgl3/zXXpMn25q3MG+xqmy9TOw=";
      "libmdex_native_nif-v0.2.8-nif-2.15-x86_64-unknown-linux-gnu--legacy_cpu.so.tar.gz" = "sha256-Mmi5stNIeTFQX9rScJJNoF4xbFneRCE16NBKdVcoaaM=";
      "libmdex_native_nif-v0.2.8-nif-2.15-x86_64-unknown-linux-gnu--legacy_cpu_lumis.so.tar.gz" = "sha256-/iFKEMR36r6oLZ+JV8Bnxss1jPGGco9WW3gTj7AL4dI=";
      "libmdex_native_nif-v0.2.8-nif-2.15-x86_64-unknown-linux-gnu--legacy_cpu_syntect.so.tar.gz" = "sha256-6SbGn9KmjsjpL2lWcMSOR2QgcwUb+HnX5gV+5/c/ddE=";
      "libmdex_native_nif-v0.2.8-nif-2.15-x86_64-unknown-linux-gnu--lumis.so.tar.gz" = "sha256-R7nfBwgrkpwqQ8Ph3MHpUtdT2nt0q8/v2pH44M+7tsc=";
      "libmdex_native_nif-v0.2.8-nif-2.15-x86_64-unknown-linux-gnu--syntect.so.tar.gz" = "sha256-M6gaT8dofCH+LuQkw6QWd2cZ5UiZPPCvKFnfd3ULC4k=";
    };
    "aarch64-apple-darwin" = {
      "libmdex_native_nif-v0.2.8-nif-2.15-aarch64-apple-darwin.so.tar.gz" = "sha256-OTjknF3eGpJgO3l10kh1mMfp1U7l1/RITNgTzK+l2Q0=";
      "libmdex_native_nif-v0.2.8-nif-2.15-aarch64-apple-darwin--lumis.so.tar.gz" = "sha256-GOMbj9WESxsE29bE3g3h16q5i/ky6Km35ekYl/oTuaI=";
      "libmdex_native_nif-v0.2.8-nif-2.15-aarch64-apple-darwin--syntect.so.tar.gz" = "sha256-UU809llZ9YgiXkFa2x0ElTX/7KwQgxGlxadXYjXqKvw=";
    };
  };

  makeup_syntect = {
    "x86_64-unknown-linux-gnu" = {
      "libmakeup_syntect-v0.1.4-nif-2.15-x86_64-unknown-linux-gnu.so.tar.gz" = "sha256-5ZlXYQqK/+aaslzUNXTXutSv5oYOec1X+nBXSW4ntyo=";
    };
    "aarch64-apple-darwin" = {
      "libmakeup_syntect-v0.1.4-nif-2.15-aarch64-apple-darwin.so.tar.gz" = "sha256-IMUDGWWjJa4QzynYXmXWfVwAgMkt2nJhcfzJ7xTn7tk=";
    };
  };

  rustlerCache = import ../rustlerCache.nix {inherit lib fetchurl runCommand;} {
    deps = [
      {
        url = "https://github.com/leandrocp/mdex_native/releases/download/v0.2.8";
        files = mdex_native.${target};
      }
      {
        url = "https://github.com/elixir-makeup/makeup_syntect/releases/download/v0.1.4";
        files = makeup_syntect.${target};
      }
    ];
  };
in
  mkRelease {
    pname = "zoeyrinha-web";
    version = "0.1.0";
    inherit src;
    mixHash = "sha256-9PPLaKDiSMSjcBGwE8jp56kh06VpRe7SR/SPob5bYCk=";
    tailwind = tailwindcss_4;
    inherit rustlerCache;
  }
