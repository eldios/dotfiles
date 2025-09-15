{
  inputs,
  pkgs,
  ...
}:
let
  system = "x86_64-linux";
in
{
  home = {
    packages =
      (with pkgs; [
        barrier
        dbeaver-bin
        guvcview
        quickemu
        remmina
        spice
        uqm
        uvcdynctrl
        vlc
        wine
      ])
      ++ (with pkgs.unstable; [
        #davinci-resolve-studio
      ])
      ++ ([
        inputs.zen-browser.packages."${system}".specific
      ]);
  };
} # EOF
