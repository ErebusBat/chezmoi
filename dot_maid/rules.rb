require_relative "_include.rb"

Maid.rules do
  rule 'Downloads' do
    dir_safe('~/Downloads/*').each do |path|
      next if green?(path)            # Ignore files tagged "Green"
      next unless File.file?(path)    # Only look at files
      atime = accessed_at(path)

      # if red?(path) && 1.week.since?(atime)
      if red?(path) && 1.hour.since?(atime)
        move(path, '~/Downloads/_limbo')
        remove_all_color_tags!(path)
        next
      end

      if yellow?(path) && 2.days.since(atime)
        red!(path)
        not_yellow!(path)
        next
      end

      if 6.hours.since?(atime)
        yellow!(path)
        next
      end
    end
  end
end

