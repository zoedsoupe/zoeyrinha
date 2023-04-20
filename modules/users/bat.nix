{ pkgs, ... }:

{
  programs.bat =
    let
      themeFile = "Catppuccin-macchiato.tmTheme";
    in
    {
      enable = true;
      config = {
        theme = "catppuccin";
      };
      themes = {
        catppuccin = builtins.readFile (pkgs.fetchFromGitHub
          {
            owner = "catppuccin";
            repo = "bat";
            rev = "HEAD";
            sha256 = "6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
          } + /${themeFile});
      };
    };
}
