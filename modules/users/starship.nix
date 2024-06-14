{
  pkgs,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.starship;
in {
  options.starship.enable = mkEnableOption "Enables starship shell prompt";
  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      settings =
        {
          add_newline = true;
          directory = {
            format = "[$path]($style)[$read_only]($read_only_style) ";
          };
          git_branch = {
            format = "[git](white)\\([$branch]($style)\\)";
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
              when = "env | grep -E '^DIRENV_FILE='";
            };
          };
          format = lib.concatStrings [
            "$directory"
            "$git_branch"
            "$git_status"
            "$nix_shell"
            "$elixir"
            "$nodejs"
            "$rust"
            "$direnv"
          ];
          palette = "catppuccin_macchiato";
        }
        // builtins.fromTOML (builtins.readFile (pkgs.fetchFromGitHub
          {
            owner = "catppuccin";
            repo = "starship";
            rev = "HEAD";
            sha256 = "KzXO4dqpufxTew064ZLp3zKIXBwbF8Bi+I0Xa63j/lI=";
          }
          + /palettes/macchiato.toml));
    };
  };
}
