{pkgs, ...}: {
  # keybase deps
  home = {
    packages = with pkgs; [
      kbfs
      keybase
    ];
  };

  services = {
    keybase.enable = true;
    kbfs.enable = true;
  };
}
# EOF
# vim: set ts=2 sw=2 et ai list nu

