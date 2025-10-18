{
  pkgs,
  ...
}:
{
  home = {
    packages = (
      with pkgs.unstable;
      [
        #davinci-resolve-studio
      ]
    );
  };
} # EOF
