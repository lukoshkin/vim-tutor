nnoremap do :echo('Cheating is not allowed!')<CR>
nnoremap dp :echo('Cheating is not allowed!')<CR>

" Leave competition if a user opens '*answers.*'
" Exclude accidental switches
nnoremap <C-w> :echo("Can't switch wins during competition.")<CR>
au BufEnter answers.* :qa!

if filereadable($vc_rules_prefix."/rules.vim")
  source $vc_rules_prefix/rules.vim
endif

