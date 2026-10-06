# TMUX & 256colors

- https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95
- Older
  - Has awk cmd: https://jdhao.github.io/2018/10/19/tmux_nvim_true_color/

## Styles

```shell
cat styles.txt
```

You should be able to see the different styles.
File from [comment on wez/wezterm#2898](https://github.com/wez/wezterm/pull/2898#issuecomment-1365644190)

## Quick Reference

```shell
curl -LO https://invisible-island.net/datafiles/current/terminfo.src.gz && gunzip terminfo.src.gz
tic -xe  alacritty,alacritty-direct,tmux-256color,tmux,xterm-256color terminfo.src

# Make sure you can read the compiled description
infocmp -x tmux-256color

# Awk command to test
awk 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
        r = 255-(colnum*255/76);
        g = (colnum*510/76);
        b = (colnum*255/76);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
}'
```

Make sure that `.tmux.conf` has correct settings:

```
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256c*:Tc"
set -ga terminal-overrides ",*256c*:RGB"
```
