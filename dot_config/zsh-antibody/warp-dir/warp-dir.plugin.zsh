#
# WarpDir (v1.6.2) shell wrapper, installed by a gem 'warp-dir'
#
# © 2015-2016, Konstantin Gredeskoul
# https://github.com/kigster/warp-dir
#
#
wd() {
  if [[ -z "${warp_dir_exec_installed}" || "${warp_dir_exec_installed}" -eq 1 ]]; then
    $(which 'warp-dir') 2>&1 1>/dev/null
    export warp_dir_exec_installed=$?
  fi

  if [[ ${warp_dir_exec_installed} -ne 0 ]]; then
    wd_not_found
    return 1
  fi

  local previous_ifs=$IFS
  IFS="+"

  local output=$(WARP_DIR_SHELL=yes RUBYOPT="-W0" warp-dir $@ 2>&1)
  local code=$?

  if [[ $code -eq 127 ]]; then
    [[ -n $(command -v rbenv) ]] && rbenv rehash >/dev/null 2>&1
    output=$(WARP_DIR_SHELL=yes RUBYOPT="-W0" warp-dir $@ 2>&1)
    code=$?
    if [ $code -eq 127 ]; then
      unset warp_dir_exec_installed
      wd_not_found
      IFS=$previous_ifs
      return 1
    fi
  fi

  eval "${output}"
  export IFS=$previous_ifs
}

wd_not_found() {
  printf "\nWhoops – I can't find 'warp-dir' executable.\n"
  printf "Is the gem properly installed?\n"
  printf "\nTry reinstalling the gem with, for example:\n\n"
  printf "    $ gem install warp-dir --no-wrappers\n"
  printf "    $ hash -r\n"
  printf "    $ warp-dir install [ --dotfile ~/.bashrc ]\n"
}

_wd() {
  local WD_OPTS WD_POINTS cur prev

  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  COMPREPLY=()

    # Only perform completion if the current word starts with a dash ('-'),
    # meaning that the user is trying to complete an option.
    if [[ ${cur} == -* ]] ; then
      # COMPREPLY is the array of possible completions, generated with
      WD_COMP_OPTIONS=$(wd --help | awk 'BEGIN{FS="--"}{print "--" $2}' | sed -E '/^--$/d' | egrep -v ']|help' | egrep -- "${cur}" | awk '{if ($1 != "") { printf "%s\n", $1} } ')
    else
      WD_COMMANDS="add ls remove warp install help list"
      if [[ -z "${cur}" ]] ; then
        WD_POINTS=$(wd list --no-color  | awk '{ print $1 }')
        WD_DIRS=$(ls -1p | grep '/')
      else
        WD_POINTS=$(wd list --no-color  | awk '{ print $1 }' | egrep -e "^${cur}")
        WD_DIRS=$(ls -1p | grep '/' | egrep -e "^${cur}")
      fi
      WD_COMP_OPTIONS="$WD_POINTS $WD_DIRS"
    fi
    [[ $COMP_CWORD == 1 ]] && WD_COMP_OPTIONS="${WD_COMP_OPTIONS} ${WD_COMMANDS}"
    COMPREPLY=( $(compgen -W "${WD_COMP_OPTIONS}" -- ${cur}) )
    return 0
  }

complete -F _wd wd
