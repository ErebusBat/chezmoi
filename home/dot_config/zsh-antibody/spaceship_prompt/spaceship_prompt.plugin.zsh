# https://denysdovhan.com/spaceship-prompt/docs/Options.html
export SPACESHIP_DIR_TRUNC=5
export SPACESHIP_DIR_TRUNC_REPO=true
export SPACESHIP_TIME_SHOW=true
export SPACESHIP_EXIT_CODE_SHOW=true

export SPACESHIP_RUBY_SHOW=true
export SPACESHIP_NODE_SHOW=false
export SPACESHIP_DOCKER_SHOW=false
export SPACESHIP_BATTERY_SHOW=true
export SPACESHIP_GCLOUD_SHOW=false
# export SPACESHIP_KUBECTL_SHOW=true

export SPACESHIP_VI_MODE_COLOR=white
export SPACESHIP_VI_MODE_INSERT='[I]'
export SPACESHIP_VI_MODE_NORMAL='%K{white}%F{black}[N]%f%k'

# Turn off for speed
export SPACESHIP_HG_SHOW=false

# I have no idea why but apparently spaceship does not reset prompt on its own
# so without the following the vi mode indicator will not update
function zle-line-init zle-keymap-select {
    zle reset-prompt
}
# zle -N zle-line-init
zle -N zle-keymap-select
