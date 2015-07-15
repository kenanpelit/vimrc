"*****************************************************************************
"                       __   _(_)_ __ ___  _ __ ___
"                       \ \ / / | '_ ` _ \| '__/ __|
"                        \ V /| | | | | | | | | (__
" kenp                  (_)_/ |_|_| |_| |_|_|  \___|
"*****************************************************************************
"" NeoBundle core
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
let s:settings.autocomplete_method='ycm'
let s:settings.enable_cursorcolumn=1
let s:settings.autocomplete_method='ycm'

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
    call add(s:settings.plugin_groups, 'unite')
    call add(s:settings.plugin_groups, 'autocomplete')
    call add(s:settings.plugin_groups, 'misc')

    " exclude all language-specific plugins by default
    if !exists('g:dotvim_settings.plugin_groups_exclude')
        let g:dotvim_settings.plugin_groups_exclude = ['web']
    endif

    for group in g:dotvim_settings.plugin_groups_exclude
        let i=index(s:settings.plugin_groups, group)
        if i != -1
            call remove(s:settings.plugin_groups, i)
        endif
    endfor

    if exists('g:dotvim_settings.plugin_groups_include')
        for group in g:dotvim_settings.plugin_groups_include =['python','bash']
            call add(s:settings.plugin_groups, group)
        endfor
    endif
endif

" override defaults with the ones specified in g:dotvim_settings
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
function! s:get_cache_dir(suffix) "{{{
    return resolve(expand(s:cache_dir . '/' . a:suffix))
endfunction "}}}

function! Source(begin, end) "{{{
    let lines=getline(a:begin, a:end)
    for line in lines
        execute line
    endfor
endfunction "}}}

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

function! StripTrailingWhitespace() "{{{
    call Preserve("%s/\\s\\+$//e")
endfunction "}}}

function! EnsureExists(path) "{{{
    if !isdirectory(expand(a:path))
        call mkdir(expand(a:path))
    endif
endfunction "}}}

function! CloseWindowOrKillBuffer() "{{{
    let number_of_windows_to_this_buffer = len(filter(range(1, winnr('$')), "winbufnr(v:val) == bufnr('%')"))
    " never bdelete a nerd tree
    if matchstr(expand("%"), 'NERD') == 'NERD'
        wincmd c
        return
    endif
    if number_of_windows_to_this_buffer > 1
        wincmd c
    else
        bdelete
    endif
endfunction "}}}
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
set shell=/bin/bash
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
set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮
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
set dictionary+=/home/kenan/.vim/dict/tr-words

if executable('ack')
    set grepprg=ack\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ $*
    set grepformat=%f:%l:%c:%m
endif

if executable('ag')
    set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
    set grepformat=%f:%l:%c:%m
endif

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

" Map leader to
let mapleader = "\<Space>"
let g:mapleader = "\<Space>"
nnoremap <SPACE> <Nop>
let maplocalleader = ","
set timeoutlen=600

" ui configuration {{{
set showmatch                                       "automatically highlight matching braces/brackets/etc.
set matchtime=2                                     "tens of a second to show matching parentheses
set number
set relativenumber
set lazyredraw
set laststatus=2
set noshowmode
set foldenable                                      "enable folds by default
set foldmethod=syntax                               "fold via syntax of files
set foldlevelstart=99                               "open all folds by default
let g:xml_syntax_folding=1                          "enable xml folding

set cursorline
autocmd WinLeave * setlocal nocursorline
autocmd WinEnter * setlocal cursorline
let &colorcolumn=s:settings.max_column

if exists('+colorcolumn')
    let &colorcolumn="80,".join(range(400,999),",")
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
    NeoBundle 'Shougo/vimproc.vim', {'build': {'unix': 'make -f make_unix.mak'}}
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
    nnoremap <silent> <leader>gs :Gstatus<CR>
    nnoremap <silent> <leader>gd :Gdiff<CR>
    nnoremap <silent> <leader>gc :Gcommit<CR>
    nnoremap <silent> <leader>gb :Gblame<CR>
    nnoremap <silent> <leader>gl :Glog<CR>
    nnoremap <silent> <leader>gp :Git push<CR>
    nnoremap <silent> <leader>gw :Gwrite<CR>
    nnoremap <silent> <leader>gr :Gremove<CR>
    autocmd BufReadPost fugitive://* set bufhidden=delete
    "}}}
    NeoBundleLazy 'gregsexton/gitv', {'depends':['tpope/vim-fugitive'], 'autoload':{'commands':'Gitv'}} "{{{
    nnoremap <silent> <leader>gv :Gitv<CR>
    nnoremap <silent> <leader>gV :Gitv!<CR>
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
    if s:settings.autocomplete_method == 'neocomplcache' "{{{
        NeoBundleLazy 'Shougo/neocomplcache.vim', {'autoload':{'insert':1}} "{{{
        let g:neocomplcache_enable_at_startup=1
        let g:neocomplcache_temporary_dir=s:get_cache_dir('neocomplcache')
        let g:neocomplcache_enable_fuzzy_completion=1
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
    NeoBundle 'terryma/vim-multiple-cursors'
    NeoBundle 'chrisbra/NrrwRgn'
    NeoBundleLazy 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}} "{{{
    nmap <Leader>a& :Tabularize /&<CR>
    vmap <Leader>a& :Tabularize /&<CR>
    nmap <Leader>a= :Tabularize /=<CR>
    vmap <Leader>a= :Tabularize /=<CR>
    nmap <Leader>a: :Tabularize /:<CR>
    vmap <Leader>a: :Tabularize /:<CR>
    nmap <Leader>a:: :Tabularize /:\zs<CR>
    vmap <Leader>a:: :Tabularize /:\zs<CR>
    nmap <Leader>a, :Tabularize /,<CR>
    vmap <Leader>a, :Tabularize /,<CR>
    nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
    vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
    "}}}
    NeoBundle 'jiangmiao/auto-pairs'
    NeoBundle 'justinmk/vim-sneak' "{{{
    let g:sneak#streak=1
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
    NeoBundle 'ctrlpvim/ctrlp.vim', { 'depends': 'tacahiroy/ctrlp-funky' } "{{{
    let g:ctrlp_clear_cache_on_exit=0
    let g:ctrlp_use_caching=1
    let g:ctrlp_open_new_file='rw'
    let g:ctrlp_max_height=20
    let g:ctrlp_show_hidden=1
    let g:ctrlp_follow_symlinks=1
    let g:ctrlp_max_files=20000
    let g:ctrlp_cache_dir=s:get_cache_dir('ctrlp')
    let g:ctrlp_reuse_window='startify'
    let g:ctrlp_extensions=['funky']
    set wildmode=list:longest,list:full
    set wildignore+=*/tmp/*,*.o,*.obj,.git,*.rbc,*.mp3,*.flac,*.avi,*.svg,*.jpg,*.png,*.so,*.a,*.swp,*.zip,*.pyc,*.pyo,*.classh,__pycache__
    let g:ctrlp_custom_ignore = '\Trash$\|\.git$\|\.hg$\|\.cache$\|\.svn$\|public\|\images\|
                \ \public\|system\|data\|log\|\tmp$\|\.exe$\|\.so$\|\.dat$\|\Library\|\Download\|
                \ \Music\|\Movies\|Pictures\|undo\|chromium\|\.pdf$\|\.epub$\|\.mobi$\|\.rar$\|\.png$\|
                \ \.jpg$\|\.dmg$\|\.nib$\|\.bz$\|\.gz$\|\.tar$\|\.avi\|\.mp3$\|\.flac\|\.mp4$\|\.xib$'
    "let g:ctrlp_user_command = "find %s -type f | grep -Ev '"+ g:ctrlp_custom_ignore +"'"
    if executable('ag')
        let g:ctrlp_user_command="ag %s -l --nocolor -g '"+ g:ctrlp_custom_ignore +"'"
    endif
    nmap \ [ctrlp]
    nnoremap [ctrlp] <nop>
    nnoremap [ctrlp]t :CtrlPBufTag<cr>
    nnoremap [ctrlp]T :CtrlPTag<cr>
    nnoremap [ctrlp]l :CtrlPLine<cr>
    nnoremap [ctrlp]o :CtrlPFunky<cr>
    nnoremap [ctrlp]b :CtrlPBuffer<cr>
    "}}}
    NeoBundle 'mattn/ctrlp-mark' "{{{
    "}}}
    NeoBundleLazy 'scrooloose/nerdtree', {'autoload':{'commands':['NERDTreeToggle','NERDTreeFind']}} "{{{
    let NERDTreeShowHidden=1
    let NERDTreeQuitOnOpen=0
    let NERDTreeShowLineNumbers=1
    let NERDTreeChDirMode=0
    let NERDTreeShowBookmarks=1
    let NERDTreeHighlightCursorline=1
    let NERDTreeHijackNetrw=0
    let NERDTreeWinSize=40
    let NERDTreeIgnore=['\.git','\.hg']
    let NERDTreeBookmarksFile=s:get_cache_dir('NERDTreeBookmarks')
    nnoremap <leader>9 :NERDTreeToggle<CR>
    nnoremap <F3> :NERDTreeFind<CR>
    "}}}
    NeoBundle 'jistr/vim-nerdtree-tabs' "{{{
    let g:nerdtree_tabs_open_on_gui_startup=0
    let g:nerdtree_tabs_open_on_console_startup=0
    let g:nerdtree_tabs_focus_on_files=1
    let g:nerdtree_tabs_synchronize_view=1
    let g:nerdtree_tabs_synchronize_focus=1
    let g:nerdtree_tabs_smart_startup_focus=1
    let g:nerdtree_tabs_autofind=1
    "}}}
    NeoBundle 'scrooloose/nerdcommenter' "{{{
    filetype plugin on
    let NERDMenuMode=0
    let NERDSpaceDelims=1
    nmap <leader>7 :call NERDComment(0, "toggle")<cr>
    vmap <leader>7 :call NERDComment(0, "toggle")<cr>")"
    "}}}
    NeoBundle 'Xuyuanp/nerdtree-git-plugin', {'depends': 'tpope/vim-fugitive'} "{{{
    "let g:loaded_nerdtree_fugitive=1
    let g:NERDTreeMapNextHunk=",n"
    let g:NERDTreeMapPrevHunk=",p"
    "}}}
    NeoBundle 'voronkovich/ctrlp-nerdtree.vim' "{{{
    let g:ctrlp_nerdtree_show_hidden=1
    "}}}
    NeoBundle 'rhysd/clever-f.vim' "{{{
    "}}}
    NeoBundle 'gabesoft/vim-ags' "{{{
    "}}}
    NeoBundle 'MattesGroeger/vim-bookmarks' "{{{
    let g:bookmark_sign='⚑'
    let g:bookmark_highlight_lines=0
    let g:bookmark_save_per_working_dir=0
    let g:bookmark_manage_per_buffer=1
    let g:bookmark_auto_close=1
    let g:bookmark_auto_save=1
    let g:bookmark_auto_save_file=s:get_cache_dir('bookmark')
    let g:bookmark_center=1
    let g:bookmark_no_default_key_mappings=1
    function! BookmarkMapKeys()
        nmap mm :BookmarkToggle<CR>
        nmap mi :BookmarkAnnotate<CR>
        nmap mn :BookmarkNext<CR>
        nmap mp :BookmarkPrev<CR>
        nmap ma :BookmarkShowAll<CR>
        nmap mc :BookmarkClear<CR>
        nmap mx :BookmarkClearAll<CR>
    endfunction
    function! BookmarkUnmapKeys()
        unmap mm
        unmap mi
        unmap mn
        unmap mp
        unmap ma
        unmap mc
        unmap mx
    endfunction
    autocmd BufEnter * :call BookmarkMapKeys()
    autocmd BufEnter NERD_tree_* :call BookmarkUnmapKeys()
    highlight BookmarkSign ctermbg=NONE ctermfg=1
    highlight BookmarkLine ctermbg=240 ctermfg=NONE
    highlight BookmarkAnnotationSign ctermbg=NONE ctermfg=190
    highlight BookmarkAnnotationLine ctermbg=23 ctermfg=NONE
    "}}}
    NeoBundleLazy 'majutsushi/tagbar', {'autoload':{'commands':'TagbarToggle'}} "{{{
    nnoremap <silent> <leader>6 :TagbarToggle<CR>
    "}}}
endif "}}}

if count(s:settings.plugin_groups, 'unite') "{{{
    NeoBundle 'Shougo/unite.vim' "{{{
    let bundle = neobundle#get('unite.vim')
    function! bundle.hooks.on_source(bundle)
        call unite#filters#matcher_default#use(['matcher_fuzzy'])
        call unite#filters#sorter_default#use(['sorter_rank'])
        call unite#custom#source('file_mru,file_rec,file_rec/async,grep,locate',
                    \ 'ignore_pattern', join(['\.git/', 'tmp/', 'bundle/', '.pip/',
                    \ '.mozilla/', '.thunderbird/', '.local/share/', '.local/lib/',
                    \ '.config/', '.gnome*', '.gconf/', 'Music/', 'Downloads/'], '\|'))
        call unite#custom#profile('default', 'context', {
                    \ 'start_insert': 1
                    \ })
    endfunction
    let g:unite_data_directory=s:get_cache_dir('unite')
    let g:unite_enable_start_insert=0
    let g:unite_source_history_yank_enable=1
    let g:unite_source_rec_max_cache_files=1000
    let g:unite_source_grep_default_opts="-iRHn"
    let g:unite_source_menu_menus = {}
    let g:unite_enable_short_source_mes = 0
    let g:unite_force_overwrite_statusline = 0
    let g:unite_update_time = 200

    "let g:unite_split_rule = 'botright'
    let g:unite_prompt='❯❯❯ '
    let g:unite_marked_icon='✓'

    let g:unite_source_buffer_time_format='(%d-%m-%Y %H:%M:%S) '
    let g:unite_source_file_mru_time_format='(%d-%m-%Y %H:%M:%S) '
    let g:unite_source_directory_mru_time_format='(%d-%m-%Y %H:%M:%S) '

    if executable('ag')
        let g:unite_source_grep_command='ag'
        let g:unite_source_grep_default_opts='--nocolor --line-numbers --nogroup -S -C4'
        let g:unite_source_grep_recursive_opt=''
        let g:unite_source_grep_search_word_highlight = 1
    elseif executable('ack')
        let g:unite_source_grep_command='ack'
        let g:unite_source_grep_default_opts='--no-heading --no-color -C4'
        let g:unite_source_grep_recursive_opt=''
        let g:unite_source_grep_search_word_highlight = 1
    endif

    function! s:unite_settings()
        nmap <buffer> Q <plug>(unite_exit)
        nmap <buffer> <esc> <plug>(unite_exit)
        imap <buffer> <esc> <plug>(unite_exit)
    endfunction
    autocmd FileType unite call s:unite_settings()

    nmap <space> [unite]
    nnoremap [unite] <nop>
    nmap <LocalLeader> [menu]
    nnoremap <silent>[menu]u :Unite -silent -winheight=12 menu<CR>

    nnoremap <silent> [unite]<space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec/async:! buffer file_mru bookmark<cr><c-u>
    nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec/async:!<cr><c-u>
    nnoremap <silent> [unite]e :<C-u>Unite -buffer-name=recent file_mru<cr>
    nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<cr>
    nnoremap <silent> [unite]l :<C-u>Unite -auto-resize -buffer-name=line line<cr>
    nnoremap <silent> [unite]b :<C-u>Unite -auto-resize -buffer-name=buffers buffer file_mru<cr>
    nnoremap <silent> [unite]/ :<C-u>Unite -no-quit -buffer-name=search grep:.<cr>
    nnoremap <silent> [unite]m :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
    nnoremap <silent> [unite]s :<C-u>Unite -quick-match buffer<cr>
    nnoremap <silent> [unite]ff :<C-u>UniteWithInputDirectory -toggle -auto-resize -buffer-name=files file_rec/async:!<cr><c-u>
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
    nnoremap <silent><Leader>ut :Unite -silent -vertical -winwidth=40 -direction=topleft -toggle outline<cr>
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
    NeoBundleLazy 'Shougo/unite-session', {'autoload':{'unite_sources':'session', 'commands': ['UniteSessionSave', 'UniteSessionLoad']}               }
    "}}}
    NeoBundleLazy 'osyo-manga/unite-quickfix', {'autoload':{'unite_sources': ['quickfix', 'location_list']}}
    NeoBundleLazy 'thinca/vim-unite-history', { 'autoload' : { 'unite_sources' : ['history/command', 'history/search']}}
    NeoBundleLazy 'ujihisa/unite-colorscheme', {'autoload':{'unite_sources': 'colorscheme'}}
    NeoBundleLazy 'klen/unite-radio.vim', {'autoload':{'unite_sources':'radio'}}
endif "}}}


" Session {{{
let g:unite_source_menu_menus.sessions = {
            \ 'description' : '       sessions                                              ⌘ [space]s'}
let g:unite_source_menu_menus.sessions.command_candidates = [
            \['session list', 'Unite session'],
            \['load last auto-session', 'UniteSessionLoad last.vim'],
            \['save session (default)', 'UniteSessionSave'],
            \['save session (custom)', 'exe "UniteSessionSave " input("name: ")'],
            \]
exe 'nnoremap <silent>[menu]s :Unite -silent -winheight='.(len(g:unite_source_menu_menus.sessions.command_candidates) + 2).' menu:sessions<CR>'
"}}}

" Buffers, tabs and windows operations {{{
nnoremap <silent> <leader>ub :<C-u>Unite buffer<CR>
let g:unite_source_menu_menus.navigation = {
            \ 'description' : '     navigate by buffers, tabs & windows                   ⌘ [space]b', }
let g:unite_source_menu_menus.navigation.command_candidates = [
            \['buffers                                                    ⌘ ,b', 'Unite buffer'],
            \['tabs', 'Unite tab'],
            \['windows', 'Unite window'],
            \['location list', 'Unite location_list'],
            \['quickfix', 'Unite quickfix'],
            \['new vertical window', 'vsplit'],
            \['new horizontal window', 'split'],
            \['close current window                                       ⌘ ,cw', 'close'],
            \['toggle quickfix window                                     ⌘ ,ll', 'normal ,ll'],
            \['delete buffer                                              ⌘ ,bd', 'bd'],
            \]
exe 'nnoremap <silent>[menu]b :Unite -silent -winheight='.(len(g:unite_source_menu_menus.navigation.command_candidates) + 2).' menu:navigation<CR>'
" }}}

" File's operations {{{
nnoremap <leader>uo :<C-u>Unite -no-split -start-insert file<CR>
nnoremap <leader>uO :<C-u>Unite -no-split -start-insert file_rec/async:!<CR>
nnoremap <leader>um :<C-u>Unite -no-split file_mru<CR>
let g:unite_source_menu_menus.files = {
            \ 'description' : '          files & dirs                                          ⌘ [space]o',}
let g:unite_source_menu_menus.files.command_candidates = [
            \['open file                                                  ⌘ ,uo', 'normal ,uo'],
            \['open file with recursive search                            ⌘ ,uO', 'normal ,uO'],
            \['open more recently used files                              ⌘ ,um', 'normal ,um'],
            \['edit new file', 'Unite file/new'],
            \['search directory', 'Unite directory'],
            \['search recently used directories', 'Unite directory_mru'],
            \['search directory with recursive search', 'Unite directory_rec/async'],
            \['make new directory', 'Unite directory/new'],
            \['change working directory', 'Unite -default-action=lcd directory'],
            \['know current working directory', 'Unite -winheight=3 output:pwd'],
            \['save as root                                               ⌘ :w!!', 'exe "write !sudo tee % >/dev/null"'],
            \['quick save                                                 ⌘ ,w', 'normal ,w'],
            \]
exe 'nnoremap <silent>[menu]o :Unite -silent -winheight='.(len(g:unite_source_menu_menus.files.command_candidates) + 2).' menu:files<CR>'
" }}}

" Search files {{{
nnoremap <silent><Leader>ua :Unite -silent -no-quit grep<CR>
let g:unite_source_menu_menus.grep = {
            \ 'description' : '           search files                                          ⌘ [space]a',
            \}
let g:unite_source_menu_menus.grep.command_candidates = [
            \['grep (ag → ack → grep)                                     ⌘ ,ua', 'Unite -no-quit grep'],
            \['find', 'Unite find'],
            \['vimgrep (very slow)', 'Unite vimgrep'],
            \]
exe 'nnoremap <silent>[menu]a :Unite -silent -winheight='.(len(g:unite_source_menu_menus.grep.command_candidates) + 2).' menu:grep<CR>'
" }}}

" Yanks, registers & history {{{
nnoremap <silent><Leader>ui :Unite -silent history/yank<CR>
nnoremap <silent><Leader>ur :Unite -silent register<CR>
let g:unite_source_menu_menus.registers = {
            \ 'description' : '      yanks, registers & history                            ⌘ [space]i'}
let g:unite_source_menu_menus.registers.command_candidates = [
            \['yanks                                                      ⌘ ,ui', 'Unite history/yank'],
            \['commands       (history)                                   ⌘ q:', 'Unite history/command'],
            \['searches       (history)                                   ⌘ q/', 'Unite history/search'],
            \['registers                                                  ⌘ ,ur', 'Unite register'],
            \['messages', 'Unite output:messages'],
            \['undo tree      (undotree)                                     ⌘ ,uu', 'UndotreeToggle'],
            \]
exe 'nnoremap <silent>[menu]i :Unite -silent -winheight='.(len(g:unite_source_menu_menus.registers.command_candidates) + 2).' menu:registers<CR>'
" }}}

" Vim {{{
let g:unite_source_menu_menus.vim = {
            \ 'description' : '            vim                                                   ⌘ [space]v'}
let g:unite_source_menu_menus.vim.command_candidates = [
            \['choose colorscheme', 'Unite colorscheme -auto-preview'],
            \['mappings', 'Unite mapping -start-insert'],
            \['edit configuration file (vimrc)', 'edit $HOME/.vim/vimrc.vim'],
            \['vim help', 'Unite -start-insert help'],
            \['vim commands', 'Unite -start-insert command'],
            \['vim functions', 'Unite -start-insert function'],
            \['vim runtimepath', 'Unite -start-insert runtimepath'],
            \['vim command output', 'Unite output'],
            \['unite sources', 'Unite source'],
            \['kill process', 'Unite -default-action=sigkill process'],
            \['play radio', 'Unite radio'],
            \['launch executable (dmenu like)', 'Unite -start-insert launcher'],
            \]
exe 'nnoremap <silent>[menu]v :Unite -silent -winheight='.(len(g:unite_source_menu_menus.vim.command_candidates) + 2).' menu:vim<CR>'
" }}}

" Text edition {{{
let g:unite_source_menu_menus.text = {
            \ 'description' : '           text edition                                          ⌘ [space]e'}
let g:unite_source_menu_menus.text.command_candidates = [
            \['toggle search results highlight                            ⌘ ,[space]', 'set invhlsearch'],
            \['toggle line numbers                                        ⌘ ,on', 'call ToggleRelativeAbsoluteNumber()'],
            \['toggle wrapping                                            ⌘ ,or', 'normal ,or'],
            \['show hidden chars                                          ⌘ ,ol', 'normal ,ol!'],
            \['toggle fold                                                ⌘ /', 'normal za'],
            \['open all folds                                             ⌘ zR', 'normal zR'],
            \['close all folds                                            ⌘ zM', 'normal zM'],
            \['toggle paste mode                                          ⌘ ,p', 'normal ,p'],
            \['show current char info                                     ⌘ ga', 'normal ga'],
            \]
exe 'nnoremap <silent>[menu]e :Unite -silent -winheight='.(len(g:unite_source_menu_menus.text.command_candidates) + 2).' menu:text<CR>'
" }}}

" Neobundle {{{
let g:unite_source_menu_menus.neobundle = {
            \ 'description' : '      plugins administration with neobundle                 ⌘ [space]n'}
let g:unite_source_menu_menus.neobundle.command_candidates = [
            \['neobundle', 'Unite neobundle'],
            \['neobundle log', 'Unite neobundle/log'],
            \['neobundle lazy', 'Unite neobundle/lazy'],
            \['neobundle update', 'Unite neobundle/update'],
            \['neobundle search', 'Unite neobundle/search'],
            \['neobundle install', 'Unite neobundle/install'],
            \['neobundle check', 'Unite -no-empty output:NeoBundleCheck'],
            \['neobundle docs', 'Unite output:NeoBundleDocs'],
            \['neobundle clean', 'NeoBundleClean'],
            \['neobundle list', 'Unite output:NeoBundleList'],
            \['neobundle direct edit', 'NeoBundleDirectEdit'],
            \]
exe 'nnoremap <silent>[menu]n :Unite -silent -winheight='.(len(g:unite_source_menu_menus.neobundle.command_candidates) + 2).' menu:neobundle<CR>'
" }}}

" Git {{{
let g:unite_source_menu_menus.git = {
            \ 'description' : '            admin git repositories                                ⌘ [space]g'}
let g:unite_source_menu_menus.git.command_candidates = [
            \['git viewer             (gitv)                              ⌘ ,gL', 'normal ,gL'],
            \['git viewer - buffer    (gitv)                              ⌘ ,gl', 'normal ,gl'],
            \['git status             (fugitive)                          ⌘ ,gs', 'normal ,gs'],
            \['git diff               (fugitive)                          ⌘ ,gd', 'normal ,gd'],
            \['git commit             (fugitive)                          ⌘ ,gc', 'normal ,gc'],
            \['git blame              (fugitive)                          ⌘ ,gb', 'normal ,gb'],
            \['git add/stage          (fugitive)                          ⌘ ,ga', 'normal ,ga'],
            \['git checkout           (fugitive)                          ⌘ ,go', 'normal ,go'],
            \['git rm                 (fugitive)                          ⌘ ,gR', 'normal ,gr'],
            \['git push               (fugitive, buffer output)           ⌘ ,gpp', 'normal ,gpp'],
            \['git pull               (fugitive, buffer output)           ⌘ ,gpl', 'normal ,gpl'],
            \]
exe 'nnoremap <silent>[menu]g :Unite -silent -winheight='.(len(g:unite_source_menu_menus.git.command_candidates) + 2).' menu:git<CR>'
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
    NeoBundle 'mhinz/vim-startify' "{{{
    let g:startify_session_dir=s:get_cache_dir('sessions')
    let g:startify_change_to_vcs_root=1
    let g:startify_show_sessions=1
    let g:startify_restore_position=1
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
                \ '~/.vim/vimrc',
                \ '~/.zshrc',
                \ ]
    let g:startify_skiplist = [
                \ 'COMMIT_EDITMSG',
                \ expand($VIMRUNTIME) . '/doc',
                \ expand($VIMFILES) . 'bundle/.*/doc',
                \ ]
    let g:startify_files_number=15
    let g:startify_relative_path=1
    let g:startify_enable_special=0
    let g:startify_change_to_dir=0
    let g:startify_session_autoload=1
    let g:startify_change_to_vcs_root=1
    let g:startify_session_persistence=1
    nnoremap <leader>8 :Startify<cr>
    "}}}
    NeoBundle 'scrooloose/syntastic' "{{{
    let g:syntastic_error_symbol='✗'
    let g:syntastic_style_error_symbol='✠'
    let g:syntastic_warning_symbol='∆'
    "}}}
    NeoBundle 'vim-scripts/vim-auto-save' "{{{
    let g:auto_save=1 " enable AutoSave on Vim startup
    let g:auto_save_in_insert_mode=0 " do not save while in insert mode
    "let g:auto_save_no_updatetime=1 " do not change the 'updatetime' option
    "let g:auto_save_silent = 1 " do not display the auto-save notification
    let g:syntastic_style_warning_symbol = '≈'
    noremap <leader>4  :AutoSaveToggle<cr>
    "}}}
    NeoBundle 'phongvcao/vim-stardict' "{{{
    let g:stardict_split_horizontal=1
    let g:stardict_split_size=20
    let g:stardict_prefer_python3=0
    nnoremap <leader>hh :StarDict<Space>
    nnoremap <leader>h :StarDictCursor<CR>

    "" https://github.com/soimort/translate-shell
    "" Shift-k
    set keywordprg=~/.local/bin/trans\ :tr+en
    autocmd FileType vim nnoremap <buffer> K :r! '/home/kenan/.local/bin/trans\ :tr+en ' . expand("<cword>")<cr>
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
    let g:ctrlspace_ignored_files='\v(tmp|temp|dist|build)[\/]'
    let g:ctrlspace_use_ruby_bindings=has("ruby")
    set wildmode=list:longest,list:full
    set wildignore+=*/tmp/*,*.o,*.obj,.git,*.rbc,*.mp3,*.flac,*.avi,*.svg,*.jpg,*.png,*.so,*.a,*.swp,*.zip,*.pyc,*.pyo,*.classh,__pycache__
    if executable("ag")
        let g:ctrlspace_glob_command = "ag %s -l --nocolor -g '"+ g:ctrlspace_ignored_files +"'"
        "let g:ctrlspace_glob_command = 'ag -l --nocolor -g ""'
    endif
    function s:adjust_ctrlspace_colors()
        let css = airline#themes#get_highlight('CursorLine')
        exe "hi CtrlSpaceStatus guibg=" . css[1]
    endfunction

    let g:airline_exclude_preview=1

    set showtabline=1
    hi CtrlSpaceSelected term=reverse ctermfg=187  ctermbg=23  cterm=bold
    hi CtrlSpaceNormal   term=NONE    ctermfg=244  ctermbg=232 cterm=NONE
    hi CtrlSpaceSearch   ctermfg=220  ctermbg=NONE cterm=bold
    hi CtrlSpaceStatus   ctermfg=230  ctermbg=234  cterm=NONE
    hi link CtrlSpaceSelected Visual
    hi link CtrlSpaceNormal Normal
    hi link CtrlSpaceFound Search
    "let g:ctrlspace_default_mapping_key="<C-a>"
    "let g:ctrlspace_default_mapping_key="<tab>"
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
    autocmd FileType <desired_filetypes> autocmd BufWritePre <buffer> StripWhitespace
    nnoremap <silent> <leader>0 :StripWhitespace<CR>
    "}}}
    NeoBundleLazy 'zhaocai/GoldenView.Vim', {'autoload':{'mappings':['<Plug>ToggleGoldenViewAutoResize']}} "{{{
    let g:goldenview__enable_default_mapping=0
    nmap <F4> <Plug>ToggleGoldenViewAutoResize
    nmap <silent> <C-g>  <Plug>GoldenViewSplit
    "}}}
    NeoBundle 'thinca/vim-quickrun' "{{{
    " Vim plugin to execute whole/part of editing file and show the result.
    " <Leader>r
    "}}}
    NeoBundle 'idbrii/vim-mark' "{{{
    let g:mark_no_mappings=1
    "}}}
    NeoBundle 'asins/renamer.vim' "{{{
    "}}}
    NeoBundle 'vim-scripts/LargeFile' "{{{
    " Edit large files quickly - g:LargeFile (by default, its 100)
    "}}}
    NeoBundle 'tyru/restart.vim' "{{{
    " Only gui - Gvim
    "}}}
endif "}}}

nnoremap <leader>nbu :Unite neobundle/update -vertical -no-start-insert<cr>

" mappings {{{
" formatting shortcuts {{{
nmap <leader>fef :call Preserve("normal gg=G")<CR>
nmap <leader>f$ :call StripTrailingWhitespace()<CR>
vmap <leader>s :sort<cr>
"}}}

" eval vimscript by line or visual selection {{{
nmap <silent> <leader>e :call Source(line('.'), line('.'))<CR>
vmap <silent> <leader>e :call Source(line('v'), line('.'))<CR>
"}}}

" toggle paste {{{
map <F6> :set invpaste<CR>:set paste?<CR>
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
map <A-m> i<CR><Esc>
"}}}

" Insert a newline without entering in insert mode {{{
nmap oo o<Esc>k
nmap OO O<Esc>j
nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>
"}}}

" Tab tab {{{
nnoremap <tab> <c-w>
nnoremap <tab><tab> <c-w><c-w>
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

" window killer {{{
nnoremap <silent> Q :call CloseWindowOrKillBuffer()<cr>
nnoremap <Leader>dd :call CloseWindowOrKillBuffer()<cr>
nnoremap <leader>w :w<cr>
"}}}

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
"}}}

" commands {{{
command! -bang Q q<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>
"}}}

" F<> commands {{{
map <F9> :!python % <enter>
map <F10> :!sh % <enter>
"}}}

" autocmd {{{
" go back to previous position of cursor if any
autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \  exe 'normal! g`"zvzz' |
            \ endif

autocmd FileType js,scss,css autocmd BufWritePre <buffer> call StripTrailingWhitespace()
autocmd FileType css,scss setlocal foldmethod=marker foldmarker={,}
autocmd FileType css,scss nnoremap <silent> <leader>S vi{:sort<CR>
autocmd FileType python setlocal foldmethod=indent
autocmd FileType markdown setlocal nolist
autocmd FileType vim setlocal fdm=indent keywordprg=:help
"}}}

" color schemes {{{
NeoBundle 'junegunn/seoul256.vim' "{{{
set background=dark
let g:seoul256_background=234
let s:settings.colorscheme = 'seoul256'
"}}}
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
