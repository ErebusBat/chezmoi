require 'yaml'
require 'pathname'

class WallpaperConfig
  class ConfigError < StandardError; end

  Entry = Struct.new(:path, :weight, :enabled, :recurse, :groups, keyword_init: true) do
    def effective_enabled?
      enabled && groups.all?(&:enabled)
    end

    def effective_weight
      weight + groups.sum(&:boost)
    end

    def weight_breakdown
      parts = [weight.to_s]
      groups.each do |group|
        parts << "#{group.name}: #{group.boost}"
      end
      "#{effective_weight}=[#{parts.join(', ')}]"
    end
  end

  Group = Struct.new(:name, :boost, :enabled, keyword_init: true)

  def parse(config_path)
    config_path = Pathname.new(config_path).expand_path
    unless config_path.file?
      raise ConfigError, "Config file not found: #{config_path}"
    end

    content = config_path.read
    data = YAML.safe_load(content, aliases: true)

    unless data.is_a?(Hash) && data['paths'].is_a?(Array)
      raise ConfigError, "Invalid wallpaper config format; expected top-level 'paths' array"
    end

    groups = parse_groups(data['groups'])

    data['paths'].map do |entry_data|
      validate_entry(entry_data)

      path_groups = (entry_data['groups'] || []).map do |group_name|
        unless groups.key?(group_name)
          raise ConfigError, "Unknown group '#{group_name}' referenced in path '#{entry_data['path']}'"
        end
        groups[group_name]
      end

      # Implicitly add default group if no groups specified
      if path_groups.empty?
        path_groups << groups['default']
      end

      Entry.new(
        path: entry_data['path'],
        weight: entry_data.fetch('weight', 1).to_i,
        enabled: entry_data.fetch('enabled', true),
        recurse: entry_data.fetch('recurse', 255).to_i,
        groups: path_groups
      )
    end
  end

  private

  def parse_groups(groups_data)
    groups = {}

    # Always ensure default group exists
    groups['default'] = Group.new(name: 'default', boost: 0, enabled: true)

    return groups unless groups_data

    unless groups_data.is_a?(Hash)
      raise ConfigError, "Invalid 'groups' format; expected a map"
    end

    groups_data.each do |name, config|
      config ||= {} # Handle empty group definition (e.g. "pets:")

      unless config.is_a?(Hash)
        raise ConfigError, "Invalid group '#{name}' format; expected a map"
      end

      groups[name] = Group.new(
        name: name,
        boost: config.fetch('boost', 0).to_i,
        enabled: config.fetch('enabled', true)
      )
    end

    groups
  end

  def validate_entry(entry)
    unless entry.is_a?(Hash)
      raise ConfigError, "Invalid path entry format; expected a map"
    end

    path = entry['path']
    if path.nil? || path.to_s.strip.empty?
      raise ConfigError, "Invalid path entry: missing 'path'"
    end

    groups = entry['groups']
    return if groups.nil? || groups.is_a?(Array)

    raise ConfigError, "Invalid groups for path '#{path}'; expected an array"
  end
end
