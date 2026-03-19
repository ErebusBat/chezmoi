require 'minitest/autorun'
require 'tempfile'

require_relative '../lib/wallpaper_config'

class TestWallpaperConfig < Minitest::Test
  def test_parse_valid_config
    with_config(<<~YAML) do |path|
      paths:
        - path: /tmp/test_wallpaper.jpg
          weight: 5
        - path: /tmp/test_dir/*
          enabled: false
          recurse: 1
    YAML
      entries = WallpaperConfig.new.parse(path)

      assert_equal 2, entries.size
      assert_equal '/tmp/test_wallpaper.jpg', entries.first.path
      assert_equal 5, entries.first.weight
      assert_equal true, entries.first.enabled
      assert_equal 1, entries.first.groups.size
      assert_equal 'default', entries.first.groups.first.name

      assert_equal '/tmp/test_dir/*', entries.last.path
      assert_equal false, entries.last.enabled
      assert_equal 1, entries.last.recurse
      assert_equal 'default', entries.last.groups.first.name
    end
  end

  def test_verbose_format_weight_line_is_two_line_friendly
    with_config(<<~YAML) do |path|
      groups:
        family:
          boost: 7
        pets:
      paths:
        - path: /tmp/albus.jpg
          weight: 5
          groups:
            - family
            - pets
    YAML
      entry = WallpaperConfig.new.parse(path).first

      assert_equal '12=[5, family: 7, pets: 0]', entry.weight_breakdown
      assert_equal 'sum=48   range=[  36..47  ] /tmp/albus.jpg',
        "sum=48   range=[  36..47  ] #{entry.path}"
      assert_equal '            weight=12=[5, family: 7, pets: 0]',
        "            weight=#{entry.weight_breakdown}"
    end
  end

  def test_parse_with_groups
    with_config(<<~YAML) do |path|
      groups:
        family:
          boost: 7
        pets:
      paths:
        - path: /tmp/albus.jpg
          weight: 5
          groups:
            - family
            - pets
        - path: /tmp/bash.jpg
          groups:
            - family
        - path: /tmp/ungrouped.jpg
    YAML
      entries = WallpaperConfig.new.parse(path)

      albus = entries.find { |e| e.path == '/tmp/albus.jpg' }
      assert_equal 2, albus.groups.size
      assert_equal 'family', albus.groups[0].name
      assert_equal 7, albus.groups[0].boost
      assert_equal 'pets', albus.groups[1].name
      assert_equal 0, albus.groups[1].boost
      assert_equal 12, albus.effective_weight
      assert_equal '12=[5, family: 7, pets: 0]', albus.weight_breakdown
      assert_equal true, albus.effective_enabled?

      bash = entries.find { |e| e.path == '/tmp/bash.jpg' }
      assert_equal 8, bash.effective_weight
      assert_equal '8=[1, family: 7]', bash.weight_breakdown

      ungrouped = entries.find { |e| e.path == '/tmp/ungrouped.jpg' }
      assert_equal 1, ungrouped.groups.size
      assert_equal 'default', ungrouped.groups[0].name
      assert_equal '1=[1, default: 0]', ungrouped.weight_breakdown
    end
  end

  def test_effective_weight_adds_multiple_group_boosts_to_base_weight
    with_config(<<~YAML) do |path|
      groups:
        family:
          boost: 7
        pets:
          boost: 2
      paths:
        - path: /tmp/albus.jpg
          weight: 5
          groups:
            - family
            - pets
    YAML
      entry = WallpaperConfig.new.parse(path).first

      assert_equal 14, entry.effective_weight
      assert_equal '14=[5, family: 7, pets: 2]', entry.weight_breakdown
    end
  end

  def test_effective_weight_uses_group_boost_when_base_weight_implicit
    with_config(<<~YAML) do |path|
      groups:
        family:
          boost: 7
      paths:
        - path: /tmp/bash.jpg
          groups:
            - family
    YAML
      entry = WallpaperConfig.new.parse(path).first

      assert_equal 8, entry.effective_weight
      assert_equal '8=[1, family: 7]', entry.weight_breakdown
    end
  end

  def test_disabled_group_overrides_positive_boost
    with_config(<<~YAML) do |path|
      groups:
        family:
          boost: 7
          enabled: false
      paths:
        - path: /tmp/albus.jpg
          weight: 5
          groups:
            - family
    YAML
      entry = WallpaperConfig.new.parse(path).first

      assert_equal 12, entry.effective_weight
      assert_equal false, entry.effective_enabled?
    end
  end

  def test_parse_with_group_filter_keeps_matching_entries
    with_config(<<~YAML) do |path|
      groups:
        family:
          boost: 7
        pets:
      paths:
        - path: /tmp/albus.jpg
          weight: 5
          groups:
            - family
            - pets
        - path: /tmp/bash.jpg
          groups:
            - family
        - path: /tmp/ungrouped.jpg
    YAML
      entries = WallpaperConfig.new.parse(path, selected_groups: %w[pets])

      assert_equal 1, entries.size
      assert_equal '/tmp/albus.jpg', entries.first.path
    end
  end

  def test_parse_with_group_filter_supports_or_semantics
    with_config(<<~YAML) do |path|
      groups:
        family:
          boost: 7
        pets:
      paths:
        - path: /tmp/albus.jpg
          groups:
            - family
            - pets
        - path: /tmp/bash.jpg
          groups:
            - family
        - path: /tmp/cat.jpg
          groups:
            - pets
    YAML
      entries = WallpaperConfig.new.parse(path, selected_groups: %w[family pets])

      assert_equal 3, entries.size
      assert_equal ['/tmp/albus.jpg', '/tmp/bash.jpg', '/tmp/cat.jpg'], entries.map(&:path).sort
    end
  end

  def test_parse_with_group_filter_raises_for_unknown_selected_group
    with_config(<<~YAML) do |path|
      groups:
        family:
      paths:
        - path: /tmp/bash.jpg
          groups:
            - family
    YAML
      error = assert_raises(WallpaperConfig::ConfigError) do
        WallpaperConfig.new.parse(path, selected_groups: %w[unknown])
      end

      assert_match(/Unknown selected group 'unknown'/, error.message)
    end
  end

  def test_sort_entries_for_display_orders_by_weight_desc_then_path
    entries = [
      WallpaperConfig::Entry.new(path: '/tmp/c.jpg', weight: 3, enabled: true, recurse: 1, groups: []),
      WallpaperConfig::Entry.new(path: '/tmp/a.jpg', weight: 12, enabled: true, recurse: 1, groups: []),
      WallpaperConfig::Entry.new(path: '/tmp/b.jpg', weight: 12, enabled: true, recurse: 1, groups: []),
      WallpaperConfig::Entry.new(path: '/tmp/d.jpg', weight: 1, enabled: true, recurse: 1, groups: []),
    ]

    sorted = WallpaperConfig.sort_entries_for_display(entries)

    assert_equal ['/tmp/a.jpg', '/tmp/b.jpg', '/tmp/c.jpg', '/tmp/d.jpg'], sorted.map(&:path)
  end

  def test_parse_unknown_group
    with_config(<<~YAML) do |path|
      paths:
        - path: /tmp/bad.jpg
          groups:
            - unknown_group
    YAML
      error = assert_raises(WallpaperConfig::ConfigError) do
        WallpaperConfig.new.parse(path)
      end

      assert_match(/Unknown group 'unknown_group'/, error.message)
    end
  end

  def test_effective_enabled_false_when_group_disabled
    with_config(<<~YAML) do |path|
      groups:
        family:
          enabled: false
      paths:
        - path: /tmp/albus.jpg
          enabled: true
          groups:
            - family
    YAML
      entry = WallpaperConfig.new.parse(path).first

      assert_equal false, entry.effective_enabled?
    end
  end

  def test_effective_enabled_false_when_path_disabled
    with_config(<<~YAML) do |path|
      groups:
        family:
          enabled: true
      paths:
        - path: /tmp/albus.jpg
          enabled: false
          groups:
            - family
    YAML
      entry = WallpaperConfig.new.parse(path).first

      assert_equal false, entry.effective_enabled?
    end
  end

  private

  def with_config(contents)
    file = Tempfile.new(['wallpaper', '.yaml'])
    file.write(contents)
    file.rewind
    yield file.path
  ensure
    file.close
    file.unlink
  end
end
