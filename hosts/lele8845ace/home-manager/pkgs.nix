{
  pkgs,
  ...
}:
{
  home = {
    packages = (
      with pkgs.unstable;
      [
        davinci-resolve-studio
        kdePackages.kdenlive
      ]
    );
  };
} # EOF
