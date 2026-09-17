# See https://starship.rs/guide/
_starship_path_context() {
  case "${PWD:A}" in
    "${HOME:A}/src/lshq"|"${HOME:A}/src/lshq"/*)
      export STARSHIP_K8S=1
      ;;
    *)
      unset STARSHIP_K8S
      ;;
  esac
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _starship_path_context
_starship_path_context

if [[ -t 0 && -t 1 ]]; then
  if [[ -x /opt/homebrew/bin/starship ]]; then
    eval "$( /opt/homebrew/bin/starship init zsh)"
  else
    # starship_path=$(mise which starship)
    # echo "Attempting to use $starship_path"
    # eval "$( $starship_path init zsh)"
    eval "$( starship init zsh)"
  fi

  # Render the expensive prompt once per command. A vi-mode switch only changes
  # the trailing character module; keep Starship's configured symbols and colors.
  zmodload zsh/stat
  typeset -g _starship_uncached_prompt=$PROMPT
  typeset -g _starship_uncached_rprompt=$RPROMPT
  typeset -gA _starship_mode_prompts _starship_mode_characters
  typeset -g _starship_character_config_key _starship_cached_rprompt _starship_prompt_columns

  _starship_refresh_prompt_cache() {
    emulate -L zsh
    setopt extendedglob
    local config_file=${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml}
    local -A config_stat
    zstat -H config_stat -- "$config_file" 2>/dev/null
    local config_key="$config_file:${config_stat[mtime]}:${config_stat[size]}:${config_stat[inode]}:${NO_COLOR-}:$TERM"

    if [[ $_starship_character_config_key != "$config_key" ]]; then
      _starship_mode_characters[success]=$(starship module character --keymap main --status 0)
      _starship_mode_characters[error]=$(starship module character --keymap main --status 1)
      _starship_mode_characters[normal]=$(starship module character --keymap vicmd --status 0)
      # `module` prints raw ANSI; `prompt` wraps SGR codes for ZLE's width count.
      local mode MATCH MBEGIN MEND
      for mode in success error normal; do
        _starship_mode_characters[$mode]=${_starship_mode_characters[$mode]//(#m)$'\e'\[[0-9\;]#m/"%{$MATCH%}"}
      done
      _starship_character_config_key=$config_key
    fi

    # Expand the original Starship templates after its precmd hook saved status,
    # pipeline results, duration, and job count. Keep rendered text in parameters
    # so promptsubst cannot execute dollar expressions from directory names.
    local rendered_prompt=${(e)_starship_uncached_prompt}
    _starship_cached_rprompt=${(e)_starship_uncached_rprompt}
    local insert_character=$_starship_mode_characters[success]
    [[ ${STARSHIP_CMD_STATUS:-0} == 0 ]] || insert_character=$_starship_mode_characters[error]
    local rendered_character=$insert_character
    [[ ${KEYMAP:-main} == vicmd ]] && rendered_character=$_starship_mode_characters[normal]

    if [[ -n $rendered_character && $rendered_prompt == *"$rendered_character" ]]; then
      local prompt_body=${rendered_prompt%"$rendered_character"}
      _starship_mode_prompts[main]=${prompt_body}${insert_character}
      _starship_mode_prompts[vicmd]=${prompt_body}${_starship_mode_characters[normal]}
      PROMPT='${_starship_mode_prompts[${KEYMAP:-main}]:-${_starship_mode_prompts[main]}}'
      RPROMPT='${_starship_cached_rprompt}'
    else
      # Preserve upstream behavior if a future layout moves/removes $character.
      PROMPT=$_starship_uncached_prompt
      RPROMPT=$_starship_uncached_rprompt
    fi
    _starship_prompt_columns=$COLUMNS
  }
  add-zsh-hook precmd _starship_refresh_prompt_cache

  _starship_refresh_prompt_on_resize() {
    [[ $_starship_prompt_columns == $COLUMNS ]] && return 0
    _starship_refresh_prompt_cache
    zle reset-prompt
  }
  autoload -Uz add-zle-hook-widget
  add-zle-hook-widget line-pre-redraw _starship_refresh_prompt_on_resize
fi
