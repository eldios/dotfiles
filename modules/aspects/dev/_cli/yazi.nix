# yazi, the terminal file manager, with a selection of the plugins nixpkgs
# packages linked into ~/.config/yazi/plugins. Keymaps, init.lua and
# yazi.toml are written by hand, not generated here.
{pkgs, ...}: {
  programs.yazi = {
    enable = true;

    # Plugins are plain Lua and shell out to these; the rest of what they
    # call (git, glow, fzf, ripgrep, bat, ffmpeg, imagemagick, wl-copy,
    # starship, btrfs, findmnt, sudo) is already in the profile.
    extraPackages = with pkgs; [
      jdupes # dupes
      mediainfo # mediainfo
      miller # miller
      ripdrag # drag
      unar # lsar
    ];

    # `y` opens yazi and cd's to where it was on exit, in zsh and nushell.
    shellWrapperName = "y";
    enableZshIntegration = true;
    enableNushellIntegration = true;

    plugins = with pkgs.yaziPlugins; {
      inherit
        bookmarks # vi-like marks on directories
        chmod # chmod on the selected files
        diff # diff the selected file against the hovered one, copy the patch
        drag # drag and drop files out of the terminal through ripdrag
        dupes # find duplicate files
        full-border # full border around the panes
        git # git status of each file as a linemode
        glow # markdown preview through glow
        lsar # preview archive contents through lsar
        mediainfo # preview media files through mediainfo
        miller # preview tabular data through miller
        mime-ext # mime types from the file extension, faster than `file`
        relative-motions # vim-style counted motions
        smart-enter # one key to enter a directory or open a file
        smart-filter # incremental filter that also navigates
        smart-paste # paste into the hovered directory, or the cwd
        starship # starship prompt inside yazi
        time-travel # browse btrfs or zfs snapshots back and forth
        toggle-pane # show, hide or maximize the panes
        wl-clipboard # Wayland clipboard through wl-copy
        yafg # fuzzy find and grep with fzf and ripgrep
        ;
    };
  };
}
