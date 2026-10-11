# Helix Editor Module

```
modules/users/helix/
├── default.nix     # entry point, wires the pieces into programs.helix
├── editor.nix      # editor settings + UI theme
├── languages.nix   # per-language data (grammars, servers, formatters)
├── lsp-servers.nix # programs.helix.languages.language-server
└── lib.nix         # turns languages.nix into programs.helix.languages.language
```

There is one source of truth: `languages.nix`. Every language the module can
emit is defined there, and `lib.nix` walks it. Adding a language means adding
one attrset to `languages.nix` — no other file changes.

## Enabling a language

`custom.nix` on each host is the only place you enable things:

```nix
helix = {
  enable = true;
  editor = {
    disable-line-numbers = true;
  };
  languages = {
    nix = {
      enable = true;
      wakatime.enable = true;
    };
    elixir.enable = true;
  };
};
```

`enable` and `wakatime.enable` are the only knobs read per language. The LSP
server list comes from `languages.nix`, so overriding it per host would drift
from the defaults; change `languages.nix` instead.

The editor block has two toggles: `disable-line-numbers` and
`rainbow-brackets`. `rainbow-brackets` defaults to `false` and must stay that
way on any tagged Helix: the key only exists on master, and the release nixpkgs
ships (25.07.1) rejects the whole editor table when it parses it. Turn it on
only against a master build.

## Anatomy of a language entry

```nix
elixir = {
  helix-names = ["elixir" "heex" "eex"];   # one entry each in languages.toml
  language-servers = ["expert-lsp"];
  extra-servers.heex = ["emmet-ls" "tailwindcss-intellisense" "uwu-colors"];
  formatter = {
    command = "mix";
    args = ["format" "--stdin-filename" "%{buffer_name}"];
  };
  auto-format = false;
  except-features = ["inlay-hints"];       # optional, applies to all servers
};
```

- `helix-names` — one Helix language per entry. Several can share a config.
- `language-servers` — servers for every name in `helix-names`.
- `extra-servers.<name>` — added to a single name.
- `formatter` — optional. Omit it and no formatter block is emitted.
- `auto-format` — defaults to `true`.
- `except-features` — optional, applied to every server of the language.

`heex` and `eex` carry no `grammar` field upstream, only a scope, but Helix
resolves grammar by scope, so they need their own `helix-names` entry to ship.

## Tree-sitter grammars

Helix ships roughly 300 grammars. `lib/default.nix` restricts the build to the
union of every `helix-names` in this file:

```nix
helix = prev.helix.override {
  includeGrammarIf = g: builtins.elem g.name helix-grammars;
};
```

Two things bite here:

1. The predicate receives the whole grammar attrset, not its name. Write
   `g: builtins.elem g.name [...]`. Using `n: builtins.elem n [...]` builds
   zero grammars and fails silently.
2. The list is the union over all hosts, not per host. A host that only enables
   nix still builds the grammars the other hosts use. Making it per host would
   mean a separate `pkgs` per host, which is more machinery than the handful of
   extra grammars costs.