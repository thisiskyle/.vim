if has("win32")
    let g:vimhome = '~/vimfiles/'
    set guifont=Victor_Mono:h10,Cascadia_Code_Light:h10
elseif has("unix")
    let g:vimhome = '~/.vim/'
endif
"===============================================================================================================
" plugins
"===============================================================================================================
call plug#begin(g:vimhome . 'plug')
" utility
Plug 'https://github.com/sheerun/vim-polyglot'
Plug 'https://github.com/itchyny/vim-gitbranch'
" colors
Plug 'https://github.com/lifepillar/vim-gruvbox8'
call plug#end()
"===============================================================================================================
" plugin variables
"===============================================================================================================
" my functions
let g:comment_delimiters = { 'default':"//" }
let g:comment_delimiters.vim = "\""
let g:comment_delimiters.python = "#"
let g:comment_delimiters.sh = "#"
let g:comment_delimiters.gdscript3 = "#"
" gruvbox8
let g:gruvbox_italics = 0
let g:gruvbox_bold = 0
let g:gruvbox_italicize_strings = 0
"===============================================================================================================
" vim settings
"===============================================================================================================
if has("gui_running")
    set guioptions ='' lines=40 columns=120
endif
exec "set viewdir=" . g:vimhome . ".tmp/views//"
exec "set directory=" . g:vimhome . ".tmp/swap//"
set nobackup incsearch hlsearch autoindent expandtab tabstop=4 shiftwidth=4
set belloff=all laststatus=0 background=dark scrolloff=0 t_Co=256
set tags=tags;/
filetype plugin indent on
set rulerformat=%60(%=%m\ %#RulerFile#%t\ %#RulerBranch#%{gitbranch#name()}%#Normal#\ %l:%c%)
"since window splits force a status line, this makes it look like my ruler
set fillchars=stl:-,stlnc:-,vert:\|,fold:-,diff:- 
set statusline=%=%#StatusNormal#%m\ %t\ %#StatusBranch#%{gitbranch#name()}%#StatusNormal#\ %l:%c\  

color nightswatch
"===============================================================================================================
" key bindings
"===============================================================================================================
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <c-n> :call ToggleComment()<cr>
vnoremap <c-n> :call ToggleComment()<cr>
nnoremap <leader>r :silent call ReplaceAll()<cr>
"===============================================================================================================
" commands 
"===============================================================================================================
command Config :execute ":e" . g:vimhome . "config.vim"
command Notes :execute ":e ~/notes.txt" 
command Ctags :execute "!ctags -f tags -R * " . getcwd()
command CD :cd %:p:h
command FormatJson :%!python -m json.tool
command Todo noautocmd vimgrep /\(TODO\|todo\|Todo\)/j **/* | cw
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview
"===============================================================================================================
" functions 
"===============================================================================================================
" adds a comment string at the beginning of current line unless the line is empty
function! ToggleComment()
    " skip line if empty
    if strlen(getline('.')) <= 0 
        return 
    endif
    " save position
    let save_pos = getpos(".")
    " get the comment string
    if has_key(g:comment_delimiters, &ft) 
        let cstr = g:comment_delimiters[&ft]
    else 
        let cstr = g:comment_delimiters["default"] 
    endif
    " jump to first character in line
    normal ^
    " check to see if the line has a comment
    let a = col(".") - 1
    if getline(".")[a : a + (strlen(cstr) - 1)] == cstr
        " remove the comment string
        :execute "normal " . strlen(cstr) . "x"
        call setpos(".", save_pos)
        :execute "normal " . strlen(cstr) . "h"
    else 
        " add a comment string
        :execute "normal i" . cstr
        call setpos(".", save_pos)
        :execute "normal " . strlen(cstr) . "l"
    endif
endfunction

" shortcut for :%s/<word>/<replacement>/g/
function! ReplaceAll()
    let save_pos = getpos(".")
    let word = expand("<cword>")
    :execute "%s/" . word . "/" . input("Replace [" . word . "] with: ") . "/g"
    call setpos(".", save_pos)
endfunction
