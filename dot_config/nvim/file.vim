" explicitly set filetype to Ruby for some well-known files
au BufRead,BufNewFile {Gemfile,Rakefile,Vagrantfile,Thorfile,Procfile,Capfile,Guardfile,.Guardfile,config.ru,.railsrc,.irbrc,.pryrc} set ft=ruby
au BufRead,BufNewFile *.zone set ft=bindzone

" tmux files
au BufRead,BufNewFile */tmux/*.conf set ft=tmux

" Markdown default folding
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_folding_level = 2
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0

" Auto-save/read daily log when exiting insert mode
" autocmd BufRead */daily-log.md imap <buffer> <Esc> <Esc>:w<CR>
" autocmd BufRead *.md imap <buffer> <Esc> <Esc>:w<CR>
" autocmd FocusLost   *.md :w
" autocmd FocusGained *.md :e

" Reset text width for gitcommits
au FileType gitcommit setlocal tw&

" Stupid work around for LSP stealing my keeb
autocmd FocusGained * nmap <C-k> :TmuxNavigateUp<CR>

" Auto-save/read when losing/gaining foucs
autocmd FocusGained * call AutoSaveLoadFocus('FocusGained')
autocmd FocusLost   * call AutoSaveLoadFocus('FocusLost')

function! AutoSaveLoadFocus(event)
  let curBufNum = winbufnr(winnr())
  let curBufName = bufname(curBufNum)
  let curBufHasFile = filereadable(curBufName)
  " echo "Current buffer is: " . curBufNum
  " echo "Current buffer name: " . curBufName
  " echo "Current buffer readable: " . curBufHasFile
  " if curBufHasFile < 1
  "   echo "Current buffer does not have a backing file..."
  "   return
  " endif

  if mode() == 'n' && expand('%') != ''
    if a:event == 'FocusGained'
      " :edit
      " normal! mq
      " :edit
      " normal! `q
    elseif a:event == 'FocusLost'
      if &modified
        " Auto remove trailing whitespace and save
        sil! :%s/\s\+$//e
        :write
      endif
    else
      echo "Unknown event: " . a:event
    endif
  endif
endfunction
set autoread
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
            \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif
autocmd FileChangedShellPost *
  \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable Auto Comments
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd Filetype vim setlocal formatoptions-=cro
autocmd Filetype ruby setlocal formatoptions-=cro


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File Type Specific Options
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocmd Filetype ruby call SetRubyOptions()
" function SetRubyOptions()
"   set formatoptions-=cro
" endfunction
au BufRead,BufNewFile *.vcl.j2 set ft=vcl
let g:terraform_align=1

" Ruby end
au FileType ruby inoremap <C-CR> <CR><CR>end<Esc>-cc

" shell fi
au FileType sh inoremap <C-CR> <CR><CR>fi<Esc>-cc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Spelling
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_us
autocmd FileType gitcommit setlocal spell spelllang=en_us
autocmd BufRead,BufNewFile scratch.txt setlocal spell spelllang=en_us
set complete+=kspell


nnoremap <F10> :setlocal spell!<CR>
if g:aab_search == 'fzf'
  function! FzfSpellSink(word)
    exe 'normal! "_ciw'.a:word
  endfunction
  function! FzfSpell()
    let suggestions = spellsuggest(expand("<cword>"))
    return fzf#run({'source': suggestions, 'sink': function("FzfSpellSink"), 'down': 10 })
  endfunction
  nnoremap z= :call FzfSpell()<CR>
elseif g:aab_search == 'telescope'
  " See telescope/hotkeys.vim
endif
