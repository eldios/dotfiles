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

    # Lenovo ThinkPad X1 Extreme Gen2 laptop, shared with a second account
    sox1x = {
      users.eldios = {};
      users.nimbina.classes = ["user"];
    };

    # Minisforum NUC: storage and services, headless
    mininixos = {
      luksRoot = "M";
      users.eldios = {};
    };
  };
}
