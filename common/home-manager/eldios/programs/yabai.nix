{ ... }:
{

  xdg.configFile."yabai/yabairc" = {
    enable = true;
    executable = true;
    text = ''
      # bsp, stack or float
      yabai -m config layout bsp

      yabai -m config window_placement

      # padding set to 12px
      yabai -m config top_padding 12
      yabai -m config bottom_padding 12
      yabai -m config left_padding 12
      yabai -m config right_padding 12
      yabai -m config window_gap 12

      # -- mouse settings --

      # center mouse on window with focus
      yabai -m config mouse_follows_focus on

      # modifier for clicking and dragging with mouse
      yabai -m config mouse_modifier alt
      # set modifier + left-click drag to move window
      yabai -m config mouse_action1 move
      # set modifier + right-click drag to resize window
      yabai -m config mouse_action2 resize

      # when window is dropped in center of another window, swap them (on edges it will split it)
      yabai -m mouse_drop_action swap

      # disable specific apps
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off
      yabai -m rule --add app="^QuickTime Player$" manage=off
    '';
  };

  xdg.configFile."skhd/skhdrc" = {
    enable = true;
    executable = true;
    text = ''
      # -- Application shortcuts
      alt + shift - return : open -a /Applications/iTerm.app
      alt + ctrl - return : open -na /Applications/iTerm.app

      alt + shift - b : open -a /Applications/Bitwarden.app
      alt + shift - e : open -a /Applications/Email.app
      alt + shift - o : open -a /Applications/Obsidian.app
      alt + shift - s : open -a /Applications/Spotify.app
      alt + shift - w : open -a /Applications/Brave\ Browser.app

      # -- Window movement

      # change window focus within space
      alt - j : /opt/homebrew/bin/yabai -m window --focus south
      alt - k : /opt/homebrew/bin/yabai -m window --focus north
      alt - h : /opt/homebrew/bin/yabai -m window --focus west
      alt - l : /opt/homebrew/bin/yabai -m window --focus east

      # increase window size
      alt + shift + ctrl - h : /opt/homebrew/bin/yabai -m window --resize left:0:0
      alt + shift + ctrl - k : /opt/homebrew/bin/yabai -m window --resize top:0:20

      # decrease window size
      alt + shift + ctrl - j : /opt/homebrew/bin/yabai -m window --resize bottom:0:20
      alt + shift + ctrl - l : /opt/homebrew/bin/yabai -m window --resize right:0:20

      # swap windows
      alt + shift - j : /opt/homebrew/bin/yabai -m window --swap south
      alt + shift - k : /opt/homebrew/bin/yabai -m window --swap north
      alt + shift - h : /opt/homebrew/bin/yabai -m window --swap west
      alt + shift - l : /opt/homebrew/bin/yabai -m window --swap east

      # move window and split
      alt + ctrl - j : /opt/homebrew/bin/yabai -m window --warp south
      alt + ctrl - k : /opt/homebrew/bin/yabai -m window --warp north
      alt + ctrl - h : /opt/homebrew/bin/yabai -m window --warp west
      alt + ctrl - l : /opt/homebrew/bin/yabai -m window --warp east

      # float / unfloat window and center on screen
      alt + shift - f : /opt/homebrew/bin/yabai -m window --toggle float --grid 4:4:1:1:2:2
      ## make floating window fill screen
      #alt + shift - up : /opt/homebrew/bin/yabai -m window --grid 1:1:0:0:1:1
      # make floating window fill left-half of screen
      alt + shift - left : /opt/homebrew/bin/yabai -m window --grid 1:2:0:0:1:1
      # toggle sticky(+float), picture-in-picture
      alt + shift - t : /opt/homebrew/bin/yabai -m window --toggle sticky --toggle pip

      # maximize a window
      alt + shift - m : /opt/homebrew/bin/yabai -m window --toggle zoom-fullscreen

      # go to desktop
      alt - 1 : /opt/homebrew/bin/yabai -m space --focus  1
      alt - 2 : /opt/homebrew/bin/yabai -m space --focus  2
      alt - 3 : /opt/homebrew/bin/yabai -m space --focus  3
      alt - 4 : /opt/homebrew/bin/yabai -m space --focus  4
      alt - 5 : /opt/homebrew/bin/yabai -m space --focus  5
      alt - 6 : /opt/homebrew/bin/yabai -m space --focus  6
      alt - 7 : /opt/homebrew/bin/yabai -m space --focus  7
      alt - 8 : /opt/homebrew/bin/yabai -m space --focus  8
      alt - 9 : /opt/homebrew/bin/yabai -m space --focus  9
      alt - 0 : /opt/homebrew/bin/yabai -m space --focus 10

      # send window to desktop and follow focus
      alt + shift - 1 : /opt/homebrew/bin/yabai -m window --space  1; /opt/homebrew/bin/yabai -m space --focus  1
      alt + shift - 2 : /opt/homebrew/bin/yabai -m window --space  2; /opt/homebrew/bin/yabai -m space --focus  2
      alt + shift - 3 : /opt/homebrew/bin/yabai -m window --space  3; /opt/homebrew/bin/yabai -m space --focus  3
      alt + shift - 4 : /opt/homebrew/bin/yabai -m window --space  4; /opt/homebrew/bin/yabai -m space --focus  4
      alt + shift - 5 : /opt/homebrew/bin/yabai -m window --space  5; /opt/homebrew/bin/yabai -m space --focus  5
      alt + shift - 6 : /opt/homebrew/bin/yabai -m window --space  6; /opt/homebrew/bin/yabai -m space --focus  6
      alt + shift - 7 : /opt/homebrew/bin/yabai -m window --space  7; /opt/homebrew/bin/yabai -m space --focus  7
      alt + shift - 8 : /opt/homebrew/bin/yabai -m window --space  8; /opt/homebrew/bin/yabai -m space --focus  8
      alt + shift - 9 : /opt/homebrew/bin/yabai -m window --space  9; /opt/homebrew/bin/yabai -m space --focus  9
      alt + shift - 0 : /opt/homebrew/bin/yabai -m window --space 10; /opt/homebrew/bin/yabai -m space --focus 10

      # -- Workspace/Desktop movement

      # fast focus desktop
      # cmd + alt - x : /opt/homebrew/bin/yabai -m space --focus recent
      alt - 1 : /opt/homebrew/bin/yabai -m space --focus 1
      alt - 2 : /opt/homebrew/bin/yabai -m space --focus 2
      alt - 3 : /opt/homebrew/bin/yabai -m space --focus 3

      # send window to desktop and follow focus
      alt - n : /opt/homebrew/bin/yabai -m space --focus next
      alt - p : /opt/homebrew/bin/yabai -m space --focus prev
      # move window to prev and next space
      alt + shift - p : /opt/homebrew/bin/yabai -m window --space prev; /opt/homebrew/bin/yabai -m space --focus prev
      alt + shift - n : /opt/homebrew/bin/yabai -m window --space next; /opt/homebrew/bin/yabai -m space --focus next

      # -- Display/Monitor movement

      # change focus between external displays (left and right)
      alt - s: /opt/homebrew/bin/yabai -m display --focus west
      alt - g: /opt/homebrew/bin/yabai -m display --focus east

      # move window to display left and right
      alt + shift - s : /opt/homebrew/bin/yabai -m window --display west; /opt/homebrew/bin/yabai -m display --focus west
      alt + shift - g : /opt/homebrew/bin/yabai -m window --display east; /opt/homebrew/bin/yabai -m display --focus east

      # rotate layout clockwise
      alt + shift - r : /opt/homebrew/bin/yabai -m space --rotate 270
      # flip along y-axis
      alt + shift - y : /opt/homebrew/bin/yabai -m space --mirror y-axis
      # flip along x-axis
      alt + shift - x : /opt/homebrew/bin/yabai -m space --mirror x-axis

      # balance out tree of windows (resize to occupy same area)
      alt + shift - 0 : /opt/homebrew/bin/yabai -m space --balance

      # stop/start/restart yabai
      alt + ctrl - q : /opt/homebrew/bin/yabai --stop-service
      alt + ctrl - s : /opt/homebrew/bin/yabai --start-service
      alt + ctrl - r : /opt/homebrew/bin/yabai --restart-service

      # -- var for future implementation
      # # create desktop, move window and follow focus - uses jq for parsing json (brew install jq)
      # # shift + cmd - n : /opt/homebrew/bin/yabai -m space --create && \
      # #                   index="$(yabai -m query --spaces --display | jq 'map(select(."is-native-fullscreen" == false))[-1].index')" && \
      # #                   yabai -m window --space "$${index}" && \
      # #                   yabai -m space --focus "$${index}"

      # focus monitor
      # ctrl + alt - z  : /opt/homebrew/bin/yabai -m display --focus prev
      # ctrl + alt - 3  : /opt/homebrew/bin/yabai -m display --focus 3

      # send window to monitor and follow focus
      # ctrl + cmd - c  : /opt/homebrew/bin/yabai -m window --display next; /opt/homebrew/bin/yabai -m display --focus next
      # ctrl + cmd - 1  : /opt/homebrew/bin/yabai -m window --display 1; /opt/homebrew/bin/yabai -m display --focus 1

      # move floating window
      # shift + ctrl - a : /opt/homebrew/bin/yabai -m window --move rel:-20:0
      # shift + ctrl - s : /opt/homebrew/bin/yabai -m window --move rel:0:20

      # set insertion point in focused container
      # ctrl + alt - h : /opt/homebrew/bin/yabai -m window --insert west

      # toggle window zoom
      # alt - d : /opt/homebrew/bin/yabai -m window --toggle zoom-parent
      # alt - f : /opt/homebrew/bin/yabai -m window --toggle zoom-fullscreen

      # toggle window split type
      # alt - e : /opt/homebrew/bin/yabai -m window --toggle split
    '';
  };

} # EOF
# vim: set ts=2 sw=2 et ai list nu
