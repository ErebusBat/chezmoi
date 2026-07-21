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

### OMP Session
# Supports the following formats:
#  - Entry Update Text; <context>/<session-hash>
#  - <anchor> <session-hash>
#  - Entry Update Text; zsh-antibody/019f851e-8493-7000-9222-da344486193a
OMP_REGEXP = /(?<statement_anchor>[!?;])\s+\b((?<context>[^ \/]+)\/)?(?<hash>[0-9a-f]{8})\b/
add_gsub OMP_REGEXP do |entry, match|
  matches = OMP_REGEXP.match(match)
  data = {
    hash: matches["hash"],
    context: matches["context"],
    anchor: matches["statement_anchor"] ,
  }
  fmt_str =
    if data[:context].blank?
      '%<anchor>s [🤖 `%<hash>s`]'
    else
      '%<anchor>s [🤖 `%<context>s`/`%<hash>s`]'
      '%<anchor>s [🤖 %<context>s/`%<hash>s`]'
    end
  fmt_str % data
end

# Extract phone numbers and parse them via MDT
add_gsub phone? do |entry, match|
  set_tool_path '~/.raycast-cmds/markdown-tool.sh'
  next unless has_tool?

  run_tool :with_args, match
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
