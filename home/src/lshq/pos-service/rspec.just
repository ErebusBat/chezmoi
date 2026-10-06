# vim: set ft=just ts=4 sw=4 sts=4 et ai si sta:
import? '../.git.just'

PARALLEL_LOG_MASTER_PATH := source_dir() / 'parallel_runtime_rspec.log'

# List changed spec files.
[group('git')]
[no-cd]
git-changed-spec-files base-branch='master':
    just git-changed-files {{ base-branch }} | rg '^spec/'

# List changed spec files.
[group('rspec')]
[no-cd]
rspec-changed-spec-files base-branch='master':
    #!/usr/bin/env zsh
    set -euo pipefail

    # Get changed spec files, ignore factories.
    spec_files=($(just git-changed-files {{ base-branch }} | rg '^spec/' | rg -v 'spec/factories/'))
    echo "rspec -f d ${spec_files[*]}"
    bundle exec rspec -f d "${spec_files[@]}"

# Copy this worktree's parallel_tests runtime log to the master copy, so a fresh
# worktree can pre-warm `bin/dev rspec-all` before its first run. Any existing
# master is kept, suffixed with its own last-modified time.
[group('rspec')]
[no-cd]
preserve-rspec-parallel-log log='tmp/parallel_runtime_rspec.log':
    #!/usr/bin/env zsh
    set -euo pipefail
    zmodload zsh/stat

    log="{{ log }}"
    master="{{ PARALLEL_LOG_MASTER_PATH }}"

    # Every worker truncates the log when it boots and writes its timings only
    # as it finishes, so an interrupted run leaves a short or empty file here.
    if [[ ! -s $log ]]; then
        print -u2 "preserve-rspec-parallel-log: $log is missing or empty; let rspec-all finish first"
        exit 1
    fi

    if [[ -e $master ]]; then
        archive="$master.$(zstat -F '%Y%m%d-%H%M%S' +mtime $master)"
        mv "$master" "$archive"
        print "archived previous master as $archive"
    fi

    # -p so the master keeps the mtime of the run that produced it, which is
    # what the archive suffix above is then named from.
    cp -p "$log" "$master"

    # parallel_tests balances on this log only while it holds timings for two
    # thirds of the spec files; below that it silently sorts by file size.
    entries=$(rg -c '^spec/.*_spec\.rb:' "$master" || true)
    specs=$(rg --files spec | rg -c '_spec\.rb$' || true)
    print "preserved ${entries:-0} timings for ${specs:-0} spec files -> $master"
    if (( ${entries:-0} * 3 <= ${specs:-0} * 2 )); then
        print -u2 "preserve-rspec-parallel-log: under the two-thirds threshold; rspec-all will sort by file size"
    fi

# Symlink this worktree's parallel_tests runtime log at the master copy, so
# rspec-all is balanced on its very first run here and keeps the master current.
#
# The master is snapshotted first for a reason: every rspec worker opens this
# path with mode 'w' when it boots, which through a symlink truncates the master
# itself. An interrupted run therefore empties your warm cache, and two
# worktrees running rspec-all at once will clobber each other.
[group('rspec')]
[no-cd]
warm-rspec-parallel-log log='tmp/parallel_runtime_rspec.log':
    #!/usr/bin/env zsh
    set -euo pipefail
    zmodload zsh/stat

    log="{{ log }}"
    master="{{ PARALLEL_LOG_MASTER_PATH }}"

    if [[ ! -s $master ]]; then
        print -u2 "warm-rspec-parallel-log: no timings at $master; run preserve-rspec-parallel-log from a worktree that has some"
        exit 1
    fi

    # Idempotent: the suffix is the master's own mtime, so warming several
    # worktrees from one master keeps rewriting the same snapshot.
    snapshot="$master.$(zstat -F '%Y%m%d-%H%M%S' +mtime $master)"
    cp -p "$master" "$snapshot"

    mkdir -p "${log:h}"

    # Never drop real timings this worktree already recorded.
    if [[ -f $log && ! -L $log ]]; then
        if [[ -s $log ]]; then
            kept="$log.$(zstat -F '%Y%m%d-%H%M%S' +mtime $log)"
            mv "$log" "$kept"
            print "kept this worktree's own timings as $kept"
        else
            rm -f "$log"
        fi
    fi

    ln -sfn "$master" "$log"
    print "$log -> $(readlink $log)"
    print "snapshot: $snapshot"
    print "runs here now rewrite the master in place; the snapshot is the fallback"
