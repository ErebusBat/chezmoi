set title
" set bg=light
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Font
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Re-use the zoom global to not reset font if re-sourcing
if !exists("g:loaded_zoom")
  " set guifont=Fira\ Code:h16
  " set guifont=DejaVu\ Sans\ Mono:h16
  set guifont=JetBrains\ Mono\ NL:h16
endif

" Font zooming in gnvim is lacking so we use the following script
" It has only been modified to remove the mappings.  We provide our own
" mappings as well as a direct size set script.
source ~/.config/nvim/_zoom.vim

" Honestly with the check to not reset guifont above I am not sure how useful
" this actually is
function SetFontSize(pts)
  let l:guifont = substitute(&guifont, ':h\([^:]*\)', ':h' . a:pts, '')
  let &guifont = l:guifont
endfunction
command! -nargs=1 SetFontSize :call SetFontSize(<args>)

" These mappings layout nicley on a 104 as well as the brightness
" Up/Down arrows on my Darter Pro :D
nmap <C-F8> :ZoomOut<CR>
nmap <C-F9> :ZoomIn<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NeoVide Specifics
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:neovide_cursor_vfx_mode = "railgun"
let g:neovide_cursor_antialiasing=v:true
