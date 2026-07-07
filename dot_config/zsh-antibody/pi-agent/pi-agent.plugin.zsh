##################################################
### Pi (vanilla)
##################################################
if [[ -d ~/.pi ]]; then
  .launch-pi-agent() {
    # Export dir and make sure it exists
    export PI_CODING_AGENT_DIR=$1
    if [[ ! -d $PI_CODING_AGENT_DIR ]]; then
      echo "***FATAL: PI Agent Directory Not Found: $PI_CODING_AGENT_DIR"
      return -7
    fi

    # Unset OpenAI API Key so it doesn't auto-use it
    if [[ -n $OPENAI_API_KEY ]]; then
      unset OPENAI_API_KEY
    fi

    # Eat PI_CODING_AGENT_DIR
    shift

    # Info Display
    echo "Launching Pi ${PI_CODING_AGENT_DIR:t}"
    echo "  in $PWD"

    # Use correct node version, then launch pi
    nvm use $(< ~/.pi/.nvmrc) --silent >/dev/null && pi "${@}"
  }

  pi-personal() {
    .launch-pi-agent ~/.pi/agent-personal "${@}"
  }

  pi-work() {
    .launch-pi-agent ~/.pi/agent "${@}"
  }
fi

##################################################
### Oh-My-Pi
##################################################
if command -v omp 2>&1 >/dev/null; then
  # wrapper function to make sure we don't accidentally set up anything in the root profile.
  omp() {
    local profile=$1

    # Check if a profile was specified by the user.
    #   If it was, verify it's valid.
    #   If not, try to auto-devine and relaunch.
    if [[ -z $profile ]]; then
      # See if we have OCP_PROFILE exposed
      if [[ -n $OCP_PROFILE ]]; then
        printf "INFO: Attempting auto-profile negotiation using \$OCP_PROFILE...\n" >&2
        case $OCP_PROFILE in
          work|lshq|upserve)
            omp-work         # Use custom wrapper to make sure the proper environment variables are set and or unset.
            return $?
            ;;
          personal)
            omp-personal     # Use custom wrapper to make sure the proper environment variables are set and or unset.
            return $?
            ;;
          *)
            omp $OCP_PROFILE
            return $?
            ;;
        esac
      fi
      printf "ERROR: No Oh-My-Pi profile specified!\n" >&2
      # Remaining output is handled below.
    elif [[ -d ~/.omp/profiles/$profile ]]; then
      # We were given a profile name, yay!

      # Eat profile name
      shift

      # Check for unintended mismatches
      if [[ -n $OCP_PROFILE ]] && [[ $OCP_PROFILE != $profile ]]; then
        printf "\n⚠️ WARN: You specified '$profile' as a Oh-My-Pi profile,s but \$OCP_PROFILE=$OCP_PROFILE." >&2
        printf "\n         Starting with $profile...\n" >&2
        sleep 1
      fi

      # Unset OpenAI API Key so it doesn't auto-use it
      if [[ -n $OPENAI_API_KEY ]]; then
        unset OPENAI_API_KEY
      fi

      # Launch actual omp
      command omp --profile=$profile "${@}"
      return $?
    fi

    # Error Condition
    if [[ -n $profile ]]; then
      printf "ERROR: Oh-My-Pi Profile '%s' not found!\n" $profile >&2
    fi

    # Display Configured Profiles
    printf "       The following profiles were found on this machine:\n" >&2
    for f in ~/.omp/profiles/*; do
      printf "\t- ${f:t}\n" >&2
    done
    printf "\n" >&2
    return -7
  }

  ### Profile Wrapper - Personal
  omp-personal() {
    if [[ -f ~/.config/erebusbat/agent-personal-api-keys.sh ]]; then
      source ~/.config/erebusbat/agent-personal-api-keys.sh
    fi
    omp personal "${@}"
  }
  alias ompp=omp-personal

  ### Profile Wrapper - LSHQ/Upserve
  omp-work() {
    # unset FIRECRAWL_API_KEY
    # unset BRAVE_API_KEY
    omp upserve "${@}"
  }
  alias ompw=omp-work
fi
