{pkgs, ...}: {
  config = {
    programs.nnn = {
      enable = true;
      bookmarks = {
        d = "~/Documents";
        D = "~/Downloads";
        p = "~/Pictures";
        v = "~/Videos";
      };
      plugins = {
        mappings = {
          z = "autojump";
          y = "cbcopy-mac";
          p = "cbpaste-mac";
          ff = "fzopen";
          su = "suedit";
          dx = "xdgdefault";
        };
        src =
          (pkgs.fetchFromGitHub {
            owner = "jarun";
            repo = "nnn";
            rev = "v4.0";
            sha256 = "sha256-Hpc8YaJeAzJoEi7aJ6DntH2VLkoR6ToP6tPYn3llR7k=";
          })
          + "/plugins";
      };
    };
  };
}
