{ ... }:
{

  xdg.configFile."yabai/yabairc" = {
    enable = true;
    executable = true;
    text = ''
      # bsp, stack or float
      /opt/homebrew/bin/yabai -m config layout bsp

      /opt/homebrew/bin/yabai -m config window_placement

      # padding set to 12px
      /opt/homebrew/bin/yabai -m config top_padding 12
      /opt/homebrew/bin/yabai -m config bottom_padding 12
      /opt/homebrew/bin/yabai -m config left_padding 12
      /opt/homebrew/bin/yabai -m config right_padding 12
      /opt/homebrew/bin/yabai -m config window_gap 12

      # -- mouse settings --

      # center mouse on window with focus
      /opt/homebrew/bin/yabai -m config mouse_follows_focus on

      # modifier for clicking and dragging with mouse
      /opt/homebrew/bin/yabai -m config mouse_modifier alt
      # set modifier + left-click drag to move window
      /opt/homebrew/bin/yabai -m config mouse_action1 move
      # set modifier + right-click drag to resize window
      /opt/homebrew/bin/yabai -m config mouse_action2 resize

      # when window is dropped in center of another window, swap them (on edges it will split it)
      /opt/homebrew/bin/yabai -m mouse_drop_action swap

      # disable specific apps
      /opt/homebrew/bin/yabai -m rule --add app="^System Settings$" manage=off
      /opt/homebrew/bin/yabai -m rule --add app="^Calculator$" manage=off
      /opt/homebrew/bin/yabai -m rule --add app="^QuickTime Player$" manage=off
    '';
  };

  xdg.configFile."skhd/skhdrc" = {
    enable = true;
    executable = true;
    text = ''
      # go to desktop
      alt - 1 : /opt/homebrew/bin/yabai -m space --focus  1 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd -  1"
      alt - 2 : /opt/homebrew/bin/yabai -m space --focus  2 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd -  2"
      alt - 3 : /opt/homebrew/bin/yabai -m space --focus  3 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd -  3"
      alt - 4 : /opt/homebrew/bin/yabai -m space --focus  4 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd -  4"
      alt - 5 : /opt/homebrew/bin/yabai -m space --focus  5 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd -  5"
      alt - 6 : /opt/homebrew/bin/yabai -m space --focus  6 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd -  6"
      alt - 7 : /opt/homebrew/bin/yabai -m space --focus  7 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd -  7"
      alt - 8 : /opt/homebrew/bin/yabai -m space --focus  8 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd -  8"
      alt - 9 : /opt/homebrew/bin/yabai -m space --focus  9 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd -  9"
      alt - 0 : /opt/homebrew/bin/yabai -m space --focus 10 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - 10"

      alt - c : /opt/homebrew/bin/yabai -m window --focus stack.next
      alt - h : /opt/homebrew/bin/yabai -m window  --focus west
      alt - j : /opt/homebrew/bin/yabai -m window  --focus south
      alt - k : /opt/homebrew/bin/yabai -m window  --focus north
      alt - l : /opt/homebrew/bin/yabai -m window  --focus east
      alt - n : /opt/homebrew/bin/yabai -m space   --focus next
      alt - o : /opt/homebrew/bin/yabai -m display --focus east
      alt - p : /opt/homebrew/bin/yabai -m space   --focus prev
      alt - v : /opt/homebrew/bin/yabai -m space   --mirror x-axis
      alt - x : /opt/homebrew/bin/yabai -m window --focus recent
      alt - y : /opt/homebrew/bin/yabai -m display --focus west
      alt - z : /opt/homebrew/bin/yabai -m window --focus stack.prev

      alt + ctrl - h : /opt/homebrew/bin/yabai -m window --warp west
      alt + ctrl - j : /opt/homebrew/bin/yabai -m window --warp south
      alt + ctrl - k : /opt/homebrew/bin/yabai -m window --warp north
      alt + ctrl - l : /opt/homebrew/bin/yabai -m window --warp east

      alt + ctrl - q : /opt/homebrew/bin/yabai --stop-service
      alt + ctrl - r : /opt/homebrew/bin/yabai --restart-service
      alt + ctrl - s : /opt/homebrew/bin/yabai --start-service

      alt + shift + ctrl - 0 : /opt/homebrew/bin/yabai -m space --balance
      alt + shift + ctrl - h : /opt/homebrew/bin/yabai -m window --resize left:0:0
      alt + shift + ctrl - j : /opt/homebrew/bin/yabai -m window --resize bottom:0:20
      alt + shift + ctrl - k : /opt/homebrew/bin/yabai -m window --resize top:0:20
      alt + shift + ctrl - l : /opt/homebrew/bin/yabai -m window --resize right:0:20

      # make floating window fill screen
      alt + shift - up     : /opt/homebrew/bin/yabai -m window --grid 1:1:0:0:1:1
      # make floating window fill left-half of screen
      alt + shift - left   : /opt/homebrew/bin/yabai -m window --grid 1:2:0:0:1:1
      # make floating window fill right-half of screen
      alt + shift - right  : /opt/homebrew/bin/yabai -m window --grid 1:2:1:0:1:1

      alt + shift - 1 : /opt/homebrew/bin/yabai -m window --space  1 ; /opt/homebrew/bin/yabai -m space --focus  1
      alt + shift - 2 : /opt/homebrew/bin/yabai -m window --space  2 ; /opt/homebrew/bin/yabai -m space --focus  2
      alt + shift - 3 : /opt/homebrew/bin/yabai -m window --space  3 ; /opt/homebrew/bin/yabai -m space --focus  3
      alt + shift - 4 : /opt/homebrew/bin/yabai -m window --space  4 ; /opt/homebrew/bin/yabai -m space --focus  4
      alt + shift - 5 : /opt/homebrew/bin/yabai -m window --space  5 ; /opt/homebrew/bin/yabai -m space --focus  5
      alt + shift - 6 : /opt/homebrew/bin/yabai -m window --space  6 ; /opt/homebrew/bin/yabai -m space --focus  6
      alt + shift - 7 : /opt/homebrew/bin/yabai -m window --space  7 ; /opt/homebrew/bin/yabai -m space --focus  7
      alt + shift - 8 : /opt/homebrew/bin/yabai -m window --space  8 ; /opt/homebrew/bin/yabai -m space --focus  8
      alt + shift - 9 : /opt/homebrew/bin/yabai -m window --space  9 ; /opt/homebrew/bin/yabai -m space --focus  9
      alt + shift - 0 : /opt/homebrew/bin/yabai -m window --space 10 ; /opt/homebrew/bin/yabai -m space --focus 10

      alt + shift - f : /opt/homebrew/bin/yabai -m window --toggle float --grid 4:4:1:1:2:2
      alt + shift - h : /opt/homebrew/bin/yabai -m window --swap west
      alt + shift - j : /opt/homebrew/bin/yabai -m window --swap south
      alt + shift - k : /opt/homebrew/bin/yabai -m window --swap north
      alt + shift - l : /opt/homebrew/bin/yabai -m window --swap east
      alt + shift - m : /opt/homebrew/bin/yabai -m window --toggle zoom-fullscreen
      alt + shift - n : /opt/homebrew/bin/yabai -m window --space next; /opt/homebrew/bin/yabai -m space --focus next
      alt + shift - o : /opt/homebrew/bin/yabai -m window --display east; /opt/homebrew/bin/yabai -m display --focus east
      alt + shift - p : /opt/homebrew/bin/yabai -m window --space prev; /opt/homebrew/bin/yabai -m space --focus prev
      alt + shift - r : /opt/homebrew/bin/yabai -m space --rotate 270
      alt + shift - t : /opt/homebrew/bin/yabai -m window --toggle sticky --toggle pip
      alt + shift - v : /opt/homebrew/bin/yabai -m space --mirror y-axis
      alt + shift - x : /opt/homebrew/bin/yabai -m window --swap recent
      alt + shift - y : /opt/homebrew/bin/yabai -m window --display west; /opt/homebrew/bin/yabai -m display --focus west

      alt + shift - b : open -a /Applications/Bitwarden.app
      alt + shift - e : open -a /Applications/Email.app
      alt + shift - s : open -a /Applications/Spotify.app
      alt + shift - w : open -a /Applications/Brave\ Browser.app
      alt + shift - z : open -a /Applications/Obsidian.app

      alt + ctrl  - return : open -na /Applications/iTerm.app
      alt + shift - return : open -a /Applications/iTerm.app

      # # destroy desktop
      # # cmd + alt - w : /opt/homebrew/bin/yabai -m space --destroy
      # cmd + alt - w : /opt/homebrew/bin/yabai -m space --focus prev && /opt/homebrew/bin/yabai -m space recent --destroy
      # 
      # # fast focus desktop
      # cmd + alt - x : /opt/homebrew/bin/yabai -m space --focus recent
      # cmd + alt - z : /opt/homebrew/bin/yabai -m space --focus prev || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - z"
      # cmd + alt - c : /opt/homebrew/bin/yabai -m space --focus next || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - c"
      # cmd + alt - 1 : /opt/homebrew/bin/yabai -m space --focus  1 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - 1"
      # cmd + alt - 2 : /opt/homebrew/bin/yabai -m space --focus  2 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - 2"
      # cmd + alt - 3 : /opt/homebrew/bin/yabai -m space --focus  3 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - 3"
      # cmd + alt - 4 : /opt/homebrew/bin/yabai -m space --focus  4 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - 4"
      # cmd + alt - 5 : /opt/homebrew/bin/yabai -m space --focus  5 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - 5"
      # cmd + alt - 6 : /opt/homebrew/bin/yabai -m space --focus  6 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - 6"
      # cmd + alt - 7 : /opt/homebrew/bin/yabai -m space --focus  7 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - 7"
      # cmd + alt - 8 : /opt/homebrew/bin/yabai -m space --focus  8 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - 8"
      # cmd + alt - 9 : /opt/homebrew/bin/yabai -m space --focus  9 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - 9"
      # cmd + alt - 0 : /opt/homebrew/bin/yabai -m space --focus 10 || /opt/homebrew/bin/skhd -k "ctrl + alt + cmd - 0"
      # 
      # # send window to desktop and follow focus
      # shift + cmd - x : /opt/homebrew/bin/yabai -m window --space recent && /opt/homebrew/bin/yabai -m space --focus recent
      # shift + cmd - z : /opt/homebrew/bin/yabai -m window --space prev && /opt/homebrew/bin/yabai -m space --focus prev
      # shift + cmd - c : /opt/homebrew/bin/yabai -m window --space next && /opt/homebrew/bin/yabai -m space --focus next
      # shift + cmd - 1 : /opt/homebrew/bin/yabai -m window --space  1 && /opt/homebrew/bin/yabai -m space --focus 1
      # shift + cmd - 2 : /opt/homebrew/bin/yabai -m window --space  2 && /opt/homebrew/bin/yabai -m space --focus 2
      # shift + cmd - 3 : /opt/homebrew/bin/yabai -m window --space  3 && /opt/homebrew/bin/yabai -m space --focus 3
      # shift + cmd - 4 : /opt/homebrew/bin/yabai -m window --space  4 && /opt/homebrew/bin/yabai -m space --focus 4
      # shift + cmd - 5 : /opt/homebrew/bin/yabai -m window --space  5 && /opt/homebrew/bin/yabai -m space --focus 5
      # shift + cmd - 6 : /opt/homebrew/bin/yabai -m window --space  6 && /opt/homebrew/bin/yabai -m space --focus 6
      # shift + cmd - 7 : /opt/homebrew/bin/yabai -m window --space  7 && /opt/homebrew/bin/yabai -m space --focus 7
      # shift + cmd - 8 : /opt/homebrew/bin/yabai -m window --space  8 && /opt/homebrew/bin/yabai -m space --focus 8
      # shift + cmd - 9 : /opt/homebrew/bin/yabai -m window --space  9 && /opt/homebrew/bin/yabai -m space --focus 9
      # shift + cmd - 0 : /opt/homebrew/bin/yabai -m window --space 10 && /opt/homebrew/bin/yabai -m space --focus 10
      # 
      # # focus monitor
      # ctrl + alt - x  : /opt/homebrew/bin/yabai -m display --focus recent
      # ctrl + alt - z  : /opt/homebrew/bin/yabai -m display --focus prev
      # ctrl + alt - c  : /opt/homebrew/bin/yabai -m display --focus next
      # ctrl + alt - 1  : /opt/homebrew/bin/yabai -m display --focus 1
      # ctrl + alt - 2  : /opt/homebrew/bin/yabai -m display --focus 2
      # ctrl + alt - 3  : /opt/homebrew/bin/yabai -m display --focus 3
      # 
      # # send window to monitor and follow focus
      # ctrl + cmd - x  : /opt/homebrew/bin/yabai -m window --display recent && /opt/homebrew/bin/yabai -m display --focus recent
      # ctrl + cmd - z  : /opt/homebrew/bin/yabai -m window --display prev && /opt/homebrew/bin/yabai -m display --focus prev
      # ctrl + cmd - c  : /opt/homebrew/bin/yabai -m window --display next && /opt/homebrew/bin/yabai -m display --focus next
      # ctrl + cmd - 1  : /opt/homebrew/bin/yabai -m window --display 1 && /opt/homebrew/bin/yabai -m display --focus 1
      # ctrl + cmd - 2  : /opt/homebrew/bin/yabai -m window --display 2 && /opt/homebrew/bin/yabai -m display --focus 2
      # ctrl + cmd - 3  : /opt/homebrew/bin/yabai -m window --display 3 && /opt/homebrew/bin/yabai -m display --focus 3
      # 
      # # move window
      # shift + ctrl - a : /opt/homebrew/bin/yabai -m window --move rel:-20:0
      # shift + ctrl - s : /opt/homebrew/bin/yabai -m window --move rel:0:20
      # shift + ctrl - w : /opt/homebrew/bin/yabai -m window --move rel:0:-20
      # shift + ctrl - d : /opt/homebrew/bin/yabai -m window --move rel:20:0
      # 
      # # increase window size
      # shift + alt - a : /opt/homebrew/bin/yabai -m window --resize left:-20:0
      # shift + alt - s : /opt/homebrew/bin/yabai -m window --resize bottom:0:20
      # shift + alt - w : /opt/homebrew/bin/yabai -m window --resize top:0:-20
      # shift + alt - d : /opt/homebrew/bin/yabai -m window --resize right:20:0
      # 
      # # decrease window size
      # shift + cmd - a : /opt/homebrew/bin/yabai -m window --resize left:20:0
      # shift + cmd - s : /opt/homebrew/bin/yabai -m window --resize bottom:0:-20
      # shift + cmd - w : /opt/homebrew/bin/yabai -m window --resize top:0:20
      # shift + cmd - d : /opt/homebrew/bin/yabai -m window --resize right:-20:0
      # 
      # # set insertion point in focused container
      # ctrl + alt - h : /opt/homebrew/bin/yabai -m window --insert west
      # ctrl + alt - j : /opt/homebrew/bin/yabai -m window --insert south
      # ctrl + alt - k : /opt/homebrew/bin/yabai -m window --insert north
      # ctrl + alt - l : /opt/homebrew/bin/yabai -m window --insert east
      # ctrl + alt - i : /opt/homebrew/bin/yabai -m window --insert stack
      # 
      # # rotate tree
      # alt - r : /opt/homebrew/bin/yabai -m space --rotate 90
      # 
      # # mirror tree y-axis
      # alt - y : /opt/homebrew/bin/yabai -m space --mirror y-axis
      # 
      # # mirror tree x-axis
      # alt - x : /opt/homebrew/bin/yabai -m space --mirror x-axis
      # 
      # # toggle desktop offset
      # alt - a : /opt/homebrew/bin/yabai -m space --toggle padding --toggle gap
      # 
      # # toggle window parent zoom
      # alt - d : /opt/homebrew/bin/yabai -m window --toggle zoom-parent
      # 
      # # toggle window fullscreen zoom
      # alt - f : /opt/homebrew/bin/yabai -m window --toggle zoom-fullscreen
      # 
      # # toggle window native fullscreen
      # shift + alt - f : /opt/homebrew/bin/yabai -m window --toggle native-fullscreen
      # 
      # # toggle window split type
      # alt - e : /opt/homebrew/bin/yabai -m window --toggle split
      # 
      # # float / unfloat window and restore position
      # # alt - t : /opt/homebrew/bin/yabai -m window --toggle float && /tmp//opt/homebrew/bin/yabai-restore/$(/opt/homebrew/bin/yabai -m query --windows --window | jq -re '.id').restore 2>/dev/null || true
      # alt - t : /opt/homebrew/bin/yabai -m window --toggle float --grid 4:4:1:1:2:2
      # 
      # # toggle sticky (show on all spaces)
      # alt - s : /opt/homebrew/bin/yabai -m window --toggle sticky
      # 
      # # toggle topmost (keep above other windows)
      # alt - o : /opt/homebrew/bin/yabai -m window --toggle topmost
      # 
      # # toggle picture-in-picture
      # alt - p : /opt/homebrew/bin/yabai -m window --toggle border --toggle pip
      # 
      # # change layout of desktop
      # ctrl + alt - a : /opt/homebrew/bin/yabai -m space --layout bsp
      # ctrl + alt - d : /opt/homebrew/bin/yabai -m space --layout float
      # ctrl + alt - s : /opt/homebrew/bin/yabai -m space --layout $(/opt/homebrew/bin/yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "float" else "bsp" end')
    '';
  };

} # EOF
# vim: set ts=2 sw=2 et ai list nu
