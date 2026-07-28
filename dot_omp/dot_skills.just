# vim: set ft=just ts=4 sw=4 sts=4 et ai si sta:

# List raw skill files for given profile
[group('Skills')]
ls-skills profile:
    #!/usr/bin/env zsh
    OMP_PROFILE="{{profile}}"
    AGENT_DIR=$(printf "{{TEMPLATE_AGENT_DIR }}" "{{profile}}")

    echo "*** INFO: Listing raw on disk state skill files for profile $OMP_PROFILE"
    cd $AGENT_DIR
    eza -Tlh -L 2 --icons=auto ./.agents/skills ./skills

# Run's 'npx skills@latest' in the correct "project" directory to install for
# profile only skills
[group('Skills')]
skills profile *args: (_skill-ensure-setup profile)
    #!/usr/bin/env zsh
    # The _skill-ensure-setup will err if the profile doesn't exist so we don't
    # have to check it here
    OMP_PROFILE="{{profile}}"
    AGENT_DIR=$(printf "{{TEMPLATE_AGENT_DIR }}" "{{profile}}")

    echo "*** INFO: Changing into profile agent directory: $AGENT_DIR"
    echo "          Select 'project' to install skills and they will install at the profile level"
    cd $AGENT_DIR

    echo "> npx skills@latest {{args}}"
    npx skills@latest {{args}}

# This sets up a directory structure and links so we can use standard
# npx install commands and it will install just for this agent in this profile.
[private]
_skill-ensure-setup profile:
    #!/usr/bin/env zsh
    OMP_PROFILE="{{profile}}"
    AGENT_DIR=$(printf "{{TEMPLATE_AGENT_DIR }}" "{{profile}}")
    DOT_SKILLS_DIR="$AGENT_DIR/.agents/skills"
    SKILLS_DIR="$AGENT_DIR/skills"

    if [[ ! -d "$AGENT_DIR" ]]; then
        echo "*** FATAL: Unknown profile: $OMP_PROFILE"
        exit 1
    fi

    if [[ ! -d "$SKILLS_DIR" ]]; then
        mkdir -p "$SKILLS_DIR"
    fi
    if [[ -L "$DOT_SKILLS_DIR" ]]; then
        # Already a symlink
    else
        mkdir -p "${DOT_SKILLS_DIR:h}"
        ln -s "$SKILLS_DIR" "$DOT_SKILLS_DIR"
    fi
