# Everything a graphical session needs regardless of compositor: portals,
# keyring, bluetooth, GTK/Qt theming plumbing, the GUI application set and
# the user services that only make sense with a display.
{
  den.aspects.desktop-gui = {
    nixos.imports = [
      ./_desktop-gui/desktop-gui.nix
      ./_desktop-gui/locale_gui.nix
    ];

    homeManager = {
      imports = [
        ./_desktop-gui/packages_common_gui.nix
        ./_desktop-gui/packages_linux_gui.nix
        ./_desktop-gui/keybase.nix
        ./_desktop-gui/keychain.nix
      ];

      # Syncthing tray icon (GUI hosts).
      services.syncthing.tray.enable = true;

      # virt-manager opens the local libvirt system socket on start.
      dconf.settings."org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
