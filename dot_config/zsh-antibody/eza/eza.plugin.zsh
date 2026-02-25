# export LS_COLORS="rs=0:di=01;34:ln=01;36:hl=44;37:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:"
export LS_COLORS="rs=0:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:"

if [[ `which eza` =~ 'not found' ]]; then
  alias l='ls'
  alias ll='ls -lh'
  # no ls
  alias lst='tree -L 2'
  alias lsd='ls -ld'
  alias lsdt='tree -d -L 2'
else
  setopt no_aliases
  unalias ll llg lla ls lsa lsw lst lsta lsd lsda lsdt lsdta 2>/dev/null
  alias l='lsw'
  function ll {
    command eza -lh --icons=auto "$@"
  }
  function llg {
    command eza -lh --git --icons=auto "$@"
  }
  function lla {
    command eza -lah --icons=auto "$@"
  }
  function ls {
    command eza -lh --icons=auto "$@"
  }
  function lsa {
    command eza -lha --icons=auto "$@"
  }
  function lsw {
    command eza -hG --icons=auto "$@"
  }
  function lst {
    command eza -Tlh -L 2 --icons=auto "$@"
  }
  function lsta {
    command eza -Tlha -L 2 --icons=auto "$@"
  }
  function lsd {
    command eza -lD "$@"
  }
  function lsda {
    command eza -lDa "$@"
  }
  function lsdt {
    command eza -lDT -L2 "$@"
  }
  function lsdta {
    command eza -lDTa -L2 "$@"
  }

  alias tree='eza --tree'
  unsetopt no_aliases
fi

if [[ -o interactive ]]; then
  typeset -g _eza_completion_has_arguments=0

  _eza_completion_detect() {
    local eza_file

    for eza_file in ${^fpath}/_eza(N); do
      if [[ -r $eza_file ]]; then
        if [[ $(<"$eza_file") == *"_arguments"* ]]; then
          _eza_completion_has_arguments=1
        else
          _eza_completion_has_arguments=0
        fi
        return
      fi
    done

    _eza_completion_has_arguments=0
  }

  _eza_or_files() {
    local current_word
    current_word=${words[CURRENT]}

    if [[ $current_word == -* ]]; then
      if [[ $_eza_completion_has_arguments == 1 ]]; then
        autoload -Uz _eza
        _eza "$@"
        return
      fi
    fi

    _files "$@"
  }

  _eza_completion_init() {
    if ! (( $+functions[compdef] )); then
      return
    fi

    _eza_completion_detect

    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path "$HOME/.cache/zsh"

    local eza_cmd
    for eza_cmd in ll llg lla ls lsa lsw lst lsta lsd lsda lsdt lsdta; do
      compdef _eza_or_files "$eza_cmd"
    done

    add-zsh-hook -d precmd _eza_completion_init
    unfunction _eza_completion_init
    unfunction _eza_completion_detect
  }

  autoload -Uz add-zsh-hook
  if (( $+functions[compdef] )); then
    _eza_completion_init
  else
    add-zsh-hook precmd _eza_completion_init
  fi
fi
