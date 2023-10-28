{
  mixRelease,
  fetchMixDeps,
  erlang,
  fetchFromGitHub,
}: let
  src = fetchFromGitHub {
    owner = "lexical-lsp";
    repo = "lexical";
    rev = "v0.4.0";
    sha256 = "GKUZqRmh8a/u9oGc6WIE//P8jRkHYjPl09VlPJ/CIsY=";
  };
in
  mixRelease rec {
    inherit src;
    pname = "lexical";
    version = "development";

    mixFodDeps = fetchMixDeps {
      inherit pname version src;
      sha256 = "SQiXUjHmvtXUbHpPI1WSqsvPCauw+wiQmuwqUXOOscM=";
    };

    installPhase = ''
      runHook preInstall
      mix do compile --no-deps-check, package --path "$out"
      runHook postInstall
    '';

    preFixup = ''
      for script in $out/releases/*/elixir; do
        substituteInPlace "$script" --replace 'ERL_EXEC="erl"' 'ERL_EXEC="${erlang}/bin/erl"'
      done

      makeWrapper $out/bin/start_lexical.sh $out/bin/lexical --set RELEASE_COOKIE lexical
    '';
  }
