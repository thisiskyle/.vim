"=========================================
" autoload/doit.vim
"=========================================

" ::TODO Add the ability to sort the output
"        Would be cool to sort the output by the status
"        which isnt really the status anymore, or tags

" ::FIX Buffer closing after running Doit()
"       For some reason the buffer closes when the NewBuffer()
"       pops up.

let s:output = []

" main function to run doit.vim
fun! doit#Doit()
    try
        :silent bd! doit_board
    catch
    endtry
    if len(s:output) == 0

        if (g:doit_recursive == 1)
            let wildcard = "**"
        else
            let wildcard = "*"
        endif

        let files = globpath(g:doit_search_path, wildcard, 0, 1)

        echo "Doing it...   "
        for file in files
            if (s:CheckFileExtension(file) == 1)
                call SearchFile(file)
            endif 
        endfor
    endif
    call NewBuffer()
    :set filetype=doit
    :redraw
    echo "Done!"
    normal <c-m>
endfun

fun! doit#DoitFresh()
    call ClearCache()
    call doit#Doit()
endfun

fun! ClearCache()
    let s:output = []
endfun

" insert a 'todo' line using given tag
fun! doit#NewTodo(tag)

    if (a:tag == '')
        let l:endspace = ''
    else
        let l:endspace = ' '
    endif

    let l:tag = substitute(a:tag, " ", "-", "g")
    let l:spaces = ''
    let l:char_count = strlen(getline('.'))

    if l:char_count > 0
        normal ^
        let l:indent = col('.')
        normal O
    else
        normal k^
        let l:indent = col('.')
        normal j
    endif

    let l:i = 1
    while l:i < l:indent
        let l:spaces = l:spaces . ' '
        let l:i += 1
    endwhile

    :call setline('.', spaces . s:GetCommentString(bufname('%')) . ' ' . g:doit_identifier . l:tag . l:endspace)
    :startinsert!
endfun

" returns true is file extension is 'supported' in g:doit_file_extensions
fun! s:CheckFileExtension(file)
    for ext in g:doit_file_extensions
        if (fnamemodify(a:file, ":e") == ext)
            return 1
        endif
    endfor
    return 0
endfun

" get the correct comment string based on filetype
fun! s:GetCommentString(file)
    "vim
    if (fnamemodify(a:file, ":e") == 'vim')
        return '"'
    "python
    elseif (fnamemodify(a:file, ":e") == 'py')
        return '#'
    "c style
    else
        return '//'
    endif
endfun

" get the correct comment string based on filetype but for regex
fun! s:GetRegexCommentString(file)
    "vim
    if (fnamemodify(a:file, ":e") == 'vim')
        return '\"'
    "python
    elseif (fnamemodify(a:file, ":e") == 'py')
        return '\#'
    "c style
    else
        return '\/\/'
    endif
endfun

fun! NewBuffer()
    :silent below new doit_board
    setlocal 
            \ bufhidden=wipe 
            \ buftype=nofile 
            "\ nobuflisted
            \ nocursorcolumn 
            \ nolist 
            \ nonumber 
            \ noswapfile 
            \ norelativenumber

    for l in s:output
        call append('$', l)
    endfor
    normal ggdd
    execute "resize " . g:doit_split_h  
    setlocal nomodifiable nomodified readonly
endfun

fun! doit#OpenSelectedFile()
    try
        let line = getline('.')
        let reg = '\(\S\+\):\(\d\+\)$'
        let matches = matchlist(line, reg)
        :bd!
        execute ":e " . matches[1]
        execute ":" . matches[2]
    catch
    endtry
endfun

fun! SearchFile(file)
    try
        let commentString = s:GetRegexCommentString(a:file)
        let lines = readfile(a:file)
        let line_num = 0
        let regex_line = commentString . " " . g:doit_identifier
        let regex_status = g:doit_identifier . '\S\+'
        let regex_epic = '+\S\+'
        let regex_tag = '#\S\+'

        for line in lines
            let line_num = line_num + 1
            if(match(line, regex_line) > -1)
                let templine = line
                let temp = ""
                let statusString = ""
                let epicString = ""
                let tagString = ""
                let status = []
                let tags = []
                let epic = []

                " add priority we dont really need this anymore?
                " keeping it for later maybe?
                "let matches = matchlist(line, regex_line)
                "let priority = matches[1]
                
                call substitute(line, regex_status, '\=add(status, submatch(0))', 'g')
                call substitute(line, regex_epic, '\=add(epic, submatch(0))', 'g')
                call substitute(line, regex_tag, '\=add(tags, submatch(0))', 'g')

                " build status string
                if len(status) > 0
                    let statusString = ""
                    for s in status
                        let statusString = statusString . s
                        let templine = substitute(templine, " " . s, "", 'g')
                    endfor
                    let statusString = statusString . " |"
                else
                    let statusString = ""
                endif
                " build epic string
                if len(epic) > 0
                    let epicString = " |"
                    for c in epic
                        let epicString = epicString . " " . c
                    endfor
                endif
                " build tags string
                if len(tags) > 0
                    let tagString = " |"
                    for t in tags
                        let tagString = tagString . " " . t
                    endfor
                endif
                " build file info string
                let fileinfo = fnamemodify(a:file, g:doit_filename_modifier) . ":" . line_num
                " build output string 
                let temp = statusString . templine . " | " . fileinfo
                " remove the doit_identifier string
                let temp = substitute(temp, g:doit_identifier, "", 'g')
                " remove the comment string
                let temp = substitute(temp, commentString, "", 'g')
                " remove leading spaces
                let temp = substitute(temp, '^\s*\(.\{-}\)\s*$', '\1', '')

                call add(s:output, temp)
            endif
        endfor
    catch
    endtry
endfun

