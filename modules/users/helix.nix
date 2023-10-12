{
  pkgs,
  lib,
  next-ls,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.helix;
  erl = pkgs.beam.interpreters.erlang_25.overrideAttrs (old: {
    configureFlags = ["--disable-jit"] ++ old.configureFlags;
  });
  beam = pkgs.beam.packagesWith erl;
  vscode-lsp = pkgs.nodePackages.vscode-langservers-extracted;
in {
  options.helix = {
    enable = mkEnableOption "Enbales Helix Editor";
  };

  config = mkIf cfg.enable {
    # home.packages = [pkgs.alejandra pkgs.nil pkgs.rust-analyzer vscode-lsp beam.elixir-ls next-ls];
    programs.helix = {
      inherit (cfg) enable;
      settings = {
        theme = "base16_transparent";
        editor = {
          line-number = "relative";
          lsp.display-messages = true;
        };
        keys.normal = {
          esc = ["collapse_selection" "keep_primary_selection"];
        };
      };
      languages = {
        language-server = {
          /*
             next-ls = {
            command = "${next-ls}/bin/next-ls";
            args = ["--stdio=true"];
          };
          */
          nil.command = "${pkgs.nil}/bin/nil";
          elixir-ls.command = "${beam.elixir-ls}/bin/elixir-ls";
          clojure-lsp.command = "${pkgs.clojure-lsp}/bin/clojure-lsp";
          rust-analyzer.command = "${pkgs.rust-analyzer}bin/rust-analyzer";
          vscode-css-language-server = {
            command = "${vscode-lsp}/bin/vscode-css-language-server";
            args = ["--stdio"];
            config = {
              provideFormatter = true;
              css = {validate = {enable = true;};};
            };
          };
          vscode-html-language-server = {
            command = "${vscode-lsp}/bin/vscode-css-language-server";
            args = ["--stdio"];
            config = {
              provideFormatter = true;
              html = {validate = {enable = true;};};
            };
          };
          vscode-json-language-server = {
            command = "${vscode-lsp}/bin/vscode-css-language-server";
            args = ["--stdio"];
            config = {
              provideFormatter = true;
              json = {validate = {enable = true;};};
            };
          };
        };

        language = [
          {
            name = "elixir";
            auto-format = true;
            /*
               language-server = {
              command = "nextls";
              args = ["--stdio=true"];
            };
            */
            formatter = {
              command = "mix";
              args = ["format" "-"];
            };
          }
          {
            name = "nix";
            auto-format = true;
            formatter = {command = "${pkgs.alejandra}/bin/alejandra";};
          }
        ];
      };
    };
  };
}
