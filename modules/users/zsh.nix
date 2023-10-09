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
    dirHashes = mkOption {
      description = "Set up alias for common paths";
      type = types.nullOr types.attr;
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
    history.ignorePatterns = mkOption {
      description = "Ignores given patterns on history";
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = let
      fileName = "catppuccin_${cfg.theme.flavour}-zsh-syntax-highlighting";
      catppuccinThemePath = builtins.readFile (pkgs.fetchFromGitHub
        {
          owner = "catppuccin";
          repo = "zsh-syntax-highlighting";
          rev = "HEAD";
          sha256 = "Q7KmwUd9fblprL55W0Sf4g7lRcemnhjh4/v+TacJSfo=";
        }
        + /themes/${fileName}.zsh);
    in {
      inherit (cfg) enable sessionVariables dirHashes profileExtra;
      enableAutosuggestions = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      enableVteIntegration = true;
      autocd = true;
      initExtraFirst = catppuccinThemePath;
      history = {
        inherit (cfg.history) ignorePatterns;
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
      };
    };
  };
}
