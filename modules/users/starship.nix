{
  lib,
  custom-config,
  starship-themes,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.starship;
in {
  options.starship = {
    enable = mkEnableOption "Enables starship shell prompt";
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      settings = let
        nyxvamp = builtins.fromTOML (builtins.readFile "${starship-themes}/nyxvamp-veil.toml");
      in {
        inherit (nyxvamp) palettes;
        palette = "nyxvamp_veil";
        scan_timeout = 50;
        command_timeout = 1500;
        add_newline = false;
        directory = {
          format = "[$path]($style)[$read_only]($read_only_style) ";
        };
        git_branch = {
          format = "[git](white)\\([$branch]($style)\\) ";
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
          "$nix_shell"
          "$direnv"
        ];
      };
    };
  };
}
