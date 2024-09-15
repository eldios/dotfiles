{
  console.useXkbConfig = true;
  services.xserver = {
    xkb = {
      layout = "us"; #"it"
      variant = "";
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
