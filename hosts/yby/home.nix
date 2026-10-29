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
    (elixir-with-otp erlang_28).latest
    erlang_28

    gnupg

    # tools
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
    ((pkgs.cloudflared.override {
        buildGoModule = pkgs.buildGo127Module;
      }).overrideAttrs (finalAttrs: oldAttrs: {
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
