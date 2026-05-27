BATBOT_ICON_PATH := '/Users/andrew.burns/Documents/Library/I/Icons/batbot/batbot_main.png'
BATBOT_TITLE := 'BatBot'

# Create batbot app
[group('BatBot')]
batbot-create:
  pake 'https://app.slack.com/client/T0BKSEBCL/C0AG75EMK7Z' \
    --name "{{ BATBOT_TITLE}}" \
    --icon "{{ BATBOT_ICON_PATH }}"
  mv -v BatBot.dmg ~/Downloads
