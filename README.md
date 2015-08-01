Vim Config
===========

The ultimate vim configuration

![My Vim](https://github.com/kenanpelit/vimrc/blob/master/ss/vim01.png)

#### Themes (ColorSchemes)

* **seoul256.vim** is a low-contrast Vim color scheme based on [Seoul Colors](http://www.seoul.go.kr/v2012/seoul/symbol/color.html).
Works on 256-color terminal or on GVim.
The updated version is [here](https://github.com/kenanpelit/seoul256.vim).

### #File Browser (VimFiler)

* Use **`<Leader>9`** to toggle the file browser
* Use **`<Leader>8`** to toggle the find open file in the file browser
* Use standard movement keys to move around

#### Viewports (Windows/Splits)

* Use **`<Leader>h`** **`<Leader>j`** **`<Leader>k`** **`<Leader>l`** to navigate between viewports
* Use **`<Leader>q`** to close the current window

#### Tabs

* Use **`<leader>tn`** to open a new tab
* Use **`<leader>tn`** to close the current tab

#### Keymap

##### Leader & LocalLeader Key

* The Leader key is **`space`**
* The LocalLeader key is **`comma`**


##### Leader

| Shortcut                      | Command                                   |
| ----------------------------- | ----------------------------------------- |
|  **`<Leader>0`**              | StripWhitespace                           |
|  **`<Leader>1`**              | AutoSaveToggle                            |
|  **`<Leader>2`**              | RainbowToggle                             |
|  **`<Leader>3`**              | ToggleRelativeAbsoluteNumber              |
|  **`<Leader>4`**              | TagbarToggle                              |
|  **`<Leader>5`**              | UndotreeToggle                            |
|  **`<Leader>6`**              | NERDComment                               |
|  **`<Leader>7`**              | Startify                                  |
|  **`<Leader>8`**              | VimFiler Toggle                           |
|  **`<Leader>9`**              | VimFiler Toggle Find                      |
|  **`<Leader>nbu`**            | Unite neobundle/update                    |
|  **`<Leader>c`**              | VimShell -split                           |
|  **`<Leader>cv`**             | VimShellPop                               |
|  **`<Leader>cp`**             | VimShellInteractive python                |
|  **`<Leader>ef`**             | Unite output:WordFrequency                |
|  **`<Leader>em`**             | Text statistics                           |
|  **`<Leader>ev`**             | Edit vsplit ~/.vim/vimrc                  |
|  **`<Leader>fef`**            | Preserve("normal gg=G")                   |
|  **`<Leader>feg`**            | Sort                                      |
|  **`<Leader>fg`**             | Last search in quickfix                   |
|  **`<Leader>fw`**             | Current word in quickfix                  |
|  **`<Leader>...`**            | ...                                       |

##### LocalLeader

| Shortcut                      | Command                                   |
| ----------------------------- | ----------------------------------------- |
|  **`<LocalLeader>a`**         | Unite grep (ag → ack → grep)              |
|  **`<LocalLeader>b`**         | Unite menu:navigation                     |
|  **`<LocalLeader>c`**         | Unite menu:colorv                         |
|  **`<LocalLeader>d`**         | Unite ~                                   |
|  **`<LocalLeader>e`**         | Unite menu:text                           |
|  **`<LocalLeader>f`**         | Unite menu:searching                      |
|  **`<LocalLeader>g`**         | Unite menu:git                            |
|  **`<LocalLeader>i`**         | Unite menu:registers                      |
|  **`<LocalLeader>k`**         | Unite menu:markdown                       |
|  **`<LocalLeader>l`**         | Unite ~                                   |
|  **`<LocalLeader>m`**         | Unite menu:bookmarks                      |
|  **`<LocalLeader>n`**         | Unite menu:neobundle                      |
|  **`<LocalLeader>o`**         | Unite menu:files                          |
|  **`<LocalLeader>p`**         | Unite menu:code                           |
|  **`<LocalLeader>r`**         | Unite menu:rest                           |
|  **`<LocalLeader>s`**         | Unite menu:spelling                       |
|  **`<LocalLeader>t`**         | Unite menu:tabularize                     |
|  **`<LocalLeader>u`**         | Unite **menu:menu**                       |
|  **`<LocalLeader>v`**         | Unite **menu:vim**                        |
|  **`<LocalLeader>...`**       | Unite ~                                   |

##### F Keys

| Shortcut                      | Command                                   |
| ----------------------------- | ----------------------------------------- |
| **`<F2>`**                    | Scratch                                   |
| **`<F3>`**                    | ScratchPreview                            |
| **`<F4>`**                    | ToggleGoldenViewAutoResize                |
| **`<F5>`**                    | Multiple Cursors Start                    |
| **`<F6>`**                    | PasteMode                                 |
| **`<F7>`**                    | ToggleCurline                             |
| **`<F8>`**                    | Echo                                      |
| **`<F9>`**                    | Python -> !python %                       |
| **`<F10>`**                   | Bash -> !./%                              |
| **`<F11>`**                   | ~                                         |
| **`<F12>`**                   | ~                                         |

---

#### [NeoBundle](https://github.com/Shougo/neobundle.vim)

##### NeoBundle is a next generation Vim plugin manager.

* '907th/vim-auto-save' " Automatically save changes to disk in Vim
* 'DavidEGx/ctrlp-smarttabs'
* 'FelikZ/ctrlp-py-matcher'
* 'MattesGroeger/vim-bookmarks' " Vim bookmark plugin
* 'Rykka/colorv.vim' "A powerful color tool in vim
* 'Shougo/junkfile.vim'
* 'Shougo/neobundle.vim' " Next generation Vim package manager
* 'Shougo/neocomplete.vim' " Next generation completion framework after neocomplcache
* 'Shougo/neomru.vim'
* 'Shougo/neosnippet-snippets' " The standard snippets repository for neosnippets
* 'Shougo/neosnippet.vim' " neo-snippet plugin contains neocomplcache snippets source
* 'Shougo/unite-help'
* 'Shougo/unite-outline'
* 'Shougo/unite-session'
* 'Shougo/unite.vim' " Unite and create user interfaces
* 'Shougo/vimfiler.vim' " Powerful file explorer implemented by Vim script
* 'Shougo/vimproc.vim' " Interactive command execution in Vim.
* 'Shougo/vimshell.vim' " Powerful shell implemented by vim
* 'SirVer/ultisnips' " UltiSnips - The ultimate snippet solution for Vim. Send pull requests to SirVer/ultisnips!
* 'Valloric/YouCompleteMe' " A code-completion engine for Vim
* 'airblade/vim-gitgutter' " A Vim plugin which shows a git diff in the gutter (sign column) and stages/reverts hunks.
* 'ap/vim-css-color' " Highlight colors in css files
* 'aperezdc/vim-template' " Simple templates plugin for Vim
* 'asins/renamer.vim' " Use the power of vim to rename groups of files
* 'benmills/vimux' " vim plugin to interact with tmux
* 'bitbucket:ludovicchabant/vim-lawrencium' " A Mercurial wrapper for Vim
* 'bling/vim-airline' " lean & mean status/tabline for vim that's light as airline
* 'cakebaker/scss-syntax.vim' " Vim syntax file for scss (Sassy CSS)
* 'chrisbra/NrrwRgn' " A Narrow Region Plugin for vim (like Emacs Narrow Region)
* 'chrisbra/vim_faq' " The Vim FAQ from http://vimdoc.sourceforge.net/
* 'christoomey/vim-tmux-navigator' " Seamless navigation between tmux panes and vim splits
* 'ctrlpvim/ctrlp.vim' " Fuzzy file, buffer, mru, tag, etc finder
* 'davidhalter/jedi-vim' " Using the jedi autocompletion library for VIM
* 'dhruvasagar/vim-prosession'
* 'digitaltoad/vim-jade' " Vim Jade template engine syntax highlighting and indention
* 'easymotion/vim-easymotion' " Vim motions on speed!
* 'editorconfig/editorconfig-vim' " EditorConfig plugin for Vim
* 'fmoralesc/vim-autogit' " autocommit changes to a file to an independent git repository
* 'fmoralesc/vim-pad' " a quick notetaking plugin
* 'fmoralesc/vim-tutor-mode' " interactive tutorials for vim
* 'fullybaked/toggle-numbers.vim' " Very simple Vim plugin to toggle between relative and absolute line numbers
* 'godlygeek/tabular' " Vim script for text filtering and alignment
* 'gregsexton/MatchTag' " Vim's MatchParen for HTML tags
* 'gregsexton/gitv' " gitk for Vim
* 'groenewege/vim-less' " vim syntax for LESS (dynamic CSS)
* 'guns/xterm-color-table.vim' " All 256 xterm colors with their RGB equivalents, right in Vim!
* 'hail2u/vim-css3-syntax' " Add CSS3 syntax support to vim's built-in `syntax/css.vim`
* 'honza/vim-snippets' " vim-snipmate default snippets (Previously snipmate-snippets)
* 'idbrii/bufkill.vim' " Unload/delete/wipe a buffer, keep its window(s), display last accessed buffer(s)
* 'idbrii/vim-mark' " highlight several words in different colors simultaneously
* 'jasoncodes/ctrlp-modified.vim'
* 'jiangmiao/auto-pairs' " Vim plugin, insert or delete brackets, parens, quotes in pair
* 'jmcantrell/vim-virtualenv' " Work with python virtualenvs in vim
* 'junegunn/fzf' " :cherry_blossom: A command-line fuzzy finder written in Go
* 'junegunn/vim-github-dashboard' " :octocat: Browse GitHub events in Vim
* 'justinmk/vim-sneak' " :shoe: The missing motion for Vim
* 'juvenn/mustache.vim' " Vim mode for mustache and handlebars (Deprecated)
* 'kana/vim-textobj-entire' " Vim plugin: Text objects for entire buffer
* 'kana/vim-textobj-indent' " Vim plugin: Text objects for indented blocks of lines
* 'kana/vim-textobj-user' " Vim plugin: Create your own text object
* 'kana/vim-vspec' " Vim plugin: Testing framework for Vim script
* 'kenanpelit/seoul256.vim'
* 'klen/python-mode' " Vim python-mode. PyLint, Rope, Pydoc, breakpoints from box
* 'klen/unite-radio.vim'
* 'lambdalisue/vim-gista'
* 'lucapette/vim-textobj-underscore' " Underscore text-object for Vim
* 'luochen1990/rainbow' " rainbow parentheses improved, shorter code, no level limit, smooth and fast, powerful configuration
* 'majutsushi/tagbar' " Vim plugin that displays tags in a window, ordered by
* 'mattn/ctrlp-mark'
* 'mattn/emmet-vim' " emmet for vim: http://emmet.io/
* 'mattn/gist-vim'
* 'mattn/webapi-vim' " vimscript for gist
* 'mbbill/undotree', " The ultimate undo history visualizer for VIM
* 'mhinz/vim-signify' " Show a diff via Vim sign column
* 'mhinz/vim-startify' " A fancy start screen for Vim
* 'mileszs/ack.vim' " Vim plugin for the Perl module / CLI script 'ack'
* 'moll/vim-bbye' " Delete buffers and close files in Vim without closing your windows or messing up your layout. Like Bclose.vim, but rewritten and well maintained.
* 'mtth/scratch.vim' " Unobtrusive scratch window
* 'myusuf3/numbers.vim' " numbers.vim is a vim plugin for better line numbers
* 'nathanaelkane/vim-indent-guides' " A Vim plugin for visually displaying indent levels in code
* 'ntpeters/vim-better-whitespace' " Better whitespace highlighting for Vim
* 'osyo-manga/unite-airline_themes'
* 'osyo-manga/unite-filetype'
* 'osyo-manga/unite-quickfix'
* 'othree/html5.vim' " HTML5 omnicomplete and syntax
* 'pbrisbin/vim-mkdir' " Automatically create any non-existent directories before writing the buffer.
* 'phongvcao/vim-stardict' " Looking up meaning of words inside Vim, Bash and Zsh using StarDict Command-Line Version (SDCV) dictionary program.
* 'rhysd/clever-f.vim' " Extended f, F, t and T key mappings for Vim
* 'rking/ag.vim' "Vim plugin for the_silver_searcher, 'ag', a replacement for the Perl module / CLI script 'ack'
* 'ryanoasis/vim-devicons' " vim web developer filetype font unicode icons for NERDTree and vim-airline
* 'scrooloose/nerdcommenter' " Vim plugin for intensely orgasmic commenting
* 'scrooloose/syntastic' "Syntax checking hacks for vim
* 'sgur/ctrlp-extensions.vim'
* 'suan/vim-instant-markdown' " Instant Markdown previews from VIm!
* 'szw/vim-ctrlspace' " Vim Workspace Controller
* 't9md/vim-choosewin' " land to window you choose like tmux's 'display-pane'
* 'tacahiroy/ctrlp-funky'
* 'terryma/vim-expand-region' " Vim plugin that allows you to visually select increasingly larger regions of text using the same key combination
* 'terryma/vim-multiple-cursors' " True Sublime Text style multiple selections for
* 'thinca/vim-quickrun' " Run commands quickly. Vim plugin to execute whole/part of editing file and show the result. <leader>r
* 'thinca/vim-unite-history'
* 'thinca/vim-visualstar' " star for Visual-mode
* 'tmux-plugins/vim-tmux' " vim plugin for tmux.conf
* 'tomtom/tcomment_vim' " An extensible & universal comment vim-plugin that also handles embedded filetype
* 'tpope/vim-dispatch' " dispatch.vim: asynchronous build and test dispatcher
* 'tpope/vim-endwise' " endwise.vim: wisely add 'end' in ruby, endfunction/endif/more in vim script, etc
* 'tpope/vim-eunuch' " eunuch.vim: helpers for UNIX
* 'tpope/vim-fugitive' " fugitive.vim: a Git wrapper so awesome, it should be illegal
* 'tpope/vim-markdown' " Vim Markdown runtime files
* 'tpope/vim-obsession'
* 'tpope/vim-repeat' " repeat.vim: enable repeating supported plugin maps with '.'
* 'tpope/vim-scriptease' " scriptease.vim: A Vim plugin for Vim plugins
* 'tpope/vim-speeddating' " speeddating.vim: use CTRL-A/CTRL-X to increment dates, times, and more
* 'tpope/vim-surround' " surround.vim: quoting/parenthesizing made simple
* 'tpope/vim-unimpaired' " unimpaired.vim: pairs of handy bracket mappings
* 'tsukkee/unite-tag'
* 'tyru/open-browser.vim'
* 'ujihisa/unite-colorscheme'
* 'ujihisa/unite-colorscheme'
* 'ujihisa/unite-locate'
* 'vim-scripts/EasyGrep' " Fast and Easy Find and Replace Across Multiple Files
* 'vim-scripts/LargeFile' " Edit large files quickly (keywords: large huge speed)
* 'vim-scripts/bash-support.vim' " BASH IDE -- Write and run BASH-scripts using menus and hotkeys
* 'vim-scripts/matchit.zip' " extended % matching for HTML, LaTeX, and many other language
* 'vim-scripts/utl.vim' " Univeral Text Linking - Execute URLs, footnotes, open emails, organize ideas
* 'vim-scripts/vimwiki' " Personal Wiki for Vim
* 'wavded/vim-stylus' " Syntax Highlighting for Stylus
* 'xolox/vim-misc' " Automatic reloading of Vim scripts ((file-type) plug-ins, auto-load/syntax/indent scripts, color schemes)
* 'xolox/vim-notes' " Easy note taking in Vim
* 'xolox/vim-reload'
* 'yssl/AutoCWD.vim' " Auto current working directory update system
* 'zhaocai/GoldenView.Vim' " Always have a nice view for vim split windows!

---
*To be continued...*
