{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.xplr = {
    enable = mkEnableOption "Enables TUI File Manager";
  };

  config = {
    programs.xplr = {
      enable = true;
    };
  };
}
