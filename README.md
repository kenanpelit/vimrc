Vim Config
===========

The ultimate vim configuration

## Features

- NeoBundle plugin manager
- Lot of unite menus

![My Vim](https://github.com/kenanpelit/vimrc/blob/master/ss/vim01.png)

### Themes (ColorSchemes)

* **seoul256.vim** is a low-contrast Vim color scheme based on [Seoul Colors](http://www.seoul.go.kr/v2012/seoul/symbol/color.html).
Works on 256-color terminal or on GVim.
The updated version is [here](https://github.com/kenanpelit/seoul256.vim).

### File Browser (VimFiler)

* Use **`<Leader>9`** to toggle the file browser
* Use **`<Leader>8`** to toggle the find open file in the file browser
* Use standard movement keys to move around

### Viewports (Windows/Splits)

* Use **`<Leader>h`** **`<Leader>j`** **`<Leader>k`** **`<Leader>l`** to navigate between viewports
* Use **`<Leader>q`** to close the current window

### Tabs

* Use **`<leader>tn`** to open a new tab
* Use **`<leader>tn`** to close the current tab

### Keymap

#### Leader & LocalLeader Key

* The Leader key is **`space`**
* The LocalLeader key is **`comma`**

#### Leader

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

#### LocalLeader

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

#### F Keys

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

### [NeoBundle](https://github.com/Shougo/neobundle.vim)

#### NeoBundle is a next generation Vim plugin manager.

[vim-auto-save] Automatically save changes to disk in Vim
[ctrlp-smarttabs]
[ctrlp-py-matcher]
[vim-bookmarks] Vim bookmark plugin
[colorv.vim] A powerful color tool in vim
[junkfile.vim]
[neobundle.vim] Next generation Vim package manager
[neocomplete.vim] Next generation completion framework after neocomplcache
[neomru.vim]
[neosnippet-snippets] The standard snippets repository for neosnippets
[neosnippet.vim] neo-snippet plugin contains neocomplcache snippets source
[unite-help]
[unite-outline]
[unite-session]
[unite.vim] Unite and create user interfaces
[vimfiler.vim] Powerful file explorer implemented by Vim script
[vimproc.vim] Interactive command execution in Vim.
[vimshell.vim] Powerful shell implemented by vim
[ultisnips] UltiSnips - The ultimate snippet solution for Vim. Send pull requests to SirVer/ultisnips!
[YouCompleteMe] A code-completion engine for Vim
[vim-gitgutter] A Vim plugin which shows a git diff in the gutter (sign column) and stages/reverts hunks.
[vim-css-color] Highlight colors in css files
[vim-template] Simple templates plugin for Vim
[renamer.vim] Use the power of vim to rename groups of files
[vimux] vim plugin to interact with tmux
[vim-lawrencium] A Mercurial wrapper for Vim
[vim-airline] lean & mean status/tabline for vim thats light as airline
[scss-syntax.vim] Vim syntax file for scss (Sassy CSS)
[NrrwRgn] A Narrow Region Plugin for vim (like Emacs Narrow Region)
[vim_faq] The Vim FAQ from http://vimdoc.sourceforge.net/
[vim-tmux-navigator] Seamless navigation between tmux panes and vim splits
[ctrlp.vim] Fuzzy file, buffer, mru, tag, etc finder
[jedi-vim] Using the jedi autocompletion library for VIM
[vim-prosession]
[vim-jade] Vim Jade template engine syntax highlighting and indention
[vim-easymotion] Vim motions on speed!
[editorconfig-vim] EditorConfig plugin for Vim
[vim-autogit] autocommit changes to a file to an independent git repository
[vim-pad] a quick notetaking plugin
[vim-tutor-mode] interactive tutorials for vim
[toggle-numbers.vim] Very simple Vim plugin to toggle between relative and absolute line numbers
[tabular] Vim script for text filtering and alignment
[MatchTag] Vim]s MatchParen for HTML tags
[gitv] gitk for Vim
[vim-less] vim syntax for LESS (dynamic CSS)
[xterm-color-table.vim] All 256 xterm colors with their RGB equivalents, right in Vim!
[vim-css3-syntax] Add CSS3 syntax support to vims built-in `syntax/css.vim`
[vim-snippets] vim-snipmate default snippets (Previously snipmate-snippets)
[bufkill.vim] Unload/delete/wipe a buffer, keep its window(s), display last accessed buffer(s)
[vim-mark] highlight several words in different colors simultaneously
[ctrlp-modified.vim]
[auto-pairs] Vim plugin, insert or delete brackets, parens, quotes in pair
[vim-virtualenv] Work with python virtualenvs in vim
[fzf] :cherry_blossom: A command-line fuzzy finder written in Go
[vim-github-dashboard] :octocat: Browse GitHub events in Vim
[vim-sneak] :shoe: The missing motion for Vim
[mustache.vim] Vim mode for mustache and handlebars (Deprecated)
[vim-textobj-entire] Vim plugin: Text objects for entire buffer
[vim-textobj-indent] Vim plugin: Text objects for indented blocks of lines
[vim-textobj-user] Vim plugin: Create your own text object
[vim-vspec] Vim plugin: Testing framework for Vim script
[seoul256.vim]
[python-mode] Vim python-mode. PyLint, Rope, Pydoc, breakpoints from box
[unite-radio.vim]
[vim-gista]
[vim-textobj-underscore] Underscore text-object for Vim
[rainbow] rainbow parentheses improved, shorter code, no level limit, smooth and fast, powerful configuration
[tagbar] Vim plugin that displays tags in a window, ordered by
[ctrlp-mark]
[emmet-vim] emmet for vim: http://emmet.io/
[gist-vim]
[webapi-vim] vimscript for gist
[undotree], The ultimate undo history visualizer for VIM
[vim-signify] Show a diff via Vim sign column
[vim-startify] A fancy start screen for Vim
[ack.vim] Vim plugin for the Perl module / CLI script ack
[vim-bbye] Delete buffers and close files in Vim without closing your windows or messing up your layout. Like Bclose.vim, but rewritten and well maintained.
[scratch.vim] Unobtrusive scratch window
[numbers.vim] numbers.vim is a vim plugin for better line numbers
[vim-indent-guides] A Vim plugin for visually displaying indent levels in code
[vim-better-whitespace] Better whitespace highlighting for Vim
[unite-airline_themes]
[unite-filetype]
[unite-quickfix]
[html5.vim] HTML5 omnicomplete and syntax
[vim-mkdir] Automatically create any non-existent directories before writing the buffer.
[vim-stardict] Looking up meaning of words inside Vim, Bash and Zsh using StarDict Command-Line Version (SDCV) dictionary program.
[clever-f.vim] Extended f, F, t and T key mappings for Vim
[ag.vim] im plugin for the_silver_searcher, ag, a replacement for the Perl module / CLI script ack
[vim-devicons] vim web developer filetype font unicode icons for NERDTree and vim-airline
[nerdcommenter] Vim plugin for intensely orgasmic commenting
[syntastic] yntax checking hacks for vim
[ctrlp-extensions.vim]
[vim-instant-markdown] Instant Markdown previews from VIm!
[vim-ctrlspace] Vim Workspace Controller
[vim-choosewin] land to window you choose like tmuxs display-pane
[ctrlp-funky]
[vim-expand-region] Vim plugin that allows you to visually select increasingly larger regions of text using the same key combination
[vim-multiple-cursors] True Sublime Text style multiple selections for
[vim-quickrun] Run commands quickly. Vim plugin to execute whole/part of editing file and show the result. <leader>r
[vim-unite-history]
[vim-visualstar] star for Visual-mode
[vim-tmux] vim plugin for tmux.conf
[tcomment_vim] An extensible & universal comment vim-plugin that also handles embedded filetype
[vim-dispatch] dispatch.vim: asynchronous build and test dispatcher
[vim-endwise] endwise.vim: wisely add end in ruby, endfunction/endif/more in vim script, etc
[vim-eunuch] eunuch.vim: helpers for UNIX
[vim-fugitive] fugitive.vim: a Git wrapper so awesome, it should be illegal
[vim-markdown] Vim Markdown runtime files
[vim-obsession]
[vim-repeat] repeat.vim: enable repeating supported plugin maps with .
[vim-scriptease] scriptease.vim: A Vim plugin for Vim plugins
[vim-speeddating] speeddating.vim: use CTRL-A/CTRL-X to increment dates, times, and more
[vim-surround] surround.vim: quoting/parenthesizing made simple
[vim-unimpaired] unimpaired.vim: pairs of handy bracket mappings
[unite-tag]
[open-browser.vim]
[unite-colorscheme]
[unite-colorscheme]
[unite-locate]
[EasyGrep] Fast and Easy Find and Replace Across Multiple Files
[LargeFile] Edit large files quickly (keywords: large huge speed)
[bash-support.vim] BASH IDE -- Write and run BASH-scripts using menus and hotkeys
[matchit.zip] extended % matching for HTML, LaTeX, and many other language
[utl.vim] Univeral Text Linking - Execute URLs, footnotes, open emails, organize ideas
[vimwiki] Personal Wiki for Vim
[vim-stylus] Syntax Highlighting for Stylus
[vim-misc] Automatic reloading of Vim scripts ((file-type) plug-ins, auto-load/syntax/indent scripts, color schemes)
[vim-reload]
[AutoCWD.vim] Auto current working directory update system
[GoldenView.Vim]  Always have a nice view for vim split windows!

---

*To be continued...*
