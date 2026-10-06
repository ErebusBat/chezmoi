local wezterm = require 'wezterm'

return {
  keys = {
    -- KEYBINDINGS REFERENCE:
    -- | Keys                 | Action                          |
    -- |----------------------|---------------------------------|
    -- | ⌘+Shift+,            | Reload Configuration            |
    -- | Ctrl+Shift+n         | Toggle Fullscreen               |
    -- | Ctrl+Shift+LeftArrow | 🤖 <== (tmux nav)               |
    -- | Ctrl+Shift+RightArrow| 🤖 ==> (tmux nav)               |
    -- | ⌘+Shift+t            | Toggle Window Decorations       |
    -- | Ctrl+Shift+\         | Split Vertical                  |
    -- | Ctrl+Shift+-         | Split Horizontal                |
    -- | Ctrl+Shift+f         | Search                          |
    -- | ⌘+k                  | Command Palette                 |
    -- | ◆+F11                | Close Tmux Window (tmux user-key)|
    -- | ◆+F12                | Clear Tmux Notification (tmux user-key)|
    -- (◆ = Ctrl+Alt+Shift+Super, 🤖 = tmux pane nav)

    {
      key = ',',
      mods = 'CMD|SHIFT',
      action = wezterm.action.ReloadConfiguration,
    },
    {
      key = 'n',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ToggleFullScreen,
    },

    -- Use Kitty CSI-u so Herdr receives Alt+Shift+P as one complete key event
    -- instead of mistaking the legacy ESC P sequence for a DCS control string.
    {
      key = 'P',
      mods = 'ALT|SHIFT',
      action = wezterm.action.SendString('\x1b[112;4u'),
    },

    -- Move the command palette from Ctrl+Shift+P to ⌘K so Ctrl+Shift+P
    -- passes through to apps (OMP reverse role-cycle).
    {
      key = 'k',
      mods = 'CMD',
      action = wezterm.action.ActivateCommandPalette,
    },
    {
      key = 'P',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      key = 'p',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.DisableDefaultAssignment,
    },

    -- Route macOS tab shortcuts to Herdr instead of switching WezTerm tabs.
    {
      key = '[',
      mods = 'CMD|SHIFT',
      action = wezterm.action.SendKey({
        key = 'F10',
        mods = 'NONE',
      }),
    },
    {
      key = ']',
      mods = 'CMD|SHIFT',
      action = wezterm.action.SendKey({
        key = 'F11',
        mods = 'NONE',
      }),
    },
    -- WezTerm may report shifted brackets as their `{`/`}` glyphs rather
    -- than `[`/`]` plus SHIFT, so override both representations.
    {
      key = '{',
      mods = 'CMD',
      action = wezterm.action.SendKey({
        key = 'F10',
        mods = 'NONE',
      }),
    },
    {
      key = '{',
      mods = 'CMD|SHIFT',
      action = wezterm.action.SendKey({
        key = 'F10',
        mods = 'NONE',
      }),
    },
    {
      key = '}',
      mods = 'CMD',
      action = wezterm.action.SendKey({
        key = 'F11',
        mods = 'NONE',
      }),
    },
    {
      key = '}',
      mods = 'CMD|SHIFT',
      action = wezterm.action.SendKey({
        key = 'F11',
        mods = 'NONE',
      }),
    },

    -- TMUX Nav Keys
    {
      key = 'LeftArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SendKey({
        key = 'LeftArrow',
        mods = 'CTRL|SHIFT',
      }),
    },
    {
      key = 'RightArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SendKey({
        key = 'RightArrow',
        mods = 'CTRL|SHIFT',
      }),
    },
    {
      key = 'UpArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SendKey({
        key = 'UpArrow',
        mods = 'CTRL|SHIFT',
      }),
    },
    {
      key = 'DownArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SendKey({
        key = 'DownArrow',
        mods = 'CTRL|SHIFT',
      }),
    },

    -- Toggle window title bar
    {
      key = 't',
      mods = 'CMD|SHIFT',
      action = wezterm.action.EmitEvent('toggle-window-decorations'),
    },

    -- Hyper keys (Ctrl+Alt+Shift+Cmd) for tmux user-keys
    -- Sends tmux user-key escape sequences (defined in tmux.conf user-keys[1]/[2])
    -- See chezmoi: dot_config/tmux/tmux.conf lines 50-54
    {
      key = 'F11',
      mods = 'CTRL|ALT|SHIFT|SUPER',
      action = wezterm.action.SendString('\x1b[91~'),
    },
    {
      key = 'F12',
      mods = 'CTRL|ALT|SHIFT|SUPER',
      action = wezterm.action.SendString('\x1b[90~'),
    },

    -- Splits & Search
    {
      key = '\\',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }),
    },
    {
      key = '-',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },
    {
      key = 'f',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.Search('CurrentSelectionOrEmptyString'),
    },
  },

  mouse_bindings = {
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection',
    },
  },
}
