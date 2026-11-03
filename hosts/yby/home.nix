{
  pkgs,
  unstable,
  ...
}: {
  home.stateVersion = "26.05";
  home.homeDirectory = "/home/zoedsoupe";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  # no wayland shell on a headless box; flip on together with niri.enable
  # in configuration.nix when a monitor shows up
  noctalia.enable = false;

  home.packages = with pkgs; [
    (pkgs.beam-overlay.mkToolchain {
      elixir.version = "1.20.5";
      erlang-otp.version = "29";
    })

    gnupg

    # tools
    atuin
    eza
    fd
    jq
    just
    zip
    unzip
    forgejo
    vim
    silver-searcher
    unstable.opencode
    # patch de seguranca eMudhra (emSign)
    (pkgs.cloudflared.overrideAttrs (finalAttrs: oldAttrs: {
      version = "2026.10.4";

      src = pkgs.fetchFromGitHub {
        owner = "cloudflare";
        repo = "cloudflared";
        rev = finalAttrs.version;
        sha256 = "sha256-HuKjytbGutwjUMepozeUmeeHczm4qI7vMvS+hgLsaZ0=";
      };

      preCheck = "";
      doCheck = false;
      proxyVendor = true;
      configureFlags = ["-mod=mod"];
      makeFlags = ["-mod=mod"];

      vendorHash = "sha256-+A92cHKGNThxlJyrMo5RhizLclKeh3ovjuraZBU262M=";
    }))
  ];
}
