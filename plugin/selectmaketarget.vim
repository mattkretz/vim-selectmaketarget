" selectmaketarget.vim - Select a target with <F9> and build it with <F10>
" Maintainer:   Matthias Kretz <m.kretz@gsi.de>
" Version:      1.0
"

let s:Builddir = '.'

function! s:CompleteBuildDir(ArgLead, CmdLine, CursorPos)
    let p = expand("%:p")
    if a:ArgLead == ""
        if p =~ '/src/'
            let ps = split(p, "/src/")
            let l = glob(ps[0]."/src/build_dirs/*/", 0, 1)
            let i = index(l, ps[0] . "/src/build_dirs/" . split(ps[1], "/")[0] . "/")
            if i <= 0
                return l
            else
                return l[i:] + l[:i-1]
            endif
        else
            return glob("~/*/", 0, 1)
        endif
    endif
    let path = a:ArgLead
    if p =~ 'simd' && path =~ '/src/build_dirs/.*/'
        if path =~ '/simd/'
            let l = globpath(path, "**/Makefile", 0, 1)
        else
            if path[-1:] != '/'
                let path = join(glob(path . '*/', 0, 1), ',')
            endif
            let l = globpath(path, "**/simd/**/Makefile", 0, 1)
        endif
        if !empty(l)
            return map(l, 'v:val[:-9]')
        endif
    endif
    return glob(path . "*/", 0, 1)
endfunction

function! s:SelectMakeBuildDir(dir)
    let s:Builddir = a:dir
endfunction

command! -complete=customlist,s:CompleteBuildDir -nargs=1 SelectMakeBuildDir call s:SelectMakeBuildDir("<args>")

function! s:SelectMakeTargetThis(build)
    let s:Maketarget=getline('.')
    bd!
    if a:build > 0
        call MakeTarget()
    endif
endfunction

function! SelectMakeTarget(build)
    let completefun = split(string(function("s:CompleteBuildDir")), "'")[1]
    if empty(s:Builddir) || s:Builddir == '.'
        let s:Builddir = input("Build directory: ", s:CompleteBuildDir("", "", 0)[0], "customlist," . completefun)
    endif
    let l:pattern = @/
    let l:mp0 = substitute(&mp, '\$\*', 'cached_help', '')
    let l:mp1 = substitute(&mp, '\$\*', 'help', '')
    let lastbuf = bufnr()
    silent vertical botright new
    if (lastbuf == bufnr() || bufname() != "")
        echoerr "Creating a new window & buffer failed for some reason. Aborting."
        return
    endif
    silent vertical resize 60
    normal IGenerating list of targets...
    redraw
    silent normal 0D
    exec ":lcd ".s:Builddir
    "silent exec "0r !" . l:mp0 . " 2>/dev/null || " . l:mp1 . " 2>/dev/null"
    silent let l:help = systemlist(l:mp0)
    if v:shell_error != 0
        silent let l:help = systemlist(l:mp1)
        if v:shell_error != 0
            let s:Builddir = input("Build directory: ", s:Builddir, "customlist," . completefun)
            exec ":lcd ".s:Builddir
            silent let l:help = systemlist(l:mp0)
            if v:shell_error != 0
                silent let l:help = systemlist(l:mp1)
            endif
        endif
    endif
    if v:shell_error != 0
        call append(line('$'), "Error: no help target found")
    else
        call append(line('$'), l:help)
        silent exec ":%s/: .*$//e"
        silent exec ":%s/^\.\.\. //e"
        silent exec ":v/^[-+a-zA-Z_0-9=./]*$/d"
        silent exec ':g/^\(help\|depend\|Continuous.*\|Experimental.*\|Nightly.*\|list_install_components\|cmake_object_order_depends_target_.*\)$/d'
        silent exec ":g/^$/d"
        "silent exec ":%!sort -u"
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
    endif
endfunction

function! MakeTarget()
    if !exists('s:Maketarget')
        call SelectMakeTarget(1)
    else
        let l:cwd = getcwd()
        exec ":lcd ".s:Builddir
        if exists(":Make")
            let l:curwin = winnr()
            AbortDispatch
            let $COLUMNS = &co
            exec ":Make ".s:Maketarget
            "Copen
            "exec l:curwin . 'wincmd w'
        else
            exec ":make! ".s:Maketarget
        endif
        exec ":lcd ".l:cwd
    endif
endfunction

nmap <F10> :call MakeTarget()<CR>
nmap <S-F10> :call SelectMakeTarget(1)<CR>
nmap <F9> :call SelectMakeTarget(0)<CR>

" vim: sw=4 et
