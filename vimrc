"*****************************************************************************
"                       __   _(_)_ __ ___  _ __ ___
"                       \ \ / / | '_ ` _ \| '__/ __|
"                        \ V /| | | | | | | | | (__
" kenp                  (_)_/ |_|_| |_| |_|_|  \___|
"*****************************************************************************
" NeoBundle core
"*****************************************************************************
" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if has('vim_starting')
    set nocompatible
    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

let iCanHazNeoBundle=1
let neobundle_readme=expand('~/.vim/bundle/neobundle.vim/README.md')

if !filereadable(neobundle_readme)
    echo "Installing NeoBundle..."
    echo ""
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim/
    let iCanHazNeoBundle=0
endif

let s:cache_dir=get(g:dotvim_settings, 'cache_dir', '~/.vim/.cache')

" initialize default settings
let s:settings={}
let s:settings.default_indent=4
let s:settings.max_column=80
let s:settings.enable_cursorcolumn=0
let s:settings.autocomplete_method='ycm'
let s:settings.colorscheme='seoul256'

if has('lua')
    let s:settings.autocomplete_method = 'neocomplete'
elseif filereadable(expand("~/.vim/bundle/YouCompleteMe/python/ycm_core.*"))
    let s:settings.autocomplete_method = 'ycm'
endif

if exists('g:dotvim_settings.plugin_groups')
    let s:settings.plugin_groups = g:dotvim_settings.plugin_groups
else

    let s:settings.plugin_groups = []
    call add(s:settings.plugin_groups, 'core')
    call add(s:settings.plugin_groups, 'web')
    call add(s:settings.plugin_groups, 'bash')
    call add(s:settings.plugin_groups, 'python')
    call add(s:settings.plugin_groups, 'scm')
    call add(s:settings.plugin_groups, 'editing')
    call add(s:settings.plugin_groups, 'indents')
    call add(s:settings.plugin_groups, 'navigation')
    call add(s:settings.plugin_groups, 'ctrlp')
    call add(s:settings.plugin_groups, 'unite')
    call add(s:settings.plugin_groups, 'autocomplete')
    call add(s:settings.plugin_groups, 'misc')

    " exclude all language-specific plugins by default
    if !exists('g:dotvim_settings.plugin_groups_exclude')
        let g:dotvim_settings.plugin_groups_exclude = ['']
    endif

    for group in g:dotvim_settings.plugin_groups_exclude
        let i=index(s:settings.plugin_groups, group)
        if i != -1
            call remove(s:settings.plugin_groups, i)
        endif
    endfor

    if exists('g:dotvim_settings.plugin_groups_include')
        for group in g:dotvim_settings.plugin_groups_include =['python', 'web', 'bash']
            call add(s:settings.plugin_groups, group)
        endfor
    endif
endif

" override defaults with the ones specified in g:dotvim_settings {{{
for key in keys(s:settings)
    if has_key(g:dotvim_settings, key)
        let s:settings[key] = g:dotvim_settings[key]
    endif
endfor
"}}}

" setup & neobundle {{{
set nocompatible
set all& "reset everything to their defaults
set rtp+=~/.vim/bundle/neobundle.vim
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'
"}}}

" functions {{{
function! s:get_cache_dir(suffix)
    return resolve(expand(s:cache_dir . '/' . a:suffix))
endfunction "}}}

function! Source(begin, end) "{{{
    let lines=getline(a:begin, a:end)
    for line in lines
        execute line
    endfor
endfunction "}}}

function! ToggleWrap() "{{{
    let s:nowrap_cc_bg = [22, '#005f00']
    redir => s:curr_cc_hi
    silent hi ColorColumn
    redir END
    let s:curr_cc_ctermbg = matchstr(s:curr_cc_hi, 'ctermbg=\zs.\{-}\s\ze\1')
    let s:curr_cc_guibg = matchstr(s:curr_cc_hi, 'guibg=\zs.\{-}\_$\ze\1')
    if s:curr_cc_ctermbg != s:nowrap_cc_bg[0]
        let g:curr_cc_ctermbg = s:curr_cc_ctermbg
    endif
    if s:curr_cc_guibg != s:nowrap_cc_bg[1]
        let g:curr_cc_guibg = s:curr_cc_guibg
    endif
    if &textwidth == 80
        set textwidth=0
        exec 'hi ColorColumn ctermbg='.s:nowrap_cc_bg[0].
                    \' guibg='.s:nowrap_cc_bg[1]
    elseif &textwidth == 0
        set textwidth=80
        exec 'hi ColorColumn ctermbg='.g:curr_cc_ctermbg.
                    \' guibg='.g:curr_cc_guibg
    endif
endfunction
" }}}

" Toggle the Quickfix window {{{
function! s:QuickfixToggle()
    for i in range(1, winnr('$'))
        let bnum = winbufnr(i)
        if getbufvar(bnum, '&buftype') == 'quickfix'
            cclose
            lclose
            return
        endif
    endfor
    copen
endfunction
command! ToggleQuickfix call <SID>QuickfixToggle()
nnoremap <silent> <leader>q :ToggleQuickfix<CR>
" }}}

" get the word frequency in the text {{{
function! WordFrequency() range
    let all = split(join(getline(a:firstline, a:lastline)), '\A\+')
    let frequencies = {}
    for word in all
        let frequencies[word] = get(frequencies, word, 0) + 1
    endfor
    let lst = []
    for [key,value] in items(frequencies)
        call add(lst, value."\t".key."\n")
    endfor
    call sort(lst)
    echo join(lst)
endfunction
command! -range=% WordFrequency <line1>,<line2>call WordFrequency()
nmap <leader>ef :Unite output:WordFrequency<CR>
" }}}

" Move between Vim and Tmux windows  {{{
if exists('$TMUX')
    function! TmuxOrSplitSwitch(wincmd, tmuxdir)
        let previous_winnr = winnr()
        execute "wincmd " . a:wincmd
        if previous_winnr == winnr()
            " The sleep and & gives time to get back to vim so tmux's focus tracking
            " can kick in and send us our ^[[O
            execute "silent !sh -c 'sleep 0.01; tmux select-pane -" . a:tmuxdir . "' &"
            redraw!
        endif
    endfunction
    let previous_title = substitute(system("tmux display-message -p '#{pane_title}'"), '\n', '', '')
    let &t_ti = "\<Esc>]2;vim\<Esc>\\" . &t_ti
    let &t_te = "\<Esc>]2;". previous_title . "\<Esc>\\" . &t_te
    nnoremap <silent> <C-h> :call TmuxOrSplitSwitch('h', 'L')<CR>
    nnoremap <silent> <C-j> :call TmuxOrSplitSwitch('j', 'D')<CR>
    nnoremap <silent> <C-k> :call TmuxOrSplitSwitch('k', 'U')<CR>
    nnoremap <silent> <C-l> :call TmuxOrSplitSwitch('l', 'R')<CR>
else
    map <C-h> <C-w>h
    map <C-j> <C-w>j
    map <C-k> <C-w>k
    map <C-l> <C-w>l
endif
" }}}

" VimFler fonction {{{
function! VimfilerCurrentDir()
    let currentDir = vimfiler#get_current_vimfiler().original_files
    for dirItem in currentDir
        if dirItem.vimfiler__is_marked == 1
            return dirItem.action__path
        endif
    endfor
endfunction

function! VimfilerSearch()
    let dirToSearch = VimfilerCurrentDir()
    let pattern = input("Search [".dirToSearch."] For: ")
    if pattern == ''
        echo 'Maybe another time...'
        return
    endif
    exec 'silent grep! "'.pattern.'" '.dirToSearch
    exec "redraw!"
    exec "redrawstatus!"
    exec "copen"
endfunction
"}}}

" Count lines of code {{{
function! LinesOfCode()
    echo system('cloc --quiet '.bufname("%"))
endfunction
"}}}

" formatting shortcuts {{{
function! Preserve(command) "{{{
    " preparation: save last search, and cursor position.
    let _s=@/
    let l=line(".")
    let c=col(".")
    " do the business:
    execute a:command
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction "}}}
nmap <leader>zf :call Preserve("normal gg=G")<cr>
vmap <leader>feg :sort<cr>
autocmd BufWritePre *.sh :normal gg=G
"autocmd BufWritePre *.py :normal gg=G
"autocmd BufWritePre * :normal gg=G
"}}}

"Toggle cursorline and cursorcolumn function in VIM {{{
fu! ToggleCurline () "{{{
    if &cursorline && &cursorcolumn
        set nocursorline
        set nocursorcolumn
    else
        set cursorline
        set cursorcolumn
    endif
endfunction "}}}
nmap <F7> :call ToggleCurline()<CR>
"}}}

" vim file/folder management fonction {{{
function! EnsureExists(path) "{{{
    if !isdirectory(expand(a:path))
        call mkdir(expand(a:path))
    endif
endfunction "}}}
"}}}

" window killer function {{{
function! CloseWindowOrKillBuffer()
    let number_of_windows_to_this_buffer = len(filter(range(1, winnr('$')), "winbufnr(v:val) == bufnr('%')"))
    " never bdelete a nerd tree
    if matchstr(expand("%"), 'vimfiler') == 'vimfiler'
        wincmd c
        return
    endif
    if number_of_windows_to_this_buffer > 1
        wincmd c
    else
        bdelete
    endif
endfunction
nnoremap <silent> Q :call CloseWindowOrKillBuffer()<cr>
"}}}

" base configuration {{{
set timeoutlen=300                                  "mapping timeout
set ttimeoutlen=50                                  "keycode timeout

"set mouse=a                                         "enable mouse
set mousehide                                       "hide when characters are typed
set history=1000                                    "number of command lines to remember
set ttyfast                                         "assume fast terminal connection
set viewoptions=folds,options,cursor,unix,slash     "unix compatibility
set encoding=utf-8                                  "set encoding for text

if exists('$TMUX')
    set clipboard=
else
    set clipboard=unnamed                             "sync with OS clipboard
endif

set hidden                                          "allow buffer switching without saving
set autoread                                        "auto reload if file saved externally
set fileformats+=mac                                "add mac to auto-detection of file format line endings
set nrformats-=octal                                "always assume decimal numbers
set showcmd
set tags=tags;/
set showfulltag
set modeline
set modelines=5
set shell=/bin/zsh
set noshelltemp                                     "use pipes

" whitespace
set backspace=indent,eol,start                      "allow backspacing everything in insert mode
set autoindent                                      "automatically indent to match adjacent lines
set expandtab                                       "spaces instead of tabs
set smarttab                                        "use shiftwidth to enter tabs
let &tabstop=s:settings.default_indent              "number of spaces per tab for display
let &softtabstop=s:settings.default_indent          "number of spaces per tab in insert mode
let &shiftwidth=s:settings.default_indent           "number of spaces when indenting
set list                                            "highlight whitespace
set listchars=tab:¦\ ,trail:•,extends:❯,precedes:❮
set shiftround
set linebreak
let &showbreak='↪ '

set scrolloff=1                                     "always show content after scroll
set scrolljump=5                                    "minimum number of lines to scroll
set display+=lastline
set wildmenu                                        "show list for autocomplete
set wildmode=list:full
set wildignorecase

set splitbelow
set splitright

" disable sounds
set noerrorbells
set novisualbell
set t_vb=

" searching
set hlsearch                                        "highlight searches
set incsearch                                       "incremental searching
set ignorecase                                      "ignore case for searching
set smartcase                                       "do case-sensitive if there's a capital letter

" dict
set dictionary+=n$HOME/.vim/dict/tr-words
set viminfo+=n$HOME/.vim/.cache/viminfo

"if executable('ack')
"    set grepprg=ack\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ $*
"    set grepformat=%f:%l:%c:%m
"endif

"if executable('ag')
"    set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
"    set grepformat=%f:%l:%c:%m
"endif

" vim file/folder management {{{
" persistent undo
if exists('+undofile')
    set undofile
    let &undodir=s:get_cache_dir('undo')
endif

" backups
set backup
let &backupdir=s:get_cache_dir('backup')

" swap files
let &directory=s:get_cache_dir('swap')
set noswapfile

call EnsureExists(s:cache_dir)
call EnsureExists(&undodir)
call EnsureExists(&backupdir)
call EnsureExists(&directory)
"}}}

" Map leader to {{{
let mapleader = "\<Space>"
let g:mapleader = "\<Space>"
nnoremap <SPACE> <Nop>
let maplocalleader = ","
let g:maplocalleader = ","
set timeoutlen=600
"}}}

" ui configuration {{{
set showmatch                                       "automatically highlight matching braces/brackets/etc.
set matchtime=2                                     "tens of a second to show matching parentheses
"set number
"set norelativenumber
set lazyredraw
set laststatus=2
set noshowmode
set foldenable                                      "enable folds by default
set foldmethod=syntax                               "fold via syntax of files
set foldlevelstart=99                               "open all folds by default
let g:xml_syntax_folding=1                          "enable xml folding

let &colorcolumn=s:settings.max_column
if exists('+colorcolumn')
    let &colorcolumn="s:settings.max_column,".join(range(400,999),",")
endif

if s:settings.enable_cursorcolumn
    set cursorcolumn
    autocmd WinLeave * setlocal nocursorcolumn
    autocmd WinEnter * setlocal cursorcolumn
endif

if has('gui_running')
    "set lines=999 columns=9999                        "open a maximize"
    set mouse=a                                        "enable mouse
    set lines=60
    set columns=180
    set guioptions=i
    set guioptions+=t                                 "tear off menu items
    set guioptions-=T                                 "toolbar icons
    autocmd InsertLeave * hi Cursor guibg=DodgerBlue3
    autocmd InsertEnter * hi Cursor guibg=red
    let g:goldenview_enable_at_startup=0
    set gfn=Ubuntu\ Mono\ 16
endif

if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif
"}}}

" plugin/mapping configuration {{{
if count(s:settings.plugin_groups, 'core') "{{{
    NeoBundle 'matchit.zip'
    NeoBundle 'bling/vim-airline' "{{{
    let g:airline#extensions#tabline#enabled=1
    let g:airline#extensions#tabline#left_sep=''
    let g:airline#extensions#tabline#left_alt_sep=''
    let g:airline#extensions#tabline#buffer_idx_mode=1
    let g:airline_powerline_fonts=1
    let g:airline_theme='ubaryd'
    autocmd User Startified AirlineRefresh
    "nmap <leader>1 <Plug>AirlineSelectTab1
    "nmap <leader>2 <Plug>AirlineSelectTab2
    "nmap <leader>3 <Plug>AirlineSelectTab3
    "nmap <leader>4 <Plug>AirlineSelectTab4
    "nmap <leader>5 <Plug>AirlineSelectTab5
    "nmap <leader>6 <Plug>AirlineSelectTab6
    "nmap <leader>7 <Plug>AirlineSelectTab7
    "nmap <leader>8 <Plug>AirlineSelectTab8
    "nmap <leader>9 <Plug>AirlineSelectTab9
    "}}}
    NeoBundle 'tpope/vim-surround'
    NeoBundle 'tpope/vim-repeat'
    NeoBundle 'tpope/vim-dispatch'
    NeoBundle 'tpope/vim-eunuch'
    NeoBundle 'tpope/vim-unimpaired' "{{{
    nmap <c-up> [e
    nmap <c-down> ]e
    vmap <c-up> [egv
    vmap <c-down> ]egv
    "}}}
    NeoBundle 'Shougo/vimproc.vim', {'build': {'linux': 'make'}}
endif "}}}

if count(s:settings.plugin_groups, 'web') "{{{
    NeoBundleLazy 'groenewege/vim-less', {'autoload':{'filetypes':['less']}}
    NeoBundleLazy 'cakebaker/scss-syntax.vim', {'autoload':{'filetypes':['scss','sass']}}
    NeoBundleLazy 'hail2u/vim-css3-syntax', {'autoload':{'filetypes':['css','scss','sass']}}
    NeoBundleLazy 'ap/vim-css-color', {'autoload':{'filetypes':['css','scss','sass','less','styl']}}
    NeoBundleLazy 'othree/html5.vim', {'autoload':{'filetypes':['html']}}
    NeoBundleLazy 'wavded/vim-stylus', {'autoload':{'filetypes':['styl']}}
    NeoBundleLazy 'digitaltoad/vim-jade', {'autoload':{'filetypes':['jade']}}
    NeoBundleLazy 'juvenn/mustache.vim', {'autoload':{'filetypes':['mustache']}}
    NeoBundleLazy 'gregsexton/MatchTag', {'autoload':{'filetypes':['html','xml']}}
    NeoBundleLazy 'mattn/emmet-vim', {'autoload':{'filetypes':['html','xml','xsl','xslt','xsd','css','sass','scss','less','mustache']}} "{{{
    NeoBundleLazy 'Rykka/colorv.vim', {'autoload' : {'commands' : [
                \ 'ColorV', 'ColorVView', 'ColorVPreview',
                \ 'ColorVPicker', 'ColorVEdit', 'ColorVEditAll',
                \ 'ColorVInsert', 'ColorVList', 'ColorVName',
                \ 'ColorVScheme', 'ColorVSchemeFav',
                \ 'ColorVSchemeNew', 'ColorVTurn2'],
                \ }}
    function! s:zen_html_tab()
        let line = getline('.')
        if match(line, '<.*>') < 0
            return "\<c-y>,"
        endif
        return "\<c-y>n"
    endfunction
    autocmd FileType xml,xsl,xslt,xsd,css,sass,scss,less,mustache imap <buffer><tab> <c-y>,
    autocmd FileType html imap <buffer><expr><tab> <sid>zen_html_tab()
    "}}}
endif "}}}

if count(s:settings.plugin_groups, 'bash') "{{{
    NeoBundle 'vim-scripts/bash-support.vim' , {'autoload': { 'filetypes': ['sh']}}
    let g:BASH_SyntaxCheckOptionsGlob="-O extglob"
endif "}}}

if count(s:settings.plugin_groups, 'python') "{{{
    NeoBundleLazy 'klen/python-mode', {'autoload':{'filetypes':['python']}} "{{{
    let g:pymode_rope=0
    "}}}
    NeoBundleLazy 'jmcantrell/vim-virtualenv' "{{{
    "}}}
    NeoBundleLazy 'davidhalter/jedi-vim', {'autoload':{'filetypes':['python']}} "{{{
    let g:jedi#popup_on_dot=0
    "}}}
endif "}}}

if count(s:settings.plugin_groups, 'scm') "{{{
    NeoBundle 'mhinz/vim-signify' "{{{
    let g:signify_update_on_bufenter=0
    "}}}
    if executable('hg')
        NeoBundle 'bitbucket:ludovicchabant/vim-lawrencium'
    endif
    NeoBundle 'tpope/vim-fugitive' "{{{
    nnoremap <localleader>gn :Unite output:echo\ system("git\ init")<CR>
    nnoremap <localleader>gs :Gstatus<CR>
    nnoremap <localleader>gw :Gwrite<CR>
    nnoremap <localleader>go :Gread<CR>
    nnoremap <localleader>gR :Gremove<CR>
    nnoremap <localleader>gm :Gmove<Space>
    nnoremap <localleader>gc :Gcommit<CR>
    nnoremap <localleader>gd :Gdiff<CR>
    nnoremap <localleader>gb :Gblame<CR>
    nnoremap <localleader>gB :Gbrowse<CR>
    nnoremap <localleader>gp :Git! push<CR>
    nnoremap <localleader>gP :Git! pull<CR>
    nnoremap <localleader>gi :Git!<Space>
    nnoremap <localleader>ge :Gedit<CR>
    nnoremap <localleader>gE :Gedit<Space>
    nnoremap <localleader>gl :exe "silent Glog <Bar> Unite -no-quit quickfix"<CR>:redraw!<CR>
    nnoremap <localleader>gL :exe "silent Glog -- <Bar> Unite -no-quit quickfix"<CR>:redraw!<CR>
    nnoremap <localleader>gt :!tig<CR>:redraw!<CR>
    nnoremap <localleader>gS :exe "silent !shipit"<CR>:redraw!<CR>
    nnoremap <localleader>gg :exe 'silent Ggrep -i '.input("Pattern: ")<Bar> Unite quickfix -no-quit<CR>
    nnoremap <localleader>ggm :exe 'silent Glog --grep='.input("Pattern: ").' <Bar> Unite -no-quit quickfix'<CR>
    nnoremap <localleader>ggt :exe 'silent Glog -S='.input("Pattern: ").' <Bar> Unite -no-quit quickfix'<CR>
    nnoremap <localleader>ggc :silent! Ggrep -i<Space>
    autocmd FileType gitcommit nmap <buffer> U :Git checkout -- <C-r><C-g><CR>
    autocmd BufReadPost fugitive://* set bufhidden=delete
    "}}}
    NeoBundle 'airblade/vim-gitgutter' "{{{
    "}}}
    NeoBundle 'joedicastro/vim-github-dashboard' "{{{
    "}}}
    NeoBundleLazy 'gregsexton/gitv', {'depends':['tpope/vim-fugitive'], 'autoload':{'commands':'Gitv'}}
    "}}}
    NeoBundleLazy 'gregsexton/gitv', {'depends':['tpope/vim-fugitive'], 'autoload':{'commands':'Gitv'}} "{{{
    nnoremap <silent> <localleader>gv :Gitv<CR>
    nnoremap <silent> <localleader>gV :Gitv!<CR>
    "}}}
endif "}}}

if count(s:settings.plugin_groups, 'autocomplete') "{{{
    NeoBundle 'honza/vim-snippets'
    if s:settings.autocomplete_method == 'ycm' "{{{
        NeoBundle 'Valloric/YouCompleteMe', {'vim_version':'7.3.584'} "{{{
        let g:ycm_complete_in_comments_and_strings=1
        let g:ycm_key_list_select_completion=['<C-n>', '<Down>']
        let g:ycm_key_list_previous_completion=['<C-p>', '<Up>']
        let g:ycm_filetype_blacklist={'unite': 1}
        "}}}
        NeoBundle 'SirVer/ultisnips' "{{{
        let g:UltiSnipsExpandTrigger="<tab>"
        let g:UltiSnipsJumpForwardTrigger="<tab>"
        let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
        let g:UltiSnipsSnippetsDir='~/.vim/snippets'
        "}}}
    else
        NeoBundle 'Shougo/neosnippet-snippets'
        NeoBundle 'Shougo/neosnippet.vim' "{{{
        let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets,~/.vim/snippets'
        let g:neosnippet#enable_snipmate_compatibility=1
        imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ? "\<C-n>" : "\<TAB>")
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
        imap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
        smap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
        "}}}
    endif "}}}
    if s:settings.autocomplete_method == 'neocomplete' "{{{
        NeoBundleLazy 'Shougo/neocomplete.vim', {'autoload':{'insert':1}, 'vim_version':'7.3.885'} "{{{
        let g:neocomplete#enable_at_startup=1
        let g:neocomplete#data_directory=s:get_cache_dir('neocomplete')
        "}}}
    endif "}}}
endif "}}}

if count(s:settings.plugin_groups, 'editing') "{{{
    NeoBundleLazy 'editorconfig/editorconfig-vim', {'autoload':{'insert':1}}
    NeoBundle 'tpope/vim-endwise'
    NeoBundle 'tpope/vim-speeddating'
    NeoBundle 'thinca/vim-visualstar'
    NeoBundle 'tomtom/tcomment_vim'
    NeoBundle 'terryma/vim-expand-region'
    NeoBundle 'chrisbra/NrrwRgn'
    NeoBundleLazy 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}} "{{{
    nmap <localleader>& :Tabularize /&<CR>
    vmap <localleader>& :Tabularize /&<CR>
    nmap <localleader>= :Tabularize /=<CR>
    vmap <localleader>= :Tabularize /=<CR>
    nmap <localleader>: :Tabularize /:<CR>
    vmap <localleader>: :Tabularize /:<CR>
    nmap <localleader>:: :Tabularize /:\zs<CR>
    vmap <localleader>:: :Tabularize /:\zs<CR>
    nmap <localleader>, :Tabularize /,<CR>
    vmap <localleader>, :Tabularize /,<CR>
    nmap <localleader>,, :Tabularize /,\zs<CR>
    vmap <localleader>,, :Tabularize /,\zs<CR>
    nmap <localleader><Bar> :Tabularize /<Bar><CR>
    vmap <localleader><Bar> :Tabularize /<Bar><CR>
    "}}}
    NeoBundle 'jiangmiao/auto-pairs'
    NeoBundle 'justinmk/vim-sneak' "{{{
    let g:sneak#streak=1
    "}}}
    NeoBundle 'terryma/vim-multiple-cursors' "{{{
    let g:multi_cursor_start_key='<F5>'
    let g:multi_cursor_start_key='<C-n>'
    let g:multi_cursor_start_word_key='g<C-n>'
    "}}}
endif "}}}

if count(s:settings.plugin_groups, 'navigation') "{{{
    NeoBundle 'mileszs/ack.vim' "{{{
    if executable('ag')
        "let g:ackprg = "ag --nogroup --column --smart-case --follow"
        let g:ackprg = "ag --vimgrep"
    endif
    "}}}
    NeoBundle 'rking/ag.vim' "{{{
    set runtimepath^=~/.vim/bundle/ag
    let g:agprg="ag --vimgrep"
    "}}}
    NeoBundleLazy 'mbbill/undotree', {'autoload':{'commands':'UndotreeToggle'}} "{{{
    let g:undotree_WindowLayout=3
    let g:undotree_SetFocusWhenToggle=1
    nnoremap <silent> <leader>5 :UndotreeToggle<CR>
    "}}}
    NeoBundleLazy 'EasyGrep', {'autoload':{'commands':'GrepOptions'}} "{{{
    let g:EasyGrepRecursive=1
    let g:EasyGrepAllOptionsInExplorer=1
    let g:EasyGrepCommand=1
    nnoremap <leader>vo :GrepOptions<cr>
    "}}}
    NeoBundle 'scrooloose/nerdcommenter' "{{{
    filetype plugin on
    let NERDMenuMode=0
    let NERDSpaceDelims=1
    nmap <leader>6 :call NERDComment(0, "toggle")<cr>
    vmap <leader>6 :call NERDComment(0, "toggle")<cr>")"
    "}}}
    NeoBundle 'rhysd/clever-f.vim' "{{{
    "}}}
    NeoBundle 'MattesGroeger/vim-bookmarks' "{{{
    let g:bookmark_sign='⚑'
    let g:bookmark_highlight_lines=0
    let g:bookmark_save_per_working_dir=0
    let g:bookmark_manage_per_buffer=0
    let g:bookmark_auto_close=1
    let g:bookmark_auto_save=1
    let g:bookmark_auto_save_file=s:get_cache_dir('bookmark')
    let g:bookmark_center=1
    let g:bookmark_no_default_key_mappings=0
    highlight BookmarkSign ctermbg=NONE ctermfg=1
    highlight BookmarkLine ctermbg=240 ctermfg=NONE
    highlight BookmarkAnnotationSign ctermbg=NONE ctermfg=190
    highlight BookmarkAnnotationLine ctermbg=23 ctermfg=NONE
    "}}}
    NeoBundleLazy 'majutsushi/tagbar', {'autoload':{'commands':'TagbarToggle'}} "{{{
    nnoremap <silent> <leader>4 :TagbarToggle<CR>
    "}}}
    NeoBundle 'easymotion/vim-easymotion' "{{{
    let g:EasyMotion_do_mapping = 0
    let g:EasyMotion_smartcase = 1
    nmap s <Plug>(easymotion-s)
    nmap s <Plug>(easymotion-s2)
    map <leader>j <Plug>(easymotion-j)
    map <leader>k <Plug>(easymotion-k)
    "}}}
    NeoBundle 'Shougo/vimfiler.vim' "{{{
    let g:vimfiler_data_directory=s:get_cache_dir('vimfiler')
    let g:vimfiler_as_default_explorer=1
    let g:vimfiler_safe_mode_by_default=0
    let g:vimfiler_tree_leaf_icon=" "
    let g:vimfiler_tree_closed_icon='▸'
    let g:vimfiler_tree_opened_icon='▾'
    let g:vimfiler_file_icon='-'
    let g:vimfiler_marked_file_icon='✓'
    let g:vimfiler_readonly_file_icon='⭤'
    let g:vimfiler_expand_jump_to_first_child=0
    let g:vimfiler_enable_auto_cd=1
    let g:vimfiler_ignore_pattern='\.'
    "let g:vimfiler_ignore_pattern='^\%(\.git\|\.hg\)$'
    "let g:vimfiler_sort_type = "Time"
    "let g:vimfiler_time_format = '%m-%d-%y %H:%M:%S'
    "autocmd VimEnter * VimFiler
    "autocmd VimEnter * if !argc() | VimFiler | endif
    autocmd FileType vimfiler nmap q <buffer> <Plug>(vimfiler_close)
    autocmd FileType vimfiler nunmap <buffer> <C-l>
    autocmd FileType vimfiler nunmap <buffer> <C-j>
    autocmd FileType vimfiler nunmap <buffer> l
    autocmd FileType vimfiler nmap <buffer> l <Plug>(vimfiler_cd_or_edit)
    autocmd FileType vimfiler nmap <buffer> h <Plug>(vimfiler_switch_to_parent_directory)
    autocmd FileType vimfiler nmap <buffer> <C-R> <Plug>(vimfiler_redraw_screen)
    autocmd FileType vimfiler nmap <buffer> <Leader>sd <Plug>(vimfiler_mark_current_line):call VimfilerSearch()<CR>
    autocmd FileType vimfiler nmap <silent><buffer><expr> <CR> vimfiler#smart_cursor_map("\<Plug>(vimfiler_expand_tree)", "\<Plug>(vimfiler_edit_file)")
    nnoremap <Leader>9 :<C-u>VimFiler -winwidth=55 -buffer-name=kenp -split -parent -winwidth=55 -toggle -no-quit<CR>
    nnoremap <Leader>8 :<C-u>VimFiler -winwidth=55 -buffer-name=kenp -split -parent -winwidth=55 -toggle -no-quit -find<CR>
    "}}}
    NeoBundle 'ryanoasis/vim-webdevicons' "{{{
    let g:webdevicons_enable = 1
    let g:webdevicons_enable_unite = 1
    let g:webdevicons_enable_vimfiler = 1
    "}}}
    NeoBundle 't9md/vim-choosewin' "{{{
    nmap  -  <Plug>(choosewin)
    let g:choosewin_overlay_enable = 1
    let g:choosewin_overlay_clear_multibyte = 1
    let g:choosewin_color_overlay = {
                \ 'gui': ['DodgerBlue3', 'DodgerBlue3' ],
                \ 'cterm': [ 25, 25 ]
                \ }
    let g:choosewin_color_overlay_current = {
                \ 'gui': ['firebrick1', 'firebrick1' ],
                \ 'cterm': [ 124, 124 ]
                \ }
    let g:choosewin_blink_on_land      = 1 " dont' blink at land
    let g:choosewin_statusline_replace = 1 " don't replace statusline
    let g:choosewin_tabline_replace    = 1 " don't replace tabline
    "}}}
endif "}}}

if count(s:settings.plugin_groups, 'ctrlp') "{{{
    NeoBundle 'ctrlpvim/ctrlp.vim', { 'depends': 'tacahiroy/ctrlp-funky' } "{{{
    NeoBundle 'mattn/ctrlp-mark'
    NeoBundle 'DavidEGx/ctrlp-smarttabs'
    NeoBundle 'sgur/ctrlp-extensions.vim'
    NeoBundle 'jasoncodes/ctrlp-modified.vim'
    NeoBundle 'FelikZ/ctrlp-py-matcher'
    let g:airline#extensions#tabline#enabled = 1
    let g:ctrlp_cache_dir=s:get_cache_dir('ctrlp')
    let g:ctrlp_clear_cache_on_exit=0
    let g:ctrlp_use_caching=1
    let g:ctrlp_open_new_file='rw'
    let g:ctrlp_max_height=20
    let g:ctrlp_show_hidden=1
    let g:ctrlp_follow_symlinks=1
    let g:ctrlp_max_files=20000
    let g:ctrlp_yankring_limit = 100
    let g:ctrlp_yankring_minimum_chars = 2
    let g:ctrlp_cmdpalette_execute = 1
    let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
    let g:ctrlp_reuse_window='startify'
    let g:ctrlp_extensions = ['smarttabs', 'buffer', 'line', 'changes',
                \'mixed', 'cmdpalette', 'funky', 'autoignore', 'mark']
    set wildmode=list:longest,list:full
    set wildignore+=*/tmp/*,*.o,*.obj,.git,*.rbc,*.mp3,*.flac,*.avi,*.svg,*.jpg,*.png,*.so,*.a,*.swp,*.zip,*.pyc,*.pyo,*.classh,__pycache__
    let g:ctrlp_custom_ignore = '\Trash\|\.git$\|\.hg$\|\.cache$\|\.svn$\|public\|\images\|
                \ \public\|system\|data\|log\|\tmp$\|\.exe$\|\.so$\|\.dat$\|\Library\|\Download\|\.fonts\|
                \ \Music\|\Movies\|Pictures\|undo\|chromium\|\.thunderbird\|\.pdf$\|\.epub$\|\.gitmodules$\|\.mobi$\|\.rar$\|\.png$\|
                \ \.jpg$\|\.dmg$\|\.nib$\|\.bz$\|\.gz$\|\.tar$\|\.avi\|\.mp3$\|\.flac\|\.mp4$\|\.gitmodules$\|\.xib$'
    if executable('ag') "{{{
        let g:ctrlp_user_command="ag --vimgrep'"+ g:ctrlp_custom_ignore +"'"
    endif
    "}}}
    nmap <localleader> [ctrlp]
    nnoremap [ctrlp] <nop>
    nnoremap [ctrlp]t :CtrlPBufTag<cr>
    nnoremap [ctrlp]l :CtrlPLine<cr>
    nnoremap [ctrlp]b :CtrlPBuffer<cr>
    nnoremap [ctrlp]e :CtrlPModified<cr>
    nnoremap [ctrlp]g :CtrlPBranch<cr>
    nnoremap [ctrlp]o :CtrlPFunky<cr>
    "}}}
endif "}}}

if count(s:settings.plugin_groups, 'unite') "{{{
    NeoBundle 'Shougo/unite.vim' "{{{
    let bundle = neobundle#get('unite.vim')
    function! bundle.hooks.on_source(bundle)
        call unite#filters#matcher_default#use(['matcher_fuzzy'])
        call unite#filters#sorter_default#use(['sorter_rank'])
        call unite#custom#source('file_mru,file_rec,file_rec/async,grep,locate',
                    \ 'ignore_pattern', join(['\.git/', 'tmp/', 'bundle/', '.pip/', '.fonts/',
                    \ '.mozilla/', '.thunderbird/', '.cache/', '.ccache/', '.local/share/', '.local/lib/',
                    \ '.config/', '.gnome*', '.gconf/', '.purple/', '.macromedia/', 'Music/', 'VirtualBox VMs/', 'Videos/', 'Downloads/'], '\|'))
        call unite#custom#profile('default', 'context', {
                    \ 'start_insert': 1
                    \ })
    endfunction
    let g:unite_data_directory=s:get_cache_dir('unite')
    let g:unite_enable_start_insert=1
    let g:unite_source_history_yank_enable=1
    let g:unite_source_file_rec_async_command='ag --nocolor --nogroup -g ""'
    let g:unite_source_file_rec_max_cache_files = 1000000
    let g:unite_source_rec_max_cache_files = 1000000
    let g:unite_source_file_mru_limit = 300
    let g:unite_source_grep_default_opts="-iRHn"
    let g:unite_source_menu_menus = {}
    let g:unite_enable_short_source_mes = 0
    let g:unite_force_overwrite_statusline = 0
    let g:unite_cursor_line_highlight = 'TabLineSel'
    let g:unite_update_time = 500
    let g:unite_prompt='❯❯❯ '
    let g:unite_marked_icon='✓'
    let g:unite_source_buffer_time_format='(%d-%m-%Y %H:%M:%S) '
    let g:unite_source_file_mru_time_format='(%d-%m-%Y %H:%M:%S) '
    let g:unite_source_directory_mru_time_format='(%d-%m-%Y %H:%M:%S) '

    if executable('ag')
        " Use ag in unite grep source.
        let g:unite_source_grep_command = 'ag'
        let g:unite_source_grep_default_opts = '--nocolor --nogroup -g ""'
        let g:unite_source_grep_recursive_opt = ''
        let g:unite_source_grep_search_word_highlight = 1
    elseif executable('ack')
        " Use ack in unite grep source.
        let g:unite_source_grep_command = 'ack'
        let g:unite_source_grep_default_opts = '--no-heading --no-color -a'
        let g:unite_source_grep_recursive_opt = ''
        let g:unite_source_grep_search_word_highlight = 1
    endif
    function! s:unite_settings()
        nmap <buffer> Q <plug>(unite_exit)
        nmap <buffer> <esc> <plug>(unite_exit)
        imap <buffer> <esc> <plug>(unite_exit)
    endfunction
    autocmd FileType unite call s:unite_settings()

    nnoremap <leader>nbu :Unite neobundle/update -vertical -no-start-insert<cr>

    nmap <space> [unite]
    nnoremap [unite] <nop>

    nmap <localleader> [menu]
    nnoremap <silent>[menu]u :Unite -silent -winheight=12 menu<cr>

    nnoremap <silent> [unite]<space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec/async:! buffer file_mru bookmark<cr><c-u>
    nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec/async:!<cr><c-u>
    nnoremap <silent> [unite]e :<C-u>Unite -buffer-name=recent file_mru<cr>
    nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<cr>
    nnoremap <silent> [unite]l :<C-u>Unite -auto-resize -buffer-name=line line<cr>
    nnoremap <silent> [unite]b :<C-u>Unite -auto-resize -buffer-name=buffers buffer file_mru<cr>
    nnoremap <silent> [unite]/ :<C-u>Unite -no-quit -buffer-name=search grep:.<cr>
    nnoremap <silent> [unite]m :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
    nnoremap <silent> [unite]s :<C-u>Unite -quick-match buffer<cr>
    nnoremap <silent> [unite]p :<C-u>UniteWithInputDirectory -toggle -auto-resize -buffer-name=files file_rec/async:!<cr><c-u>
    "nnoremap <silent> [unite]p :<C-u>Unite file_rec/async<cr>
    "}}}
    NeoBundleLazy 'Shougo/neomru.vim', {'autoload':{'unite_sources':'file_mru'}}
    NeoBundleLazy 'osyo-manga/unite-airline_themes', {'autoload':{'unite_sources':'airline_themes'}} "{{{
    nnoremap <silent> [unite]a :<C-u>Unite -winheight=10 -auto-preview -buffer-name=airline_themes airline_themes<cr>
    "}}}
    NeoBundleLazy 'ujihisa/unite-colorscheme', {'autoload':{'unite_sources':'colorscheme'}} "{{{
    nnoremap <silent> [unite]c :<C-u>Unite -winheight=10 -auto-preview -buffer-name=colorschemes colorscheme<cr>
    "}}}
    NeoBundleLazy 'tsukkee/unite-tag', {'autoload':{'unite_sources':['tag','tag/file']}} "{{{
    nnoremap <silent> [unite]t :<C-u>Unite -auto-resize -buffer-name=tag tag tag/file<cr>

    nnoremap <silent> [unite]u :<C-u>Unite -silent -vertical -winwidth=40 -direction=topleft -toggle outline<cr>
    "}}}
    NeoBundleLazy 'Shougo/unite-outline', {'autoload':{'unite_sources':'outline'}} "{{{
    nnoremap <silent> [unite]o :<C-u>Unite -auto-resize -buffer-name=outline outline<cr>
    "}}}
    NeoBundleLazy 'Shougo/unite-help', {'autoload':{'unite_sources':'help'}} "{{{
    nnoremap <silent> [unite]h :<C-u>Unite -auto-resize -buffer-name=help help<cr>
    "}}}
    NeoBundleLazy 'Shougo/junkfile.vim', {'autoload':{'commands':'JunkfileOpen','unite_sources':['junkfile','junkfile/new']}} "{{{
    let g:junkfile#directory=s:get_cache_dir('junk')
    nnoremap <silent> [unite]j :<C-u>Unite -auto-resize -buffer-name=junk junkfile junkfile/new<cr>
    "}}}
    NeoBundleLazy 'Shougo/unite-session', {'autoload':{'unite_sources':'session', 'commands': ['UniteSessionSave', 'UniteSessionLoad']}} "{{{
    "}}}
    NeoBundleLazy 'osyo-manga/unite-quickfix', {'autoload':{'unite_sources': ['quickfix', 'location_list']}} "{{{
    "}}}
    NeoBundleLazy 'thinca/vim-unite-history', { 'autoload' : { 'unite_sources' : ['history/command', 'history/search']}} "{{{
    "}}}
    NeoBundleLazy 'ujihisa/unite-colorscheme', {'autoload':{'unite_sources': 'colorscheme'}} "{{{
    "}}}
    NeoBundleLazy 'osyo-manga/unite-filetype', {'autoload':{'unite_sources': 'filetype'}} "{{{
    "}}}
    NeoBundleLazy 'ujihisa/unite-locate', {'autoload':{'unite_sources':'locate'}} "{{{
    "}}}
    NeoBundleLazy 'klen/unite-radio.vim', {'autoload':{'unite_sources':'radio'}} "{{{
    "}}}
    NeoBundleLazy 'lambdalisue/vim-gista', {'depends': ['Shougo/unite.vim', 'tyru/open-browser.vim'],
                \ 'autoload': {'commands': ['Gista'], 'mappings': '<Plug>(gista-', 'unite_sources': 'gista'}} "{{{
    let g:gista#interactive_description = 1
    " }}}
endif "}}}

" files and dirs menu {{{
let g:unite_source_menu_menus.files = {
            \ 'description' : '          files & dirs
            \                            ⌘ [space]o',
            \}
let g:unite_source_menu_menus.files.command_candidates = [
            \['▷ open file                                                  ⌘ ,o',
            \'Unite -start-insert file'],
            \['▷ open more recently used files                              ⌘ ,m',
            \'Unite file_mru'],
            \['▷ open file with recursive search                            ⌘ ,O',
            \'Unite -start-insert file_rec/async'],
            \['▷ edit new file',
            \'Unite file/new'],
            \['▷ search directory',
            \'Unite directory'],
            \['▷ search recently used directories',
            \'Unite directory_mru'],
            \['▷ search directory with recursive search',
            \'Unite directory_rec/async'],
            \['▷ make new directory',
            \'Unite directory/new'],
            \['▷ change working directory',
            \'Unite -default-action=lcd directory'],
            \['▷ know current working directory',
            \'Unite output:pwd'],
            \['▷ junk files                                                 ⌘ ,d',
            \'Unite junkfile/new junkfile'],
            \['▷ save as root                                               ⌘ :w!!',
            \'exe "write !sudo tee % >/dev/null"'],
            \['▷ quick save                                                 ⌘ ,w',
            \'normal ,w'],
            \['▷ open ranger                                                                           ⌘ ,x',
            \'call RangerChooser()'],
            \['▷ open vimfiler                                              ⌘ ,X',
            \'VimFiler'],
            \]
nnoremap <silent>[menu]o :Unite -silent -winheight=17 -start-insert
            \ menu:files<CR>
" }}}

" file searching menu {{{
let g:unite_source_menu_menus.grep = {
            \ 'description' : '           search files
            \                             ⌘ [space]a',
            \}
let g:unite_source_menu_menus.grep.command_candidates = [
            \['▷ search line                                                            ⌘ ',
            \'Unite -auto-preview -start-insert line'],
            \['▷ grep (ag → ack → grep)                                                 ⌘ ,a',
            \'Unite -auto-preview -winheight=25 -no-quit grep'],
            \['▷ grep current word                                                      ⌘ ,A',
            \'UniteWithCursorWord -auto-preview -winheight=25 -no-quit grep'],
            \['▷ search word under the cursor in current buffer                         ⌘ ',
            \'UniteWithCursorWord -no-split -auto-preview line'],
            \['▷ search outlines & tags (ctags)                                         ⌘ ,c',
            \'Unite -vertical -winwidth=25 -start-insert -direction=topleft -toggle outline'],
            \['▷ search marks                                                           ⌘ ,k',
            \'Unite -auto-preview -winheight=25 mark'],
            \['▷ find                                                                   ⌘ ',
            \'Unite find'],
            \['▷ locate',
            \'Unite -start-insert locate'],
            \['▷ vimgrep (very slow)',
            \'Unite vimgrep'],
            \['▷ trigger easymotion               (easymotion)                          ⌘ ,,',
            \''],
            \]
nnoremap <silent>[menu]a :Unite -silent -winheight=12 -start-insert menu:grep<CR>
" }}}

" buffers, tabs & windows menu {{{
let g:unite_source_menu_menus.navigation = {
            \ 'description' : '           navigate by buffers, tabs & windows
            \                             ⌘ [space]b',
            \}
let g:unite_source_menu_menus.navigation.command_candidates = [
            \['▷ buffers                                                    ⌘ ,b',
            \'Unite buffer'],
            \['▷ tabs                                                       ⌘ ,B',
            \'Unite tab'],
            \['▷ windows',
            \'Unite window'],
            \['▷ location list',
            \'Unite location_list'],
            \['▷ quickfix',
            \'Unite quickfix'],
            \['▷ resize windows                                             ⌘ C-C C-W',
            \'WinResizerStartResize'],
            \['▷ new vertical window                                        ⌘ ,v',
            \'vsplit'],
            \['▷ new horizontal window                                      ⌘ ,h',
            \'split'],
            \['▷ close current window                                       ⌘ ,k',
            \'close'],
            \['▷ toggle quickfix window                                     ⌘ ,q',
            \'normal ,q'],
            \['▷ zoom                                                       ⌘ ,z',
            \'ZoomWinTabToggle'],
            \['▷ delete buffer                                              ⌘ ,K',
            \'bd'],
            \]
nnoremap <silent>[menu]b :Unite -silent menu:navigation<CR>
" }}}

" buffer internal searching menu {{{
let g:unite_source_menu_menus.searching = {
            \ 'description' : '          searchs inside the current buffer
            \                            ⌘ [space]f',
            \}
let g:unite_source_menu_menus.searching.command_candidates = [
            \['▷ search line                                                ⌘ ,f',
            \'Unite -auto-preview -start-insert line'],
            \['▷ search word under the cursor                               ⌘ [space]8',
            \'UniteWithCursorWord -no-split -auto-preview line'],
            \['▷ search outlines & tags (ctags)                             ⌘ ,t',
            \'Unite -vertical -winwidth=40 -direction=topleft -toggle outline'],
            \['▷ search marks',
            \'Unite -auto-preview mark'],
            \['▷ search folds',
            \'Unite -vertical -winwidth=30 -auto-highlight fold'],
            \['▷ search changes',
            \'Unite change'],
            \['▷ search jumps',
            \'Unite jump'],
            \['▷ search undos',
            \'Unite undo'],
            \['▷ search tasks                                               ⌘ ,;',
            \'Unite -toggle grep:%::FIXME|TODO|NOTE|XXX|COMBAK|@todo'],
            \]
nnoremap <silent>[menu]f :Unite -silent menu:searching<CR>
" }}}

" yanks, registers & history menu {{{
let g:unite_source_menu_menus.registers = {
            \ 'description' : '          yanks, registers & history
            \                            ⌘ [space]i',
            \}
let g:unite_source_menu_menus.registers.command_candidates = [
            \['▷ yanks                                                      ⌘ ,i',
            \'Unite history/yank'],
            \['▷ commands       (history)                                   ⌘ q:',
            \'Unite history/command'],
            \['▷ searches       (history)                                   ⌘ q/',
            \'Unite history/search'],
            \['▷ registers',
            \'Unite register'],
            \['▷ messages',
            \'Unite output:messages'],
            \['▷ undo tree      (Undotree)                                  ⌘ ,u',
            \'UndotreeToggle'],
            \]
nnoremap <silent>[menu]i :Unite -silent menu:registers<CR>
" }}}

" spelling menu {{{
let g:unite_source_menu_menus.spelling = {
            \ 'description' : '          spell checking
            \                            ⌘ [space]s',
            \}
let g:unite_source_menu_menus.spelling.command_candidates = [
            \['▷ spell checking in English                                  ⌘ ,se',
            \'setlocal spell spelllang=en'],
            \['▷ turn off spell checking                                    ⌘ ,so',
            \'setlocal nospell'],
            \['▷ jumps to next bad spell word and show suggestions          ⌘ ,sc',
            \'normal ,sc'],
            \['▷ jumps to next bad spell word                               ⌘ ,sn',
            \'normal ,sn'],
            \['▷ suggestions                                                ⌘ ,sp',
            \'normal ,sp'],
            \['▷ add word to dictionary                                     ⌘ ,sa',
            \'normal ,sa'],
            \]
nnoremap <silent>[menu]s :Unite -silent menu:spelling<CR>
" }}}

" text edition menu {{{
let g:unite_source_menu_menus.text = {
            \ 'description' : '          text edition
            \                            ⌘ [space]e',
            \}
let g:unite_source_menu_menus.text.command_candidates = [
            \['▷ toggle search results highlight                            ⌘ ,eq',
            \'set invhlsearch'],
            \['▷ toggle line numbers                                        ⌘ ,l',
            \'call ToggleRelativeAbsoluteNumber()'],
            \['▷ toggle wrapping                                            ⌘ ,ew',
            \'call ToggleWrap()'],
            \['▷ toggle auto-completion state (manual → disabled → auto)    ⌘ ,ea',
            \'call ToggleNeoCompleteAutoSelect()'],
            \['▷ show hidden chars                                          ⌘ ,eh',
            \'set list!'],
            \['▷ toggle fold                                                ⌘ /',
            \'normal za'],
            \['▷ open all folds                                             ⌘ zR',
            \'normal zR'],
            \['▷ close all folds                                            ⌘ zM',
            \'normal zM'],
            \['▷ copy to the clipboard                                      ⌘ ,y',
            \'normal ,y'],
            \['▷ paste from the clipboard                                   ⌘ ,p',
            \'normal ,p'],
            \['▷ toggle paste mode                                          ⌘ ,P',
            \'normal ,P'],
            \['▷ remove trailing whitespaces                                ⌘ ,et',
            \'normal ,et'],
            \['▷ text statistics                                            ⌘ ,es',
            \'Unite output:normal\ ,es -no-cursor-line'],
            \['▷ show word frequency                                        ⌘ ,ef',
            \'Unite output:WordFrequency'],
            \['▷ show available digraphs',
            \'digraphs'],
            \['▷ insert lorem ipsum text',
            \'exe "Loremipsum" input("number of words: ")'],
            \['▷ show current char info                                     ⌘ ga',
            \'normal ga'],
            \['▷ multiple-cursors: next               (vim-multiple-cursors)            ⌘ <C-n>',
            \'normal <C-n>'],
            \['▷ multiple-cursors: prev               (vim-multiple-cursors)            ⌘ <C-p>',
            \'normal <C-p>'],
            \['▷ multiple-cursors: skip               (vim-multiple-cursors)            ⌘ <C-x>',
            \'normal <C-x>'],
            \['▷ toggle surround in visualmode        (surround)                        ⌘ S',
            \'visual S'],
            \['▷ add surroundings in visualmode       (surround)                        ⌘ ys',
            \''],
            \['▷ change surroundings in visualmode    (surround)                        ⌘ cs',
            \''],
            \['▷ delete surroundings in visualmode    (surround)                        ⌘ ds',
            \''],
            \]
nnoremap <silent>[menu]e :Unite -silent -winheight=20 menu:text <CR>
" }}}

" neobundle menu {{{
let g:unite_source_menu_menus.neobundle = {
            \ 'description' : '          plugins administration with neobundle
            \                            ⌘ [space]n',
            \}
let g:unite_source_menu_menus.neobundle.command_candidates = [
            \['▷ neobundle',
            \'Unite neobundle'],
            \['▷ neobundle log',
            \'Unite neobundle/log'],
            \['▷ neobundle lazy',
            \'Unite neobundle/lazy'],
            \['▷ neobundle update',
            \'Unite neobundle/update'],
            \['▷ neobundle search',
            \'Unite neobundle/search'],
            \['▷ neobundle install',
            \'Unite neobundle/install'],
            \['▷ neobundle check',
            \'Unite -no-empty output:NeoBundleCheck'],
            \['▷ neobundle docs',
            \'Unite output:NeoBundleDocs'],
            \['▷ neobundle clean',
            \'NeoBundleClean'],
            \['▷ neobundle rollback',
            \'exe "NeoBundleRollback" input("plugin: ")'],
            \['▷ neobundle list',
            \'Unite output:NeoBundleList'],
            \['▷ neobundle direct edit',
            \'NeoBundleExtraEdit'],
            \]
nnoremap <silent>[menu]n :Unite -silent -start-insert menu:neobundle<CR>
" }}}

" git menu {{{
let g:unite_source_menu_menus.git = {
            \ 'description' : '          admin git repositories
            \                            ⌘ [space]g',
            \}
let g:unite_source_menu_menus.git.command_candidates = [
            \['▷ tig                                                        ⌘ ,gt',
            \'normal ,gt'],
            \['▷ git viewer             (gitv)                              ⌘ ,gv',
            \'normal ,gv'],
            \['▷ git viewer - buffer    (gitv)                              ⌘ ,gV',
            \'normal ,gV'],
            \['▷ git status             (fugitive)                          ⌘ ,gs',
            \'Gstatus'],
            \['▷ git diff               (fugitive)                          ⌘ ,gd',
            \'Gdiff'],
            \['▷ git commit             (fugitive)                          ⌘ ,gc',
            \'Gcommit'],
            \['▷ git log                (fugitive)                          ⌘ ,gl',
            \'exe "silent Glog | Unite -no-quit quickfix"'],
            \['▷ git log - all          (fugitive)                          ⌘ ,gL',
            \'exe "silent Glog -all | Unite -no-quit quickfix"'],
            \['▷ git blame              (fugitive)                          ⌘ ,gb',
            \'Gblame'],
            \['▷ git add/stage          (fugitive)                          ⌘ ,gw',
            \'Gwrite'],
            \['▷ git checkout           (fugitive)                          ⌘ ,go',
            \'Gread'],
            \['▷ git rm                 (fugitive)                          ⌘ ,gR',
            \'Gremove'],
            \['▷ git mv                 (fugitive)                          ⌘ ,gm',
            \'exe "Gmove " input("destino: ")'],
            \['▷ git push               (fugitive, buffer output)           ⌘ ,gp',
            \'Git! push'],
            \['▷ git pull               (fugitive, buffer output)           ⌘ ,gP',
            \'Git! pull'],
            \['▷ git command            (fugitive, buffer output)           ⌘ ,gi',
            \'exe "Git! " input("comando git: ")'],
            \['▷ git edit               (fugitive)                          ⌘ ,gE',
            \'exe "command Gedit " input(":Gedit ")'],
            \['▷ git grep               (fugitive)                          ⌘ ,gg',
            \'exe "silent Ggrep -i ".input("Pattern: ") | Unite -no-quit quickfix'],
            \['▷ git grep - messages    (fugitive)                          ⌘ ,ggm',
            \'exe "silent Glog --grep=".input("Pattern: ")." | Unite -no-quit quickfix"'],
            \['▷ git grep - text        (fugitive)                          ⌘ ,ggt',
            \'exe "silent Glog -S".input("Pattern: ")." | Unite -no-quit quickfix"'],
            \['▷ git init                                                   ⌘ ,gn',
            \'Unite output:echo\ system("git\ init")'],
            \['▷ git cd                 (fugitive)',
            \'Gcd'],
            \['▷ git lcd                (fugitive)',
            \'Glcd'],
            \['▷ git browse             (fugitive)                          ⌘ ,gB',
            \'Gbrowse'],
            \['▷ github dashboard       (github-dashboard)                  ⌘ ,gD',
            \'exe "GHD! " input("Username: ")'],
            \['▷ github activity        (github-dashboard)                  ⌘ ,gA',
            \'exe "GHA! " input("Username or repository: ")'],
            \['▷ github issues & PR                                         ⌘ ,gS',
            \'normal ,gS'],
            \]
nnoremap <silent>[menu]g :Unite -silent -winheight=29 -start-insert menu:git<CR>
" }}}

" code menu {{{
let g:unite_source_menu_menus.code = {
            \ 'description' : '          code tools
            \                            ⌘ [space]p',
            \}
let g:unite_source_menu_menus.code.command_candidates = [
            \['▷ run python code                            (pymode)        ⌘ ,r',
            \'PymodeRun'],
            \['▷ show docs for the current word             (pymode)        ⌘ K',
            \'normal K'],
            \['▷ insert a breakpoint                        (pymode)        ⌘ ,B',
            \'normal ,B'],
            \['▷ pylint check                               (pymode)        ⌘ ,n',
            \'PymodeLint'],
            \['▷ run with python2 in tmux panel             (vimux)         ⌘ ,rr',
            \'normal ,rr'],
            \['▷ run with python3 in tmux panel             (vimux)         ⌘ ,r3',
            \'normal ,r3'],
            \['▷ run with python2 & time in tmux panel      (vimux)         ⌘ ,rt',
            \'normal ,rt'],
            \['▷ run with pypy & time in tmux panel         (vimux)         ⌘ ,rp',
            \'normal ,rp'],
            \['▷ command prompt to run in a tmux panel      (vimux)         ⌘ ,rc',
            \'VimuxPromptCommand'],
            \['▷ repeat last command                        (vimux)         ⌘ ,rl',
            \'VimuxRunLastCommand'],
            \['▷ stop command execution in tmux panel       (vimux)         ⌘ ,rs',
            \'VimuxInterruptRunner'],
            \['▷ inspect tmux panel                         (vimux)         ⌘ ,ri',
            \'VimuxInspectRunner'],
            \['▷ close tmux panel                           (vimux)         ⌘ ,rq',
            \'VimuxCloseRunner'],
            \['▷ sort imports                               (isort)',
            \'Isort'],
            \['▷ go to definition                           (pymode-rope)   ⌘ C-C g',
            \'call pymode#rope#goto_definition()'],
            \['▷ find where a function is used              (pymode-rope)   ⌘ C-C f',
            \'call pymode#rope#find_it()'],
            \['▷ show docs for current word                 (pymode-rope)   ⌘ C-C d',
            \'call pymode#rope#show_doc()'],
            \['▷ reorganize imports                         (pymode-rope)   ⌘ C-C r o',
            \'call pymode#rope#organize_imports()'],
            \['▷ refactorize - rename                       (pymode-rope)   ⌘ C-C r r',
            \'call pymode#rope#rename()'],
            \['▷ refactorize - inline                       (pymode-rope)   ⌘ C-C r i',
            \'call pymode#rope#inline()'],
            \['▷ refactorize - move                         (pymode-rope)   ⌘ C-C r v',
            \'call pymode#rope#move()'],
            \['▷ refactorize - use function                 (pymode-rope)   ⌘ C-C r u',
            \'call pymode#rope#use_function()'],
            \['▷ refactorize - change signature             (pymode-rope)   ⌘ C-C r s',
            \'call pymode#rope#signature()'],
            \['▷ refactorize - rename current module        (pymode-rope)   ⌘ C-C r 1 r',
            \'PymodeRopeRenameModule'],
            \['▷ refactorize - module to package            (pymode-rope)   ⌘ C-C r 1 p',
            \'PymodeRopeModuleToPackage'],
            \['▷ syntastic toggle                           (syntastic)',
            \'SyntasticToggleMode'],
            \['▷ syntastic check & errors                   (syntastic)     ⌘ ,N',
            \'normal ,N'],
            \['▷ list virtualenvs                           (virtualenv)',
            \'Unite output:VirtualEnvList'],
            \['▷ activate virtualenv                        (virtualenv)',
            \'VirtualEnvActivate'],
            \['▷ deactivate virtualenv                      (virtualenv)',
            \'VirtualEnvDeactivate'],
            \['▷ run coverage2                              (coveragepy)',
            \'call system("coverage2 run ".bufname("%")) | Coveragepy report'],
            \['▷ run coverage3                              (coveragepy)',
            \'call system("coverage3 run ".bufname("%")) | Coveragepy report'],
            \['▷ toggle coverage report                     (coveragepy)',
            \'Coveragepy session'],
            \['▷ toggle coverage marks                      (coveragepy)',
            \'Coveragepy show'],
            \['▷ coffeewatch                                (coffeescript)  ⌘ ,rw',
            \'CoffeeWatch vert'],
            \['▷ count lines of code',
            \'Unite -default-action= output:call\\ LinesOfCode()'],
            \['▷ toggle indent lines                                        ⌘ ,L',
            \'IndentLinesToggle'],
            \]
nnoremap <silent>[menu]p :Unite -silent -winheight=42 menu:code<CR>
" }}}

" markdown menu {{{
let g:unite_source_menu_menus.markdown = {
            \ 'description' : '          preview markdown extra docs
            \                            ⌘ [space]k',
            \}
let g:unite_source_menu_menus.markdown.command_candidates = [
            \['▷ preview',
            \'Me'],
            \['▷ refresh',
            \'Mer'],
            \]
nnoremap <silent>[menu]k :Unite -silent menu:markdown<CR>
" }}}

" reST menu {{{
let g:unite_source_menu_menus.rest = {
            \ 'description' : '         reStructuredText
            \                           ⌘ [space]r',
            \}
let g:unite_source_menu_menus.rest.command_candidates = [
            \['▷ CheatSheet',
            \'RivCheatSheet'],
            \['▷ reStructuredText Specification',
            \'RivSpecification'],
            \]
nnoremap <silent>[menu]r :Unite -silent menu:rest<CR>
" }}}

" bookmarks menu {{{
let g:unite_source_menu_menus.bookmarks = {
            \ 'description' : '         bookmarks
            \                           ⌘ [space]m',
            \}
let g:unite_source_menu_menus.bookmarks.command_candidates = [
            \['▷ open bookmarks',
            \'Unite bookmark:*'],
            \['▷ add bookmark',
            \'UniteBookmarkAdd'],
            \]
nnoremap <silent>[menu]m :Unite -silent menu:bookmarks<CR>
" }}}

" colorv menu {{{
function! GetColorFormat()
    let formats = {'r' : 'RGB',
                \'n' : 'NAME',
                \'s' : 'HEX',
                \'ar': 'RGBA',
                \'pr': 'RGBP',
                \'pa': 'RGBAP',
                \'m' : 'CMYK',
                \'l' : 'HSL',
                \'la' : 'HSLA',
                \'h' : 'HSV',
                \}
    let formats_menu = ["\n"]
    for [k, v] in items(formats)
        call add(formats_menu, "  ".k."\t".v."\n")
    endfor
    let fsel = get(formats, input('Choose a format: '.join(formats_menu).'? '))
    return fsel
endfunction

function! GetColorMethod()
    let methods = {
                \'h' : 'Hue',
                \'s' : 'Saturation',
                \'v' : 'Value',
                \'m' : 'Monochromatic',
                \'a' : 'Analogous',
                \'3' : 'Triadic',
                \'4' : 'Tetradic',
                \'n' : 'Neutral',
                \'c' : 'Clash',
                \'q' : 'Square',
                \'5' : 'Five-Tone',
                \'6' : 'Six-Tone',
                \'2' : 'Complementary',
                \'p' : 'Split-Complementary',
                \'l' : 'Luma',
                \'g' : 'Turn-To',
                \}
    let methods_menu = ["\n"]
    for [k, v] in items(methods)
        call add(methods_menu, "  ".k."\t".v."\n")
    endfor
    let msel = get(methods, input('Choose a method: '.join(methods_menu).'? '))
    return msel
endfunction

let g:unite_source_menu_menus.colorv = {
            \ 'description' : '        color management
            \                          ⌘ [space]c',
            \}
let g:unite_source_menu_menus.colorv.command_candidates = [
            \['▷ open colorv                                                ⌘ ,cv',
            \'ColorV'],
            \['▷ open colorv with the color under the cursor                ⌘ ,cw',
            \'ColorVView'],
            \['▷ preview colors                                             ⌘ ,cpp',
            \'ColorVPreview'],
            \['▷ color picker                                               ⌘ ,cd',
            \'ColorVPicker'],
            \['▷ edit the color under the cursor                            ⌘ ,ce',
            \'ColorVEdit'],
            \['▷ edit the color under the cursor (and all the concurrences) ⌘ ,cE',
            \'ColorVEditAll'],
            \['▷ insert a color                                             ⌘ ,cii',
            \'exe "ColorVInsert " .GetColorFormat()'],
            \['▷ color list relative to the current                         ⌘ ,cgh',
            \'exe "ColorVList " .GetColorMethod() "
            \ ".input("number of colors? (optional): ")
            \ " ".input("number of steps?  (optional): ")'],
            \['▷ show colors list (Web W3C colors)                          ⌘ ,cn',
            \'ColorVName'],
            \['▷ choose color scheme (ColourLovers, Kuler)                  ⌘ ,css',
            \'ColorVScheme'],
            \['▷ show favorite color schemes                                ⌘ ,csf',
            \'ColorVSchemeFav'],
            \['▷ new color scheme                                           ⌘ ,csn',
            \'ColorVSchemeNew'],
            \['▷ create hue gradation between two colors',
            \'exe "ColorVTurn2 " " ".input("Color 1 (hex): ")
            \" ".input("Color 2 (hex): ")'],
            \]
nnoremap <silent>[menu]c :Unite -silent menu:colorv<CR>
" }}}

" vim menu {{{
let g:unite_source_menu_menus.vim = {
            \ 'description' : '            vim
            \                              ⌘ [space]v',
            \}
let g:unite_source_menu_menus.vim.command_candidates = [
            \['▷ choose colorscheme',
            \'Unite colorscheme -auto-preview'],
            \['▷ mappings',
            \'Unite mapping -start-insert'],
            \['▷ edit configuration file (vimrc)',
            \'edit $MYVIMRC'],
            \['▷ choose filetype',
            \'Unite -start-insert filetype'],
            \['▷ vim help',
            \'Unite -start-insert help'],
            \['▷ vim commands',
            \'Unite -start-insert command'],
            \['▷ vim functions',
            \'Unite -start-insert function'],
            \['▷ vim runtimepath',
            \'Unite -start-insert runtimepath'],
            \['▷ vim command output',
            \'Unite output'],
            \['▷ unite sources',
            \'Unite source'],
            \['▷ kill process',
            \'Unite -default-action=sigkill -start-insert process'],
            \['▷ launch executable (dmenu like)',
            \'Unite -start-insert launcher'],
            \]
nnoremap <silent>[menu]v :Unite menu:vim -silent -start-insert<CR>
" }}}

let g:unite_source_menu_menus.tabularize = {
            \ 'description' : '     tabularize
            \                       ⌘ <Space>a',
            \}
let g:unite_source_menu_menus.tabularize.command_candidates = [
            \['▷ Tabularize &                                               ⌘ <Space>&',
            \'Tabularize /&'],
            \['▷ Tabularize =                                               ⌘ <Space>=',
            \'Tabularize /='],
            \['▷ Tabularize :                                               ⌘ <Space>:',
            \'Tabularize /:'],
            \['▷ Tabularize ::                                              ⌘ <Space>::',
            \'Tabularize /:\zs'],
            \['▷ Tabularize ,                                               ⌘ <Space>,',
            \'Tabularize /,'],
            \['▷ Tabularize ,,                                              ⌘ <Space>,,',
            \'Tabularize /,\zs'],
            \['▷ Tabularize <Bar>                                           ⌘ <Space><Bar>',
            \'Tabularize /<Bar>'],
            \]
nnoremap <silent>[menu]t :Unite menu:tabularize<CR>
" }}}

if count(s:settings.plugin_groups, 'indents') "{{{
    NeoBundle 'nathanaelkane/vim-indent-guides' "{{{
    let g:indent_guides_start_level=1
    let g:indent_guides_guide_size=1
    let g:indent_guides_enable_on_vim_startup=0
    let g:indent_guides_color_change_percent=3
    if !has('gui_running')
        let g:indent_guides_auto_colors=0
        function! s:indent_set_console_colors()
            hi IndentGuidesOdd ctermbg=235
            hi IndentGuidesEven ctermbg=236
        endfunction
        autocmd VimEnter,Colorscheme * call s:indent_set_console_colors()
    endif
    "}}}
endif "}}}

if count(s:settings.plugin_groups, 'textobj') "{{{
    NeoBundle 'kana/vim-textobj-user'
    NeoBundle 'kana/vim-textobj-indent'
    NeoBundle 'kana/vim-textobj-entire'
    NeoBundle 'lucapette/vim-textobj-underscore'
endif "}}}

if count(s:settings.plugin_groups, 'misc') "{{{
    if exists('$TMUX')
        NeoBundle 'christoomey/vim-tmux-navigator'
        let g:tmux_navigator_no_mappings = 1
        nnoremap <silent> {Left-mapping} :TmuxNavigateLeft<cr>
        nnoremap <silent> {Down-Mapping} :TmuxNavigateDown<cr>
        nnoremap <silent> {Up-Mapping} :TmuxNavigateUp<cr>
        nnoremap <silent> {Right-Mapping} :TmuxNavigateRight<cr>
        nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>
        let g:tmux_navigator_save_on_switch = 1
        NeoBundle 'benmills/vimux'
        NeoBundleLazy 'vimez/vim-tmux', { 'autoload' : { 'filetypes' : 'conf'}}
    endif
    NeoBundle 'kana/vim-vspec'
    NeoBundleLazy 'tpope/vim-scriptease', {'autoload':{'filetypes':['vim']}}
    NeoBundleLazy 'tpope/vim-markdown', {'autoload':{'filetypes':['markdown']}}
    if executable('redcarpet') && executable('instant-markdown-d')
        NeoBundleLazy 'suan/vim-instant-markdown', {'autoload':{'filetypes':['markdown']}}
    endif
    NeoBundleLazy 'guns/xterm-color-table.vim', {'autoload':{'commands':'XtermColorTable'}}
    NeoBundle 'chrisbra/vim_faq'
    NeoBundle 'vimwiki'
    NeoBundle 'amilaperera/bufkill.vim'
    NeoBundle 'yssl/autocwd.vim'
    NeoBundle 'pbrisbin/vim-mkdir'
    NeoBundle 'moll/vim-bbye'
    nnoremap <Leader>q :Bdelete<CR>
    "command! -bang -complete=buffer -nargs=? Bclose Bdelete<bang> <args>
    NeoBundle 'mhinz/vim-startify' "{{{
    let g:startify_session_dir=s:get_cache_dir('sessions')
    let g:startify_change_to_vcs_root=1
    let g:startify_show_sessions=0
    let g:startify_restore_position=0
    let g:startify_custom_header=map(split(system('fortune'), '\n'), '"   ". v:val') + ['']
    let g:startify_list_order=[
                \ ['=== Recent files:'], 'files',
                \ ['=== Last modified files in: ' . getcwd() ], 'dir',
                \ ['=== Sessions:'], 'sessions',
                \ ['=== Bookmarks:'], 'bookmarks',
                \ ]
    let g:startify_bookmarks = [
                \ '~/Documents/script',
                \ '~/Documents/tank',
                \ '~/Documents/tecmint',
                \ '~/Documents/bash',
                \ '~/.vim/vimrc',
                \ '~/Documents/notes/vim/vimfiler',
                \ '~/.zshrc',
                \ ]
    let g:startify_skiplist = [
                \ 'COMMIT_EDITMSG',
                \ expand($VIMRUNTIME) . '/doc',
                \ expand($VIMFILES) . 'bundle/.*/doc',
                \ ]
    let g:startify_files_number=20
    let g:startify_relative_path=1
    let g:startify_enable_special=0
    let g:startify_change_to_dir=0
    let g:startify_session_autoload=0
    let g:startify_change_to_vcs_root=1
    let g:startify_session_persistence=1
    let g:startify_disable_at_vimenter=0
    nnoremap <leader>7 :Startify<cr>
    "}}}
    NeoBundle 'scrooloose/syntastic' "{{{
    let g:syntastic_error_symbol='✗'
    let g:syntastic_style_error_symbol='✠'
    let g:syntastic_warning_symbol='∆'
    "}}}
    NeoBundle 'vim-scripts/vim-auto-save' "{{{
    let g:auto_save=0 " enable AutoSave on Vim startup 1
    let g:auto_save_in_insert_mode=0 " do not save while in insert mode
    "let g:auto_save_no_updatetime=1 " do not change the 'updatetime' option
    "let g:auto_save_silent = 1 " do not display the auto-save notification
    let g:syntastic_style_warning_symbol = '≈'
    noremap <leader>1  :AutoSaveToggle<cr>
    "}}}
    NeoBundle 'phongvcao/vim-stardict' "{{{
    let g:stardict_split_horizontal=1
    let g:stardict_split_size=20
    let g:stardict_prefer_python3=0
    nnoremap <leader>hh :StarDict<Space>
    nnoremap <leader>h :StarDictCursor<CR>
    set keywordprg=~/.local/bin/trans\ :tr+en " https://github.com/soimort/translate-shell - Shift-k
    autocmd FileType vim nnoremap <buffer> K :r! '~/.local/bin/trans\ :tr+en ' . expand("<cword>")<cr>
    "}}}
    NeoBundle 'szw/vim-ctrlspace' "{{{
    if isdirectory($HOME . '/.vim/.cache/ctrlspace') == 0
        silent !mkdir -p ~/.vim/.cache/ctrlspace >/dev/null 2>&1
    endif
    let g:ctrlspace_cache_dir=s:get_cache_dir('ctrlspace')
    let g:ctrlspace_save_workspace_on_exit=1 " save workspace on exit
    let g:ctrlspace_save_workspace_on_switch=0 " save workspace on switch
    let g:ctrlspace_load_last_workspace_on_start=0 " load last workspace on start"
    let g:ctrlspace_show_unnamed=0
    let g:ctrlspace_show_key_info=1
    let g:airline_exclude_preview=1
    let g:ctrlspace_ignored_files='\v(tmp|temp|dist|build)[\/]'
    let g:ctrlspace_use_ruby_bindings=has("ruby")
    set showtabline=1
    set wildmode=list:longest,list:full
    set wildignore+=*/tmp/*,*.o,*.obj,.git,*.rbc,*.mp3,*.flac,*.avi,*.svg,*.jpg,*.png,*.so,*.a,*.swp,*.zip,*.pyc,*.pyo,*.classh,__pycache__
    if executable("ag")
        let g:ctrlspace_glob_command = "ag --vimgrep '"+ g:ctrlspace_ignored_files +"'"
    endif
    "}}}
    NeoBundleLazy 'mattn/gist-vim', { 'depends': 'mattn/webapi-vim', 'autoload': { 'commands': 'Gist' } } "{{{
    let g:gist_post_private=1
    let g:gist_show_privates=1
    "}}}
    NeoBundleLazy 'Shougo/vimshell.vim', {'autoload':{'commands':[ 'VimShell', 'VimShellInteractive' ]}} "{{{
    let g:vimshell_editor_command='vim'
    let g:vimshell_right_prompt='getcwd()'
    let g:vimshell_data_directory=s:get_cache_dir('vimshell')
    let g:vimshell_vimshrc_path='~/.vim/vimshrc'
    let g:vimshell_prompt='❯ '
    let g:vimshell_enable_transient_user_prompt=1
    let g:vimshell_external_history_path=expand('~/.zsh-history')
    nnoremap <leader>c :VimShell -split<cr>
    nnoremap <leader>cc :VimShell -split<cr>
    nnoremap <leader>cp :VimShellInteractive python<cr>
    "}}}
    NeoBundle 'ntpeters/vim-better-whitespace' "{{{
    ""Vim Better Whitespace Plugin
    highlight ExtraWhitespace ctermbg=yellow
    nnoremap <silent> <leader>0 :StripWhitespace<CR>
    "}}}
    NeoBundleLazy 'zhaocai/GoldenView.Vim', {'autoload':{'mappings':['<Plug>ToggleGoldenViewAutoResize']}} "{{{
    let g:goldenview_enable_at_startup=0
    let g:goldenview__enable_default_mapping=0
    nmap <F4> <Plug>ToggleGoldenViewAutoResize
    nmap <silent> <C-g>  <Plug>GoldenViewSplit
    "}}}
    NeoBundle 'thinca/vim-quickrun' "{{{
    " Vim plugin to execute whole/part of editing file and show the result.
    " <leader>r
    "}}}
    NeoBundle 'idbrii/vim-mark' "{{{
    let g:mark_no_mappings=1
    "}}}
    NeoBundle 'asins/renamer.vim' "{{{
    "}}}
    NeoBundle 'vim-scripts/LargeFile' "{{{
    " Edit large files quickly - g:LargeFile (by default, its 100)
    "}}}
    NeoBundle 'vim-scripts/utl.vim' "{{{
    "}}}
    NeoBundle 'myusuf3/numbers.vim' "{{{
    let g:numbers_exclude = ['unite', 'tagbar', 'vimfiler', 'startify', 'undotree', 'vimshell', 'vim-stardict']
    let g:enable_numbers = 0
    "nnoremap <silent> <leader>3 :NumbersToggle<CR>
    "autocmd FocusLost * :set number
    "autocmd FocusGained * :set relativenumber
    "autocmd InsertEnter * :set number
    "autocmd InsertLeave * :set relativenumber
    "}}}
    "NeoBundle 'dhruvasagar/vim-prosession', {'depends': 'tpope/vim-obsession'} "{{{
    "let g:prosession_dir=s:get_cache_dir('sessions')
    "let g:loaded_prosession=0
    "let g:prosession_on_startup=0
    "}}}
    NeoBundle 'xolox/vim-reload', {'depends': 'xolox/vim-misc'} "{{{
    let g:reload_on_write = 1
    "}}}
    NeoBundle 'fmoralesc/vim-pad' "{{{
    let g:pad#dir="~/Documents/notes/"
    let g:pad#default_format = "vim-notes"
    let g:pad#search_backend = "ag"
    let g:pad#open_in_split=0
    let g:pad#position=["list"]
    let g:pad#window_height=30
    let g:pad#window_width=50
    nmap <localleader>ll <Plug>(pad-list)
    "}}}
    NeoBundle 'xolox/vim-notes' "{{{
    let g:notes_directories = ['~/Documents/notes']
    let g:notes_suffix = ''
    "}}}
    NeoBundle 'fmoralesc/vim-tutor-mode' "{{{
    "}}}
    NeoBundle 'fmoralesc/vim-autogit' "{{{
    let b:autogit_enabled=1
    "}}}
    NeoBundle 'tth/scratch.vim' "{{{
    let g:scratch_insert_autohide=1
    nmap <F2> :Scratch<CR>
    nmap <F3> :ScratchPreview<CR>
    "}}}
    NeoBundle 'junegunn/fzf' "{{{
    command! -nargs=1 Locate call fzf#run(
                \ {'source': 'locate <q-args>', 'sink': 'tabe', 'options': '-m +c', 'dir': '~', 'source': 'ls'})
    " Open files in horizontal split
    nnoremap <silent> <Leader>ü :call fzf#run({
                \   'down': '40%',
                \   'sink': 'botright split' })<CR>
    " Open files in vertical horizontal split
    nnoremap <silent> <Leader>t :call fzf#run({
                \   'right': winwidth('.') / 2,
                \   'sink':  'vertical botright split' })<CR>
    function! s:ag_to_qf(line)
        let parts = split(a:line, ':')
        return {'filename': parts[0], 'lnum': parts[1], 'col': parts[2],
                    \ 'text': join(parts[3:], ':')}
    endfunction
    function! s:ag_handler(lines)
        if len(a:lines) < 2 | return | endif
        let cmd = get({'ctrl-x': 'split',
                    \ 'ctrl-v': 'vertical split',
                    \ 'ctrl-t': 'tabe'}, a:lines[0], 'e')
        let list = map(a:lines[1:], 's:ag_to_qf(v:val)')
        let first = list[0]
        execute cmd escape(first.filename, ' %#\')
        execute first.lnum
        execute 'normal!' first.col.'|zz'
        if len(list) > 1
            call setqflist(list)
            copen
            wincmd p
        endif
    endfunction
    command! -nargs=* Ag call fzf#run({
                \ 'source':  printf('ag --nogroup --column --color "%s"',
                \                   escape(empty(<q-args>) ? '^(?=.)' : <q-args>, '"\')),
                \ 'sink*':    function('<sid>ag_handler'),
                \ 'options': '--ansi --expect=ctrl-t,ctrl-v,ctrl-x --delimiter : --nth 4.. '.
                \            '--multi --bind ctrl-a:select-all,ctrl-d:deselect-all '.
                \            '--color hl:68,hl+:110',
                \ 'down':    '50%'
                \ })
    " List of buffers
    function! s:buflist()
        redir => ls
        silent ls
        redir END
        return split(ls, '\n')
    endfunction
    function! s:bufopen(e)
        execute 'buffer' matchstr(a:e, '^[ 0-9]*')
    endfunction
    nnoremap <silent> <Leader><Enter> :call fzf#run({
                \   'source':  reverse(<sid>buflist()),
                \   'sink':    function('<sid>bufopen'),
                \   'options': '+m',
                \   'down':    len(<sid>buflist()) + 2
                \ })<CR>
    command! FZFMru call fzf#run({
                \  'source':  v:oldfiles,
                \  'sink':    'e',
                \  'options': '-m -x +s',
                \  'down':    '40%'})
    command! FZFMru call fzf#run({
                \ 'source':  reverse(s:all_files()),
                \ 'sink':    'edit',
                \ 'options': '-m -x +s',
                \ 'down':    '40%' })
    function! s:all_files()
        return extend(
                    \ filter(copy(v:oldfiles),
                    \        "v:val !~ 'fugitive:\\|NERD_tree\\|^/tmp/\\|.git/'"),
                    \ map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'))
    endfunction
    "}}}
    NeoBundle 'luochen1990/rainbow' "{{{
    let g:rainbow_active = 0 "0 if you want to enable it later via :RainbowToggle
    nnoremap <leader>2 :RainbowToggle<CR>
    let g:rainbow_conf = {
                \   'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
                \   'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
                \   'operators': '_,_',
                \   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
                \   'separately': {
                \       '*': {},
                \       'tex': {'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/']},
                \       'vim': {'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody']},
                \       'html': {'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold']},
                \       'css': 0,
                \   }
                \}
    "}}}
endif "}}}

" mappings {{{
" eval vimscript by line or visual selection {{{
nmap <silent> <leader>e :call Source(line('.'), line('.'))<CR>
vmap <silent> <leader>e :call Source(line('v'), line('.'))<CR>
"}}}

" F<> commands {{{
map <F9> :!python % <enter>
map <F10> :!./% <enter>
"}}}

" toggle paste {{{
nmap <F6> :set invpaste<CR>:set paste?<CR>
"}}}

" remap arrow keys {{{
nnoremap <left> :bprev<CR>
nnoremap <right> :bnext<CR>
nnoremap <up> :tabnext<CR>
nnoremap <down> :tabprev<CR>
"}}}

" smash escape {{{
inoremap jk <esc>
inoremap kj <esc>
"}}}

" insert a line break where the cursor is in Vim without entering into insert mode? {{{
nmap <A-m> i<CR><Esc>
"}}}

" Insert a newline without entering in insert mode {{{
nmap oo o<Esc>k
nmap OO O<Esc>j
nnoremap <leader>o o<Esc>
nnoremap <leader>O O<Esc>
"}}}

" change cursor position in insert mode {{{
inoremap <C-h> <left>
inoremap <C-l> <right>
inoremap <C-u> <C-g>u<C-u>
"}}}

if mapcheck('<space>/') == ''
    nnoremap <space>/ :vimgrep //gj **/*<left><left><left><left><left><left><left><left>
endif

" sane regex {{{
nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v
nnoremap :s/ :s/\v
" }}}

" command-line window {{{
nnoremap q: q:i
nnoremap q/ q/i
nnoremap q? q?i
" }}}

" folds {{{
nnoremap zr zr:echo &foldlevel<cr>
nnoremap zm zm:echo &foldlevel<cr>
nnoremap zR zR:echo &foldlevel<cr>
nnoremap zM zM:echo &foldlevel<cr>
" }}}

" screen line scroll {{{
nnoremap <silent> j gj
nnoremap <silent> k gk
" }}}

" auto center {{{
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz
nnoremap <silent> <C-o> <C-o>zz
nnoremap <silent> <C-i> <C-i>zz
"}}}

" reselect visual block after indent {{{
vnoremap < <gv
vnoremap > >gv
"}}}

" reselect last paste {{{
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
"}}}

" find current word in quickfix {{{
nnoremap <leader>fw :execute "vimgrep ".expand("<cword>")." %"<cr>:copen<cr>
"}}}

" find last search in quickfix {{{
nnoremap <leader>fg :execute 'vimgrep /'.@/.'/g %'<cr>:copen<cr>
"}}}

" shortcuts for windows {{{
nnoremap <leader>v <C-w>v<C-w>l
nnoremap <leader>s <C-w>s
nnoremap <leader>vsa :vert sba<cr>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
"}}}

" Tab tab {{{
nnoremap <tab> <c-w>
nnoremap <tab><tab> <c-w><c-w>
"}}}

" tab shortcuts {{{
map <leader>tn :tabnew<CR>
map <leader>tc :tabclose<CR>
"}}}

" make Y consistent with C and D. See :help Y. {{{
nnoremap Y y$
"}}}

" hide annoying quit message {{{
nnoremap <C-c> <C-c>:echo<cr>
"}}}

nnoremap <leader>w :w<cr>

" quick buffer open {{{
nnoremap gb :ls<cr>:e #
"}}}

" Clone Paragraph with {{{
noremap cp yap<S-}>p
"}}}

if neobundle#is_sourced('vim-dispatch')
    nnoremap <leader>tag :Dispatch ctags -R<cr>
endif

" general {{{
nmap <leader>l :set list! list?<cr>
nnoremap <BS> :set hlsearch! hlsearch?<cr>

map <F8> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" helpers for profiling {{{
nnoremap <silent> <leader>DD :exe ":profile start profile.log"<cr>:exe ":profile func *"<cr>:exe ":profile file *"<cr>
nnoremap <silent> <leader>DP :exe ":profile pause"<cr>
nnoremap <silent> <leader>DC :exe ":profile continue"<cr>
nnoremap <silent> <leader>DQ :exe ":profile pause"<cr>:noautocmd qall!<cr>
"}}}

" commands {{{
command! -bang Q q<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>
"}}}

" Text statistics {{{
" get the total of lines, words, chars and bytes (and for the current position)
map <leader>em g<C-G>
" }}}

" <leader>ev edits .vimrc
nnoremap <leader>ev :vsplit ~/.vim/vimrc<CR>
" <leader>sv sources .vimrc
nnoremap <leader>sv :source $MYVIMRC<CR>:echo $MYVIMRC 'reloaded'<CR>
"autocmd! BufWritePost vimrc source %
"}}}

" Toggle line numbers {{{
function! ToggleRelativeAbsoluteNumber()
    if !&number && !&relativenumber
        set number
        set norelativenumber
    elseif &number && !&relativenumber
        set nonumber
        set relativenumber
    elseif !&number && &relativenumber
        set number
        set relativenumber
    elseif &number && &relativenumber
        set nonumber
        set norelativenumber
    endif
endfunction
nnoremap <silent> <leader>3 :call ToggleRelativeAbsoluteNumber()<CR>
" }}}

" autocmd {{{
" go back to previous position of cursor if any
autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \  exe 'normal! g`"zvzz' |
            \ endif

autocmd FileType css,scss setlocal foldmethod=marker foldmarker={,}
autocmd FileType css,scss nnoremap <silent> <leader>S vi{:sort<CR>
autocmd FileType python setlocal foldmethod=indent
autocmd FileType sh setlocal foldmethod=indent
autocmd FileType markdown setlocal nolist
autocmd FileType vim setlocal fdm=indent keywordprg=:help
"}}}

" color schemes {{{
NeoBundle 'kenanpelit/seoul256.vim' "{{{
set background=dark
let g:seoul256_background=235
let s:settings.colorscheme = 'seoul256' "}}}

"Vim Scrolling Slowly - disabling parenthesis highlighting "{{{
let loaded_matchparen = 1
"}}}

" finish loading {{{
if exists('g:dotvim_settings.disabled_plugins')
    for plugin in g:dotvim_settings.disabled_plugins
        exec 'NeoBundleDisable '.plugin
    endfor
endif

call neobundle#end()
filetype plugin indent on
syntax enable
exec 'colorscheme '.s:settings.colorscheme

NeoBundleCheck
"}}}
