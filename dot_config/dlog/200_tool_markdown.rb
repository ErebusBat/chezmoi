### Markdown Tool
add_gsub /%%/ do |entry, _match|
  set_tool_path '~/.raycast-cmds/markdown-tool.sh'
  next unless has_tool?

  run_tool
  if tool_error?
    next "❌ MDT-ERROR: #{entry}"
  end

  tool_output
end

# Extract direct issue links and use MDT to render
# This MUST go after the %% tool, otherwise it will
# override the clipboard (because of how MDT is implemented)
add_gsub /[\[\/A-Z]+-\d+/ do |entry, match|
  next if %w([ /).include?(match[0])
  dbug "JIRA-ISSUE: #{match}"
  set_tool_path '~/.raycast-cmds/markdown-tool.sh'
  next unless has_tool?

  run_tool :with_args, match
  if tool_error?
    next "❌ MDT-ERROR: #{entry}"
  end

  tool_output
end
