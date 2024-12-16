inputs: rec {
  # generally i'm using only macos
  system = "aarch64-darwin";

  user = import ./user.nix ({inherit system;} // inputs);
  host = import ./host.nix ({inherit user system;} // inputs);
  theme = import ./theme.nix inputs;
}
