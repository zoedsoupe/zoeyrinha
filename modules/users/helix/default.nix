{
  pkgs,
  lib,
  custom-config,
  helix-themes,
  wakatime-ls,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.helix;

  language-defaults = import ./languages.nix {inherit pkgs lib;};
  helpers = import ./lib.nix {inherit lib custom-config;};
  lsp-servers = import ./lsp-servers.nix {
    inherit pkgs lib custom-config wakatime-ls;
  };
  editor-config = import ./editor.nix {inherit lib custom-config;};
in {
  options.helix = {
    enable = mkEnableOption "Helix Editor";

    editor = editor-config.options.helix.editor;
  };

  config = mkIf cfg.enable {
    home.packages = let
      tmux-pipe = pkgs.writeShellScriptBin "tmux-pipe" ''
        #!/bin/bash
        #
        lang=$1

        while IFS= read -r line; do
          tmux send-keys -t .+ -l " $line "
          #tmux send-keys -t .+ -H $(echo -n $line | xxd -p -u)
        done

        if [[ $lang == "ocaml" ]]; then
          tmux send-keys -t .+ ";\;"
        else
          tmux send-keys -t .+ Enter
        fi
      '';
    in [tmux-pipe];

    home.file = {
      helix-themes = {
        enable = true;
        target = ".config/helix/themes";
        source = pkgs.runCommand "helix-themes-filtered" {} ''
          mkdir -p $out
          find ${helix-themes} -name "*.toml" -exec cp {} $out/ \;
        '';
        recursive = true;
      };
    };

    programs.helix = {
      inherit (cfg) enable;
      settings = editor-config.helix-settings;

      languages = {
        language-server = lsp-servers.language-server;

        language = helpers.build-language-configs language-defaults;
      };
    };
  };
}
