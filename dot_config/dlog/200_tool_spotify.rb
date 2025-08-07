### Spotify Song
add_gsub /^SONG$/ do |entry, _match|
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

