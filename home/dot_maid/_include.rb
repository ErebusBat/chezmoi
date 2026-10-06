#
# File Heleprs
#
def touch(path, time: nil)
  log "Touching #{path}"
  return if @file_options[:noop]

  FileUtils.touch(path, mtime: time)
end

def truncate(path, size: 0)
  return unless File.file?(path)
  return unless File.size(path) > size

  log "Truncating #{path} to #{size}b"
  return if @file_options[:noop]

  File.truncate(path, size)
end

#
# Color helpers
#
COLOR_TAGS = ["Blue", "Gray", "Green", "Orange", "Purple", "Red", "Yellow"]
COLOR_TAGS.each do |color|

  #
  # Color? method
  #
  method_name = format("%s?", color.downcase)
  define_method(method_name) do |pathOrTags|
    pTags =
      if pathOrTags.is_a?(Array)
        pathOrTags
      else
        tags(pathOrTags)
      end
    pTags.any? { |t| t.downcase == color.downcase }
  end

  #
  # Color! method
  #
  method_name = format("%s!", color.downcase)
  define_method(method_name) do |path|
    next if contains_tag?(path, color)

    add_tag(path, color)
  end

  #
  # not_color! method
  #
  method_name = format("not_%s!", color.downcase)
  define_method(method_name) do |path|
    next unless contains_tag?(path, color)

    remove_tag(path, color)
  end
end

def remove_all_color_tags!(p)
  COLOR_TAGS.each do |color|
    next unless contains_tag?(p, color)

    remove_tag(p, color)
  end
end

def any_colors?(p)
  blue?(p) || gray?(p) || green(p) || oragne?(p) || purple?(p) || red?(p) || yellow?(p)
end
