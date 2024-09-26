{
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
    theme = {
      enable = mkEnableOption "Enables custom theme syntax highlighting";
      name = mkOption {
        description = "Theme name for syntax highlighting";
        type = types.enum ["catppuccin"];
        default = "catppuccin";
      };
      flavour = mkOption {
        description = "Flavour for the set theme";
        type = types.enum ["latte" "frappe" "macchiato" "mocha"];
        default = "frappe";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      inherit (cfg) enable sessionVariables profileExtra;
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
        plugins = [
          "catppuccin/zsh-syntax-highlighting path:themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh"
        ];
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
