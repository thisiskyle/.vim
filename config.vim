if has("win32")
    let g:vimhome = '~/vimfiles/'
    set guifont=Courier_Prime_Code:h11
elseif has("unix")
    let g:vimhome = '~/.vim/'
endif
"-----------------------------------------------------------------------------------------------------------
" Plugins
"-----------------------------------------------------------------------------------------------------------
call plug#begin(g:vimhome . 'vimplug')
"Plug 'sheerun/vim-polyglot'
"Plug 'ctrlpvim/ctrlp.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'morhetz/gruvbox'
call plug#end()
"-----------------------------------------------------------------------------------------------------------
" Settings
"-----------------------------------------------------------------------------------------------------------
" general settings
if has("gui_running") | set guioptions ='' | set lines=60 | set columns=120 | endif
set incsearch hlsearch ignorecase smartcase
set nobackup noswapfile noundofile
set autoindent expandtab tabstop=4 shiftwidth=4
set belloff=all
set laststatus=0
set background=dark
set ff=unix
set tags=doc/tags;/
set path=.,**
set rulerformat=%70(%=%t\ %m%r\ %#Label#%{gitbranch#name()}%#Normal#\ \ %l:%c%)
filetype plugin indent on
" crtlp
let g:ctrlp_by_filename = 1
let g:ctrlp_regexp = 1
" todo.vim
let g:todo_output_filename = 'doc/todo'
let g:todo_identifier = '@'
" custom functions 
let g:window_max = 0
let g:session_dir = g:vimhome . "doc/sessions/"
let g:comment_types = {'vim':"\"", 'python':"#", 'default':"//"}
" gruvbox
let g:gruvbox_contrast_dark = 'soft'
let g:gruvbox_italic = 0
let g:gruvbox_bold = 0
color gruvbox
"-----------------------------------------------------------------------------------------------------------
" Key Bindings
"-----------------------------------------------------------------------------------------------------------
" normal mode
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <leader>t :NewTodo<cr>
nnoremap <leader>r :silent call ReplaceAll()<cr>
nnoremap <c-n> :call ToggleComment()<cr>
" visual mode
vnoremap <c-n> :call ToggleComment()<cr>
"-----------------------------------------------------------------------------------------------------------
" Commands 
"-----------------------------------------------------------------------------------------------------------
command Config :execute ":e" . g:vimhome . "config.vim"
command Notes :execute ":e" . g:vimhome . "doc/notes.md"
command Ctags :execute "!ctags -f doc/tags -R * " . getcwd()
command CD :cd %:p:h
command F call ToggleFullscreen()
command -nargs=? SS call SessionSave(<q-args>)
command -nargs=? SL call SessionLoad(<q-args>)
" auto commands
autocmd Vimresized * wincmd =
"-----------------------------------------------------------------------------------------------------------
" Functions 
"-----------------------------------------------------------------------------------------------------------
function! ToggleComment()
    let save_pos = getpos(".")
    if has_key(g:comment_types, &ft)
        let cstr = g:comment_types[&ft]
    else
        let cstr = g:comment_types["default"]
    endif
    normal ^
    " check to see if the line has a comment
    let i = 0
    let check = 0
    while i < strlen(cstr)
        if getline(".")[(col(".") - 1) + i] == cstr[i]
            let check = 1
        else 
            let check = 0
        endif
        let i = i + 1
    endwhile
    if check == 1
        " remove the comment string
        let i = 0
        while i < len(cstr)
            normal x
            let i += 1
        endwhile
        call setpos(".", save_pos)
        let i = 0
        while i < len(cstr)
            normal h
            let i += 1
        endwhile
    else
         "add a comment string
        :execute "normal i" . cstr
        call setpos(".", save_pos)
        let i = 0
        while i < strlen(cstr)
            normal l
            let i += 1
        endwhile
    endif
endfunction

function! ToggleFullscreen()
    if g:window_max == 0
        let g:window_max = 1
        :sim ~x
    else
        let g:window_max = 0
        :sim ~r
    endif
endfunction

function! ReplaceAll()
    let save_pos = getpos(".")
    let word = expand("<cword>")
    let replacement = input("Replace [" . word . "] with: ")
    :execute "%s/" . word . "/" . replacement . "/g"
    call setpos(".", save_pos)
endfunction

function! SessionSave(fname)
    :execute ":mks!" . g:session_dir . a:fname . ".vim"
endfunction

function! SessionLoad(fname)
    :execute ":so" . g:session_dir . a:fname . ".vim"
endfunction
