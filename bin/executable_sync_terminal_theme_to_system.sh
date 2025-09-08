#!/bin/zsh

# Function to check if macOS is in dark mode
is_dark_mode() {
    # Check the system appearance setting
    local appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null)

    # If AppleInterfaceStyle is set to "Dark", we're in dark mode
    # If the key doesn't exist or is empty, we're in light mode
    if [[ "$appearance" == "Dark" ]]; then
        return 0  # true - dark mode
    else
        return 1  # false - light mode
    fi
}

# Main script logic
BASE16_SHELL_PATH=$HOME/.config/base16-shell
if is_dark_mode; then
  echo "System is in Dark Mode"
  source $BASE16_SHELL_PATH/scripts/base16-onedark.sh

  # Example: Set a dark wallpaper
  # osascript -e 'tell application "System Events" to tell every desktop to set picture to "/path/to/dark-wallpaper.jpg"'

else
  echo "System is in Light Mode"
  source $BASE16_SHELL_PATH/scripts/base16-one-light.sh
fi

# Alternative: One-liner version for simple cases
# defaults read -g AppleInterfaceStyle &>/dev/null && echo "Dark mode" || echo "Light mode"
