{pkgs, ...}: {
  mk-nyxvamp-for = {
    tool,
    format ? "toml",
    variant ? "radiance",
  }:
    (pkgs.fetchFromGitHub {
      repo = tool;
      owner = "nyxvamp-theme";
      rev = "HEAD";
      sha256 = "c4WO83o74aTAQfy6DXoYzGpXviXzKJqniw9CyVaZFLE=";
    })
    + /nyxvamp-${variant}.${format};
}
