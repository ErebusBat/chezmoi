# WezTerm launch and route commands.

# Launch work WezTerm and move new window to workspace W.
wezterm-work:
    just route::_capture-before "WezTerm"
    just wezterm::_launch-wezterm-lshq
    just route::_move-to-workspace "WezTerm" W

# Launch personal WezTerm and move new window to workspace Q.
wezterm-personal:
    just route::_capture-before "WezTerm"
    just wezterm::_launch-wezterm-system
    just route::_move-to-workspace "WezTerm" Q

# Launch both WezTerm profiles and route each to its workspace.
wezterm-both:
    just wezterm::wezterm-work
    just wezterm::wezterm-personal

[private]
_launch-wezterm-lshq:
    open -na "WezTerm" --args start -- zsh -lc '~/bin/tmpa lshq'

[private]
_launch-wezterm-system:
    open -na "WezTerm" --args start -- zsh -lc '~/bin/tmpa system'
