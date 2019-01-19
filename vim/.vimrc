set nocompatible              " be iMproved, required
filetype off                  " required
filetype plugin on

" ------------------ Plugins -------------------------
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Plugin 'https://github.com/freeo/vim-kalisi'

" For commenting stuff
Plugin 'scrooloose/nerdcommenter'

Plugin 'christoomey/vim-tmux-navigator'
" code browser
Plugin 'https://github.com/majutsushi/tagbar'
nmap <C-\> :TagbarToggle<CR>
" smart parentheses
Plugin 'https://github.com/jiangmiao/auto-pairs'
" autocomplete
Plugin 'Valloric/YouCompleteMe'
highlight Pmenu ctermbg=238 gui=bold ctermfg=2
" compile stuff
" Plugin 'jonmorehouse/vim-flow'
" surround with tags and parentheses
Plugin 'tpope/vim-surround'
" remember mappings
Plugin 'urbainvaes/vim-remembrall'
" fzf
set rtp+=~/.fzf
Plugin 'junegunn/fzf.vim'
call vundle#end()            " required
" ------------------ Generic -------------------------
filetype plugin indent on    " required

syntax on
set number
set rnu

" Indents
filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

" case insensitive search
set ignorecase

" ------------------ completion setup -------------------------
"YCM config
"let g:ycm_filetype_whitelist = { 'cpp' : 1, 'python' : 1  }
let g:ycm_filetype_blacklist = { 'vim' : 1, 'text' : 1  }
"let g:ycm_filetype_specific_completion_to_disable = { 'python': 1   }
let g:ycm_confirm_extra_conf = 0
let g:ycm_autoclose_preview_window_after_completion=1
nnoremap <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>
" ------------------ Fixes -------------------------
" set <m-a>=^[a
" map <m-a> ggVG
set nowrap
set fo-=t
set noswapfile
" copy to clipboard by default
set clipboard=unnamedplus
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
set timeoutlen=1000 ttimeoutlen=10
" ------------------ Functions -------------------------
" ------------------ Keys -------------------------
let mapleader = "\<Space>"
inoremap jk <esc>
inoremap kj <esc>
" simplify vertical movement
nnoremap k gk
nnoremap j gj

nnoremap <C-e> <C-u>
inoremap <C-e> <esc>$a

noremap <Leader>y "*y
noremap <Leader>p "*p

" some spacemacs keys
nmap <LEADER>fs :w<CR>
nmap <LEADER>fed :e ~/.vimrc<CR>
nmap <LEADER>feR :source ~/.vimrc<CR>

nnoremap <LEADER>bb :buffers<CR>:buffer<Space>
nnoremap <C-s> :w<CR>

" build
" map <C-b> :FlowRun<CR>
nnoremap <C-b> :make<CR>
" nmap <C-B> :makeprg\t
" ------------------------------ WM -------------------------
nnoremap <LEADER>ws :hsplit<CR>
nnoremap <LEADER>w/ :vsplit<CR>
nnoremap <LEADER>wh :vsplit<CR>
" ------------------ rememberall -------------------------
nnoremap <silent> <LEADER>? :call remembrall#remind('n', ',')<cr>
vnoremap <silent> ? :call remembrall#remind('n', '')<cr>
" ------------------ TMUX -------------------------
let g:tmux_navigator_no_mappings = 1

execute "set <M-h>=\eh"
execute "set <M-j>=\ej"
execute "set <M-k>=\ek"
execute "set <M-l>=\el"
nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
" nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>

if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_SR = "\<Esc>]50;CursorShape=2\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

inoremap <C-o> <esc>o
inoremap <C-f> <esc>lli
inoremap <C-f> <esc>lli
inoremap <C-d> <esc>lxi
inoremap <C-a> <esc>^i
inoremap <C-b> <esc>lhi
nnoremap <C-a> <esc>^
" inoremap <C-v> <esc>pi

" Mapping alt key is tricky
execute "set <M-f>=\ef"
execute "set <M-b>=\eb"
execute "set <M-o>=\eo"
inoremap <M-f> <esc>lwi
inoremap <M-b> <esc><esc>bi
" inoremap <M-b> <C-c>bi
inoremap <M-o> <esc>O
" easier moving blocks of code
vnoremap < <gv
vnoremap > >gv

" ------------------ NERD COMMENTER -------------------------
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
vmap <silent><LEADER>; <Plug>NERDCommenterToggle
nmap <silent><LEADER>; <Plug>NERDCommenterToggle
" execute "set <M-;>=\e;"
" inoremap <M-;>; <Plug>NERDCommenterToggle
inoremap <M-;>; <Plug>NERDCommenterToggle
" ------------------ Surround -------------------------------
vmap ( S)
vmap [ S]
vmap { S}
" ------------------ POWERLINE ------------------------------
set rtp+=$HOME/.local/lib/python3.6/site-packages/powerline/bindings/vim/
" Always show statusline
set laststatus=2
let g:airline_powerline_fonts='fancy'

" colorscheme kalisi
" set background=dark
" if exists('+colorcolumn')
  " set colorcolumn=80
" else
    " au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
" endif

set t_Co=256

" enable mouse
:set mouse=a
" auto remove trailing whitespaces
autocmd BufWritePre * %s/\s\+$//e
