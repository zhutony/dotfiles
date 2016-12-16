" vim:foldmethod=marker:foldlevel=0
" zo + zc to open / close folds in case I forgot :P
call plug#begin('~/.config/nvim/plugged')

" Plug {{{
function! DoRemote(arg)
  UpdateRemotePlugins
endfunction
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
Plug 'scrooloose/nerdtree'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'justinmk/vim-sneak'
Plug 'tomtom/tcomment_vim' " gc comments

" FZF
if executable('fzf')
  Plug '/usr/local/opt/fzf'
  Plug 'junegunn/fzf.vim'
endif


" Scala plugins
Plug 'derekwyatt/vim-scala'
" Haskell Plugins
" Plug 'neovimhaskell/haskell-vim'

call plug#end()
" }}}

" Leader key
let mapleader = ","

" Custom
source ~/.config/nvim/custom/functions.vim
nnoremap <leader>t :call ToggleTodo()<cr>
vnoremap <leader>t :call ToggleTodo()<cr>

" SYNTAX HILIGHTING {{{
set t_Co=256
colorscheme delek
syntax on
set background=dark

hi MatchParen cterm=none ctermbg=none ctermfg=red
hi Pmenu ctermbg=black ctermfg=white
hi LineNr ctermfg=black
hi CursorLineNr ctermfg=blue
hi Comment ctermfg=black
hi Folded ctermbg=none ctermfg=white

" whitespace
highlight ExtraWhitespace ctermbg=red guibg=red

match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Automatic syntax highlighting for files
au BufRead,BufNewFile *.txt     set filetype=markdown
au BufRead,BufNewFile *.conf    set filetype=dosini
au BufRead,BufNewFile *.bash*   set filetype=sh

" Better split character
" Override color scheme to make split them black
" set fillchars=vert:\|
set fillchars=vert:│
highlight VertSplit cterm=NONE ctermfg=black ctermbg=NONE
" }}}

" arrow keys disable
nnoremap <right> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <up> <nop>

vnoremap <right> <nop>
vnoremap <down> <nop>
vnoremap <left> <nop>
vnoremap <up> <nop>

" j/k move virtual lines, gj/jk move physical lines
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" brace completion {{{
set showmatch
inoremap {      {}<Left>
inoremap {<CR>  {<CR>}<Esc>O
inoremap <expr> }  strpart(getline('.'), col('.')-1, 1) == "}" ? "\<Right>" : "}"
inoremap {}     {}

inoremap (      ()<Left>
inoremap (<CR>  (<CR>)<Esc>O
inoremap <expr> )  strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"
inoremap ()     ()

inoremap [      []<Left>
inoremap [<CR>  [<CR>]<Esc>O
inoremap <expr> ]  strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"
inoremap []     []
" }}}
" General/Toggleable Settings {{{
" horizontal split splits below
set splitbelow

" indentation
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent

" line numbers
set number
set relativenumber

" show title
set title

" mouse
set mouse-=a

" utf-8 ftw
" nvim sets utf8 by default, wrap in if because prevents reloading vimrc
if !has('nvim')
  set encoding=utf-8
endif

" Ignore case unless use a capital in search (smartcase needs ignore set)
set ignorecase
set smartcase
" }}}
" Plugins + Custom functions {{{
" panes
nnoremap <leader>d :vsp<cr>
set splitright
nnoremap <leader>s :split<cr>
set splitbelow
" map <C-w>w (switch buffer focus) to something nicer
nnoremap <leader>w <C-w>w

" deoplete
let g:deoplete#enable_at_startup=1
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-i>"

" NERDTree
" Open NERDTree in the directory of the current file (or /home if no file is open)
function! NERDTreeToggleFind()
  if (exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1)
    execute ":NERDTreeClose"
  else
    execute ":NERDTreeFind"
  endif
endfunction

autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
nnoremap <leader>c :call NERDTreeToggleFind()<cr>

" sarsi
let sarsivim = 'sarsi-nvim'
if (executable(sarsivim))
  call rpcstart(sarsivim)
endif
nnoremap <leader>l :cfirst<cr>
nnoremap <leader>f :cnext<cr>
nnoremap <leader>g :cprevious<cr>

" Edit vimrc
nnoremap <leader>ev :edit $MYVIMRC<cr>
" nnoremap <leader>sv :source $MYVIMRC<cr>

" Quickfix toggle
nnoremap <leader>q :call QuickfixToggle()<cr>

set colorcolumn=101
highlight colorcolumn ctermbg=black

if executable('rg')
  set grepprg=rg\ --color=never
endif

" airline
set laststatus=2
let g:airline_left_sep=""
let g:airline_left_alt_sep="|"
let g:airline_right_sep=""
let g:airline_right_alt_sep="|"
source ~/.config/nvim/custom/custom-airline.vim
let g:airline_theme="customairline"

" FZF
function! Fzf_tags_sink(line)
  " Split line in tags file by parts, jump to file + line number
  " <tag><TAB><file><TAB><lineNumber>
  let parts = split(a:line, '\t')
  execute 'silent e' parts[1]
  execute 'normal! ' . parts[2] . 'G'
endfunction

if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --no-messages "" .'
endif

let g:fzf_command_prefix = 'Fzf'
let fzf_tags_sink = {'sink': function('Fzf_tags_sink')}
nnoremap <leader>v :FzfFiles<cr>
nnoremap <leader>u :call fzf#vim#tags("", fzf_tags_sink)<cr>
nnoremap <leader>j :call fzf#vim#tags("'".expand('<cword>'), fzf_tags_sink)<cr>
" }}}