# noctalia HM module itself is imported in lib/default.nix (sharedModules),
# since imports cannot depend on module args.
#
# nyxvamp-veil port (palette lifted from nyxvamp-helix/nyxvamp-veil.toml).
# candidate to upstream as nyxvamp-theme/noctalia once validated on yby.
{...}: {
  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      theme = {
        mode = "dark";
        custom_palette = "nyxvamp-veil";
      };
    };

    # written to ~/.config/noctalia/palettes/nyxvamp-veil.json
    customPalettes.nyxvamp-veil = {
      dark = {
        mPrimary = "#F5C2E7"; # pink keywords
        mOnPrimary = "#1E1E2E";
        mSecondary = "#C9CBFF"; # lavender types
        mOnSecondary = "#1E1E2E";
        mTertiary = "#96CDFB"; # blue functions
        mOnTertiary = "#1E1E2E";
        mError = "#F28FAD"; # red errors
        mOnError = "#1E1E2E";
        mSurface = "#1E1E2E"; # background
        mOnSurface = "#D9E0EE"; # foreground
        mSurfaceVariant = "#2E2E3E"; # cursorline
        mOnSurfaceVariant = "#8C88A6"; # comments
        mOutline = "#494D64"; # selection gray
        mShadow = "#1E1E2E";
      };
    };
  };
}
