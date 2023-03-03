#!/usr/bin/env ruby
require 'date'
require 'pathname'
require 'stringio'
require 'yaml'

class MyApp
  class PathInfo
    attr_accessor :path, :weight

    def valid?
      @path.size? || @weight > 0
    end

    def initialize(path, weight: 1)
      @path = Pathname.new(path)
      @weight = weight.to_i
    end

    def short_path(home_replacement = "~")
      # @path.absolute_path.to_s.gsub(/^#{ENV['HOME']}/, "wezterm.home_dir .. '")
      @path.realpath.to_s.gsub(/^#{ENV['HOME']}/, home_replacement)
    end

    def ==(rhs)
      if rhs.is_a?(Pathname)
        @path == rhs
      else
        @path == Pathname.new(rhs).expand_path
      end
    end

    def <=>(rhs)
      rhs =
        if rhs.is_a?(PathInfo)
          rhs.path
        elsif rhs.is_a?(Pathname)
          rhs
        else
          Pathname.new(rhs)
        end
      @path <=> rhs
    end

    def to_s
      "[#{@weight}]#{short_path}"
    end
  end

  attr_accessor :paths

  def initialize
    @paths = []
  end

  def add_path(path, weight: 1, recurse: 255)
    path = Pathname.new(path).expand_path

    # Handle globs
    if path.basename.to_s.include?('*')
      Dir.glob(path.to_s).each do |child|
        add_path(child, weight: weight, recurse: recurse - 1)
      end
      return
    end

    # Handle directories
    if path.directory? && recurse > 0
      path.children.each do |child|
        recurse = 255
        recurse = recurse - 1 if child.directory?
        add_path(child, weight: weight, recurse: recurse)
      end
      return
    end

    # Sanity Checking
    return unless path.size?
    return if path_included?(path)
    return if %w(.DS_Store).include?(path.basename.to_s)
    @paths << PathInfo.new(path, weight: weight)
  end

  def path_included?(path)
    @paths.find do |pi|
      pi.path == path
    end
  end

  def total_weight
    @paths.inject(0) { |sum, pi| pi.weight + sum }
  end

  def output(out = StringIO.new)
    # out = StringIO.new
    out.puts %Q[-- DO NOT EDIT THIS FILE; IT IS GENERATED FROM A SCRIPT]
    out.puts %Q[--    LAST GENERATED #{DateTime.now}]
    out.puts %q[local wezterm = require('wezterm')]
    out.puts %q[return {]

    wezterm_home_prefix = "wezterm.home_dir .. '"
    count = 0
    total_weight = self.total_weight
    last_group = ""
    @paths.sort.each do |pi|
      if !pi.valid?
        last_group = ""
        out.print "-- Skipping #{pi.to_s}"
        unless pi.path.size?
          out.print " - NOT FOUND"
        end
        out.puts ""
        next
      end
      current_group = pi.weight.to_s

      # Output grouping headers, if needed
      if last_group != current_group
        if pi.weight > 1
          out.puts "" if count > 1
          out.puts "  -- Weight: #{pi.weight}"
        elsif last_group[%r{(\d+)$}, 1].to_i > 1
          out.puts ""
        end
      end

      pi.weight.times do
        out.puts "  #{pi.short_path(wezterm_home_prefix)}',"
      end

      last_group = current_group
      count += 1
    end

    out.puts %q[}]
    out
  end

  def write_file(path = "~/.config/wezterm/wallpapers.lua")
    path = Pathname.new(path).expand_path.to_s
    File.open(path, 'w') { |f| self.output(f) }
  end
end

def read_config(app)
  config = Pathname.new("~/.config/wezterm/wallpaper.yaml").expand_path
  return app unless config.file?

  cfg = YAML.load(config.read)
  cfg["paths"].each do |entry|
    path = entry["path"]
    enabled=  entry.fetch("enabled", true)
    weight = entry.fetch("weight", 1).to_i
    recurse = entry.fetch("recurse", 255).to_i
    weight = 0 unless enabled
    app.add_path(path, weight: weight, recurse: recurse)
  end
end

app = MyApp.new
read_config(app)
app.add_path("~/.config/wezterm/wallpaper")
# # puts app.output.string
app.write_file
