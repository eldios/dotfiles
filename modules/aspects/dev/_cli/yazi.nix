# yazi, the terminal file manager, with every plugin nixpkgs packages for
# Linux linked into ~/.config/yazi/plugins. Keymaps, init.lua and yazi.toml
# are written by hand, not generated here.
{pkgs, ...}: {
  programs.yazi = {
    enable = true;

    # `y` opens yazi and cd's to where it was on exit, in zsh and nushell.
    shellWrapperName = "y";
    enableZshIntegration = true;
    enableNushellIntegration = true;

    plugins = with pkgs.yaziPlugins; {
      inherit
        bookmarks # vi-like marks on directories
        bypass # skip directories that contain a single sub-directory
        chmod # chmod on the selected files
        clipboard # copy yanked paths to the system clipboard
        close-and-restore-tab # close a tab and bring it back later
        compress # compress the selected files into an archive
        convert # convert images between formats with ImageMagick
        diff # diff the selected file against the hovered one, copy the patch
        drag # drag and drop files out of the terminal through ripdrag
        duckdb # preview data files (csv, parquet, ...) through duckdb
        dupes # find duplicate files
        full-border # full border around the panes
        git # git status of each file as a linemode
        githead # git status header, powerlevel10k style
        gitui # open gitui on the current repo
        glow # markdown preview through glow
        gvfs # mount and unmount devices and remote storage through gvfs
        jjui # open jjui (jujutsu) on the current repo
        jump-to-char # vim-like f<char> jump to the next matching file name
        lazygit # open lazygit on the current repo
        lsar # preview archive contents through lsar
        mediainfo # preview media files through mediainfo
        miller # preview tabular data through miller
        mime-ext # mime types from the file extension, faster than `file`
        mount # mount manager
        nav-parent-panel # move between sibling directories from the parent pane
        no-status # hide the status bar
        nord # nord theme
        office # preview office documents
        ouch # preview archives through ouch
        piper # use any shell command as a previewer
        projects # save and restore sets of tabs as projects
        recycle-bin # browse, restore and clean the trash
        relative-motions # vim-style counted motions
        restore # undo the last trash operation
        rich-preview # preview through rich (markdown, json, csv, ...)
        rsync # copy the selected files somewhere with rsync
        smart-enter # one key to enter a directory or open a file
        smart-filter # incremental filter that also navigates
        smart-paste # paste into the hovered directory, or the cwd
        split-tabs # dual pane view from two tabs
        sshfs # mount remote hosts through sshfs
        starship # starship prompt inside yazi
        sudo # run file operations through sudo
        time-travel # browse btrfs or zfs snapshots back and forth
        toggle-pane # show, hide or maximize the panes
        vcs-files # list the files changed in the repo
        wl-clipboard # Wayland clipboard through wl-copy
        yafg # fuzzy find and grep with fzf and ripgrep
        yatline # customizable header and status lines
        yatline-catppuccin # catppuccin theme for yatline
        yatline-githead # githead for yatline
        ;
    };
  };
}
