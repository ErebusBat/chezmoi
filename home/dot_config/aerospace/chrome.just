# Chrome profile launch and route commands.

# Launch work Chrome profile (Default) and move new window to workspace W.
chrome-work:
    just route::_capture-before "Google Chrome"
    just chrome::_launch-chrome-work
    just route::_move-to-workspace "Google Chrome" W

# Launch personal Chrome profile (Profile 1) and move new window to workspace Q.
chrome-personal:
    just route::_capture-before "Google Chrome"
    just chrome::_launch-chrome-personal
    just route::_move-to-workspace "Google Chrome" Q

# Launch both Chrome profiles and route each to its workspace.
chrome-both:
    just chrome::chrome-work
    just chrome::chrome-personal

[private]
_launch-chrome-work:
    open -na "Google Chrome" --args --profile-directory="Default" --new-window

[private]
_launch-chrome-personal:
    open -na "Google Chrome" --args --profile-directory="Profile 1" --new-window
