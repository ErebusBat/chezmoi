set termguicolors

source ~/.config/nvim/color_plumbing.vim

" Setup firenvim settings explicitly
if exists('g:started_by_firenvim')
  source ~/.config/nvim/firevim/color.vim
else
  call TryLoadVimRcBackground()
  call SetupBase16FallbackColors()

  " Smart Default background (from colorscheme)
  if g:colors_name =~ 'light'
    set background=light
  else
    set background=dark
  end
endif

highlight Comment cterm=italic gui=italic

" ideally use base16-shell to change colors and then just re-source vim config (or restart)
" base16 colorschemes that did NOT work
" colorscheme base16-onedark  " much harder to read with jump highlighting
" colorscheme base16-dracula

" Gruvbox is 'okay' but found others I prefer better
" colorscheme base16-gruvbox-dark-hard
" colorscheme base16-gruvbox-dark-medium
" colorscheme base16-gruvbox-dark-pale
" colorscheme base16-gruvbox-dark-soft

" https://github.com/chriskempson/base16-vim/tree/master/colors

