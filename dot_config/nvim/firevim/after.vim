" Lightlight Mods

" Default Settings
function! SaveDefaultGeometry(timer)
  let g:firenvim_aab_columns = &columns
  let g:firenvim_aab_lines = &lines

  " Do initial noop resize to handle line numbers
  call s:WebResize(0, 0)
endfunction

function! OnUIEnter(event) abort
  if 'Firenvim' ==# get(get(nvim_get_chan_info(a:event.chan), 'client', {}), 'name', '')
    " set guifont=JetBrains\ Mono\ NL:h8
    set guifont=Fira\ Code:h8
    call timer_start(100, function("SaveDefaultGeometry"))
  endif
endfunction
autocmd UIEnter * call OnUIEnter(deepcopy(v:event))

if exists('g:started_by_firenvim')
  " Force these options
  set spell nonumber norelativenumber

  " Resize Functionality (with restore)
  command! -narg=0 WebRestore :call s:WebRestore()
  function! s:WebRestore()
    let &columns = g:firenvim_aab_columns
    let &lines = g:firenvim_aab_lines

    " Do noop resize to handle line numbers
    call s:WebResize(0, 0)
  endfunction

  command! -narg=* WebResize :call s:WebResize(<f-args>)
  function s:WebResize(cols = 0, lines = 0)
    let &columns = &columns + a:cols
    let &lines = &lines + a:lines

    if &lines > 5
      set number
    else
      set nonumber
    endif
  endfunction

  " Create commands that call WebResize
  command! -narg=0 WebTaller :call s:WebResize(0, 5)
  command! -narg=0 WebShorter :call s:WebResize(0, -5)
  command! -narg=0 WebWider :call s:WebResize(10, 0)
  command! -narg=0 WebNarrower :call s:WebResize(-10, 0)
  command! -narg=0 WebHuge :call s:WebResize(150 - &columns, 25 - &lines)

  " Mappings
  nnoremap <C--> :WebShorter<CR>
  nnoremap <C-=> :WebTaller<CR>
  nnoremap <C-,> :WebNarrower<CR>
  nnoremap <C-.> :WebWider<CR>
  nnoremap <C-S-=> :WebRestore<CR>
  nnoremap <C-S-z> :WebHuge<CR>

  " Per-site settings
  " au BufEnter github.com_*.txt set lines=20
  au BufEnter app.slack.com_*.txt set lines=4
endif
