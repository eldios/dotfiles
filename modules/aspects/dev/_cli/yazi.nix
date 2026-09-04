# yazi, the terminal file manager, with a selection of the plugins nixpkgs
# packages linked into ~/.config/yazi/plugins. Keymaps, init.lua and
# yazi.toml are written by hand, not generated here.
{pkgs, ...}: {
  programs.yazi = {
    enable = true;

    # Plugins are plain Lua and shell out to these; the rest of what they
    # call (git, glow, fzf, ripgrep, bat, ffmpeg, imagemagick, wl-copy,
    # starship, lazygit) is already in the profile.
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
        # enabled
        bookmarks # vi-like marks on directories
        diff # diff the selected file against the hovered one, copy the patch
        drag # drag and drop files out of the terminal through ripdrag
        dupes # find duplicate files
        full-border # full border around the panes
        glow # markdown preview through glow
        lazygit # open lazygit on the current repo
        lsar # preview archive contents through lsar
        mediainfo # preview media files through mediainfo
        miller # preview tabular data through miller
        mime-ext # mime types from the file extension, faster than `file`
        relative-motions # vim-style counted motions
        smart-enter # one key to enter a directory or open a file
        smart-filter # incremental filter that also navigates
        smart-paste # paste into the hovered directory, or the cwd
        starship # starship prompt inside yazi
        wl-clipboard # Wayland clipboard through wl-copy
        yafg # fuzzy find and grep with fzf and ripgrep
        # disabled
        #chmod # chmod on the selected files
        #close-and-restore-tab # close a tab and bring it back later
        #compress # compress the selected files into an archive
        #convert # convert images between formats with ImageMagick
        #duckdb # preview data files (csv, parquet, ...) through duckdb
        #git # git status of each file as a linemode
        #githead # git status header, powerlevel10k style
        #gvfs # mount and unmount devices and remote storage through gvfs
        #jump-to-char # vim-like f<char> jump to the next matching file name
        #mount # mount manager
        #nav-parent-panel # move between sibling directories from the parent pane
        #ouch # preview archives through ouch
        #piper # use any shell command as a previewer
        #projects # save and restore sets of tabs as projects
        #rich-preview # preview through rich (markdown, json, csv, ...)
        #rsync # copy the selected files somewhere with rsync
        #split-tabs # dual pane view from two tabs
        #sshfs # mount remote hosts through sshfs
        #sudo # run file operations through sudo
        #time-travel # browse btrfs or zfs snapshots back and forth
        #toggle-pane # show, hide or maximize the panes
        #vcs-files # list the files changed in the repo
        #yatline # customizable header and status lines
        #yatline-githead # githead for yatline
        ;
    };
  };
}
