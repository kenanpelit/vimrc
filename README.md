Vim Config
===========

The ultimate vim configuration

![My Vim](https://github.com/kenanpelit/vimrc/blob/master/ss/vim01.png)

### Leader & LocalLeader Key

* The Leader key is **`space`**
* The LocalLeader key is **`comma`**

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

#### Leader

* **`<Leader>0`**   | StripWhitespace
* **`<Leader>1`**   | AutoSaveToggle
* **`<Leader>2`**   | RainbowToggle
* **`<Leader>3`**   | ToggleRelativeAbsoluteNumber
* **`<Leader>4`**   | TagbarToggle
* **`<Leader>5`**   | UndotreeToggle
* **`<Leader>6`**   | NERDComment
* **`<Leader>7`**   | Startify
* **`<Leader>8`**   | VimFiler Toggle
* **`<Leader>9`**   | VimFiler Toggle Find
* **`<Leader>nbu`** | Unite neobundle/update
* **`<Leader>c`**   | VimShell -split
* **`<Leader>cv`**  | VimShellPop
* **`<Leader>cp`**  | VimShellInteractive python
* **`<Leader>ef`**  | Unite output:WordFrequency
* **`<Leader>em`**  | Text statistics
* **`<Leader>ev`**  | Edit vsplit ~/.vim/vimrc
* **`<Leader>fef`** | Preserve("normal gg=G")
* **`<Leader>feg`** | Sort
* **`<Leader>fg`**  | Last search in quickfix
* **`<Leader>fw`**  | Current word in quickfix
* **`<Leader>...`** | ...

#### LocalLeader

* **`<LocalLeader>a`**   | Unite grep (ag → ack → grep)
* **`<LocalLeader>b`**   | Unite menu:navigation
* **`<LocalLeader>c`**   | Unite menu:colorv
* **`<LocalLeader>d`**   | Unite ~
* **`<LocalLeader>e`**   | Unite menu:text
* **`<LocalLeader>f`**   | Unite menu:searching
* **`<LocalLeader>g`**   | Unite menu:git
* **`<LocalLeader>i`**   | Unite menu:registers
* **`<LocalLeader>k`**   | Unite menu:markdown
* **`<LocalLeader>l`**   | Unite ~
* **`<LocalLeader>m`**   | Unite menu:bookmarks
* **`<LocalLeader>n`**   | Unite menu:neobundle
* **`<LocalLeader>o`**   | Unite menu:files
* **`<LocalLeader>p`**   | Unite menu:code
* **`<LocalLeader>r`**   | Unite menu:rest
* **`<LocalLeader>s`**   | Unite menu:spelling
* **`<LocalLeader>t`**   | Unite menu:tabularize
* **`<LocalLeader>u`**   | Unite **menu:menu**
* **`<LocalLeader>v`**   | Unite **menu:vim**
* **`<LocalLeader>...`** | Unite ~

#### F Keys

* **`<F2>`**  | Scratch
* **`<F3>`**  | ScratchPreview
* **`<F4>`**  | ToggleGoldenViewAutoResize
* **`<F5>`**  | Multiple Cursors Start
* **`<F6>`**  | PasteMode
* **`<F7>`**  | ToggleCurline
* **`<F8>`**  | Echo
* **`<F9>`**  | Python -> !python %
* **`<F10>`** | Bash -> !./%
* **`<F11>`** | ~
* **`<F12>`** | ~


---
*To be continued...*
