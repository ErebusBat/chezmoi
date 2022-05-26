set title
" set bg=light

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Font
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Re-use the zoom global to not reset font if re-sourcing
if !exists("g:loaded_zoom")
  set guifont=Fira\ Code:h10
  " set guifont=DejaVu\ Sans\ Mono:h10
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
" FZF Panel Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/vhakulinen/gnvim/issues/144#issuecomment-674522436
let $FZF_DEFAULT_OPTS=' --layout=reverse --margin=1,4'
let g:fzf_layout = { 'window': 'call FloatingFZF()' }

function! FloatingFZF()
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')

  let height = 20
  let width = 120
  let horizontal = float2nr((&columns - width) / 2)
  let vertical = 1

  let opts = {
        \ 'relative': 'editor',
        \ 'row': vertical,
        \ 'col': horizontal,
        \ 'width': width,
        \ 'height': height,
        \ 'style': 'minimal'
        \ }

  call nvim_open_win(buf, v:true, opts)
endfunction
