if has("win32")
    let g:vimhome = '~/vimfiles/'
    set guifont=Consolas:h10
elseif has("unix")
    let g:vimhome = '~/.vim/'
    set guifont=Consolas\ 10
endif
"-----------------------------------------------------------------------------------------------------------
" Plugin
"-----------------------------------------------------------------------------------------------------------
call plug#begin(g:vimhome . 'plugged')
Plug 'ctrlpvim/ctrlp.vim'
Plug 'sheerun/vim-polyglot'
Plug 'thisiskyle/todo.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'morhetz/gruvbox'
call plug#end()
"-----------------------------------------------------------------------------------------------------------
" Settings
"-----------------------------------------------------------------------------------------------------------
if has("gui_running")
    set guioptions =''
    set lines=60
    set columns=140
    set guifont=Consolas:h10
endif
set incsearch
set ignorecase
set nobackup
set noswapfile
set noundofile
set tabstop=4
set shiftwidth=4
set expandtab
set ignorecase
set smartcase
set autoindent
set belloff=all
set laststatus=0
set ff=unix
set tags=tags;/
set rulerformat=%50(%m%r\ %#GitBranch#%{gitbranch#name()}\ %#Normal#%l,%c%)
filetype plugin indent on
"-----------------------------------------------------------------------------------------------------------
" Colors
"-----------------------------------------------------------------------------------------------------------
color gruvbox
hi GitBranch guifg=#fb4934
hi Todo gui=italic guifg=#928374
"-----------------------------------------------------------------------------------------------------------
" Key Bindings
"-----------------------------------------------------------------------------------------------------------
inoremap {<cr> {<cr>}<esc>O

nnoremap <c-n> :w<cr>:bn<cr>
nnoremap <c-b> :w<cr>:bp<cr>

nnoremap <leader>t :TODO<cr>
nnoremap <leader>n :NewTODO TODO<cr>
nnoremap <leader>b :NewTODO BUG<cr>

nnoremap <c-m> :ToggleComment<cr>
vnoremap <c-m> :ToggleComment<cr>
"-----------------------------------------------------------------------------------------------------------
" Commands
"-----------------------------------------------------------------------------------------------------------
command Config :call OpenConfig()
command ToggleComment :call ToggleComment()
command Ctags :call Ctags()
command Cd :call CdToCurrent()
"-----------------------------------------------------------------------------------------------------------
" Functions
"-----------------------------------------------------------------------------------------------------------
function! ToggleComment()
    let l:comment_types = {'vim':"\"", 'python':"#", 'default':"//"}
    let save_pos = getpos(".")
    if has_key(g:comment_types, &ft)
        let cstr = l:comment_types[&ft]
    else
        let cstr = l:comment_types["default"]
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


function! OpenConfig()
    :execute ":e" . g:vimhome . "config.vim"
endfunction


function! Ctags()
    CdToCurrent()
    :execute "!ctags -R * " . getcwd()
endfunction


function! CdToCurrent()
    :cd %:p:h
    :pwd
endfunction
