
" Plugin:  plurk.vim
" Author:  Cornelius
" Email:   cornelius.howl@gmail.com
" Version: 0.1

let g:plurk_emb_perl = 0

fun! s:post(file)

  if ! exists('g:plurk_user')
    let g:plurk_user = input("user:")
    let g:plurk_pass = input("pass:")
  endif

  if ! filereadable(a:file)
    echo "Skipped."
    return
  endif

  let c = readfile(a:file)
  if len(c) < 2
    echo "Skipped."
    return
  endif

  if strlen(g:plurk_user) == 0
    echo "Skipped."
    return
  endif

  if g:plurk_emb_perl == 1 && has('perl')

perl << END
  use Net::Plurk;

  my $d = Net::Plurk->new;
  my $user = VIM::Eval('g:plurk_user')
  my $pass = VIM::Eval('g:plurk_pass')
  my $content = VIM::Eval('content')
  $d->login( $user , $pass );
  my $ret = $d->add_plurk( content => $content );

  VIM::Msg("Plurk Posted.")
END
  else
    let b = expand('~/.vim/bin/plurk_post')
    let cmd = 'perl ' . b . ' --user=' . g:plurk_user . ' --pass=' . g:plurk_pass . ' --file="' . a:file  . '"'
    let ret = system(cmd)
	if v:shell_error
      echo ret
	  echo v:shell_error
	endif
  endif
endf

fun! s:new_post_buffer()
  let tmp = tempname()
  exec '3split' . tmp
  cal s:init_buffer()
  if exists(':EnableEmoticonOmni')
    :EnableEmoticonOmni
    redraw
    echo "EmotionOmni Enabled."
  endif
  exec printf('autocmd BufWinLeave <buffer> :cal s:post("%s")',tmp)
  "startinsert
endf

fun! s:init_buffer()
  setlocal modifiable noswapfile bufhidden=hide nobuflisted nowrap cursorline
  setlocal nu fdc=0
  setfiletype plurk
  setlocal syntax=plurk
  let x = '  http://github.com/c9s/plurk.vim (powered by plurk.vim)'
  put=x
endf

com! NewPlurk   :cal s:new_post_buffer()
