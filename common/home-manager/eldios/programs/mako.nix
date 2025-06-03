{
  services.mako = {
    enable = true;
    settings = {
      maxVisible = -1;
      layer = "overlay";
      anchor = "top-right";
      borderSize = 2;
      #borderColor = "#${config.colorScheme.colors.base0C}";
      borderRadius = 10;
      defaultTimeout = 5000;
      ignoreTimeout = false;
    };
  };

} # EOF
# vim: set ts=2 sw=2 et ai list nu
