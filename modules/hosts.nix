# The fleet. What each host does is declared by the aspects it includes in
# modules/hosts/<name>.nix; this file only says what exists.
{
  den.hosts.x86_64-linux = {
    # AMD 8845 AceMagic NUC, desktop workstation
    lele8845ace = {
      users.eldios = {};
      luksRoot = "data";
    };

    # Yoga 9i Intel laptop
    lele9iyoga = {
      users.eldios = {};
    };

    # SOX1 Xtreme Gen2 laptop, shared with a second local account
    sox1x = {
      users.eldios = {};
      users.nimbina.classes = ["user"];
    };

    # Minis NUC: storage and services, headless
    mininixos = {
      users.eldios = {};
      luksRoot = "M";
    };
  };
}
