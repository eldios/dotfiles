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
        guvcview
        quickemu
        remmina
        spice
        uqm
        uvcdynctrl
        vlc
        wine
        # handwriting
        saber
        xournalpp
      ])
      ++ (with pkgs.unstable; [
        dbeaver-bin
      ])
      ++ ([
        inputs.zen-browser.packages."${system}".specific
      ]);
  };
} # EOF
