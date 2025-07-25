# include 'prefixes.rb'
# include 'emojis.rb'
set_debug_output $stderr
include_glob '*_*.rb'

### Computers & Servers
add_link_gsub 'DARTER', '[[dartp6]]'
add_link_gsub 'DARTP6', page: 'dartp6'  # [[dartp6|Sys76 Laptop]]
add_link_gsub 'NAS', page: 'FreeNAS'
add_link_gsub 'M4MBP', alias: 'm4mbp', page: 'MacBook Pro M4'
add_link_gsub 'NUC', alias: 'nuc01', page: 'IntelNUC'
add_link_gsub 'MAZE', alias: 'Maze', page: 'IntelNUC 2 - Maze'
add_link_gsub 'THELIO', alias: 'Thelio', page: 'System76 Thelio Deskop'

### Personal Projects / Pages
add_link_gsub 'DLOG', alias: 'dlog', page: 'Daily Log'
add_link_gsub 'MDT', alias: '', page: 'Markdown Tool'
add_link_gsub 'TGMD', alias: 'tgmd', page: 'Jira Mark Down Link Tool'

### CompanyCam
# include 'ccam.rb'

################################################################################
### External Tools
################################################################################
### Spotify Song
add_gsub /^SONG$/ do |entry|
  # set_debug_output $stderr
  dbug "SONG TOOL"
  set_tool_path '.spotify-song.rb'
  next unless has_tool?

  run_tool
  if tool_error?
    next "❌ Error retriving song: #{song_script_path}"
  end

  if tool_output.empty?
    next "❌ Could not get current song from spotify"
  end

  tool_output
end

### Markdown Tool
add_gsub /%%/ do |entry|
  set_tool_path '~/.raycast-cmds/markdown-tool.sh'
  next unless has_tool?

  run_tool
  if tool_error?
    next "❌ MDT-ERROR: #{entry}"
  end

  tool_output
end

################################################################################
### Config & Formatting
################################################################################
[
  "~/Documents/Obsidian/vimwiki",
  "~/Documents/vimwiki",
].each do |vault_path|
  if dir?(vault_path)
    set_vault_root vault_path
    break
  end
end

set_daily_log_finder do |vault, day|
  date_path = day.strftime("%Y/%m-%b/%Y-%m-%d-%a.md")
  logs_path = vault.join("logs").join(date_path)
end

set_entry_prefix do |entry, time|
  ts = time.strftime("%H:%M")
  "- *#{ts}* - "
end
