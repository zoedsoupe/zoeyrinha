{
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption;
  cfg = custom-config.starship;
in {
  options.starship = {
    enable = mkEnableOption "Enables starship shell prompt";

    catppuccin-theme = mkOption {
      default = "macchiato";
      description = "The catppuccin theme to apply on starship";
      type = lib.types.nullOr lib.types.enum ["macchiato" "frappe" "latte" "mocha"];
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      settings = {
        scan_timeout = 50;
        command_timeout = 1500;
        add_newline = true;
        directory = {
          format = "[$path]($style)[$read_only]($read_only_style) ";
        };
        git_branch = {
          format = "[git](white)\\([$branch]($style)\\) ";
        };
        git_status = {
          deleted = "";
          ahead = "$\{count\}";
          behind = "$\{count\}";
          format = "[$all_status$ahead_behind]($style) ";
        };
        nix_shell = {
          format = "[nix](white)\\([$state( \($name\))]($style)\\) ";
          pure_msg = "λ";
          impure_msg = "⎔";
        };
        elixir = {
          format = "[elixir](white)\\([$version]($style)\\) ";
        };
        nodejs = {
          format = "[node](white)\\([$version]($style)\\) ";
        };
        rust = {
          format = "[rust](white)\\([$version]($style)\\) ";
        };
        custom = {
          direnv = {
            format = "[\\[direnv\\]]($style) ";
            style = "fg:yellow dimmed";
            when = "[[ -f .envrc ]]";
          };
        };
        format = lib.concatStrings [
          "$directory"
          "$git_branch"
          "$elixir"
          "$nodejs"
          "$rust"
          "$direnv"
        ];
      };
    };
  };
}
