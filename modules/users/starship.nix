{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.starship;
in
{
  options.zoedsoupe.starship = {
    enable = mkOption {
      description = "Enable Starship";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.starship = {
      inherit (cfg) enable;
      enableFishIntegration = true;
      settings = {
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
          format = "[nix](white)\\([$version]($style)\\) ";
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
        elm = {
          format = "[elm](white)\\([$version]($style)\\) ";
        };
        lua = {
          format = "[lua](white)\\([$version]($style)\\) ";
        };
        character = {
          success_symbol = "\n[](bold green)";
          error_symbol = "\n[](bold red)";
          vicmd_symbol = "\n[](bold green)";
        };
        format = lib.concatStrings [
          "$directory"
          "$git_branch"
          "$git_status"
          "$nix_shell"
          "$elixir"
          "$elm"
          "$nodejs"
          "$haskell"
          "$rust"
          "$character"
        ];
      };
    };
  };
}
