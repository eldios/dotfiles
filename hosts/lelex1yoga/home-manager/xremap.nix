{ config, pkgs, xremap, ...}:

{
  imports = [
    xremap.homeManagerModules.default
  ];

  #services.xremap = {
  #  withHypr = true;
  #  withSway = true;
  #  withWlroots = true;
  #  serviceMode = "user";

  #  config = {
  #    keymap = [
  #      {
  #        name = "lele remap";
  #        remap = {
  #          "CapsLock" = "esc";
  #        };
  #      }
  #    ];
  #  };
  #};

} # EOF
# vim: set ts=2 sw=2 et ai list nu
