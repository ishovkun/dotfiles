;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; place your private configuration here
;; (setq doom-font (font-spec :family "Iosevka SS04" :size 14))
(when (string= (system-name) "space")
  ;; manjaro hack
  ;; (setq doom-font (font-spec :family "Iosevka" :size 27 :width 'normal)))
  ;; (setq doom-font (font-spec :family "Iosevka SS04" :size 25))
  (setq doom-font (font-spec :family "IosevkaTerm Nerd Font" :size 25))
  (setq-default line-spacing 5)
  )

(if (eq system-type 'darwin)
    (progn
       (setq doom-font (font-spec :family "Iosevka Nerd Font" :size 12))
        ;;; I prefer cmd key for meta
       (setq mac-option-key-is-meta nil
             mac-command-key-is-meta t
             mac-command-modifier 'meta
             mac-option-modifier 'none)
       (setq-default line-spacing 5)
       (set-ligatures! 'python-mode
         ;; Types
         :null "None"
         :true "True" :false "False"
         :int "int" :str "str"
         :float "float"
         :bool "bool"
         :tuple "tuple"
         :for "for"
         :return "return")
       )
  )

(map!
 (:map treemacs-mode-map
  "M-l"         #'evil-window-right
  "M-h"         #'evil-window-left
  )
 :desc "Invoke deer" :n  "-" #'dirvish-dwim
 (:map dirvish-mode-map
  :desc "up directory" :nv "h" #'dired-up-directory
  :desc "open"         :n "l" #'dired-find-file
  )

 ;; window management
 (:map override
  :nv "M-k"         #'evil-window-up
  :nv "M-j"         #'evil-window-down
  :nv "M-l"         #'evil-window-right
  :nv "M-h"         #'evil-window-left
  :nv "M-M"         #'+workspace/switch-left
  :nv "M-<"         #'+workspace/switch-right
  :nvi "<mouse-5>"  #'scroll-up-line
  :nvi "<mouse-4>"  #'scroll-down-line

  (:after centaur-tabs
   :nv "M-n"         #'centaur-tabs-forward
   :nv "M-p"         #'centaur-tabs-backward
   :nv "C-<tab>"     #'centaur-tabs-forward
   :nv "C-S-<tab>"   #'centaur-tabs-backward
   )
  (:after awesome-tab
   :nv "C-<tab>"     #'awesome-tab-forward
   :nv "C-S-<tab>"   #'awesome-tab-backward
   :nv "M-n"         #'awesome-tab-forward
   :nv "M-p"         #'awesome-tab-backward
   )
  :nv "M-<backspace>" #'kill-current-buffer
  )
 :nv "M-="         #'increase-font-size-global
 :nv "M--"         #'decrease-font-size-global
 (:map image-mode-map :after image-mode
  :desc "Zoom in" :nv "M-="         #'increase-font-size-global
  :desc "Zoom out" :nv "M--"          #'image-decrease-size
  :desc "Invoke deer" :n "-" #'dirvish-dwim
  )
 (:map TeX-mode-map
  :nv "j"           #'evil-next-visual-line
  :nv "k"           #'evil-previous-visual-line
  )
 (:map prog-mode-map
  ;;  :i "C-h"         #'backward-delete-char
  :v "-"         #'evil-last-non-blank
  :v "="         #'evil-first-non-blank
  )
 (:map text-mode-map
  :n "Q"         #'evil-execute-macro
  )
  ;; :nv "M-H"         #'shrink-window-horizontally
  ;; :nv "M-L"         #'enlarge-window-horizontally
  ;; :nv "M-J"         #'shrink-window
  ;; :nv "M-K"         #'enlarge-window
  :nv "M-H"         #'decrease-window-width
  :nv "M-L"         #'increase-window-width
  :nv "M-J"         #'decrease-window-height
  :nv "M-K"         #'increase-window-height
  (:after org :map evil-org-mode-map
   :nv "M-H"         #'decrease-window-width
   :nv "M-L"         #'increase-window-width
   :nv "M-J"         #'decrease-window-height
   :nv "M-K"         #'increase-window-height
   )
  ;; indenting
  :n  "<"           #'evil-shift-left-line
  :n  ">"           #'evil-shift-right-line
  :n "<tab>"        #'evil-indent-line
  :v "<tab>"        #'evil-indent
  ;; moving around
  :nv "C-e"         #'evil-scroll-up
  :nv "M-e"         #'evil-scroll-up
  :nv "M-d"         #'evil-scroll-down
  :nv "`"           #'evil-jump-item
  :i  "C-f"         #'evil-forward-char
  :i  "C-b"         #'evil-backward-char
  :nvi  "M-v"         #'evil-paste-before
  :nv "g l "        #'goto-line
  :nv "C-j"         #'scroll-up-line
  :nv "C-k"         #'scroll-down-line
  ;; just list all modes, it's freaking me out
  (:after lsp :map lsp-mode-map :nv "C-j" #'scroll-up-line :nv "C-k" #'scroll-down-line)
  (:after ccls :map (c-mode-map c++-mode-map)
   :nv "C-j" #'scroll-up-line
   :nv "C-k" #'scroll-down-line
   )
  :nv "gc"          #'evil-avy-goto-char-timer
  :nv "gs"          #'counsel-imenu
  :nv "g["          #'avy-goto-char-2-above
  :nv "g]"          #'avy-goto-char-2-below
  :n  "S"           #'avy-goto-char-in-line
  :nvi "M-`"        #'+popup/toggle
  ;; :nv "S"           #'evil-snipe-s
  (:map compilation-mode-map :desc "evil backward char" :nv "h" #'evil-backward-char)
  ;; saving
  :desc "Save buffer" :nvi "C-s" #'save-buffer
  (:after evil-surround :map override :desc "Surround" :v "s" #'evil-surround-region)
  ;; editing
  :desc "Append comment" :n "M-;" #'comment-dwim
  :desc "Delete word backward" :i "C-w" #'evil-delete-backward-word
  :desc "Delete word backward" :i "<C-backspace>" #'evil-delete-backward-word
  (:after evil
    :desc ":Increment at point" "M-=" #'evil-numbers/inc-at-pt
    :desc ":Increment at point" "M--" #'evil-numbers/dec-at-pt
    :i "C-y" #'evil-paste-before
    )
  :desc "Detete character" :i "C-d" #'evil-delete-char
  :desc "New line above&insert" :nv "M-o" #'+default/newline-above
  ;; mode-specific
  (:prefix "g"
    (:after projectile :map c++-mode-map
      :desc "Switch implementation/header" :nv "o" #'projectile-find-other-file)
    (:desc "Find references" :n "r" #'+lookup/references)
    (:map override :desc "Copy and comment" :nv "y" #'duplicate-and-comment-line)
  ) ; end prefix g
  (:after projectile :map prog-mode-map
    :desc "Recompile" :nv "<f6>" #'recompile
    :desc "Recompile" :nv "<C-return>" #'recompile
    :desc "Recompile" :nv "<return>" #'recompile
    :desc "Recompile" :nv "C-<f9>" #'recompile ; in terminal
    )
  (:after tex :map LaTeX-mode-map :desc "Recompile" :nv "<C-return>" #'latex/build)
  ;; ivy
  (:after ivy :map ivy-mode-map
   :desc "Kill buffer" "C-d" #'ivy-switch-buffer-kill
   :desc "ivy next" "C-j" #'ivy-next-line
   :desc "ivy previous" "C-k" #'ivy-previous-line
   )
  ;; org
  (:after org :map org-mode-map
    :desc "Preview LaTeX" :niv "<M-return>" #'org-latex-preview)
  ;; c++
  (:map c++-mode-map
    :desc "Quick run" :niv "<M-return>" #'quickrun)
  ;; python
  (:map python-mode-map
    :desc "Quick run" :niv "<M-return>" #'quickrun)
  ;; pd-view
  (:map pdf-view-mode-map
   :desc "Page down" :nv "e" #'pdf-view-scroll-down-or-previous-page
   :desc "Page down" :nv "d" #'pdf-view-scroll-up-or-next-page)
  (:map magit-mode-map
   :desc "Toggle visibility of the body of current section" :nvi "<tab>" #'magit-section-toggle)
  (:after cfw :map cfw:calendar-mode-map
   :desc "Next item"      :nv "M-j" #'cfw:navi-next-item-command
   :desc "Previous item"  :nv "M-k" #'cfw:navi-prev-item-command
   :desc "Show details"   :nv "TAB" #'cfw:show-details-command
   :desc "Digit argument" :nv "0"   #'digit-argument
   :desc "Two week view"  :nv "T"   #'cfw:change-view-two-weeks
   :desc "Goto date"      :nv "g"   #'cfw:navi-goto-date-command
   :desc "Goto today"     :nv "t"   #'cfw:navi-goto-today-command
   )
  (:map calc-edit-mode-map
   :desc "Quit calc-edit" :nv "q" #'kill-current-buffer
   )
  ;; tabs
  (:after awesome-tab
   :desc "jump to tab 1" :nv "[1" #'awesome-tab-select-visible-tab
   :desc "jump to tab 2" :nv "[2" #'awesome-tab-select-visible-tab
   :desc "jump to tab 3" :nv "[3" #'awesome-tab-select-visible-tab
   :desc "jump to tab 4" :nv "[4" #'awesome-tab-select-visible-tab
   :desc "jump to tab 5" :nv "[5" #'awesome-tab-select-visible-tab
   :desc "jump to tab 6" :nv "[6" #'awesome-tab-select-visible-tab
   :desc "jump to tab 7" :nv "[7" #'awesome-tab-select-visible-tab
   :desc "jump to tab 8" :nv "[8" #'awesome-tab-select-visible-tab
   :desc "jump to tab 9" :nv "[9" #'awesome-tab-select-visible-tab
   )
  (:after centaur-tabs
   :desc "jump to tab 1" :nv "[1" #'centaur-tabs-select-visible-1st-tab
   :desc "jump to tab 2" :nv "[2" #'centaur-tabs-select-visible-2nd-tab
   :desc "jump to tab 3" :nv "[3" #'centaur-tabs-select-visible-3rd-tab
   :desc "jump to tab 4" :nv "[4" #'centaur-tabs-select-visible-tab
   :desc "jump to tab 5" :nv "[5" #'centaur-tabs-select-visible-tab
   :desc "jump to tab 6" :nv "[6" #'centaur-tabs-select-visible-tab
   :desc "jump to tab 7" :nv "[7" #'centaur-tabs-select-visible-tab
   :desc "jump to tab 8" :nv "[8" #'centaur-tabs-select-visible-tab
   :desc "jump to tab 9" :nv "[9" #'centaur-tabs-select-visible-tab
   :desc "jump to tab number"  :nv "gt" #'centaur-tabs-ace-jump
   )
  (:map vterm-mode-map
   :desc "send C-k"                :nvi "C-k"  #'vterm-send-C-k
   :desc "send C-j"                :nvi "C-j"  #'vterm-send-C-j
   :desc "Switch to 1st workspace" :nv "M-1"   #'+workspace/switch-to-0
   :desc "Switch to 2nd workspace" :nv "M-2"   #'+workspace/switch-to-1
   :desc "Switch to 3rd workspace" :nv "M-3"   #'+workspace/switch-to-2
   :desc "Switch to 4th workspace" :nv "M-4"   #'+workspace/switch-to-3
   :desc "Switch to 5th workspace" :nv "M-5"   #'+workspace/switch-to-4
   :desc "Switch to 6th workspace" :nv "M-6"   #'+workspace/switch-to-5
   :desc "Switch to 7th workspace" :nv "M-7"   #'+workspace/switch-to-6
   :desc "Switch to 8th workspace" :nv "M-8"   #'+workspace/switch-to-7
   :desc "Switch to 9th workspace" :nv "M-9"   #'+workspace/switch-to-8
   )
) ; end map!
(use-package! compiler-explorer
  :defer t
  :config

  ;; (defvar compiler-explorer-mode-map
  ;;   (let ((map (make-sparse-keymap)))
  ;;     ;; (set-keymap-parent map tabulated-list-mode-map)
  ;;     (evil-define-key 'normal 'visual 'compiler-explorer-mode-map (kbd "ga") 'compiler-explorer-jump)
  ;;     ;; (define-key map (kbd "RET") #'dogears-list-go)
  ;;     ;; (define-key map (kbd "k") #'dogears-list-delete)
  ;;     map)
  ;;   )

  (evil-define-key 'normal 'visual 'compiler-explorer-mode-map (kbd "ga") 'compiler-explorer-jump)
  ; (evil-define-key 'normal 'visual compiler-explorer--local-mode-map (kbd "ga") 'compiler-explorer-jump)
  ;; :desc "goto asm" :nv "ga" #'compiler-explorer-jump
  )


(map! :leader
  (:after swiper :desc "Swiper" :nv "/" #'counsel-grep-or-swiper)
  ;; commenting
  :desc "comment single line" :n ";" #'evil-commentary-line
  :desc "comment block"       :v ";" #'evil-commentary
  ;; buffers
  :desc "Switch to previous buffer" :nv "<tab>" #'spacemacs/alternate-buffer
  :desc "Switch to previous buffer" :nv "TAB" #'spacemacs/alternate-buffer ; duplicated for terminal behavior
  (:after dirvish :desc "Bookmarks" :nv "<return>" #'dirvish-quick-access)

  (:when (modulep! :ui workspaces)
    (:prefix-map ("`" . "workspace")
      :desc "Display tab bar"           "`"   #'+workspace/display
      :desc "Switch workspace"          "."   #'+workspace/switch-to
      :desc "New workspace"             "n"   #'+workspace/new
      :desc "Load workspace from file"  "l"   #'+workspace/load
      :desc "Save workspace to file"    "s"   #'+workspace/save
      :desc "Delete session"            "x"   #'+workspace/kill-session
      :desc "Delete this workspace"     "d"   #'+workspace:delete
      :desc "Rename workspace"          "r"   #'+workspace/rename
      :desc "Restore last session"      "R"   #'+workspace/restore-last-session
      :desc "Next workspace"            "]"   #'+workspace/switch-right
      :desc "Previous workspace"        "["   #'+workspace/switch-left
      :desc "Switch to 1st workspace"   "1"   #'+workspace/switch-to-0
      :desc "Switch to 2nd workspace"   "2"   #'+workspace/switch-to-1
      :desc "Switch to 3rd workspace"   "3"   #'+workspace/switch-to-2
      :desc "Switch to 4th workspace"   "4"   #'+workspace/switch-to-3
      :desc "Switch to 5th workspace"   "5"   #'+workspace/switch-to-4
      :desc "Switch to 6th workspace"   "6"   #'+workspace/switch-to-5
      :desc "Switch to 7th workspace"   "7"   #'+workspace/switch-to-6
      :desc "Switch to 8th workspace"   "8"   #'+workspace/switch-to-7
      :desc "Switch to 9th workspace"   "9"   #'+workspace/switch-to-8
      :desc "Switch to final workspace" "0"   #'+workspace/switch-to-final)
    (:prefix-map ("-" . "workspace")
      :desc "Display tab bar"           "-"   #'+workspace/display
      :desc "Switch workspace"          "."   #'+workspace/switch-to
      :desc "New workspace"             "n"   #'+workspace/new
      :desc "Load workspace from file"  "l"   #'+workspace/load
      :desc "Save workspace to file"    "s"   #'+workspace/save
      :desc "Delete session"            "x"   #'+workspace/kill-session
      :desc "Delete this workspace"     "d"   #'+workspace:delete
      :desc "Rename workspace"          "r"   #'+workspace/rename
      :desc "Restore last session"      "R"   #'+workspace/restore-last-session
      :desc "Next workspace"            "]"   #'+workspace/switch-right
      :desc "Previous workspace"        "["   #'+workspace/switch-left
      :desc "Switch to 1st workspace"   "1"   #'+workspace/switch-to-0
      :desc "Switch to 2nd workspace"   "2"   #'+workspace/switch-to-1
      :desc "Switch to 3rd workspace"   "3"   #'+workspace/switch-to-2
      :desc "Switch to 4th workspace"   "4"   #'+workspace/switch-to-3
      :desc "Switch to 5th workspace"   "5"   #'+workspace/switch-to-4
      :desc "Switch to 6th workspace"   "6"   #'+workspace/switch-to-5
      :desc "Switch to 7th workspace"   "7"   #'+workspace/switch-to-6
      :desc "Switch to 8th workspace"   "8"   #'+workspace/switch-to-7
      :desc "Switch to 9th workspace"   "9"   #'+workspace/switch-to-8
      :desc "Switch to final workspace" "0"   #'+workspace/switch-to-final)
    )
  ;; windows
  (:after winum
    :desc "Switch to 1st window" :nv "1" #'winum-select-window-1
    :desc "Switch to 2st window" :nv "2" #'winum-select-window-2
    :desc "Switch to 3st window" :nv "3" #'winum-select-window-3
    :desc "Switch to 4st window" :nv "4" #'winum-select-window-4
    :desc "Switch to 5st window" :nv "5" #'winum-select-window-5
    :desc "Switch to 6st window" :nv "6" #'winum-select-window-6
    :desc "Switch to 7st window" :nv "7" #'winum-select-window-7
    :desc "Switch to 8st window" :nv "8" #'winum-select-window-8
    :desc "Switch to 9st window" :nv "9" #'winum-select-window-9
    )
  (:prefix-map ("d" . "diff")
   :desc "ediff buffers" :nv "b" #'ediff-buffers
   :desc "ediff files" :nv "f" #'ediff-files
   )
  :desc "balance-windows" :n "=" #'balance-windows
  (:prefix "w"
    :nv "d"   #'delete-window
    :nv "SPC" #'ace-swap-window
    :nv "1"   #'delete-other-windows
    :n "f"    #'make-frame-command
    :n "D"    #'delete-frame
    :nv "v"   #'split-window-right
    :nv "s"   #'split-window-below
    :nv "e"   #'balance-windows
    )
  (:after ivy :nv "SPC" #'+ivy/switch-workspace-buffer)
  (:prefix "b"
    :desc "kill current buffer"          :nv "d" #'kill-this-buffer
    :desc "switch to compilation buffer" :nv "c" #'switch-to-compilation-buffer
    :desc "switch to messages buffer"    :nv "m" #'switch-to-messages-buffer
    :desc "switch buffer"                :nv "b" #'+ivy/switch-buffer
    :desc "show all buffers"             :nv "a" #'ibuffer-list-buffers
    )
  ;; files
  (:prefix "f"
    (:desc "Rename file" :nv "R" #'rename-file-and-buffer)
    (:desc "Browse private config dir" :nv "p" #'doom/open-private-config)
    (:desc "Save buffer" :nv "s" #'save-buffer)
    )
  ;; align
  (:prefix "a"
    :desc "align region"   :v "a"    #'align
    :desc "align region"   :v "c"    #'align-current
    :desc "align regexp"   :v "r"    #'align-regexp
    :desc "align percent"  :v "%"    #'align-repeat-percent
    :desc "align &"        :v "&"    #'align-repeat-ampersand
    :desc "align ("        :v "("    #'align-repeat-left-paren
    :desc "align )"        :v ")"    #'align-repeat-right-paren
    :desc "align ,"        :v ","    #'align-repeat-comma
    :desc "align ."        :v "."    #'align-repeat-decimal
    :desc "align :"        :v ":"    #'align-repeat-colon
    ;; :desc "align before ;" :v ":" #'align-before-last-item
    :desc "align ="        :v "="    #'align-repeat-equal
    :desc "align ["        :v "["    #'align-repeat-left-square-brace
    :desc "align ]"        :v "]"    #'align-repeat-right-square-brace
    :desc "align \\"        :v "\\"  #'align-repeat-backslash
    :desc "align |"        :v "|"    #'align-repeat-bar
    :desc "justify"        :nv "j"      #'set-justification-full
   )
  ;; projectile
  (:prefix "p"
    (:after projectile :map projectile-mode-map
      :desc "Project grep"        :nv "s" #'counsel-projectile-grep
      ;; :desc "Project find file" :nv "f" #'+ivy/projectile-find-file
      :desc "Project find file" :nv "f" #'projectile-find-file
      :desc "Project replace"   :n  "R" #'projectile-replace
      :desc "Open list of projects"   :n  "P" #'open-projects-list
      )
    )
  (:prefix "i"
   :desc "Latex input" :n "l" #'set-input-method-tex
   :desc "Insert buffer basename" :n "b" #'insert-file-basename
   )
  (:prefix "b"
   :desc "rename buffer" :n "R" #'rename-buffer)
  ;; browse functions
  (:prefix "s"
    (:desc "Browse functions" :nv "j" #'counsel-imenu)
    (:desc "Browse evil marks" :nv "m" #'counsel-evil-marks)
    )
  ;; compile
  (:prefix "c"
    :desc "recompile" :n "r" #'recompile
    (:map python-mode-map
    :desc "Quick run" :n "r" #'compile)
  )
  ;; toggles
  (:prefix "t"
    :desc "toggle line wrap" :n "L" #'toggle-truncate-lines
    :desc "toggle treemacs" :nv "\\" #'treemacs
    :desc "toggle treemacs" :nv "t" #'treemacs
  )
  (:prefix "m"
    (:after compiler-explorer :map compiler-explorer-mode-map
     :desc "goto asm" :nv "a" #'compiler-explorer-jump
     :desc "goto asm" :nv "r" #'compiler-explorer-previous-session
     :desc "goto asm" :nv "n" #'compiler-explorer-new-session
     :desc "goto asm" :nv "u" #'compiler-explorer-make-link
     :desc "goto asm" :nv "l" #'compiler-explorer-restore-from-link
     :desc "goto asm" :nv "q" #'compiler-explorer-exit
    )
  )
  (:prefix "o"
    ;; debugging
    (:after realgud :desc "toggle debug shortcuts" :n "k" #'realgud-short-key-mode)
    :desc "Open vterm" :n "t" #'+vterm/here
    :desc "Open calendar" :n "c" #'=calendar
    :desc "Open calc" :n "'" #'calc
    :desc "Open godbolt" :n "g" #'compiler-explorer
    (:after dap-mode :map c++-mode-map
     :desc "Edit default dap config" :nv "j" #'dap-debug-create-or-edit-json-template)
    (:after ein
     :desc "Open Ipython notebook" :n "i" #'ein:run)
    )
) ; end map leader

(map! :after latex
      :localleader
      :map LaTeX-mode-map
      :desc "Environment" "e" #'LaTeX-environment
      )
(map! :localleader
      :map markdown-mode-map
      :desc "Preview Emacs" "v" #'markdown-live-preview-mode
      )

(map! :after ein
      (:map ein:notebook-mode-map
       :desc "Save notebook" :nvi "C-s"  #'ein:notebook-save-notebook-command
       :desc "Interrupt" :nvi "C-c C-c"  #'ein:notebook-kernel-interrupt-command
       :desc "Next cell" :nv "]"       #'ein:worksheet-goto-next-input-km
       :desc "Prev cell" :nv "["       #'ein:worksheet-goto-prev-input-km
       :desc "Run cell" :nv "<return>"   #'ein:worksheet-execute-cell-km
       :desc "Run cell" :nv "<C-return>" #'ein:worksheet-execute-all-cells
       [remap buffer-save-function]      #'ein:notebook-save-notebook-command
       (:localleader
        :desc "Insert cell below" "o" #'ein:worksheet-insert-cell-below-km
        :desc "Insert cell above" "O" #'ein:worksheet-insert-cell-above-km
        :desc "Close notebook" "x"    #'ein:notebook-close-km
        :desc "Restart notebook" "r"   #'ein:notebook-restart-session-command
        :desc "Rename notebook" "R"   #'ein:notebook-rename-command-km
        :desc "Change cell type" "t"  #'ein:worksheet-change-cell-type-km
        :desc "Delete cell" "d"       #'ein:worksheet-kill-cell-km
        :desc "Copy cell" "y"         #'ein:worksheet-copy-cell-km
        :desc "Paste cell" "p"        #'ein:worksheet-yank-cell-km
        :desc "Clear output" "c"      #'ein:worksheet-clear-output-km
        :desc "Split cell" "s"        #'ein:worksheet-split-cell-at-point-km
        )
       )
      )
(after! evil
  (define-key evil-inner-text-objects-map (kbd "c") nil)
  (define-key evil-inner-text-objects-map (kbd "c") 'evil-inner-curly)
)

;; hack: remove titlebar
;; (add-to-list 'default-frame-alist '(undecorated . t))
(add-to-list 'default-frame-alist '(undecorated-round . t))


;; hack, disable tab completion for company
;; doesn't work via map!
(with-eval-after-load 'company
  (define-key company-active-map (kbd "<tab>") nil)
  (define-key company-active-map (kbd "TAB") 'company-yasnippet-or-completion))

(after! company
  ;; get only preview
  ;; (setq company-frontends '(company-preview-frontend))
  ;; also get a drop down
  (setq company-frontends '(company-pseudo-tooltip-frontend company-preview-frontend))
)

;; tab switching
;; (use-package! awesome-tab
;;   :config
;;   (awesome-tab-mode t)
;;   (setq awesome-tab-show-tab-index nil)
;;   (setq awesome-tab-height 120)
;;   ;; hide tab
;;   (defun awesome-tab-hide-tab (x)
;;   (let ((name (format "%s" x)))
;;     (or
;;      (string-prefix-p "*epc" name)
;;      (string-prefix-p "*Compile-Log*" name)
;;      (string-prefix-p "*lsp" name)
;;      (string-prefix-p "*doom*" name)
;;      (and (string-prefix-p "magit" name)
;;                (not (file-name-extension name)))
;;      )))
;;   )  ;; end awesome tab

(use-package! centaur-tabs
  :if window-system
  :init
  ;;(set-face-attribute 'centaur-tabs-active-bar-face nil :background "#c586d8")
  :config
  (setq
   centaur-tabs-set-close-button nil
   centaur-tabs-show-count nil
   centaur-tabs-set-bar 'left
   x-underline-at-descent-line t
   )
  ;; override the bar
  (setq centaur-tabs-active-bar
        (centaur-tabs--make-xpm 'centaur-tabs-active-bar-face
                                2
                                centaur-tabs-bar-height))
  ;; (setq x-underline-at-descent-line t)
  ;; (setq centaur-tabs-set-bar 'below)
  (centaur-tabs-init-tabsets-store)
  (centaur-tabs-display-update)

  (defun wd/get-buffer-persp-group (buffer)
    (let* ((name))
      (dolist (persp (persp-persps))
        (if persp
            (if (persp-contain-buffer-p buffer persp)
                (setq name (safe-persp-name persp)))))
      name
      ))

  (defun centaur-tabs-buffer-groups ()
    (list
     (cond
      ((or (string-equal "*" (substring (buffer-name) 0 1))
         (memq major-mode '(magit-process-mode
                            magit-status-mode
                            magit-diff-mode
                            magit-log-mode
                            magit-file-mode
                            magit-blob-mode
                            magit-blame-mode
                            )))
     "Emacs")
    ((derived-mode-p 'eshell-mode)
     "EShell")
    ;; ((derived-mode-p 'emacs-lisp-mode) ;; do not separate elisp filed from everything else
    ;;  "Elisp")
    ((derived-mode-p 'dired-mode)
     "Dired")
    ((memq major-mode '(org-mode org-agenda-mode diary-mode))
     "OrgMode")
    (t
     (let ((name (wd/get-buffer-persp-group (current-buffer))))
       (if name
           name
         ;;(centaur-tabs-get-group-name (current-buffer))
         "Other"
         )
       ))))
  )

  (defun centaur-tabs-hide-tab (x)
    "Do no to show buffer X in tabs."
    (let ((name (format "%s" x)))
      (or
       ;; Current window is not dedicated window.
       (window-dedicated-p (selected-window))

       ;; Buffer name not match below blacklist.
       (string-prefix-p "*epc" name)
       (string-prefix-p "*helm" name)
       (string-prefix-p "*Helm" name)
       (string-prefix-p "*Compile-Log*" name)
       (string-prefix-p "*lsp" name)
       (string-prefix-p "*company" name)
       ;; (string-prefix-p "*vterm" name)
       (string-prefix-p "*ccls" name)
       (string-prefix-p "*Flycheck" name)
       (string-prefix-p "*quickrun" name)
       (string-prefix-p "*Calculator*" name)
       (string-prefix-p "*which-key*" name)
       (string-prefix-p "*Calc Trail*" name)
       (string-prefix-p "*anaconda-mode" name)
       (string-prefix-p "*compilation" name)
       (string-prefix-p "*Deft*" name)
       (string-prefix-p "*tramp" name)
       (string-prefix-p " *Mini" name)
       (string-prefix-p "*help" name)
       (string-prefix-p "*straight" name)
       (string-prefix-p " *temp" name)
       (string-prefix-p "*Help" name)
       ;; (string-prefix-p "*mybuf" name)
       ;; Is not magit buffer.
       (and (string-prefix-p "magit" name)
            (not (file-name-extension name)))
       )))
  (centaur-tabs-mode t)
)

(use-package highlight-indent-guides
  :ensure t
  :hook ((prog-mode . highlight-indent-guides-mode)
         (yaml-mode . highlight-indent-guides-mode))
  :custom
  ;; (highlight-indent-guides-auto-enabled nil)
  (highlight-indent-guides-method 'bitmap)
  (highlight-indent-guides-responsive 'top)
  (highlight-indent-guides-bitmap-function 'highlight-indent-guides--bitmap-dots)
  ;; (setq org-ellipsis "…")
  ;; (set-face-attribute 'org-ellipsis nil :inherit 'default :box nil)
  ;; :config
  ;; (set-face-foreground 'highlight-indent-guides-character-face "#f8fce8")
  ;; (set-face-foreground 'highlight-indent-guides-odd-face "#fcba03")
  )
;; ------------------------------ GUI -----------------------------------------
;; tweaks
(setq display-line-numbers-type 'relative)
;; (add-hook 'c-mode-common-hook 'display-line-numbers-mode)
(add-hook 'cuda-mode-hook 'my-display-numbers-hook)
(add-hook 'prog-mode-hook 'my-display-numbers-hook)

;; (setq confirm-kill-emacs)
(setq confirm-kill-emacs nil)

(after! magit (setq magit-revision-show-gravatars '("^Author:     " . "^Commit:     ")))

(after! ivy-rich
  (setq ivy-rich-display-transformers-list
        '(ivy-switch-buffer
          (:columns
           (
            (+ivy-rich-buffer-name (:width 30))
            (ivy-rich-switch-buffer-size (:width 7))
            (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right))
            (ivy-rich-switch-buffer-major-mode (:width 12 :face font-lock-variable-name-face))
            (ivy-rich-switch-buffer-project (:width 15 :face font-lock-keyword-face))
            )
           )))
)

(if window-system
  (setq window-divider-default-bottom-width 4 ; in pixels
        window-divider-default-right-width  4)
  (window-divider-mode +1)
)
(use-package doom-modeline
  :demand t
  :config
  (winum-mode)
  (setq doom-modeline-height 5
          ;; doom-modeline-buffer-file-name-style 'buffer-name ;; just the buffer name
          doom-modeline-buffer-file-name-style 'relative-from-project ;; name start from root
          doom-modeline-buffer-file-name-style 'auto ;; name start from root
          doom-modeline-major-mode-color-icon nil
          doom-modeline-modal-icon nil
          doom-modeline-buffer-state-icon nil
          doom-modeline-buffer-encoding nil
          doom-modeline-enable-word-count nil ; added to the selection-info segment.
          doom-modeline-number-limit 99
          doom-modeline-indent-info t
          doom-modeline-persp-name t
          doom-modeline-display-default-persp-name t
          doom-modeline-percent-position nil
          doom-modeline-unicode-fallback t
          all-the-icons-scale-factor 1.0
          )
  (if window-system
      (setq doom-modeline-icon t
            doom-modeline-major-mode-icon t
       ))

  (doom-modeline-def-segment fancy-modals
    "The current evil state. Requires `evil-mode' to be enabled."
    (when (bound-and-true-p evil-local-mode)
      (let ((num
             (cond ((evil-normal-state-p)   "NORMAL")
                   ((evil-emacs-state-p)    "EMACS")
                   ((evil-insert-state-p)   "INSERT")
                   ((evil-motion-state-p)   "MOTION")
                   ((evil-visual-state-p)   "VISUAL")
                   ((evil-operator-state-p) "OPERATOR")
                   ((evil-replace-state-p)  "REPLACE")
                   )
             ))
      (propertize (format " %s " num)
                  'face (if (doom-modeline--active)
                            (cond ((evil-normal-state-p)   'doom-modeline-evil-normal-state)
                                  ((evil-emacs-state-p)    'doom-modeline-evil-emacs-state)
                                  ((evil-insert-state-p)   'doom-modeline-evil-insert-state)
                                  ((evil-motion-state-p)   'doom-modeline-evil-motion-state)
                                  ((evil-visual-state-p)   'doom-modeline-evil-visual-state)
                                  ((evil-operator-state-p) 'doom-modeline-evil-operator-state)
                                  ((evil-replace-state-p)  'doom-modeline-evil-replace-state))
                      'mode-line-inactive))
      )
    )
    )
  (doom-modeline-def-segment window-number-evil
      (let ((num (cond
                  ((bound-and-true-p ace-window-display-mode)
                  (aw-update)
                  (window-parameter (selected-window) 'ace-window-path))
                  ((bound-and-true-p winum-mode)
                  (setq winum-auto-setup-mode-line nil)
                  (winum-get-number-string))
                  ((bound-and-true-p window-numbering-mode)
                  (window-numbering-get-number-string))
                  (t ""))))
            (propertize (format " %s " num)
                        'face (if (doom-modeline--active)
                      (cond ((evil-normal-state-p)   'doom-modeline-evil-normal-state)
                            ((evil-emacs-state-p)    'doom-modeline-evil-emacs-state)
                            ((evil-insert-state-p)   'doom-modeline-evil-insert-state)
                            ((evil-motion-state-p)   'doom-modeline-evil-motion-state)
                            ((evil-visual-state-p)   'doom-modeline-evil-visual-state)
                            ((evil-operator-state-p) 'doom-modeline-evil-operator-state)
                            ((evil-replace-state-p)  'doom-modeline-evil-replace-state))
                      'mode-line-inactive))
          ))
  ;; filesize in modeline
  (remove-hook 'doom-modeline-mode-hook #'size-indication-mode)
  ;; my own modeline
  (doom-modeline-def-modeline 'ishovkun-line
    '(bar workspace-name window-number-evil matches buffer-info remote-host buffer-position word-count parrot selection-info)
    '(misc-info persp-name buffer-encoding major-mode indent-info process vcs lsp check))

    (defun setup-custom-doom-modeline ()
      (doom-modeline-set-modeline 'ishovkun-line 'default))

    (add-hook 'doom-modeline-mode-hook 'setup-custom-doom-modeline)
  )  ;; end use-package doom-modeline

;; Cursor shape in emacs terminal
(unless (display-graphic-p)
          (require 'evil-terminal-cursor-changer)
          (evil-terminal-cursor-changer-activate) ; or (etcc-on)
          )

;; evil yank to the end of line
(setq evil-want-Y-yank-to-eol t)
;; regular behavior of s
(after! evil-snipe
  ;; (evil-snipe-mode -1)
  ;; (add-hook 'ranger-mode-hook 'turn-off-evil-snipe-override-mode)
  ;; (add-hook 'ranger-mode-hook 'turn-off-evil-snipe-mode)
  (add-hook 'magit-mode-hook 'turn-off-evil-snipe-override-mode))

(add-to-list 'custom-theme-load-path "~/.doom.d/themes/")
;; (load-theme 'one-dark t)
;; (load-theme 'nord t)
(load-theme 'doom-nord-aurora-mod t)
;; (load-theme 'wilmersdorf t)


;; (use-package! yascroll
;;   :init
;;   (setq yascroll:delay-to-hide nil
;;         yascroll:scroll-bar 'right-fringe) ; right-fringe / text-area
;;   :config
;;   (add-hook 'prog-mode-hook 'yascroll-bar-mode)
;;   (add-hook 'text-mode-hook 'yascroll-bar-mode)
;;     )

;; posframe
(if window-system
    (use-package! ivy-posframe
      :config
      ;; (setq ivy-posframe-parameters
      ;;       '((left-fringe . 20)
      ;;         (right-fringe . 20)
      ;;         ))
      (setq ivy-posframe-display-functions-alist
            '((swiper          . nil)
              (counsel-ag      . nil)
              (complete-symbol . ivy-posframe-display-at-point)
              ;; (t               . ivy-posframe-display-at-frame-center))
              (t               . ivy-posframe-display-at-frame-top-center))
            ivy-fixed-height-minibuffer nil
            ivy-posframe-border-width 20
            ivy-posframe-parameters `((min-width . 50)
                                      (min-height . ,ivy-height))
            )
      :config
    (ivy-posframe-mode 1)
))

;; ----------------------------- dired ----------------------------------
(after! dirvish
  (setq! dirvish-quick-access-entries
         `(("h" "~/"                          "Home")
           ("e" ,user-emacs-directory         "Emacs user directory")
           ("c" "~/dev/"                      "Code")
           ("b" "~/build/"                    "Build")
           ("l" "~/Downloads/"                "Downloads")
           ("m" "/mnt/"                       "Mounted drives")
           ("t" "~/.local/share/Trash/files/" "Trash"))))
;; ranger
;; (setq ranger-deer-show-details nil)
;; (setq ranger-show-hidden nil)
;; (use-package! dirvish
;;   :custom
;;   '(("h" "~/"                          "Home")
;;      ("d" "~/dev/"                     "development")
;;      ("l" "~/Downloads/"                "Downloads")
;;      ("m" "/mnt/"                       "Drives")
;;      ("t" "~/.local/share/Trash/files/" "TrashCan")
;;      )
;;   )

;; scroll one line at a time (less "jumpy" than defaults)
(setq mouse-wheel-scroll-amount '(2 ((shift) . 1))) ;; two lines at a time
(setq mouse-wheel-progressive-speed nil)            ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't)                  ;; scroll window under mouse

;; (use-package! dired-dd)
;; ----------------------------- c/c++ ----------------------------------
;; lsp
(use-package! lsp-mode
  ;; :commands lsp
  :config
    (setq lsp-lens-enable nil     ;; disable stupid lenses (number of references inline)
          lsp-enable-file-watchers nil
          lsp-headerline-breadcrumb-icons-enable t
          lsp-headerline-breadcrumb-enable t
          lsp-headerline-breadcrumb-enable-symbol-numbers nil
          )
  )


(after! lsp-mode
  (progn

    (push 'company-lsp company-backends)
    ;; ccls
    (after! ccls
      (setq ccls-executable "ccls")
      (set-lsp-priority! 'ccls 2)
      (setq ccls-initialization-options
            `(:clang (:excludeArgs
                      ;; Linux's gcc options. See ccls/wiki
                       ["-falign-jumps=1" "-falign-loops=1" "-fconserve-stack" "-fmerge-constants" "-fno-code-hoisting" "-fno-schedule-insns"
                        "-fno-var-tracking-assignments" "-fsched-pressure" "-mhard-float" "-mindirect-branch-register"
                        "-mindirect-branch=thunk-inline" "-mpreferred-stack-boundary=2" "-mpreferred-stack-boundary=3"
                        "-mpreferred-stack-boundary=4" "-mrecord-mcount" "-mindirect-branch=thunk-extern" "-mno-fp-ret-in-387" "-mskip-rax-setup"
                        "--param=allow-store-data-races=0" "-Wa arch/x86/kernel/macros.s" "-Wa -"]
                       :extraArgs [])
              :completion
              (:include
               (:blacklist
                ["^/usr/(local/)?include/c\\+\\+/[0-9\\.]+/(bits|tr1|tr2|profile|ext|debug)/"
                 "^/usr/(local/)?include/c\\+\\+/v1/"
                 ]))
              ))
      )

    ;; clangd
     (setq lsp-clients-clangd-args '("-j=3"
                                     "--background-index"
                                     ;; "--clang-tidy"
                                     "--completion-style=detailed"
                                     "--header-insertion=never"))
     (after! lsp-clangd (set-lsp-priority! 'clangd 1))  ; ccls has priority 0

     ;; (lsp-register-client
     ;;  (make-lsp-client :new-connection (lsp-tramp-connection "/usr/bin/ccls")
     ;;                   :major-modes '(c++-mode c-mode)
     ;;                   :remote? t
     ;;                   :server-id 'ccls-remote))

     ;; (lsp-treemacs-sync-mode 1)
     ))

(use-package! lsp-ui
  :init
  (setq lsp-ui-sideline-enable nil)
  (setq lsp-ui-doc-enable t)
  (setq lsp-ui-doc-position 'bottom) ; top, bottom, at-point
  (setq lsp-ui-doc-max-width 150)
  (setq lsp-ui-doc-max-height 150)
  :config
  ;; (set-face-attribute 'lsp-ui-doc-global nil :height 0.75)
  (lsp-ui-doc-mode)
  )

;; ----------------------------- File associations (extensions) ----------------------------------
(add-to-list 'auto-mode-alist '("\\.xdmf\\'" . xml-mode))

;; Machine learnig!
;; (use-package! codeium
;;    :init
;;     ;; use globally
;;     (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)
;;     :defer t
;;     :config
;;     ;; (setq use-dialog-box nil) ;; do not use popup boxes
;;     ;; (setq use-dialog-box t) ;; do not use popup boxes

;;     ;; (setq codeium/metadata/api_key "ae87000a-d404-4747-950d-cf4d2973a50f")

;;     ;; use M-x codeium-diagnose to see apis/fields that would be sent to the local language server
;;     (setq codeium-api-enabled
;;           (lambda (api)
;;             (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))

;;     ;; You can overwrite all the codeium configs!
;;     ;; for example, we recommend limiting the string sent to codeium for better performance
;;     (defun my-codeium/document/text ()
;;       (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (min (+ (point) 1000) (point-max))))
;;    ;; if you change the text, you should also change the cursor_offset
;;     ;; warning: this is measured by UTF-8 encoded bytes
;;     (defun my-codeium/document/cursor_offset ()
;;         (codeium-utf8-byte-length
;;          (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (point))))

;;     (setq codeium/document/text 'my-codeium/document/text)
;;     (setq codeium/document/cursor_offset 'my-codeium/document/cursor_offset)
;;   )

;; (after! lsp-ui
;;   (progn
;;     (setq lsp-ui-sideline-enable nil)
;;     (setq lsp-ui-doc-enable t)
;;     (setq lsp-ui-doc-position 'bottom) ; top, bottom, at-point
;;     (setq lsp-ui-doc-max-width 150)
;;     (setq lsp-ui-doc-max-height 150)
;;     (lsp-ui-doc-mode)
;;     ;; (set-face-attribute 'lsp-ui-doc-global nil :height 0.75)
;;     )
;;   )
;; -----------------------------------------------------------------

(after! tramp
  (setq tramp-inline-compress-start-size 1000)
  (setq tramp-copy-size-limit 10000)
  (setq vc-handled-backends '(Git))
  (setq tramp-verbose 1)
  (setq tramp-default-method "scp")
  (setq tramp-use-ssh-controlmaster-options nil)
  (setq projectile--mode-line "Projectile")
  (setq tramp-verbose 1)
  (setq tramp-shell-prompt-pattern "^[^$>\n]*[#$%>] *\\(\[[0-9;]*[a-zA-Z] *\\)*")
  ;; emable tramp dir-locals
  (setq enable-remote-dir-locals t)
  (setq vc-ignore-dir-regexp
      (format "\\(%s\\)\\|\\(%s\\)"
              vc-ignore-dir-regexp
              tramp-file-name-regexp))
  ;; if line above is too radical
  ;; (setq vc-handled-backends '(Git))
  )

;; google-c-style
(use-package! google-c-style
  :load-path "~/.doom.d/extra"
  :config
  (add-hook 'c-mode-common-hook 'google-set-c-style)
  (add-hook 'c-mode-common-hook 'google-make-newline-indent)
  )
;; disable realgud confirmations
(after! realgud (setq realgud-safe-mode 'nil))
;; (after! dap-mode (setq 'dap--debug-template-configurations 'dap-debug-template-configurations))

(use-package! dap-mode
  :config
   ;;; set the debugger executable (c++)

  (setq dap-lldb-debug-program '("/usr/bin/lldb-vscode"))
  (if (eq system-type 'darwin)
      (setq dap-lldb-debug-program '("/opt/homebrew/opt/llvm/bin/lldb-vscode"))
      )
  ;; (dap-register-debug-template "LLDB::Run"
  ;; (list :type "lldb"
  ;;       :request "launch"
  ;;       :name "LLDB::Run"
  ;;       :target nil
        ;; :cwd nil))
  )
(use-package! dap-cpptools)
;; --------------------------------- autocomplete ----------------------------
;; (use-package company-box :hook (company-mode . company-box-mode))
;; ----------------------------------- Deft ----------------------------------
(after! deft
 (setq deft-directory "~/Dropbox/enotes")
 (setq deft-extensions '("org" "md"))
 (setq deft-auto-save-interval 60.0)
 (setq deft-use-filename-as-title nil)
 (setq deft-use-filter-string-for-filename t)
 (setq deft-file-naming-rules
       '((noslash . "-")
         (nospace . "-")
         (case-fn . downcase)))
 )
;; ----------------------------------- Org ----------------------------------
(after! org
  (progn
    (setq org-directory "~/Dropbox/enotes")
     (setq org-agenda-files (list org-directory))
    (when (string= (system-name) "space")
      (setq org-format-latex-options (plist-put org-format-latex-options :scale 3.0))
      )
    (add-hook 'org-mode-hook #'org-modern-mode)
    (add-hook 'org-agenda-finalize-hook #'org-modern-agenda)
    (+org-pretty-mode nil)
    (setq org-ellipsis "…")
    (set-face-attribute 'org-ellipsis nil :inherit 'default :box nil)
    (set-face-attribute 'variable-pitch nil :family "Iosevka Aile")
    (setq org-hide-emphasis-markers t
          org-pretty-entities t)


    ))
;; ----------------------------------- Org-Roam -----------------------------
;; (setq org-roam-directory "~/")
;; ---------------------------------- Calendar ------------------------------
(defun =calendar ()
  (interactive)
  (cfw:open-calendar-buffer
   :contents-sources
   (list
    (cfw:org-create-source "gainsboro")  ; org-agenda source
    ;; (cfw:org-create-file-source "cal" "/path/to/cal.org" "Cyan")  ; other org source
    ;; (cfw:org-create-file-source "cal" "~/Downloads/cal.org" "snow1")  ; other org source
    ;; (cfw:howm-create-source "Blue")  ; howm source
    ;; (cfw:cal-create-source "Orange") ; diary source
    ;; (cfw:ical-create-source "Moon" "~/moon.ics" "Gray")  ; ICS source1
    (cfw:ical-create-source "Stanford" "https://calendar.google.com/calendar/ical/50425a5bg9h9admh36h3rsfnj4%40group.calendar.google.com/public/basic.ics" "brown") ; google calendar ICS
    (cfw:ical-create-source "Google" "https://calendar.google.com/calendar/ical/igshov%40gmail.com/public/basic.ics" "medium sea green") ; google calendar ICS
   )))
;; ---------------------------------- Notifications --------------------------------
;; (use-package! alert :config (setq alert-default-style 'notifications))
;; (use-package! org-wild-notifier
;;   :config
;;   (setq alert-default-style 'notifications)
;;   (org-wild-notifier-mode t)
;;   )
  ;; ---------------------------- ORG calendar --------------------------------------
;; (use-package! org-gcal
;;   :config
;;   (setq org-gcal-client-id "1046223883337-g5m0oj48ri3g0blvpiker752kd39qv43.apps.googleusercontent.com"
;;         org-gcal-client-secret "zLRzWSYHzuQ4GG8qAJPFLjZY")
;;   (setq org-gcal-file-alist '(("igshov@gmail.com" . "/home/ishovkun/Dropbox/enotes/gmail_cal.org")))
;;   (setq org-agenda-files
;;         (quote ("/home/ishovkun/Dropbox/enotes/gmail_cal.org")))
;;   )
;; ----------------------------------- LaTeX ---------------------------------
(setq +latex-viewers '(okular))
;; --------------------------------- Compile ---------------------------------
(unless (or (string= (system-name) "space") (window-system))
  ;; (add-hook 'compilation-mode-hook 'my-compilation-hook)
  ;; truncate lines in compilation mode
  (defun compilation-mode-hook-trucate-lines ()
    (setq truncate-lines nil) ;; automatically becomes buffer local
    (set (make-local-variable 'truncate-partial-width-windows) nil))
  (add-hook 'compilation-mode-hook 'compilation-mode-hook-trucate-lines)
)
;; ------------------------- evil-commentary ---------------------------------
(use-package! evil-commentary)
;; ----------------------------------- Eclipse & GMSH ------------------------
(use-package! eclipse
  :load-path "~/.doom.d/extra/"
  :config
  (setq auto-mode-alist (cons '("\\.INCL\\'" . eclipse-mode) auto-mode-alist))
  (setq auto-mode-alist (cons '("\\.incl\\'" . eclipse-mode) auto-mode-alist))
  (setq auto-mode-alist (cons '("\\.DATA\\'" . eclipse-mode) auto-mode-alist))
  (setq auto-mode-alist (cons '("\\.data\\'" . eclipse-mode) auto-mode-alist))
  )
;; gmsh
(use-package! gmsh
  :load-path "~/.doom.d/extra/"
  :config
  (setq auto-mode-alist (cons '("\\.geo\\'" . gmsh-mode) auto-mode-alist))
  )
;; ----------------------------------- Octave ---------------------------------
(setq auto-mode-alist (cons '("\\.m\\'" . octave-mode) auto-mode-alist))
;; ----------------------------------- EAF -----------------------------------
;; (when (display-graphic-p)
;;   (use-package! eaf
;;     ;; :if (eq system-type 'gnu/linux)
;;     :custom
;;     (eaf-find-alternate-file-in-dired t)
;;     ;; :config
;;     ;; (add-hook! 'eaf-mode-hook 'xah-fly-keys-off)

;;     ;; (eaf-bind-key scroll_up "C-n" eaf-pdf-viewer-keybinding)
;;     ;; (eaf-bind-key scroll_down "C-p" eaf-pdf-viewer-keybinding)

;;     ;; (defun eaf-open-google ()
;;     ;;   "Open Google using EAF."
;;     ;;   (interactive)
;;     ;;   (eaf-open-browser "https://www.google.com"))
;;   )
;;   (use-package! eaf-evil ;; FIXME
;;     ;; :after eaf
;;     :defer t
;;     :config
;;     ;; (setq eaf-evil-leader-keymap doom-leader-map)
;;     ;; (setq eaf-evil-leader-key "SPC")
;;     ;; )
;;     (eaf-setq eaf-browser-enable-adblocker "true")
;;     (define-key key-translation-map (kbd "SPC")
;;       (lambda (prompt)
;;         (if (derived-mode-p 'eaf-mode)
;;             (pcase eaf--buffer-app-name
;;               ("browser" (if (eaf-call "call_function" eaf--buffer-id "is_focus")
;;                              (kbd "SPC")
;;                            (kbd eaf-evil-leader-key)))
;;               ("pdf-viewer" (kbd eaf-evil-leader-key))
;;               ("image-viewer" (kbd eaf-evil-leader-key))
;;               (_  (kbd "SPC")))
;;           (kbd "SPC"))))
;;     )
;;   )
;; ----------------------------------- Jupiter ---------------------------------
(use-package! ein
  :config
  (setq ein:output-area-inlined-images t)
  (setq ein:worksheet-enable-undo nil)  ;this allows to undo
  )
;; ----------------------------------- Copilot ---------------------------------
;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word))
  :config
  (add-to-list 'copilot-major-mode-alist '("cuda" . "rust"))
  (add-to-list 'copilot-indentation-alist '(python-mode 2))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2))
  )

;; ----------------------------------- Shell -----------------------------------
;; (when (display-graphic-p)
;;   (use-package mini-modeline
;;     :after doom-modeline
;;     :config
;;     (doom-modeline-def-modeline 'minibuffer-line
;;       '(matches remote-host persp-name major-mode indent-info vcs lsp checker fancy-modals)
;;       )
;;     (setq mini-modeline-l-format '("%e" mode-line-front-space
;;                                    ;; (:eval (doom-modeline--anzu))
;;                                    ;; (:eval (doom-modeline--buffer-mode-icon))
;;                                    (:eval (doom-modeline--macro-recording))
;;                                    (:eval (doom-modeline--buffer-name))
;;                                    ))
;;     (setq mini-modeline-r-format '(:eval (doom-modeline-format--minibuffer-line)))
;;     (setq mini-modeline-right-padding 0 mini-modeline-enhance-visual t)

;;     ;; (setq mini-modeline--cache
;;     ;;   (mini-modeline--multi-lr-render
;;     ;;    (format-mode-line mini-modeline-l-format)
;;     ;;    (if mini-modeline--msg
;;     ;;        (format-mode-line '(:eval (mini-modeline-msg)))
;;     ;;      (format-mode-line mini-modeline-r-format))))

;;     ;; shut up minibuffer messages
;;     ;; (setq inhibit-message nil)
;;     (global-eldoc-mode -1) ;; disable useful eldoc messages

;;     (global-hide-mode-line-mode)
    ;; (set-face-attribute 'mode-line nil :box nil :height 1)
    ;; (set-face-attribute 'minibuffer-prompt nil :background (face-background 'tab-bar))
;;     (setq mini-modeline-display-gui-line nil)
;;     (remove-hook 'dired-mode-hook #'doom-modeline-set-project-modeline t)
;;     (mini-modeline-mode t)
;;     )
;; )
;; --------------------------------- Fixes -----------------------------------
;; Do not copy on paste in visual mode
(setq evil-kill-on-visual-paste nil)

;; (setq evil-respect-visual-line-mode t)
;; (setq evil-respect-visual-line-mode 0) ;; otherwise  deletes line on cc
(setq evil-move-cursor-back nil)
(setq org-startup-truncated nil)
;; (setq-default truncate-lines nil)
;; make compilation buffer stick to the frame
;; (push '("\\*compilation\\*" . (nil (reusable-frames . t))) display-buffer-alist)
(setq doom-private-dir "~/dotfiles/doom/.doom.d/")
;; (after! evil
;;   (add-to-list 'evil-emacs-state-modes 'flycheck-error-list-mode))
(after! quickrun (setq quickrun-timeout-seconds 1000))
(after! persp-mode
;; show all buffers from workspace
(remove-hook 'persp-add-buffer-on-after-change-major-mode-filter-functions #'doom-unreal-buffer-p))
;; -------------------------------- authentify -------------------------------
(setq auth-sources '("~/.authinfo"))
;; -------------------------------- Projectile -------------------------------
(after! projectile
  ;; (setq compilation-read-command nil)  ; no prompt in projectile-compile-project
  ;; (setq compilation-read-command t)
  ;; . -> Build
  (projectile-register-project-type 'cmake '("CMakeLists.txt")
                                    :configure "cmake %s"
                                    :compile "cmake --build Debug"
                                    :test "ctest")
  (add-to-list 'projectile-globally-ignored-directories ".ccls-cache")
  (defadvice projectile-on (around exlude-tramp activate)
  "This should disable projectile when visiting a remote file"
  (unless  (--any? (and it (file-remote-p it))
                   (list
                    (buffer-file-name)
                    list-buffers-directory
                    default-directory
                    dired-directory))
    ad-do-it))

  )

(after! ivy
  (setq counsel-find-file-ignore-regexp
                   (my-counsel-ignore-regexp-builder
                    "\\`__pycache__/\\'"
                    "^.cquery"
                    "^.clangd"
                    "^.cache"
                    "^.ccls-cache"
                    (my-counsel-ignore-extensions "pyc" "elc" "so" "o")))
  )

;; (require 'subword-mode)
(global-subword-mode 1)
;; (use-package! subword-mode
;;   :config
;;   (global-subword-mode)
;;   )
;; -------------------------------- Fun -------------------------------
;; (use-package zone
;;   :config
;;   (zone-when-idle 300)
;;   )
