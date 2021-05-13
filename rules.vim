function! DiffToggle ()
  if &diff
    diffoff
  else
    diffthis
  endif
endfunction


nnoremap do :call DiffToggle() <bar> :echo("'do' is diff mode toggle now.")<CR>
nnoremap dp :echo('Cheating is not allowed!')<CR>

" Leave competition if a user opens '*answers.*'
" Exclude accidental switches
nnoremap <C-w> :echo("Can't switch wins during competition.")<CR>
au BufEnter answers.* :qa!

if filereadable($vc_rules_prefix."/rules.vim")
  source $vc_rules_prefix/rules.vim
endif

