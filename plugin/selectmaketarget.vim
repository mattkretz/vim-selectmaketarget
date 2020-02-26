" selectmaketarget.vim - Select a target with <F9> and build it with <F10>
" Maintainer:   Matthias Kretz <m.kretz@gsi.de>
" Version:      1.0
"

function! s:SelectMakeTargetThis(build)
    let s:Maketarget=getline('.')
    bd!
    if a:build > 0
        call MakeTarget()
    endif
endfunction

function! SelectMakeTarget(build)
    let l:pattern = @/
    let l:mp0 = substitute(&mp, '\$\*', 'cached_help', '')
    let l:mp1 = substitute(&mp, '\$\*', 'help', '')
    silent vertical botright new
    silent vertical resize 60
    normal IGenerating list of targets...
    redraw
    silent normal 0D
    silent exec "0r !" . l:mp0 . " 2>/dev/null || " . l:mp1 . " 2>/dev/null"
    silent exec ":%s/: .*$//e"
    silent exec ":%s/^\.\.\. //e"
    silent exec ":v/^[-+a-zA-Z_0-9=]*$/d"
    silent exec ':g/^\(help\|all\|clean\|depend\|Continuous.*\|Experimental.*\|Nightly.*\|edit_cache\|install\|list_install_components\|rebuild_cache\|test\|cmake_object_order_depends_target_.*\)$/d'
    silent exec ":g/^$/d"
    silent exec ":%!sort -u"
    silent call cursor(1, 1)
    silent exec ":normal! Oall\<CR>test\<CR>clean\<CR>install\<CR>edit_cache\<CR>rebuild_cache\<ESC>"
    silent call cursor(1, 1)
    let @/ = l:pattern
    setlocal ro
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal nowrap
    setlocal textwidth=0
    setlocal winfixwidth
    setlocal nospell

    exec ":noremap <buffer> <CR> :call <SID>SelectMakeTargetThis(" . a:build . ")<CR>"
    nnoremap <nowait> <silent> <buffer> <ESC> :bd!<CR>
endfunction

function! MakeTarget()
    if !exists('s:Maketarget')
        call SelectMakeTarget(1)
    else
        if exists(":Make")
            let l:curwin = winnr()
            AbortDispatch
            let $COLUMNS = &co
            exec ":Make! ".s:Maketarget
            Copen
            exec l:curwin . 'wincmd w'
        else
            exec ":make! ".s:Maketarget
        endif
    endif
endfunction

nmap <F10> :call MakeTarget()<CR>
nmap <S-F10> :call SelectMakeTarget(1)<CR>
nmap <F9> :call SelectMakeTarget(0)<CR>

" vim: sw=4 et
