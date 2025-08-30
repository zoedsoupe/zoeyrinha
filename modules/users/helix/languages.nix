{pkgs, ...}: let
  inherit (pkgs.nodePackages) prettier;
  ocamlpkgs = pkgs.ocamlPackages;
in {
  elixir = {
    helix-names = ["elixir" "heex" "eex"];
    language-servers = ["expert-lsp"];
    formatter = {
      command = "mix";
      args = ["format" "--stdin-filename" "%{buffer_name}"];
    };
    auto-format = false;
    extra-servers = {
      heex = ["emmet-ls" "tailwindcss-intellisense" "uwu-colors"];
      eex = ["emmet-ls" "uwu-colors"];
    };
  };

  nix = {
    helix-names = ["nix"];
    language-servers = ["nil"];
    formatter.command = "${pkgs.alejandra}/bin/alejandra";
    extra-servers.nix = ["uwu-colors"];
  };

  typescript = {
    helix-names = ["typescript" "javascript"];
    language-servers = ["typescript-language-server"];
    formatter.command = "${prettier}/bin/prettier";
    extra-servers = {
      typescript = ["vscode-eslint-language-server" "uwu-colors"];
      javascript = ["vscode-eslint-language-server" "uwu-colors"];
    };
  };

  python = {
    helix-names = ["python"];
    language-servers = ["ruff"];
  };

  rust = {
    helix-names = ["rust"];
    language-servers = ["rust-analyzer"];
  };

  go = {
    helix-names = ["go"];
    language-servers = ["gopls"];
  };

  html = {
    helix-names = ["html"];
    language-servers = ["emmet-ls" "vscode-html-language-server"];
    extra-servers.html = ["uwu-colors"];
  };

  css = {
    helix-names = ["css" "scss"];
    language-servers = ["vscode-css-language-server"];
    extra-servers.scss = ["tailwindcss-intellisense"];
  };

  json = {
    helix-names = ["json"];
    language-servers = ["vscode-json-language-server"];
    extra-servers.json = ["uwu-colors"];
  };

  markdown = {
    helix-names = ["markdown"];
    language-servers = ["marksman"];
    extra-servers.markdown = ["uwu-colors"];
  };

  toml = {
    helix-names = ["toml"];
    language-servers = [];
    extra-servers.toml = ["uwu-colors"];
  };

  ocaml = {
    helix-names = ["ocaml"];
    language-servers = ["ocamllsp"];
    formatter.command = "${ocamlpkgs.ocamlformat}/bin/ocamlformat";
  };

  nim = {
    helix-names = ["nim"];
    language-servers = ["nimlsp"];
  };

  zig = {
    helix-names = ["zig"];
    language-servers = ["zls"];
  };

  gleam = {
    helix-names = ["gleam"];
    language-servers = ["gleam"];
  };

  lua = {
    helix-names = ["lua"];
    language-servers = ["lua-language-server"];
  };

  clojure = {
    helix-names = ["clojure"];
    language-servers = ["clojure-lsp"];
  };
}
