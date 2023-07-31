#!/usr/bin/env ruby
require 'date'
require 'hashie'
require 'optparse'
require 'pathname'
require 'uri'
require 'shellwords'
require 'yaml'

BACKUP_ONLY_ARGS = %w(
  exclude
  exclude-file
  exclude_larger_than
  exclude-larger-than
  exclude-caches
).freeze

class ResticConfig
  attr_accessor *[
    :additional_tags,
    :dry_run,
    :file,
    :latest,
    :not_targets,
    :only_targets,
    :perform_target_checks,
    :use_host_for_snapshots,
    :use_path_for_snapshots,
  ]

  def self.from_args_and_file!(path: "~/.restic-multi.yml")
    path = Pathname.new(path).expand_path

    # Defautls
    cfg = ResticConfig.new
    cfg.dry_run = false
    cfg.perform_target_checks = true
    cfg.additional_tags = []
    cfg.only_targets = []
    cfg.not_targets = []
    cfg.use_path_for_snapshots = false
    cfg.use_host_for_snapshots = false

    # Parse file
    cfg.file = Hashie::Mash.new(YAML.load(path.read))

    # Defaults from file
    defaults = cfg.file.defaults || {}
    cfg.latest = defaults.fetch("latest", 10)

    # Parse Args
    OptionParser.new do |opts|
      opts.on("-n", "--[no-]dry-run", "Dry Run") do |v|
        cfg.dry_run = v
      end

      opts.on("--[no-]target-checks", "Skip target checks for this one invokation") do |v|
        cfg.perform_target_checks = v
      end

      opts.on("--[no-]path", "Pass path to snapshot command") do |v|
        cfg.use_path_for_snapshots = v
      end

      opts.on("--[no-]host", "Pass host to snapshot command") do |v|
        cfg.use_host_for_snapshots = v
      end

      opts.on("-t", "--tag=TAG", Array, "Additional tags to add to this backup") do |v|
        cfg.additional_tags = v
      end

      opts.on("--only-target=TARGET", Array, "Only use these targets") do |v|
        cfg.only_targets = v
      end

      opts.on("--not-target=TARGET", Array, "Do not use specific target") do |v|
        cfg.not_targets = v
      end

      opts.on("-l", "--latest=NUM", Integer, "Only show NUM snapshots for each host/path") do |v|
        cfg.latest = v
      end
    end.parse!

    # File Cleanup
    cfg.file["policies"] = cfg.file.fetch("policies", {})

    cfg
  end

  def targets
    return @targets unless @targets.nil?

    @targets = file.targets.map do |key, target|
      target.name = target.fetch("name", key)
      target.available = target.fetch("enabled", true)

      # Target Checks
      target.fetch("checks", {}).each do |check_name, check_opts|
        next unless perform_target_checks
        next unless target.available
        uri = URI(target.uri)

        case check_name
        when "local_path"
          the_path = check_opts || target.uri
          inverse = false
          if the_path.start_with?("!")
            inverse = true
            the_path = the_path[1..-1]
          end
          check_uri = URI(the_path)
          fatal! "Check error on target #{target.name}: local_path specified with a non-local URI" unless check_uri.scheme.nil?

          check_path = Pathname.new(the_path).expand_path
          path_exists = check_path.directory? && check_path.children.size > 0
          target.available = inverse ? !path_exists : path_exists
        when "ping"
          ping_host = check_opts
          if ping_host == :host
            if target.uri =~ /^\w+:https?:\/\// && uri.host.nil?
              # Just reparse.  This happens with minio URIs of s3:http://x.x.x.x:9000/xxx
              uri = URI(uri.opaque)
            end
            ping_host = uri.host
          end
          `ping -c2 -t1 #{ping_host}`
          target.available = $?.success?
        else
          fatal! "Unknown check '#{check_name}' for target #{target.name}!"
        end
      end

      # Fixup paths
      if !target.env_file.nil?
        target.env_file = Pathname.new(target.env_file).expand_path
      end

      [key, target]
    end.to_h
  end

  def available_targets
    return @available_targets unless @available_targets.nil?
    @available_targets = targets.select do |_, t|
      if !only_targets.empty?
        next false unless only_targets.include?(t.name)
        next true
      else !not_targets.empty?
        next false if not_targets.include?(t.name)
      end
      t.available
    end
  end

  def vaults
    return @vaults unless @vaults.nil?

    @vaults = file.vaults.map do |key, vault|
      vault["name"] = vault.fetch("name", key)
      vault["keyfile"] = Pathname.new(vault.keyfile).expand_path

      [key, vault]
    end.to_h
  end

  def datasets
    return @datasets unless @datasets.nil?

    @datasets = file.datasets.map do |key, dataset|
      dataset["name"] = dataset.fetch("name", key)

      # Reference the vault object itself
      dataset["vault_name"] = dataset.vault
      dataset["vault"] = vaults[dataset.vault_name]
      if dataset.vault.nil?
        log "Could not find vault #{dataset.vault_name} for dataset #{key}", prefix: "WARN:"
        next
      end

      dataset["policies"] = dataset.fetch("policies", {})

      [key, dataset]
    end.compact.to_h
  end

  def reset_caches!
    @targets = nil
    @available_targets = nil
    @datasets = nil
    @vaults = nil
  end

  def build_repository_uri(target, vault)
    Shellwords.escape(target["uri"] + "/" + vault["name"])
  end

  def build_restic_command(target:, vault:, dataset:, cmd: nil)
    args = []

    # Should we use sudo?  It can be set on the target level
    # OR the dataset level
    sudo = false
    sudo ||= target.fetch("sudo", false)
    sudo ||= dataset.fetch("sudo", false)

    if sudo
      args << 'sudo'
    end

    restic_bin_path = `which restic`.strip
    if !$?.success? || !File.executable?(restic_bin_path)
      raise "Could not find restic binary! Got >>#{restic_bin_path}<<\n$PATH=#{ENV['PATH']}"
    end
    args << restic_bin_path

    args += [
      "-r",
      build_repository_uri(target, vault),
    ]

    args += [
      "-p",
      Shellwords.escape(vault["keyfile"].to_s),
    ]

    args << cmd if !cmd.nil?

    args
  end

  def get_policy_for(dataset, policy_name)
    policy_name ||= "unspecified"
    policy = dataset["policies"][policy_name]
    policy = file.policies[policy_name] if policy.nil?

    policy
  end
end

def log(msg, prefix: " INFO:")
  puts "[#{DateTime.now}] #{prefix} #{msg}"
end

def fatal!(msg, ec=1)
  log(msg, prefix: "FATAL:")
  exit ec
end

def check_at_least_one_target!(opts)
  return if opts.available_targets.count > 0
  fatal! "No available targets!"
end

# Builds a hash of commands to be ran for a given target
#   {
#     "minio": {
#       "pre": [
#         "cd ~/src/guest/my_docker_env && make stop"
#       ],
#       "cmd": [
#         "restic",
#         "-r",
#         "s3:http://10.0.0.50:9000/restic/tguest",
#         "-p",
#         "/Users/andrew.burns/.restic/.traction_guest.key",
#         "backup"
#       ],
#       "post": [
#         "cd ~/src/guest/my_docker_env && make start"
#       ]
#     }
#   }
def build_commands(opts, dataset, cmd)
  check_at_least_one_target!(opts)

  ret = {}
  opts.available_targets.each do |tname, target|
    cmds = { pre: [], cmd: [], post: [] }

    cmds[:pre] = dataset.fetch("pre_commands", {}).fetch(cmd, []) #.map! { |c| c.end_with?(";") ? c : "#{c};" }

    cmds[:cmd] = opts.build_restic_command(target: target, vault: dataset.vault, cmd: cmd, dataset: dataset)

    cmds[:post] = dataset.fetch("post_commands", {}).fetch(cmd, []) #.map! { |c| c.end_with?(";") ? c : "#{c};" }

    ret[tname] = cmds
  end

  ret
end

# Returns an array:
#   env, undo = get_target_env_and_undo()
# undo can be used by revert_environment!
def get_target_env_and_undo(opts, target)
  env = {}
  undo = {}

  # From config
  if !target.env_file.nil?
    target.env_file.each_line do |line|
      next if line =~ /^\s*#/
      parts = line.chomp.split("=", 2)
      next if parts.size < 2
      undo[parts[0]] = ENV.has_key?(parts[0]) ? ENV[parts[0]] : :delete
      env[parts[0]] = parts[1]
    end
  end
  target.fetch("env", []).each do |key, val|
    # If we already have an undo entry then ignore it here
    if !undo.has_key?(key)
      undo[key] = ENV.has_key?(key) ? ENV[key] : :delete
    end
    env[key] = val
  end

  [env, undo]
end

def setup_environment!(opts, target)
  env, undo = get_target_env_and_undo(opts, target)
  env.each do |key, val|
    ENV[key] = val
  end
  undo
end

def revert_environment!(undo)
  undo.each do |key, val|
    if val == :delete
      ENV.delete(key)
    else
      ENV[key] = val
    end
  end
end

def hash_to_restic_args(hash, exclude_restic_args: [])
  return [] if hash.nil?
  hash.map do |key, val|
    key = key.to_s
    next if exclude_restic_args.include?(key)

    expand_array_to_restic_args(key, Array(val))
  end.compact.flatten
end

def expand_array_to_restic_args(orig_key, array)
  return if array.empty?

  array.map do |val|
    # If key already starts with -- then assume it is verbataim
    key = orig_key
    unless orig_key.start_with?("--")
      key = "--#{orig_key}"
      key = key.gsub("_", "-")

      # Is it a path?
      if val.is_a?(String) && val.start_with?("~/")
        val = val.gsub(/^~\//, ENV["HOME"] + "/")
      end
    end
    "#{key}=#{Shellwords.escape(val)}"
  end
end

def exec_command(opts, dataset, cmd, exclude_restic_args: [], pre_args: [], post_args: [])
  log "="*80
  log "START #{cmd} on #{dataset.name}"
  log "="*80

  log "--dry-run specified, not executing restic", prefix: " WARN:" if opts.dry_run

  extra_args = []
  extra_args += pre_args
  extra_args += hash_to_restic_args(dataset["restic_opts"], exclude_restic_args: exclude_restic_args)
  extra_args += post_args

  unless (cmd_array_lines = dataset.fetch(:pre_commands, {}).fetch("dataset_#{cmd}", [])).nil?
    cmd_array_lines.each do |cmd_array|
      log "EXEC  DS-PRE: " + cmd_array
      if !opts.dry_run
        ret_val = system(*cmd_array)
        if !ret_val
          fatal! "DS-PRE command failed! #{$?}"
        end
      end
    end
  end

  commands = build_commands(opts, dataset, cmd)
  had_errors = false
  commands.each do |tname, command_set|
    ENV["RESTIC_MULTI_TARGET"] = tname
    log "▼▼▼▼▼ #{tname} ".ljust(80, "▼")
    if !opts.dry_run
      undo_file = setup_environment!(opts, opts.targets[tname])
      undo_file["RESTIC_MULTI_TARGET"] = :delete
    end

    unless (cmd_array = command_set[:pre]).empty?
      cmd_array.each do |cmd|
        log "EXEC  PRE: " + cmd
        if !opts.dry_run
          ret_val = system(*cmd)
          if !ret_val
            log "PRE command failed! #{$?}", prefix: "ERROR: "
            had_errors = true
            next
          end
        end
      end
    end

    cmd_array = command_set[:cmd]
    cmd_array += extra_args
    log "     EXEC: " + cmd_array.join(" ")
    if !opts.dry_run
      ret_val = system(*cmd_array)
      if !ret_val
        # fatal! "Restic command failed! #{$?}"
        log "Restic command failed! #{$?}", prefix: "ERROR: "
        had_errors = true
        next
      end
    end

    unless (cmd_array = command_set[:post]).empty?
      cmd_array.each do |cmd|
        log "EXEC  POST: " + cmd
        if !opts.dry_run
          ret_val = system(*cmd)
          if !ret_val
            log "POST command failed! #{$?}", prefix: "ERROR: "
            had_errors = true
            next
          end
        end
      end
    end

    if !opts.dry_run
      revert_environment!(undo_file)
    end
    log "▲▲▲▲▲ #{tname} ".ljust(80, "▲")
  end

  # Post Commands
  unless (cmd_array = dataset.fetch(:post_commands, {}).fetch("dataset_#{cmd}", [])).nil?
    cmd_array.each do |cmd|
      log "EXEC  DS-POST: " + cmd
      if !opts.dry_run
        ret_val = system(*cmd)
        if !ret_val
          log "DS-POST command failed! #{$?}", prefix: "ERROR: "
        end
      end
    end
  end
  # Post - backup_success
  if had_errors
    log "Dataset had errors, not running post success commands"
  elsif !(cmd_array = dataset.fetch(:post_commands, {}).fetch("#{cmd}_success", [])).nil?
    cmd_array.each do |cmd|
      log "EXEC  DS-SUCCESS: " + cmd
      if !opts.dry_run
        ret_val = system(*cmd)
        if !ret_val
          log "DS-SUCCESS command failed! #{$?}", prefix: "ERROR: "
        end
      end
    end
  end

  log "="*80
  log "FINISH #{cmd} on #{dataset.name}"
  log "="*80
end

# Returns array of --tag= arguments based on dataset AND cmd line args
def get_cmd_tags(opts, dataset, use_dataset: true, use_cmd: true)
  # Start with dataset
  tags = []
  tags += dataset.fetch("tags", []) if use_cmd
  tags += opts.additional_tags if use_cmd

  tags = tags.map do |tag|
    "--tag=#{Shellwords.escape(tag)}"
  end

  tags
end

def do_targets(opts, dataset)
  puts "The following targets are configured for #{dataset.name}:"
  fmt = "    %1s %s"
  opts.targets.each do |tname, target|
    available_flag =
      if !target.fetch("enabled", true)
        "D"
      elsif !target.available
        "U"
      end
    puts fmt % [available_flag, target.name]
  end
end

def do_snapshots(opts, dataset)
  args = []
  args += get_cmd_tags(opts, dataset, use_dataset: false)
  if opts.latest.to_i > 0
    args << "--latest=#{opts.latest}"
  end
  if opts.use_path_for_snapshots
    dataset.paths.each do |path|
      p = Pathname.new(path).expand_path
      args << "--path=#{Shellwords.escape(p)}"
    end
  end
  if opts.use_host_for_snapshots
    hostname = `hostname`.strip
    args << "--host=#{hostname}"
  end
  exec_command(opts, dataset, "snapshots", pre_args: args, exclude_restic_args: BACKUP_ONLY_ARGS)
end

def do_backup(opts, dataset)
  paths = dataset.paths.map do |path|
    next if path.nil?
    p = Pathname.new(path).expand_path
    p.to_s
  end.compact

  tags = get_cmd_tags(opts, dataset)

  exec_command(opts, dataset, "backup", pre_args: paths, post_args: tags)
end

def do_eval(opts, dataset, target)
  vault = dataset.vault
  env, _ = get_target_env_and_undo(opts, target)

  # Restic Options, last so they can't be accidently overwritter from above
  env["RESTIC_REPOSITORY"] = opts.build_repository_uri(target, vault)
  env["RESTIC_PASSWORD_FILE"] = Shellwords.escape(vault.keyfile.to_s)

  # Output in eval mode
  env.each do |key, val|
    puts "export #{key}=#{val}"
  end
end

def do_cleanup(opts, dataset, policy_name: nil)
  policy = opts.get_policy_for(dataset, policy_name)
  fatal! "Unknown policy '#{policy_name}' specified for dataset #{dataset.name}" if policy.nil?
  args = hash_to_restic_args(policy)

  # Narrow to paths
  args += dataset.paths.map do |path|
    p = Pathname.new(path).expand_path
    "--path=" + Shellwords.escape(p.to_s)
  end

  # Tags
  args += dataset.fetch("tags", []).map do |tag|
    "--tag=" + Shellwords.escape(tag)
  end

  args << "--prune"
  exec_command(opts, dataset, "forget", pre_args: args, exclude_restic_args: BACKUP_ONLY_ARGS)
end

def do_prune(opts, dataset)
  exec_command(opts, dataset, "prune", exclude_restic_args: BACKUP_ONLY_ARGS)
end

def main
  opts = ResticConfig.from_args_and_file!
  if ARGV.count < 1
    datasets = opts.datasets.map do |_, ds|
      "  #{ds.name}"
    end.join("\n")
    fatal! "Specify dataset!\n#{datasets}"
  end
  dataset_name = ARGV.shift
  dataset = opts.datasets[dataset_name]
  fatal! "Unknown Dataset #{dataset_name}" if dataset.nil?

  command = ARGV.shift
  case command
  when "targets"
    do_targets(opts, dataset)
  when "snapshots"
    do_snapshots(opts, dataset)
  when "backup"
    do_backup(opts, dataset)
  when "prune"
    do_prune(opts, dataset)
  when "cleanup"
    do_cleanup(opts, dataset, policy_name: ARGV.shift)
  when "eval"
    target_name = ARGV.shift
    fatal! "USAGE: DATASET eval TARGET" if target_name.to_s.strip.size == 0
    target = opts.available_targets[target_name]
    fatal! "Unknown or unavailable target: #{target_name}" if target.nil?
    do_eval(opts, dataset, target)
  else
    fatal! "Unknown command #{command}"
  end
end
main
