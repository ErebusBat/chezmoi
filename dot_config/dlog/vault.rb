################################################################################
### Global Options
################################################################################
# set_debug_output $stderr

################################################################################
### External Files
################################################################################
# Remember that order matters as matchers are evaluated IN ORDER they were added
# expect for prefixes, which are evaluated before all others

include_glob '*_*.rb'
# Above will load all prefixed files, but here are the main ones:
#  000_prefixes.rb
#  001_emojis.rb
#  005_personal.rb
#  010_ccam.rb
#  200_tool_markdown.rb
#  200_tool_spotify.rb
#  200_tool_weather.rb


################################################################################
### Config & Formatting
################################################################################

### Vault Root
### - Support multiple computers, first match wins
[
  "~/Documents/Obsidian/vimwiki",
  "~/Documents/vimwiki",
  "/vault",
].each do |vault_path|
  if dir?(vault_path)
    set_vault_root vault_path
    break
  end
end

### Daily Log Path Format:
###   <vault>/logs/2025/01-Jan/2025-01-01-Wed.md
set_daily_log_finder do |vault, day|
  date_path = day.strftime("%Y/%m-%b/%Y-%m-%d-%a.md")
  logs_path = vault.join("logs").join(date_path)
end

### Entry Prefix (i.e. timestamp)
set_entry_prefix do |entry, time|
  ts = time.strftime("%H:%M")
  "- *#{ts}* - "
end
