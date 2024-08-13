{
  pkgs,
  unstable,
  pkgs-22,
  ...
}:
# let
#   neovim = pkgs.callPackage ./neovim.nix {inherit (pkgs) mkNeovim;};
# in
{
  home.stateVersion = "22.11";
  home.homeDirectory = "/Users/zoedsoupe";

  programs = {
    home-manager.enable = true;
    command-not-found.enable = false;
  };

  home.packages = with pkgs; [
    # languages
    unstable.elixir_1_17
    pkgs-22.nodejs-18_x

    # package managers
    yarn

    pinentry_mac
    # neovim # my custom config neovim

    gnupg
    gitAndTools.gh
    ngrok
    tmate

    # tools
    bat
    eza # exa fork
    fd
    silver-searcher
    exercism
    awscli2
    pass
    supabase-cli
    jq
    glow
    flyctl
    earthly
    croc
    ngrok
    tree

    # others
    any-nix-shell

    # audio & video
    ffmpeg
  ];
}
