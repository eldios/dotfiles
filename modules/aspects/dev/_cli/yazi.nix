# yazi, the terminal file manager, with the shell wrapper that leaves the
# shell in the last visited directory and a set of plugins from nixpkgs.
{pkgs, ...}: {
  programs.yazi = {
    enable = true;

    # `y` opens yazi and cd's to where it was on exit, in zsh and nushell.
    shellWrapperName = "y";
    enableZshIntegration = true;
    enableNushellIntegration = true;

    plugins = {
      # Plugins with setup = true get a require(...):setup() line in init.lua.
      full-border.package = pkgs.yaziPlugins.full-border;
      full-border.setup = true;

      git = {
        package = pkgs.yaziPlugins.git;
        setup = true;
        settings.order = 1500; # git status signs after the built-in linemodes
      };

      lazygit = pkgs.yaziPlugins.lazygit;
      smart-enter = pkgs.yaziPlugins.smart-enter;
      chmod = pkgs.yaziPlugins.chmod;
      toggle-pane = pkgs.yaziPlugins.toggle-pane;
      mount = pkgs.yaziPlugins.mount;
    };

    # The git plugin needs to run as a fetcher on files and on directories.
    settings.plugin.prepend_fetchers = [
      {
        url = "*";
        run = "git";
        group = "git";
      }
      {
        url = "*/";
        run = "git";
        group = "git";
      }
    ];

    keymap.mgr.prepend_keymap = [
      {
        on = ["g" "i"];
        run = "plugin lazygit";
        desc = "Open lazygit here";
      }
      {
        on = "l";
        run = "plugin smart-enter";
        desc = "Enter the directory, or open the file";
      }
      {
        on = ["c" "m"];
        run = "plugin chmod";
        desc = "Chmod the selected files";
      }
      {
        on = "T";
        run = "plugin toggle-pane max-preview";
        desc = "Maximize or restore the preview pane";
      }
      {
        on = "M";
        run = "plugin mount";
        desc = "Mount and unmount disks";
      }
    ];
  };
}
