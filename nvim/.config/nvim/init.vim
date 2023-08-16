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
    nnoremap - <Cmd>call VSCodeNotifyVisual('vsnetrw.open', 1)<CR>

    nnoremap go <Cmd>call VSCodeNotifyVisual('C_Cpp.SwitchHeaderSource', 1)<CR>
    nnoremap <leader>gg <Cmd>call VSCodeNotifyVisual('magit.status', 1)<CR>
    vnoremap <leader>gg <Cmd>call VSCodeNotifyVisual('magit.status', 1)<CR>

    " Leader bindings
    " NOTE: more bindings at https://github.com/VSpaceCode/vscode-which-key/blob/master/package.json
    "
    " global
    nnoremap <leader><Space> <Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>
    vnoremap <leader><Space> <Cmd>call VSCodeNotifyVisual('workbench.action.quickOpen', 1)<CR>
    nnoremap <leader>x <Cmd>call VSCodeNotifyVisual('workbench.action.showCommands', 1)<CR>
    vnoremap <leader>x <Cmd>call VSCodeNotifyVisual('workbench.action.showCommands', 1)<CR>
    " numbers - Focus window
    nnoremap <leader>1 <Cmd>call VSCodeNotifyVisual('workbench.action.focusFirstEditorGroup', 1)<CR>
    vnoremap <leader>1 <Cmd>call VSCodeNotifyVisual('workbench.action.focusFirstEditorGroup', 1)<CR>
    nnoremap <leader>2 <Cmd>call VSCodeNotifyVisual('workbench.action.focusSecondEditorGroup', 1)<CR>
    vnoremap <leader>2 <Cmd>call VSCodeNotifyVisual('workbench.action.focusSecondEditorGroup', 1)<CR>
    nnoremap <leader>3 <Cmd>call VSCodeNotifyVisual('workbench.action.focusThirdEditorGroup', 1)<CR>
    vnoremap <leader>3 <Cmd>call VSCodeNotifyVisual('workbench.action.focusThirdEditorGroup', 1)<CR>
    nnoremap <leader>4 <Cmd>call VSCodeNotifyVisual('workbench.action.focusFourthEditorGroup', 1)<CR>
    vnoremap <leader>4 <Cmd>call VSCodeNotifyVisual('workbench.action.focusFourthEditorGroup', 1)<CR>
    nnoremap <leader>5 <Cmd>call VSCodeNotifyVisual('workbench.action.focusFifthEditorGroup', 1)<CR>
    vnoremap <leader>5 <Cmd>call VSCodeNotifyVisual('workbench.action.focusFifthEditorGroup', 1)<CR>
    nnoremap <leader>6 <Cmd>call VSCodeNotifyVisual('workbench.action.focusSixthEditorGroup', 1)<CR>
    vnoremap <leader>6 <Cmd>call VSCodeNotifyVisual('workbench.action.focusSixthEditorGroup', 1)<CR>
    nnoremap <leader>7 <Cmd>call VSCodeNotifyVisual('workbench.action.focusSeventhEditorGroup', 1)<CR>
    vnoremap <leader>7 <Cmd>call VSCodeNotifyVisual('workbench.action.focusSeventhEditorGroup', 1)<CR>
    nnoremap <leader>8 <Cmd>call VSCodeNotifyVisual('workbench.action.focusEighthEditorGroup', 1)<CR>
    vnoremap <leader>8 <Cmd>call VSCodeNotifyVisual('workbench.action.focusEighthEditorGroup', 1)<CR>
    nnoremap <leader>9 <Cmd>call VSCodeNotifyVisual('workbench.action.focusNinthEditorGroup', 1)<CR>
    vnoremap <leader>9 <Cmd>call VSCodeNotifyVisual('workbench.action.focusNinthEditorGroup', 1)<CR>
    nnoremap <leader>0 <Cmd>call VSCodeNotifyVisual('workbench.action.focusTenthEditorGroup', 1)<CR>
    vnoremap <leader>0 <Cmd>call VSCodeNotifyVisual('workbench.action.focusTenthEditorGroup', 1)<CR>
    " prefix b -- Buffers
    nnoremap <leader>bb <Cmd>call VSCodeNotifyVisual('workbench.action.showAllEditors', 1)<CR>
    vnoremap <leader>bb <Cmd>call VSCodeNotifyVisual('workbench.action.showAllEditors', 1)<CR>
    nnoremap <leader>bB <Cmd>call VSCodeNotifyVisual('workbench.action.showEditorsInActiveGroup', 1)<CR>
    vnoremap <leader>bB <Cmd>call VSCodeNotifyVisual('workbench.action.showEditorsInActiveGroup', 1)<CR>
    nnoremap <leader>bd <Cmd>call VSCodeNotifyVisual('workbench.action.closeActiveEditor', 1)<CR>
    vnoremap <leader>bd <Cmd>call VSCodeNotifyVisual('workbench.action.closeActiveEditor', 1)<CR>
    nnoremap <leader>bh <Cmd>call VSCodeNotifyVisual('workbench.action.moveEditorToLeftGroup', 1)<CR>
    vnoremap <leader>bh <Cmd>call VSCodeNotifyVisual('workbench.action.moveEditorToLeftGroup', 1)<CR>
    nnoremap <leader>bj <Cmd>call VSCodeNotifyVisual('workbench.action.moveEditorToBelowGroup', 1)<CR>
    vnoremap <leader>bj <Cmd>call VSCodeNotifyVisual('workbench.action.moveEditorToBelowGroup', 1)<CR>
    nnoremap <leader>bk <Cmd>call VSCodeNotifyVisual('workbench.action.moveEditorToAboveGroup', 0)<CR>
    vnoremap <leader>bk <Cmd>call VSCodeNotifyVisual('workbench.action.moveEditorToAboveGroup', 1)<CR>
    nnoremap <leader>bl <Cmd>call VSCodeNotifyVisual('workbench.action.moveEditorToRightGroup', 1)<CR>
    vnoremap <leader>bl <Cmd>call VSCodeNotifyVisual('workbench.action.moveEditorToRightGroup', 1)<CR>
    nnoremap <leader>bn <Cmd>call VSCodeNotifyVisual('workbench.action.files.newUntitledFile', 1)<CR>
    vnoremap <leader>bn <Cmd>call VSCodeNotifyVisual('workbench.action.files.newUntitledFile', 1)<CR>
    " prefix e -- Errors
    nnoremap <leader>el <Cmd>call VSCodeNotifyVisual('workbench.actions.view.problems', 1)<CR>
    vnoremap <leader>el <Cmd>call VSCodeNotifyVisual('workbench.actions.view.problems', 1)<CR>
    " prefix d -- +Debug
    nnoremap <leader>dd <Cmd>call VSCodeNotifyVisual('workbench.action.debug.start', 1)<CR>
    vnoremap <leader>dd <Cmd>call VSCodeNotifyVisual('workbench.action.debug.start', 1)<CR>
    nnoremap <leader>dD <Cmd>call VSCodeNotifyVisual('workbench.action.debug.run', 1)<CR>
    vnoremap <leader>dD <Cmd>call VSCodeNotifyVisual('workbench.action.debug.run', 1)<CR>
    nnoremap <leader>dS <Cmd>call VSCodeNotifyVisual('workbench.action.debug.stop', 1)<CR>
    vnoremap <leader>dS <Cmd>call VSCodeNotifyVisual('workbench.action.debug.stop', 1)<CR>
    nnoremap <leader>dx <Cmd>call VSCodeNotifyVisual('workbench.action.debug.stop', 1)<CR>
    vnoremap <leader>dx <Cmd>call VSCodeNotifyVisual('workbench.action.debug.stop', 1)<CR>
    nnoremap <leader>ds <Cmd>call VSCodeNotifyVisual('workbench.action.debug.stepOver', 1)<CR>
    vnoremap <leader>ds <Cmd>call VSCodeNotifyVisual('workbench.action.debug.stepOver', 1)<CR>
    vnoremap <leader>di <Cmd>call VSCodeNotifyVisual('workbench.action.debug.stepInto', 1)<CR>
    " prefix i -- Insert
    nnoremap <leader>is <Cmd>call VSCodeNotifyVisual('editor.action.insertSnippet', 1)<CR>
    vnoremap <leader>is <Cmd>call VSCodeNotifyVisual('editor.action.insertSnippet', 1)<CR>
    " prefix f -- Files
    nnoremap <leader>fk <Cmd>call VSCodeNotifyVisual('workbench.action.openGlobalKeybindingsFile', 1)<CR>
    vnoremap <leader>fk <Cmd>call VSCodeNotifyVisual('workbench.action.openGlobalKeybindingsFile', 1)<CR>
    nnoremap <leader>fs <Cmd>call VSCodeNotifyVisual('workbench.action.quickOpen', 1)<CR>
    vnoremap <leader>fs <Cmd>call VSCodeNotifyVisual('workbench.action.quickOpen', 1)<CR>
    nnoremap <leader>fs <Cmd>call VSCodeNotifyVisual('workbench.action.files.save', 1)<CR>
    vnoremap <leader>fs <Cmd>call VSCodeNotifyVisual('workbench.action.files.save', 1)<CR>
    nnoremap <leader>fr <Cmd>call VSCodeNotifyVisual('workbench.action.openRecent', 1)<CR>
    vnoremap <leader>fr <Cmd>call VSCodeNotifyVisual('workbench.action.openRecent', 1)<CR>
    nnoremap <leader>fy <Cmd>call VSCodeNotifyVisual('workbench.action.files.copyPathOfActiveFile', 1)<CR>
    vnoremap <leader>fy <Cmd>call VSCodeNotifyVisual('workbench.action.files.copyPathOfActiveFile', 1)<CR>
    nnoremap <leader>fl <Cmd>call VSCodeNotifyVisual('workbench.action.editor.changeLanguageMode', 1)<CR>
    vnoremap <leader>fl <Cmd>call VSCodeNotifyVisual('workbench.action.editor.changeLanguageMode', 0)<CR>
    nnoremap <leader>f= <Cmd>call VSCodeNotifyVisual('editor.action.formatDocument', 1)<CR>
    vnoremap <leader>f= <Cmd>call VSCodeNotifyVisual('editor.action.formatDocument', 1)<CR>
    " prefix h -- ?
    nnoremap <leader>ht <Cmd>call VSCodeNotifyVisual('workbench.action.selectTheme', 1)<CR>
    " prefix p -- Project
    nnoremap <leader>pp <Cmd>call VSCodeNotifyVisual('projectManager.listProjects', 1)<CR>
    vnoremap <leader>pp <Cmd>call VSCodeNotifyVisual('projectManager.listProjects', 1)<CR>
    nnoremap <leader>pa <Cmd>call VSCodeNotifyVisual('projectManager.editProjects', 1)<CR>
    vnoremap <leader>pa <Cmd>call VSCodeNotifyVisual('projectManager.editProjects', 1)<CR>
    nnoremap <leader>pg <Cmd>call VSCodeNotifyVisual('workbench.action.openWorkspaceSettingsFile', 1)<CR>
    vnoremap <leader>pg <Cmd>call VSCodeNotifyVisual('workbench.action.openWorkspaceSettingsFile', 1)<CR>
    " prefix w -- Window
    nnoremap <leader>ws <Cmd>call VSCodeNotifyVisual('workbench.action.splitEditorDown', 1)<CR>
    vnoremap <leader>ws <Cmd>call VSCodeNotifyVisual('workbench.action.splitEditorDown', 1)<CR>
    nnoremap <leader>wv <Cmd>call VSCodeNotifyVisual('workbench.action.splitEditor', 1)<CR>
    vnoremap <leader>wv <Cmd>call VSCodeNotifyVisual('workbench.action.splitEditor', 1)<CR>
    nnoremap <leader>w= <Cmd>call VSCodeNotifyVisual('workbench.action.evenEditorWidths', 1)<CR>
    vnoremap <leader>w= <Cmd>call VSCodeNotifyVisual('workbench.action.evenEditorWidths', 1)<CR>
    nnoremap <leader>wz <Cmd>call VSCodeNotifyVisual('workbench.action.joinAllGroups', 1)<CR>
    vnoremap <leader>wz <Cmd>call VSCodeNotifyVisual('workbench.action.joinAllGroups', 1)<CR>
    nnoremap <leader>w1 <Cmd>call VSCodeNotifyVisual('workbench.action.joinAllGroups', 1)<CR>
    vnoremap <leader>w1 <Cmd>call VSCodeNotifyVisual('workbench.action.joinAllGroups', 1)<CR>
    nnoremap <leader>wd <Cmd>call VSCodeNotifyVisual('workbench.action.closeEditorsInGroup', 1)<CR>
    vnoremap <leader>w1 <Cmd>call VSCodeNotifyVisual('workbench.action.joinAllGroups', 1)<CR>
    nnoremap <leader>wx <Cmd>call VSCodeNotifyVisual('workbench.action.closeAllGroups', 1)<CR>
    vnoremap <leader>wx <Cmd>call VSCodeNotifyVisual('workbench.action.closeAllGroups', 1)<CR>
    " prefix s -- Search
    noremap  <leader>sj <Cmd>call VSCodeNotifyVisual('workbench.action.gotoSymbol', 1)<CR>

else
    " ordinary Neovim
    nnoremap <silent> <A-k> :wincmd k<CR>
    vnoremap <silent> <A-k> :wincmd k<CR>
    nnoremap <silent> <A-j> :wincmd j<CR>
    vnoremap <silent> <A-j> :wincmd j<CR>
    nnoremap <silent> <A-h> :wincmd h<CR>
    vnoremap <silent> <A-h> :wincmd h<CR>
    nnoremap <silent> <A-l> :wincmd l<CR>
    nnoremap <silent> <A-l> :wincmd l<CR>
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


