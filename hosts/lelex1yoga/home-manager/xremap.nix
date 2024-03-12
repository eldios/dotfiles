{ config, pkgs, inputs, ...}:

{
  imports = [
    inputs.xremap.homeManagerModules.default
  ];

  users.users.eldios.extraGroups = [
    "input" # needed by xRemap
    "uinput" # needed by xRemap
  ];

  services.xremap = {
    withWlroots = true;

    config = {
      keymap = [
        {
          name = "lele remap";
          remap = {
            "CapsLock" = "esc";
            "C-Shift-CapsLock" = "CapsLock";
          };
        }
      ];
    };
  }; # EOM services

} # EOF
# vim: set ts=2 sw=2 et ai list nu
