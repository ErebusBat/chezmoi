require_relative "_include.rb"

KILOBYTE = 1024
MEGABYTE = KILOBYTE * KILOBYTE
GIGABYTE = MEGABYTE * KILOBYTE

Maid.rules do
        ################################################################################
  rule '=== Downloads ==================================================================' do
    DOWNLOAD_DIR = '~/Downloads'
    LIMBO_DIR = DOWNLOAD_DIR + '/_limbo'

    dir_safe(LIMBO_DIR + "/*").each do |path|
      next if green?(path)            # Ignore files tagged "Green"
      next unless File.file?(path)    # Only look at files
      atime = accessed_at(path)

      # User has manually tagged the item red so skip progressions
      if red?(path) && 6.hours.since?(atime)
        not_red!(path)
        trash(path)
        next
      end

      # Debugging
      # if gray?(path)
      #   touch(path, time: 8.weeks.ago)
      #   red!(path)
      # end

      # Automated flow:
      #   >2d   -> yellow
      #   >2wk  -> orange
      #   >4wk  -> TRASH
      if orange?(path) && 4.weeks.since(atime)
        not_orange!(path)
        trash(path)
        next
      end

      if yellow?(path) && 2.weeks.since(atime)
        not_yellow!(path)
        orange!(path)
        next
      end

      if 2.days.since(atime)
        yellow!(path)
        next
      end
    end

    dir_safe(DOWNLOAD_DIR + "/*" ).each do |path|
      next if green?(path)            # Ignore files tagged "Green"
      next unless File.file?(path)    # Only look at files
      atime = accessed_at(path)

      # Debugging
      # if gray?(path)
      #   touch(path, time: 7.hours.ago)
      #   remove_all_color_tags!(path)
      #   next
      # end

      # User has manually tagged the item red so skip progressions
      if red?(path) && 6.hours.since?(atime)
        not_red!(path)
        trash(path)
        next
      end

      # Automated flow:
      #   >6h   -> yellow
      #   >2d   -> orange
      #   >1wk  -> Limbo
      if orange?(path) && 1.week.since?(atime)
        remove_all_color_tags!(path)
        touch(path)
        move(path, LIMBO_DIR)
        next
      end

      if yellow?(path) && 2.days.since(atime)
        not_yellow!(path)
        orange!(path)
        next
      end

      if 6.hours.since?(atime)
        yellow!(path)
        next
      end
    end
  end

  rule '=== Rails Projects =============================================================' do
    # [
    #   "~/src/sie/server"
    # ].each do |proj_dir|
    #   log "Rails: #{proj_dir}"
    #   # Cleanup temp
    #   dir(proj_dir + "/tmp/**/*").each do |path|
    #     next unless File.file?(path)
    #
    #     if 2.weeks.since?(accessed_at(path))
    #       trash(path)
    #     end
    #   end
    #
    #   # Cleanup logs
    #   dir(proj_dir + "/log/*.log").each do |path|
    #     next unless File.file?(path)
    #
    #     # Cleanup old logs
    #     if 2.weeks.since?(accessed_at(path))
    #       trash(path)
    #       next
    #     end
    #
    #     # Downsize big ones
    #     if File.size(path) >= 50 * MEGABYTE
    #       truncate(path)
    #     end
    #   end
    # end
  end

  rule '=== Vendor Projects ============================================================' do
    dir("~/src/vendor/*").each do |proj_dir|
      next unless File.directory?(proj_dir)
      next if green?(proj_dir)
      atime = accessed_at(proj_dir)

      # User has manually tagged the item red so skip progressions
      if red?(proj_dir) && 6.hours.since?(atime)
        not_red!(proj_dir)
        trash(proj_dir)
      end

      # Progression
      #   >1day -> yellow
      #   >2wk  -> orange
      #   >4wk  -> TRASH
      if orange?(proj_dir) && 4.weeks.since?(atime)
        remove_all_color_tags!(proj_dir)
        trash(proj_dir)
        next
      end

      if yellow?(proj_dir) && 2.weeks.since?(atime)
        not_yellow!(proj_dir)
        orange!(proj_dir)
        next
      end

      if 1.day.since?(atime)
        yellow!(proj_dir)
        next
      end
    end
  end

  rule '=== /tmp Logs ==================================================================' do
    dir("/tmp/**/*.log").each do |path|
      if File.size(path) >= 50 * MEGABYTE
        truncate(path)
      end
    end
  end
end

