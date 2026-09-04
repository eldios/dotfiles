# The fleet. What each host does is declared by the aspects it includes in
# modules/hosts/<name>.nix; this file only says what exists.
{
  den.hosts.x86_64-linux = {
    # desktop workstation
    lele8845ace = {
      luksRoot = "data";
      users.eldios = {};
    };

    # Lenovo Yoga 9i Intel laptop
    lele9iyoga = {
      users.eldios = {};
    };

    # SOX1 Lenovo Xtreme Gen2 laptop
    sox1x = {
      users.eldios = {};
      users.nimbina.classes = ["user"];
    };

    # Minis NUC: storage and services, headless
    mininixos = {
      luksRoot = "M";
      users.eldios = {};
    };
  };
}
