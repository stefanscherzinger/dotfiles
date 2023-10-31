"-----------------------------------------------------------------------
" !\file    .init.vim
"
" \author  Stefan Scherzinger <scherzin@fzi.de>
" \date    2016/09/09
"
" \brief   clone of vimrc for NeoVim
"
"          This file should contain the exact config as the original vimrc
"          file. The only difference are some NeoVim specific changes/addons
"          at the end of this file.
" 
"-----------------------------------------------------------------------


" ------------------------------------------------------------------------------
"	Plugin related
" ------------------------------------------------------------------------------
" Tim Pope's pathogen plugin for loading further plugins comfortably.
" Plugins have to be located in ~/.vim/bundle/ in order to be loaded
execute pathogen#infect()
"syntax on
filetype indent on
filetype plugin on

" ------------------------------------------------------------------------------
"	Miscellaneous
" ------------------------------------------------------------------------------

set mouse=nv
"set tabstop=2
"set shiftwidth=2
set rnu           " recursive numbering for easier page navigation
set nu            " show current global line (in conjunction with rnu)
set is
set hls
set expandtab
set hidden        " allow switch between unsaved buffers
"set autochdir     " set working directory to the current file buffer
"
set ignorecase    " with combination of smartcase!
set smartcase     " /hello will match HeLlO and hello, /hEllo will only match hEllo

"set colorcolumn=80
set guifont=Monospace\ 9
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
"set termguicolors

" colorschemes
set background=dark
"colorscheme onedark
let g:gruvbox_italic = 1
colorscheme gruvbox

"colorscheme ayu
"let ayucolor="light"  " for light version of theme
"let ayucolor="mirage" " for mirage version of theme
"let ayucolor="dark"   " for dark version of theme

set foldmethod=syntax
let c_no_comment_fold=1
set foldlevel=99  " don't fold by default

set wildchar=<Tab> wildmenu wildmode=full       " enhance tab completion in command mode

" Bigger command line
set cmdheight=2

" Highlight cursor in terminal buffers. See vimcasts # 76
:hi! TermCursorNC ctermfg=15 guifg=#fdf6e3 ctermbg=14 guibg=#93a1a1 cterm=NONE gui=NONE

" Reset terminal buffers by
" :set scrollback=1
" Then call clear in the terminal and
" :set scrollback=1000
"


" Open Ubuntu file manager from current terminal:
" nautilus --browser .







" ------------------------------------------------------------------------------
"	Miscellaneous functions, remaps, etc.
" ------------------------------------------------------------------------------

" search for visual selection. This is copied from Drew Neil's 'Practical Vim'
xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>

function! s:VSetSearch()
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

"  <Ctrl-l> redraws the screen and removes any search highlighting (from stack overflow)
nnoremap <silent> <C-l> :nohl<CR><C-l>
" Does currently not work due to later remapping!
"nnoremap <silent> <C-Char-246> :nohl<CR><C-Char-246>

" sudo write the current buffer (from stack overflow)
cmap w!! w !sudo tee > /dev/null %

" Open Fuzzy Finder on hitting <C-p>
nnoremap <C-p> : <C-u>FZF<CR>

" 
" Custom :Qargs command to populate the arglist from the quickfix list.
" Taken from Drew Neil: http://vimcasts.org/episodes/project-wide-find-and-replace/
" When searching, use ## to search the entire arglist.
" Workflow:
" 1) :Gclog  (:0Gclog does for the current file only)
" 2) :Qargs
" 3) :vim somestring ##
command! -nargs=0 -bar Qargs execute 'args' QuickfixFilenames()
function! QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction


" Clear the terminal's history.
" This is helpful for clearing endless logging statements.
command! Clear execute ClearScrollback()
function! ClearScrollback()
        let ClearCmd="clear"
        :execute "set scrollback=1"
        :execute "put =ClearCmd"
        :execute "set scrollback=10000"
        return 0
endfunction


" Open the file browser at the current working directory.
" Change the directory before with cd in nerdtree.
command! FileBrowser execute OpenFileBrowser()
function! OpenFileBrowser()
        :execute "!nautilus . &"
        return 0
endfunction


" ------------------------------------------------------------------------------
"	python
" ------------------------------------------------------------------------------
" For using python2 and python3 with neovim, individual virtual environments
" are used. This facilitates the management of packages that are used only
" for neovim.
let g:python_host_prog = '/home/scherzin/nvim/python2/bin/python'
let g:python3_host_prog = '/usr/bin/python3'

" ------------------------------------------------------------------------------
"	NERDTree specific stuff
" ------------------------------------------------------------------------------
" switch NERDtree on and off with \n
map <Leader>n <plug>NERDTreeTabsToggle<CR>
"map <Leader>n <plug>NERDTreeFocusToggle<CR>
map <Leader>n :NERDTreeToggle<CR>
let NERDTreeShowLineNumbers=1
let NERDTreeAutoDeleteBuffer=1
let NERDTreeWinSize=40

" ------------------------------------------------------------------------------
"	BufferExplorer specific stuff
" ------------------------------------------------------------------------------
let g:bufExplorerShowTabBuffer=1
"let g:bufExplorerSortBy='number'     " Sort by the buffer's number.
let g:bufExplorerSortBy='mru'     " Sort by most recently used


" ------------------------------------------------------------------------------
"	Ctags specific stuff
" ------------------------------------------------------------------------------
" Ctrl + \ to open in a new tab
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
" Alt + ] to open in vertical split
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" Thanks to Tim Popes seamless integration into git ctags produces the according tag files
" automatically on commiting, pulling, etc.. The according tag file resides for each project
" in the .git/.. folder. Add those paths to the tags path below.
" look in project wide .git repositories
set tags=./.git/tags;$HOME,.git/tags;$HOME        "from stackoverflow, ; means up to


" ------------------------------------------------------------------------------
"	fugitive
" ------------------------------------------------------------------------------
" Make the output of Git! ll (and G ll) produce a colored git log tree.
" These files will end in a number.
autocmd BufNewFile,BufRead,BufEnter /tmp/nvim*[0-999] set syntax=git_log_tree

"--------------------------------------------------------------------------------
" Fugitive: Workflow for merge
"--------------------------------------------------------------------------------
" 1) Use Gdiffsplit! on the conflicted file to bring up the 3 windows.
"    Instead of just Gdiff which brings up a two-way diff
"
"    Note that :Gdiff (2-way) can also be used, but it's less intuitive
"
" 2) Left = target branch, Middle = working copy, Right = merge branch
"    Visually select each separate conflict in the middle buffer.
"    This also works when the cursor is positioned on the lines highlighted in
"    green
"
"    d2o does left
"    d3o does right
"
"    There are also the more verbose commands:
"    Use :diffget //2 <CR>  to take the left chunk
"    Use :diffget //3 <CR>  to take the right chunk
"
"    As an alternative:
"    Use dp from the left (= target file) or right (merge file) to put into the
"    middle (=working copy).
"
"    Jump between the conflicts with
"    - ]c and [c
"
" 3) Save the middle file when reaching the desired state
"
" 4) Optional: Use :diffoff on this file to stop colored high-lighting. This
"    is for easier inspection of the final changes
"
" 5) Close this tab with :tabc

"--------------------------------------------------------------------------------
" Fugitive: Workflow for rebasing
"--------------------------------------------------------------------------------
" 1) Start in command mode :Grebase --interactive <branch-onto-which-to-rebase>
"
" 2) Configure the rebase in the pop-up window (reordering, squashing, etc.)
"
" 3) Use Git status (G:) when conflicts are detected.
"    In the status window, open conflicted files with O (separate Tab)
"
" 4) call
"    :Gdiffthis! and fix the conflicts like a merge conflict. The left file is
"    the version of the commit onto which we are rebasing, the right file
"    shows the changes that the commits from our feature branch would
"    introduce and the middle file shows the final changes that we will commit
"    with this rebase.
"
"    o) Optional: When using Gdiff, save the right file which shows the final changes
"   
"    o) Optional: When using Gdiff, close this tab with :tabc! (! is needed for the left tmp git file)
"   
" 5) Back in Gstatus, stage the just fixed file
"
" 6) Continue with 3) for the next conflicting file
"
" 7) When rebasing big commits, various files will conflict. Sometimes it's
"    necessary to also add new files while fixing conflicts. Just add and edit
"    new files as usual and stage them along with the fixed conflict files.
"
" 8) After fixing all files for one commit, continue with the rebase with:
"     rr (in Gstatus)
"
" 9) Continue with 3) - 9) until the rebase is complete. Gstatus will show
"    the progress with marking each commit with 'done'.
"
"
"--------------------------------------------------------------------------------
" Fugitive: Workflow for cleanup of feature branches
"--------------------------------------------------------------------------------
" 1) Start in command mode :Grebase --interactive HEAD~n
"    This will give you the chance to interactively rebase n commits
"
" 2) Configure the rebase in the pop-up window (reordering, squashing, etc.)
"
" 3) When using edit, Git will stop right AFTER the commit we want to edit.
"    That's counterintuitive at first, because no staged files appear in G:.
"    To also edit the files that were staged for this commit, use
"    git reset --soft HEAD~ in another terminal.
"    Now all of these files are visible.
"
" 4) When finished with the edit, commit the files as if it was the first
"    commit.
"
" 5) Continue the rebase with
"    rr (in Gstatus)
"
"
" ------------------------------------------------------------------------------
"	YCM specific stuff
" ------------------------------------------------------------------------------
" General python binary for neovim
let g:ycm_server_python_interpreter = '/usr/bin/python3'
"
" Special python binary for jedi. Use the one from the virtual environment
" this neovim instance is launched in. This allows parsing all python packages
" from this environment (e.g. tensorflow).
let g:ycm_python_binary_path = 'python'

" Config
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_confirm_extra_conf = 1        " don't ask to open config files

" Look-ups
nnoremap <leader>d :YcmCompleter GoToDefinitionElseDeclaration<CR>
nnoremap <leader>t :YcmCompleter GoTo<CR>
nnoremap <leader>i :YcmCompleter GoToImprecise<CR>
nnoremap <leader>gf :YcmCompleter GoToInclude<CR>
nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>

" Fall-back configuration. This is handy for looking-up declarations in
" already looked-up headers (e.g. boost, std, etc).
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'

" for vim-ros integration
let g:ycm_semantic_triggers = {
\   'roslaunch' : ['="', '$(', '/'],
\   'rosmsg,rossrv,rosaction' : ['re!^', '/'],
\ }

" Alternate approach:
" Note: to get all includes from cmake organized build systems
" use set("CMAKE_EXPORT_COMPILE_COMMANDS" "ON") in the highest CMakeLists.txt,
" on running cmake .. this will produce a compile_commands.json file in the build directory.
" In the ycm_extra_conf.py modify "compilation_database_folder = " to point to the absolute path
" of the before mentioned build directory

" ------------------------------------------------------------------------------
"	Neomake
" ------------------------------------------------------------------------------
" This uses pyflakes3 for `.py` files or `flake8` if that's available

" When writing a buffer (no delay), and on normal mode changes (after 750ms).
"call neomake#configure#automake('nw', 750)



" ------------------------------------------------------------------------------
"	UltiSnips specific stuff
" ------------------------------------------------------------------------------
set runtimepath+=~/.config/nvim/UltiSnips
let g:UltiSnipsExpandTrigger="<C-F>"    " Avoid issues with YouCompleteMe.
                                         " Press Ctrl f to apply the
                                         " selection from YouCompleteMe.

let g:UltiSnipsSnippetsDir="~/.config/nvim/UltiSnips"   " Where to create specific snippets
let g:UltiSnipsSnippetDirectories=["UltiSnips"]           " Where to look for snippets
"
"let g:UltiSnipsSnippetsDir = $HOME."/.config/nvim/UltiSnips"
"let g:UltiSnipsSnippetDirectories = ['UltiSnips', $HOME.'/.config/nvim/UltiSnips']

" ------------------------------------------------------------------------------
"	Markdown files editing
" ------------------------------------------------------------------------------
nnoremap <F6> ::ComposerStart <CR> ::ComposerOpen <CR> 
nnoremap <F5> ::ComposerUpdate <CR>
let g:markdown_composer_open_browser=0
let g:markdown_composer_autostart=0

" Actually, this is no longer needed since I got the vim-instand-markdown
" plugin.
"autocmd BufEnter *.md exe 'noremap <F5> :! /usr/bin/firefox %:p 2> /dev/null <CR>'


" ------------------------------------------------------------------------------
"	ROS specific
" ------------------------------------------------------------------------------
autocmd BufRead,BufNewFile *.launch setfiletype roslaunch " provide .launch file syntax
autocmd BufRead,BufNewFile *.test setfiletype rostest " provide .test file syntax
let ros_catkin_make_options='-C /home/scherzin/src/robot_folders/checkout/research'
let g:ros_make='all'
let g:ros_build_system='catkin'

" ------------------------------------------------------------------------------
"	Additional highliting
" ------------------------------------------------------------------------------
autocmd BufRead,BufNewFile *.urscript setfiletype python

" ------------------------------------------------------------------------------
"	Smooth scrolling
" ------------------------------------------------------------------------------
"noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
"noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
"noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 5, 2)<CR>
"noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 5, 1)<CR>
"noremap <silent> <c-e> :call smooth_scroll#down(10, 5, 1)<CR>
"noremap <silent> <c-y> :call smooth_scroll#up(10, 5, 1)<CR>

" ------------------------------------------------------------------------------
"	Neovim
" ------------------------------------------------------------------------------
" Switch from terminal mode to normal mode by hitting <Esc>,
" but send <Esc> to the terminal with hitting <C-v><Esc>.
if has('nvim')
        tnoremap <Esc> <C-\><C-n>
        tnoremap <C-v><Esc> <Esc>
endif

" Use <ctrl-R> register access in terminal mode
tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'

" Open files and directories in terminal buffers.
" Use e.g. ls to see content an then open it with pressing 'Ö'.
if has('nvim')
        nmap <silent> Ö yiWAnvim <C-R>"<cr>
        vmap <silent> Ö yAnvim <C-R>"<cr>
endif

" ------------------------------------------------------------------------------
"	Neovim Remote
" ------------------------------------------------------------------------------
"  Check here: https://github.com/mhinz/neovim-remote#typical-use-cases
if has('nvim')
  let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif

autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
" ------------------------------------------------------------------------------
"	Easy window navigation
" ------------------------------------------------------------------------------
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ------------------------------------------------------------------------------
"	Jedi autocompletion for python
" ------------------------------------------------------------------------------
"  Note: In the terminal, export
"  PYTHONPATH=/opt/ros/galactic/lib/python3.8/site-packages before starting
"  nvim.  That gives nice ROS2 completion in Python files.
"  export PYTHONPATH=/home/scherzin/src/ros2-humble/install/lib/python3.8/site-packages
"
let g:jedi#usages_command = "<leader>u"
"let g:jedi#auto_initialization = 1
"let g:jedi#completions_enabled = 1
"let g:jedi#auto_vim_configuration = 0
"let g:jedi#smart_auto_mappings = 0
"let g:jedi#popup_on_dot = 1
"let g:jedi#completions_command = "<C-Space>"
"let g:jedi#show_call_signatures = "1"
"let g:jedi#show_call_signatures_delay = 0
"let g:jedi#usages_command = "<leader>u"

" ------------------------------------------------------------------------------
"	Auto formatting (clang-format, autopep8, etc.)
" ------------------------------------------------------------------------------
"  See vim-autoformat
noremap <F3> :Autoformat<CR>
vnoremap <Leader>a :Autoformat<CR>
" Will search for a .clang-format file up the directory.
" I have the FZI style globally in ~/dotfiles/fzi_styles/
" This works on .py files with autopep8

" ------------------------------------------------------------------------------
"	Tagbar
" ------------------------------------------------------------------------------
map <Leader>c :TagbarToggle<CR>
" Close after selection
let g:tagbar_autoclose = 1

" Show relative line numbers
let g:tagbar_show_linenumbers = 2

" ------------------------------------------------------------------------------
"	Vim script testing
" ------------------------------------------------------------------------------
" redraw forces to display the message
"redraw | echo "(>^.^<)"
"
" Map - and _ to move the current line down and up
"nnoremap - ddp
"nnoremap _ ddkP

" Tip: Use <c-d> <f-d> and <m-d> to map Ctrl-d Func-d and Alt-d to something
" Tip: 'map' has consequences, 'noremap' doesn't
"
" Make words upper case when in normal modse
" nnoremap <c-u> viwUe

" Quick access to vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
" Quick sourcing the vimrc
nnoremap <leader>sv :source $MYVIMRC<cr>

" Put in double quotes
vnoremap <leader>" <esc>`<i"<esc>`>la"<esc>
nnoremap <leader>" viw<esc>a"<esc>hbi"<esc>lel

" Save current file with pressing ö
nnoremap ö :w<esc>

" Quit windows with gq
nnoremap gq :q<CR>

" Treat some_variable as two words, seperated by _
" set iskeyword-=_

" Change inside / outside _word_
" TODO: Do that with functions for _word and word_
nnoremap ci_ :call Testi() <CR>

function! Testi()
python << end_python
import vim
import sys

word = vim.eval("expand('<cword>')")
print("cursor on: {}".format(word))

vim.command('normal! ciw<CR>')
end_python
endfunction



" ------------------------------------------------------------------------------
"	 Temporal fixes (remove them later)
" ------------------------------------------------------------------------------
" This fixes strange looking characters in the current nvim build.
" See issue here: https://github.com/neovim/neovim/issues/7002
set guicursor=

" ------------------------------------------------------------------------------
"	 Tips and tricks
" ------------------------------------------------------------------------------
" To search for word doubles (e.g. the the) (note trailing white space):
"\v \zs(\w+) \1\ze 

