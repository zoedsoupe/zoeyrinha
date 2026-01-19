{
  pkgs,
  lib,
  wakatime-ls,
  custom-config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (pkgs.nodePackages) vscode-langservers-extracted typescript-language-server;
  vscode-lsp = vscode-langservers-extracted;
  ts-server = typescript-language-server;
  ocamlpkgs = pkgs.ocamlPackages;
  cfg = custom-config.helix;

  rust = pkgs.rust-bin.stable.latest;

  get-lang-config = name: cfg.languages.${name} or {};
in {
  language-server = {
    gleam = mkIf (get-lang-config "gleam").enable {
      command = "${pkgs.gleam}/bin/gleam";
    };

    typescript-language-server = mkIf (get-lang-config "typescript").enable {
      command = "${ts-server}/bin/typescript-language-server";
      args = ["--stdio"];
    };

    lua-language-server = mkIf (get-lang-config "lua").enable {
      command = "${pkgs.lua-language-server}/bin/lua-language-server";
    };

    ocamllsp = mkIf (get-lang-config "ocaml").enable {
      command = "${ocamlpkgs.ocaml-lsp}/bin/ocamllsp";
    };

    nil = mkIf (get-lang-config "nix").enable {
      command = "${pkgs.nil}/bin/nil";
    };

    zls = mkIf (get-lang-config "zig").enable {
      command = "${pkgs.zls}/bin/zls";
    };

    nimlsp = mkIf (get-lang-config "nim").enable {
      command = "${pkgs.nimlsp}/bin/nimlsp";
    };

    clojure-lsp = mkIf (get-lang-config "clojure").enable {
      command = "${pkgs.clojure-lsp}/bin/clojure-lsp";
    };

    rust-analyzer = mkIf (get-lang-config "rust").enable {
      command = "${rust.rust-analyzer}/bin/rust-analyzer";
    };

    gopls = mkIf (get-lang-config "go").enable {
      command = "${pkgs.gopls}/bin/gopls";
    };

    emmet-ls = mkIf (get-lang-config "html").enable {
      command = "${pkgs.emmet-ls}/bin/emmet-ls";
      args = ["--stdio"];
    };

    vscode-css-language-server = mkIf (get-lang-config "css").enable {
      command = "${vscode-lsp}/bin/vscode-css-language-server";
      args = ["--stdio"];
      config = {
        provideFormatter = true;
        css = {
          validate.enable = true;
          lint.unknownAtRules = "ignore";
        };
      };
    };

    vscode-html-language-server = mkIf (get-lang-config "html").enable {
      command = "${vscode-lsp}/bin/vscode-html-language-server";
      args = ["--stdio"];
      config = {
        provideFormatter = true;
        html.validate.enable = true;
      };
    };

    vscode-json-language-server = mkIf (get-lang-config "json").enable {
      command = "${vscode-lsp}/bin/vscode-json-language-server";
      args = ["--stdio"];
      config = {
        provideFormatter = true;
        json.validate.enable = true;
      };
    };

    wakatime-ls = mkIf (lib.any (name: (get-lang-config name).wakatime.enable or false) (builtins.attrNames cfg.languages)) {
      command = "${wakatime-ls}/bin/wakatime-ls";
    };

    marksman.command = "${pkgs.marksman}/bin/marksman";

    ruff = mkIf (get-lang-config "python").enable {
      command = "${pkgs.ruff}/bin/ruff";
      args = ["server"];
    };

    tailwindcss-intellisense = mkIf (get-lang-config "css").enable {
      command = "${pkgs.tailwindcss-language-server}/bin/tailwindcss-language-server";
    };

    vscode-eslint-language-server = mkIf (get-lang-config "typescript").enable {
      command = "${vscode-lsp}/bin/vscode-eslint-language-server";
      args = ["--stdio"];
    };

    expert-lsp = mkIf (get-lang-config "elixir").enable {
      command = "${pkgs.expert-lsp}/bin/expert";
      args = ["--stdio"];
    };

    uwu-colors = {
      command = "${pkgs.uwu-colors}/bin/uwu_colors";
      args = ["--named-completions-mode" "full" "--color-collection" "colorhexa" "--variable-completions"];
    };
  };
}
