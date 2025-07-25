set_debug_output $stderr
include_glob '*_*.rb'

################################################################################
### External Tools
################################################################################

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
