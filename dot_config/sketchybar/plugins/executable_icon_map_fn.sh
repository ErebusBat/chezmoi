### START-OF-ICON-MAP
function icon_map() {
  case "$1" in
  "1Password")
    icon_result="🔐"
    ;;
  "Adobe Bridge"*)
    icon_result="🖼"
    ;;
  "Affinity Designer"|"Affinity Designer 2")
    icon_result="🎨"
    ;;
  "Affinity Photo"|"Affinity Photo 2")
    icon_result="📷"
    ;;
  "Affinity Publisher"|"Affinity Publisher 2")
    icon_result="📖"
    ;;
  "Alacritty")
    icon_result="⚡"
    ;;
  "Alfred")
    icon_result="⌘"
    ;;
  "Android Messages")
    icon_result="📱"
    ;;
  "Android Studio")
    icon_result="🤖"
    ;;
  "Arc")
    icon_result="🌈"
    ;;
  "Arduino"|"Arduino IDE")
    icon_result="🔧"
    ;;
  "Bambu Studio")
    icon_result="🖨"
    ;;
  "Battle.net")
    icon_result="🎮"
    ;;
  "Bear")
    icon_result="🐻"
    ;;
  "BetterTouchTool")
    icon_result="👆"
    ;;
  "Bitwarden")
    icon_result="🔒"
    ;;
  "Blender")
    icon_result="🧊"
    ;;
  "Brave Browser")
    icon_result="🦁"
    ;;
  "BusyCal")
    icon_result="📅"
    ;;
  "Calculator"|"Calculette")
    icon_result="🧮"
    ;;
  "Calendar"|"Fantastical"|"Cron"|"Amie"|"Notion Calendar")
    icon_result="📅"
    ;;
  "Claude")
    icon_result="🤖"
    ;;
  "ClickUp")
    icon_result="☑"
    ;;
  "Code"|"Code - Insiders")
    icon_result="💻"
    ;;
  "Color Picker")
    icon_result="🎨"
    ;;
  "Copilot")
    icon_result="✦"
    ;;
  "CotEditor")
    icon_result="📝"
    ;;
  "Cursor")
    icon_result="◈"
    ;;
  "DaVinci Resolve")
    icon_result="🎬"
    ;;
  "Deezer")
    icon_result="🎧"
    ;;
  "Discord"|"Discord Canary"|"Discord PTB")
    icon_result="💬"
    ;;
  "Docker"|"Docker Desktop")
    icon_result="🐳"
    ;;
  "Docker Desktop")
    icon_result="🐳"
    ;;
  "Drafts")
    icon_result="📤"
    ;;
  "draw.io")
    icon_result="📊"
    ;;
  "Dropbox")
    icon_result="📦"
    ;;
  "Emacs")
    icon_result="😈"
    ;;
  "Figma")
    icon_result="✂"
    ;;
  "Final Cut Pro")
    icon_result="🎥"
    ;;
  "Finder"|"访达")
    icon_result="💼"
    ;;
  "Firefox"|"Firefox Developer Edition"|"Firefox Nightly")
    icon_result="🦊"
    ;;
  "GitHub Desktop")
    icon_result="⎈"
    ;;
  "Godot")
    icon_result="🎮"
    ;;
  "GoLand")
    icon_result="🐹"
    ;;
  "Google Chrome"|"Google Chrome Canary"|"Chromium")
    icon_result="🌐"
    ;;
  "Hyper")
    icon_result="⚡"
    ;;
  "IntelliJ IDEA")
    icon_result="☕"
    ;;
  "IINA")
    icon_result="🎬"
    ;;
  "Adobe Illustrator"*|"Illustrator")
    icon_result="🎨"
    ;;
  "Adobe InDesign"*|"InDesign")
    icon_result="📄"
    ;;
  "Inkscape")
    icon_result="✒"
    ;;
  "Insomnia")
    icon_result="😴"
    ;;
  "iTerm"|"iTerm2")
    icon_result="⌨"
    ;;
  "Joplin")
    icon_result="📓"
    ;;
  "KakaoTalk"|"카카오톡")
    icon_result="💬"
    ;;
  "KeePassXC")
    icon_result="🔑"
    ;;
  "Keyboard Maestro")
    icon_result="⌨"
    ;;
  "Keynote")
    icon_result="📽"
    ;;
  "kitty")
    icon_result="🐱"
    ;;
  "League of Legends")
    icon_result="🎮"
    ;;
  "LibreWolf")
    icon_result="🐺"
    ;;
  "Adobe Lightroom"|"Lightroom Classic")
    icon_result="🌄"
    ;;
  "LINE")
    icon_result="💬"
    ;;
  "Linear")
    icon_result="◐"
    ;;
  "LM Studio")
    icon_result="🤖"
    ;;
  "Logic Pro")
    icon_result="🎹"
    ;;
  "Logseq")
    icon_result="📅"
    ;;
  "Mail"|"Canary Mail"|"HEY"|"Mailspring"|"MailMate"|"Superhuman"|"Spark"|"邮件")
    icon_result="📧"
    ;;
  "Maps"|"Google Maps")
    icon_result="🗺"
    ;;
  "Messages"|"信息"|"Nachrichten")
    icon_result="💬"
    ;;
  "Microsoft Edge")
    icon_result="🔷"
    ;;
  "Microsoft Excel")
    icon_result="📊"
    ;;
  "Microsoft Outlook")
    icon_result="📧"
    ;;
  "Microsoft PowerPoint")
    icon_result="📽"
    ;;
  "Microsoft Teams"|"Microsoft Teams (work or school)")
    icon_result="👥"
    ;;
  "Microsoft Word")
    icon_result="📄"
    ;;
  "Miro")
    icon_result="◧"
    ;;
  "Music"|"音乐"|"Musique")
    icon_result="🎵"
    ;;
  "Neovim"|"neovim"|"nvim"|"Neovide")
    icon_result="📝"
    ;;
  "Notability")
    icon_result="📝"
    ;;
  "Notes"|"备忘录")
    icon_result="📝"
    ;;
  "Notion")
    icon_result="◻"
    ;;
  "Nova")
    icon_result="✾"
    ;;
  "Numbers")
    icon_result="🔢"
    ;;
  "Obsidian")
    icon_result="📓"
    ;;
  "OBS"|"OBS Studio")
    icon_result="📹"
    ;;
  "OmniFocus")
    icon_result="◉"
    ;;
  "Open Video Downloader")
    icon_result="⬇"
    ;;
  "ChatGPT"|"OpenAI")
    icon_result="✦"
    ;;
  "OrbStack")
    icon_result="◉"
    ;;
  "Pages")
    icon_result="📃"
    ;;
  "Parallels Desktop")
    icon_result="🖥"
    ;;
  "Parsec")
    icon_result="🎮"
    ;;
  "PDF Expert"|"Preview"|"Skim")
    icon_result="📄"
    ;;
  "Adobe Photoshop"*)
    icon_result="🖌"
    ;;
  "PhpStorm")
    icon_result="🐘"
    ;;
  "Plex"|"Plexamp")
    icon_result="🎞"
    ;;
  "Podcasts"|"播客")
    icon_result="🎙"
    ;;
  "Postman")
    icon_result="📬"
    ;;
  "PyCharm")
    icon_result="🐍"
    ;;
  "QQ"|"QQMusic")
    icon_result="🎵"
    ;;
  "Reeder")
    icon_result="📰"
    ;;
  "Reminders"|"提醒事项")
    icon_result="☑"
    ;;
  "Rider")
    icon_result="🏎"
    ;;
  "Safari"|"Safari浏览器"|"Safari Technology Preview")
    icon_result="🧭"
    ;;
  "Sequel Ace"|"Sequel Pro")
    icon_result="🗃"
    ;;
  "Signal")
    icon_result="📡"
    ;;
  "Slack")
    icon_result="💬"
    ;;
  "Spotify")
    icon_result="🎵"
    ;;
  "Sublime Text")
    icon_result="⌨"
    ;;
  "superProductivity")
    icon_result="☑"
    ;;
  "Telegram")
    icon_result="✈"
    ;;
  "Terminal"|"终端")
    icon_result="⌨"
    ;;
  "Things")
    icon_result="✓"
    ;;
  "Thunderbird")
    icon_result="📧"
    ;;
  "TickTick")
    icon_result="✓"
    ;;
  "Todoist")
    icon_result="☑"
    ;;
  "Toggl Track")
    icon_result="⏱"
    ;;
  "Tor Browser")
    icon_result="🧅"
    ;;
  "Tower")
    icon_result="⎇"
    ;;
  "Transmit")
    icon_result="⇧"
    ;;
  "Trello")
    icon_result="▤"
    ;;
  "Tweetbot"|"Twitter")
    icon_result="🐦"
    ;;
  "MacVim"|"Vim"|"VimR")
    icon_result="▲"
    ;;
  "Vivaldi")
    icon_result="ⅴ"
    ;;
  "VLC")
    icon_result="📺"
    ;;
  "VSCode"|"VSCodium")
    icon_result="💻"
    ;;
  "Warp")
    icon_result="📡"
    ;;
  "WebStorm")
    icon_result="🌊"
    ;;
  "WeChat"|"微信")
    icon_result="💬"
    ;;
  "WezTerm")
    icon_result="💻"
    ;;
  "WhatsApp"|"‎WhatsApp")
    icon_result="📱"
    ;;
  "Xcode")
    icon_result="🛠"
    ;;
  "Zed")
    icon_result="⚡"
    ;;
  "Zotero")
    icon_result="📚"
    ;;
  "zoom.us")
    icon_result="📹"
    ;;
  *)
    icon_result="▪"
    ;;
  esac
}
### END-OF-ICON-MAP

icon_map "$1"

echo "$icon_result"
