{
  pkgs,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = custom-config.zsh;
in {
  options.zsh = {
    enable = mkEnableOption "Enables ZSH config";
    sessionVariables = mkOption {
      description = "Set up environment variables";
      type = types.nullOr types.attr;
    };
    profileExtra = mkOption {
      description = "Extra config to go on .zprofile";
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      inherit (cfg) enable sessionVariables profileExtra;
      initContent = ''
        PROMPT="$\{PROMPT\}"$'\n'
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
      '';
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      enableVteIntegration = true;
      autocd = true;
      oh-my-zsh = {
        enable = true;
      };
      antidote = {
        enable = true;
        plugins = ["nyxvamp-theme/zsh path:nyxvamp-veil.zsh"];
      };
      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreAllDups = true;
        ignoreDups = true;
        ignoreSpace = true;
      };
    };
  };
}
