{pkgs, ...}: {
  mk-nyxvamp-for = let
    tools = {
      rio = "c4WO83o74aTAQfy6DXoYzGpXviXzKJqniw9CyVaZFLE=";
      helix = "r+JziZaOVsZmEaaS3kpz1fTD20YKOlIjP0TDacugDS0=";
    };
  in
    {
      tool,
      format ? "toml",
      variant ? "radiance",
    }:
      (pkgs.fetchFromGitHub {
        repo = tool;
        owner = "nyxvamp-theme";
        rev = "HEAD";
        sha256 = tools.${tool};
      })
      + /nyxvamp-${variant}.${format};
}
