if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endi


call plug#begin('~/.vim/plugged')
    Plug 'numToStr/Comment.nvim'
    Plug 'Shougo/vimproc.vim', { 'do': 'make' }
    Plug 'goldfeld/vim-seek'
    Plug 'bkad/CamelCaseMotion'
    Plug 'tpope/vim-surround'
call plug#end()

lua require('Comment').setup()

let mapleader = "\<Space>"

if exists('g:vscode')
    " VSCode extension
    " nnoremap <A-x> <Cmd>call VSCodeNotifyVisual('workbench.action.showCommands', 1)<CR>
    " vnoremap <A-x> <Cmd>call VSCodeNotifyVisual('workbench.action.showCommands', 1)<CR>

    "" dired
    nnoremap - <Cmd>call VSCodeNotify('vsnetrw.open', 1)<CR>

    nnoremap go <Cmd>call VSCodeNotify('C_Cpp.SwitchHeaderSource', 1)<CR>
    nnoremap <leader>gg <Cmd>call VSCodeNotify('magit.status', 1)<CR>
    vnoremap <leader>gg <Cmd>call VSCodeNotify('magit.status', 1)<CR>

    " Leader bindings
    " NOTE: more bindings at https://github.com/VSpaceCode/vscode-which-key/blob/master/package.json
    "
    " global
    noremap <leader><Space> <Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>
    noremap <leader>x <Cmd>call VSCodeNotify('workbench.action.showCommands', 1)<CR>
    " numbers - Focus window
    noremap <leader>1 <Cmd>call VSCodeNotify('workbench.action.focusFirstEditorGroup', 1)<CR>
    noremap <leader>2 <Cmd>call VSCodeNotify('workbench.action.focusSecondEditorGroup', 1)<CR>
    noremap <leader>3 <Cmd>call VSCodeNotify('workbench.action.focusThirdEditorGroup', 1)<CR>
    noremap <leader>4 <Cmd>call VSCodeNotify('workbench.action.focusFourthEditorGroup', 1)<CR>
    noremap <leader>5 <Cmd>call VSCodeNotify('workbench.action.focusFifthEditorGroup', 1)<CR>
    noremap <leader>6 <Cmd>call VSCodeNotify('workbench.action.focusSixthEditorGroup', 1)<CR>
    noremap <leader>7 <Cmd>call VSCodeNotify('workbench.action.focusSeventhEditorGroup', 1)<CR>
    noremap <leader>8 <Cmd>call VSCodeNotify('workbench.action.focusEighthEditorGroup', 1)<CR>
    noremap <leader>9 <Cmd>call VSCodeNotify('workbench.action.focusNinthEditorGroup', 1)<CR>
    noremap <leader>0 <Cmd>call VSCodeNotify('workbench.action.focusTenthEditorGroup', 1)<CR>
    " prefix b -- Buffers
    noremap <leader>bb <Cmd>call VSCodeNotify('workbench.action.showAllEditors', 1)<CR>
    noremap <leader>bB <Cmd>call VSCodeNotify('workbench.action.showEditorsInActiveGroup', 1)<CR>
    noremap <leader>bd <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor', 1)<CR>
    noremap <leader>bh <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup', 1)<CR>
    noremap <leader>bj <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup', 1)<CR>
    noremap <leader>bk <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup', 0)<CR>
    noremap <leader>bl <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup', 1)<CR>
    noremap <leader>bn <Cmd>call VSCodeNotify('workbench.action.files.newUntitledFile', 1)<CR>
    " prefix e -- Errors
    noremap <leader>el <Cmd>call VSCodeNotify('workbench.actions.view.problems', 1)<CR>
    " prefix d -- +Debug
    noremap <leader>dd <Cmd>call VSCodeNotify('workbench.action.debug.start', 1)<CR>
    noremap <leader>dD <Cmd>call VSCodeNotify('workbench.action.debug.run', 1)<CR>
    noremap <leader>dS <Cmd>call VSCodeNotify('workbench.action.debug.stop', 1)<CR>
    noremap <leader>dx <Cmd>call VSCodeNotify('workbench.action.debug.stop', 1)<CR>
    noremap <leader>ds <Cmd>call VSCodeNotify('workbench.action.debug.stepOver', 1)<CR>
    noremap <leader>di <Cmd>call VSCodeNotify('workbench.action.debug.stepInto', 1)<CR>
    " prefix i -- Insert
    noremap <leader>is <Cmd>call VSCodeNotify('editor.action.insertSnippet', 1)<CR>
    " prefix f -- Files
    noremap <leader>fk <Cmd>call VSCodeNotify('workbench.action.openGlobalKeybindingsFile', 1)<CR>
    noremap <leader>fs <Cmd>call VSCodeNotify('workbench.action.quickOpen', 1)<CR>
    noremap <leader>fs <Cmd>call VSCodeNotify('workbench.action.files.save', 1)<CR>
    noremap <leader>fr <Cmd>call VSCodeNotify('workbench.action.openRecent', 1)<CR>
    noremap <leader>fy <Cmd>call VSCodeNotify('workbench.action.files.copyPathOfActiveFile', 1)<CR>
    noremap <leader>fl <Cmd>call VSCodeNotify('workbench.action.editor.changeLanguageMode', 1)<CR>
    noremap <leader>f= <Cmd>call VSCodeNotify('editor.action.formatDocument', 1)<CR>
    " prefix h -- ?
    nnoremap <leader>ht <Cmd>call VSCodeNotify('workbench.action.selectTheme', 1)<CR>
    " prefix p -- Project
    noremap <leader>pp <Cmd>call VSCodeNotify('projectManager.listProjects', 1)<CR>
    noremap <leader>pa <Cmd>call VSCodeNotify('projectManager.editProjects', 1)<CR>
    noremap <leader>pg <Cmd>call VSCodeNotify('workbench.action.openWorkspaceSettingsFile', 1)<CR>
    noremap <leader>pf <Cmd>call VSCodeNotify('workbench.action.quickOpen', 1)<CR>
    " prefix w -- Window
    noremap <leader>ws <Cmd>call VSCodeNotify('workbench.action.splitEditorDown', 1)<CR>
    noremap <leader>wv <Cmd>call VSCodeNotify('workbench.action.splitEditor', 1)<CR>
    noremap <leader>w= <Cmd>call VSCodeNotify('workbench.action.evenEditorWidths', 1)<CR>
    noremap <leader>wz <Cmd>call VSCodeNotify('workbench.action.joinAllGroups', 1)<CR>
    noremap <leader>w1 <Cmd>call VSCodeNotify('workbench.action.joinAllGroups', 1)<CR>
    noremap <leader>wd <Cmd>call VSCodeNotify('workbench.action.closeEditorsInGroup', 1)<CR>
    noremap <leader>wx <Cmd>call VSCodeNotify('workbench.action.closeAllGroups', 1)<CR>
    " prefix s -- Search
    noremap  <leader>sj <Cmd>call VSCodeNotify('workbench.action.gotoSymbol', 1)<CR>
    " prefix tab - go to prev buffer
    noremap  <leader><tab> <Cmd>call VSCodeNotify('extension.goto-previous-buffer', 1)<CR>
else
    " ordinary Neovim
    noremap <silent> <A-k> :wincmd k<CR>
    noremap <silent> <A-j> :wincmd j<CR>
    noremap <silent> <A-h> :wincmd h<CR>
    noremap <silent> <A-l> :wincmd l<CR>
    noremap <silent> <C-j> <C-e>
    noremap <silent> <C-k> <C-y>
    nnoremap <C-e> <C-u>
    vnoremap <C-e> <C-u>
    inoremap <C-e> <esc>$a
endif

"
" Comment
nmap <silent> <Space>; gcc
vmap <silent> <Space>; gc
nnoremap ` %
vnoremap ` %


" fix go back character when entering normal mode from insert mode
:inoremap <silent> <Esc> <Esc>`^

" camel/snake case motions
map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
sunmap w
sunmap b
sunmap e
omap <silent> iw <Plug>CamelCaseMotion_iw
xmap <silent> iw <Plug>CamelCaseMotion_iw
omap <silent> ib <Plug>CamelCaseMotion_ib
xmap <silent> ib <Plug>CamelCaseMotion_ib
omap <silent> ie <Plug>CamelCaseMotion_ie
xmap <silent> ie <Plug>CamelCaseMotion_ie

nnoremap <silent> > >>
vnoremap <silent> > >>
nnoremap <silent> < <<
vnoremap <silent> < <<
nnoremap <silent> <Tab> ==
vnoremap <silent> <Tab> =

" Surround
vmap <silent> s S
" use system clipboard
set clipboard+=unnamedplus


