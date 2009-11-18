
"
" Author:  Cornelius
" Email:   cornelius.howl@gmail.com
" Version: 0.1

let g:plurk_emb_perl = 0

fun! s:post(file)

  if ! exists('g:plurk_user')
    let g:plurk_user = input("user:")
    let g:plurk_pass = input("pass:")
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
    let cmd = 'perl ' . b . ' --user=' . g:plurk_user . ' --pass=' . g:plurk_pass . ' --file=' . a:file 
    cal system(cmd)
  endif
endf

fun! s:new_post_buffer()
  let tmp = tempname()
  exec '10split' . tmp
  cal s:init_buffer()
  exec printf('autocmd BufWinLeave <buffer> :cal s:post("%s")',tmp)
  startinsert
endf

fun! s:init_buffer()
  setlocal modifiable noswapfile bufhidden=hide nobuflisted nowrap cursorline
  setlocal nu fdc=0
  setfiletype plurk
  setlocal syntax=plurk
endf

com! NewPlurk   :cal s:new_post_buffer()
