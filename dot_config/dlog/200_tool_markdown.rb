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

# Extract phone numbers and parse them via MDT
[
  /\d{7}/,
  /\d{3}-\d{4}/,
].each do |phone_rx|
  add_gsub phone_rx do |entry, match|
    set_tool_path '~/.raycast-cmds/markdown-tool.sh'
    next unless has_tool?

    run_tool :with_args, match
    if tool_error?
      next "❌ MDT-ERROR: #{entry}"
    end

    tool_output
  end
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
