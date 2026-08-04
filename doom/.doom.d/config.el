;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; place your private configuration here
;; (setq doom-font (font-spec :family "Iosevka SS04" :size 14))

;; Doom 2.2 does not emit private autodefs into this profile's generated
;; loaddefs, so load the existing helper library explicitly.
(load! "autoload/funcs")

;; macOS 26 hack: async native-comp workers hit an OS-level fork-safety bug
;; (children crash in os_log/libsystem_trace inherited state; same class as
;; ruby-lang bug #21969), then get re-queued, snowballing into a CPU-pegging
;; worker storm. Cap the workers until Apple fixes it.
(when (eq system-type 'darwin)
  (setq native-comp-async-jobs-number 4))
(when (string= (system-name) "space")
  ;; manjaro hack
  ;; (setq doom-font (font-spec :family "Iosevka" :size 27 :width 'normal)))
  ;; (setq doom-font (font-spec :family "Iosevka SS04" :size 25))
  ;; Match Zed's 13 logical px Iosevka at this display's ~2x scale.
  (setq doom-font (font-spec :family "Iosevka Nerd Font"
                             :size 25
                             :weight 'regular))
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

(defun my/agent-shell-toggle-chat-window ()
  "Load Agent Shell, then toggle its most recently used conversation window."
  (interactive)
  (require 'agent-shell)
  (my/agent-shell--toggle-chat-window))

(defvar my/ui-font-scale 1.0
  "Scale factor for mode lines, tab lines, and minibuffer text.")

(defconst my/buffer-font-scale-step 0.08
  "One Zed-like buffer-font step as a relative scale.")

(defconst my/ui-font-scale-step 0.04
  "One fine-grained UI-font step as a relative scale.")

(defvar my/buffer-font-scale-amount 0
  "Shared number of font-size steps applied to all textual buffers.")

(defvar-local my/buffer-font-scale-cookie nil
  "Face-remap cookie for the shared textual-buffer font scale.")

(defvar-local my/minibuffer-ui-font-scale-cookie nil
  "Face-remap cookie for the current minibuffer's UI font scale.")

(defun my/textual-buffer-p ()
  "Return non-nil when the current buffer displays scalable text."
  (and (not (minibufferp))
       (not (derived-mode-p 'image-mode 'pdf-view-mode 'doc-view-mode))))

(defun my/buffer-font-size--apply ()
  "Apply the shared text scale to the current textual buffer."
  ;; Remove local zoom left by the former per-buffer implementation so it
  ;; cannot stack with the new shared scale.
  (when (bound-and-true-p text-scale-mode)
    (text-scale-set 0))
  (when my/buffer-font-scale-cookie
    (face-remap-remove-relative my/buffer-font-scale-cookie)
    (setq my/buffer-font-scale-cookie nil))
  (when (and (my/textual-buffer-p)
             (not (zerop my/buffer-font-scale-amount)))
    (setq my/buffer-font-scale-cookie
          (face-remap-add-relative
           'default
           `(:height
             ,(expt (+ 1.0 my/buffer-font-scale-step)
                    my/buffer-font-scale-amount))))))

(defun my/buffer-font-size-adjust (steps)
  "Adjust every textual buffer's font size by STEPS."
  (setq my/buffer-font-scale-amount
        (max -6 (min 10 (+ my/buffer-font-scale-amount steps))))
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (my/buffer-font-size--apply)))
  (force-window-update t)
  (message "Buffer font size: %d%%"
           (round
            (* 100
               (expt (+ 1.0 my/buffer-font-scale-step)
                     my/buffer-font-scale-amount)))))

(defun my/buffer-font-size-increase ()
  "Increase text size in every textual buffer."
  (interactive)
  (my/buffer-font-size-adjust 1))

(defun my/buffer-font-size-decrease ()
  "Decrease text size in every textual buffer."
  (interactive)
  (my/buffer-font-size-adjust -1))

(defun my/minibuffer-apply-ui-font-scale ()
  "Apply `my/ui-font-scale' to all text in the current minibuffer."
  (when my/minibuffer-ui-font-scale-cookie
    (face-remap-remove-relative my/minibuffer-ui-font-scale-cookie))
  (setq my/minibuffer-ui-font-scale-cookie
        (face-remap-add-relative
         'default `(:height ,my/ui-font-scale))))

(defun my/ui-font-size--apply ()
  "Apply `my/ui-font-scale' without resizing ordinary buffer text."
  (dolist (face '(mode-line mode-line-inactive))
    (when (facep face)
      (set-face-attribute face nil :height my/ui-font-scale)))
  (when (facep 'tab-line)
    (set-face-attribute 'tab-line nil
                        :height (* 0.92 my/ui-font-scale)))
  (when-let ((window (active-minibuffer-window)))
    (with-current-buffer (window-buffer window)
      (my/minibuffer-apply-ui-font-scale)))
  (force-mode-line-update t)
  (when (fboundp 'tab-line-force-update)
    (tab-line-force-update t)))

(defun my/ui-font-size-adjust (steps)
  "Adjust UI font size by STEPS without resizing buffer text."
  (setq my/ui-font-scale
        (max 0.6
             (min 2.0
                  (+ my/ui-font-scale
                     (* my/ui-font-scale-step steps)))))
  (my/ui-font-size--apply)
  (message "UI font size: %d%%" (round (* 100 my/ui-font-scale))))

(defun my/ui-font-size-increase ()
  "Increase mode-line, tab-line, and minibuffer font size."
  (interactive)
  (my/ui-font-size-adjust 1))

(defun my/ui-font-size-decrease ()
  "Decrease mode-line, tab-line, and minibuffer font size."
  (interactive)
  (my/ui-font-size-adjust -1))

(add-hook 'minibuffer-setup-hook #'my/minibuffer-apply-ui-font-scale)
(add-hook 'after-change-major-mode-hook #'my/buffer-font-size--apply)
(add-hook 'doom-load-theme-hook #'my/ui-font-size--apply 110)

(map!
 (:map treemacs-mode-map
  "M-l"         #'evil-window-right
  "M-h"         #'evil-window-left
  )
 :desc "Open Dirvish" :n "-" #'dired-jump
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
  ;; resize — in override so org-mode's M-S-j/k line-swap doesn't win
  :nv "M-H"         #'decrease-window-width
  :nv "M-L"         #'increase-window-width
  :nv "M-J"         #'decrease-window-height
  :nv "M-K"         #'increase-window-height
  :nv "M-M"         #'+workspace/switch-left
  :nv "M-<"         #'+workspace/switch-right
  :nvi "<mouse-5>"  #'scroll-up-line
  :nvi "<mouse-4>"  #'scroll-down-line

  :nv "M-n"         #'my/tab-line-next
  :nv "M-p"         #'my/tab-line-previous
  :nv "C-<tab>"     #'my/tab-line-next
  :nv "C-S-<tab>"   #'my/tab-line-previous
  :nvi "M-r"        #'my/agent-shell-toggle-chat-window
  :nv "M-<backspace>" #'kill-current-buffer
  )
 :nvi "M-="        #'my/buffer-font-size-increase
 :nvi "M--"        #'my/buffer-font-size-decrease
 :nvi "M-+"        #'my/ui-font-size-increase
 :nvi "M-S-="      #'my/ui-font-size-increase
 :nvi "M-_"        #'my/ui-font-size-decrease
 :nvi "M-S--"      #'my/ui-font-size-decrease
 (:map image-mode-map :after image-mode
  :desc "Zoom in" :nv "M-="         #'image-increase-size
  :desc "Zoom out" :nv "M--"        #'image-decrease-size
  :desc "Open Dirvish" :n "-" #'dired-jump
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
  :desc "jump to tab 1" :nv "[1" #'my/tab-line-select-number
  :desc "jump to tab 2" :nv "[2" #'my/tab-line-select-number
  :desc "jump to tab 3" :nv "[3" #'my/tab-line-select-number
  :desc "jump to tab 4" :nv "[4" #'my/tab-line-select-number
  :desc "jump to tab 5" :nv "[5" #'my/tab-line-select-number
  :desc "jump to tab 6" :nv "[6" #'my/tab-line-select-number
  :desc "jump to tab 7" :nv "[7" #'my/tab-line-select-number
  :desc "jump to tab 8" :nv "[8" #'my/tab-line-select-number
  :desc "jump to tab 9" :nv "[9" #'my/tab-line-select-number
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
    :desc "kill current buffer"          :nv "d" #'kill-current-buffer
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
    (:after dape :map c++-mode-map
     :desc "Edit launch.json" :nv "j" #'dap-debug-create-or-edit-json-template)
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

(use-package! tab-line
  :ensure nil
  :config
  (setq tab-line-close-button-show nil
        tab-line-new-button-show nil
        ;; A one-pixel separator prevents Emacs from coalescing adjacent
        ;; inactive face boxes.  Without it, changing which tab is current
        ;; changes the number of box edges and moves every later tab.
        tab-line-separator
        (propertize " " 'display '(space :width (1)) 'face 'tab-line)
        tab-line-switch-cycling t
        tab-line-tabs-function #'my/tab-line-tabs)

  (defvar-local my/tab-line-agent-edited nil
    "Non-nil when Agent Shell was the last writer of this buffer.")

  (defun my/tab-line--apply-zed-faces ()
    "Style native tab-line tabs like the configured Zed Frappé theme."
    (let ((family (face-attribute 'default :family nil t)))
      ;; Pin every metric that can change glyph width.  In particular,
      ;; `tab-line-tab-current' does not inherit `tab-line-tab' by default,
      ;; which lets themes render the active title with a different font.
      (set-face-attribute 'tab-line nil
                          :family family
                          :background "#232634"
                          :foreground "#9099AB"
                          :height (* 0.92 my/ui-font-scale)
                          :weight 'normal
                          :width 'normal
                          :slant 'normal
                          :box nil)
      (set-face-attribute 'tab-line-tab nil
                          :inherit 'tab-line
                          :background "#191C25"
                          :foreground "#C2C8D1"
                          :weight 'normal
                          :width 'normal
                          :slant 'normal
                          :box '(:line-width (1 . 5) :color "#191C25"))
      (set-face-attribute 'tab-line-tab-inactive nil
                          :inherit 'tab-line-tab
                          :background "#191C25"
                          :foreground "#C2C8D1"
                          :weight 'normal
                          :width 'normal
                          :slant 'normal
                          :box '(:line-width (1 . 5) :color "#191C25"))
      (set-face-attribute 'tab-line-tab-current nil
                          :inherit 'tab-line-tab
                          :background "#2C333F"
                          :foreground "#C2C8D1"
                          :weight 'normal
                          :width 'normal
                          :slant 'normal
                          :box '(:line-width (1 . 5) :color "#2C333F"))
      (set-face-attribute 'tab-line-highlight nil
                          :inherit 'tab-line-tab
                          :background "#434C5E"
                          :foreground "#ECEFF4"
                          :weight 'normal
                          :width 'normal
                          :slant 'normal
                          :box '(:line-width (1 . 5) :color "#434C5E"))))

  (defun my/tab-line--clear-agent-edited (&rest _)
    "Clear the Agent Shell edit marker after a subsequent human edit."
    (when my/tab-line-agent-edited
      (setq my/tab-line-agent-edited nil)
      (remove-hook 'after-change-functions
                   #'my/tab-line--clear-agent-edited t)
      (remove-hook 'after-revert-hook
                   #'my/tab-line--clear-agent-edited t)
      (tab-line-force-update t)))

  (defun my/tab-line--mark-agent-edited (event)
    "Mark the file buffer written by Agent Shell EVENT."
    (when-let* ((data (map-elt event :data))
                (path (map-elt data :path))
                (buffer (find-buffer-visiting path)))
      (with-current-buffer buffer
        (setq my/tab-line-agent-edited t)
        (add-hook 'after-change-functions
                  #'my/tab-line--clear-agent-edited nil t)
        (add-hook 'after-revert-hook
                  #'my/tab-line--clear-agent-edited nil t))
      (tab-line-force-update t)))

  (defun my/tab-line--tab-name (buffer)
    "Return BUFFER's tab label with Zed-like state markers."
    (with-current-buffer buffer
      (if (equal (my/tab-line-buffer-group buffer) "Regular")
          ;; Literal padding avoids an Emacs face-box quirk that moves text
          ;; when a tab changes between active and inactive faces.  Reserve
          ;; equal-width status space on both sides of regular file titles.
          (concat
           "    "
           (buffer-name)
           " "
           (cond ((buffer-modified-p)
                  (propertize "●"
                              'face 'warning
                              'help-echo "Unsaved changes"))
                 (my/tab-line-agent-edited
                 (propertize "✦"
                              'face 'font-lock-keyword-face
                              'help-echo "Last edited by Agent Shell"))
                 (t " "))
           "  ")
        ;; Popup, Terminal, and Chat buffers intentionally have no file-state
        ;; markers; process output commonly leaves them modified forever.
        (concat "  " (buffer-name) "  "))))

  (defun my/tab-line--chat-buffer-p (&optional buffer)
    "Return non-nil when BUFFER is a user-facing Agent Shell buffer."
    (with-current-buffer (or buffer (current-buffer))
      (derived-mode-p 'agent-shell-mode
                      'agent-shell-viewport-edit-mode
                      'agent-shell-viewport-view-mode)))

  (defun my/tab-line--terminal-buffer-p (&optional buffer)
    "Return non-nil when BUFFER is an interactive terminal or REPL."
    (with-current-buffer (or buffer (current-buffer))
      (derived-mode-p 'vterm-mode
                      'eshell-mode
                      'term-mode
                      'shell-mode
                      'comint-mode)))

  (defun my/tab-line--doom-popup-rule (buffer)
    "Return the first Doom popup rule matching BUFFER."
    (when (boundp '+popup--display-buffer-alist)
      (seq-find
       (lambda (rule)
         (condition-case nil
             (buffer-match-p (car rule) buffer (cdr rule))
           (error nil)))
       +popup--display-buffer-alist)))

  (defun my/tab-line--popup-buffer-p (&optional buffer)
    "Return non-nil when BUFFER belongs to Doom's Popup group."
    (let* ((buffer (or buffer (current-buffer)))
           (rule (my/tab-line--doom-popup-rule buffer)))
      (or (and (fboundp '+popup-buffer-p)
               (+popup-buffer-p buffer))
          (and rule
               (memq #'+popup-buffer (cadr rule))))))

  (defun my/tab-line-buffer-group (&optional buffer)
    "Return BUFFER's tab group.
Chat takes precedence over Popup, and Popup over Terminal."
    (let ((buffer (or buffer (current-buffer))))
      (cond ((my/tab-line--chat-buffer-p buffer) "Chat")
            ((my/tab-line--popup-buffer-p buffer) "Popup")
            ((my/tab-line--terminal-buffer-p buffer) "Terminal")
            ((doom-real-buffer-p buffer) "Regular"))))

  (defun my/tab-line--workspace-buffers ()
    "Return current workspace buffers, falling back to all buffers."
    (condition-case nil
        (if (fboundp '+workspace-buffer-list)
            (+workspace-buffer-list)
          (buffer-list))
      (error (buffer-list))))

  (defun my/tab-line--shell-for-chat-buffer (buffer)
    "Return the Agent Shell backend associated with chat BUFFER."
    (with-current-buffer buffer
      (cond ((derived-mode-p 'agent-shell-mode) buffer)
            ((derived-mode-p 'agent-shell-viewport-edit-mode
                             'agent-shell-viewport-view-mode)
             (agent-shell-viewport--shell-buffer buffer)))))

  (defun my/tab-line--chat-buffers ()
    "Return one user-facing buffer for every Agent Shell conversation."
    (when (fboundp 'agent-shell-buffers)
      (let ((current-shell
             (when (my/tab-line--chat-buffer-p)
               (my/tab-line--shell-for-chat-buffer (current-buffer)))))
        (mapcar
         (lambda (shell-buffer)
           (cond ((eq shell-buffer current-shell) (current-buffer))
                 ((and (bound-and-true-p agent-shell-prefer-viewport-interaction)
                       (agent-shell-viewport--buffer
                        :shell-buffer shell-buffer :existing-only t)))
                 (shell-buffer)))
         (agent-shell-buffers)))))

  (defun my/tab-line--group-buffers (group)
    "Return live buffers belonging to GROUP."
    (let* ((candidates
            (if (equal group "Chat")
                (my/tab-line--chat-buffers)
              (if (equal group "Popup")
                  (buffer-list)
                (my/tab-line--workspace-buffers))))
           (buffers
            (seq-filter
             (lambda (buffer)
               (and (buffer-live-p buffer)
                    (equal (my/tab-line-buffer-group buffer) group)))
             (delete-dups (cons (current-buffer) candidates)))))
      (seq-sort-by #'buffer-name #'string< buffers)))

  (defun my/tab-line--select-buffer (buffer &optional window)
    "Display BUFFER in WINDOW without leaving a Doom popup window dedicated."
    (let ((window (or window (selected-window))))
      (cl-labels
          ((select-buffer
            ()
            (if (and (fboundp '+popup-window-p)
                     (+popup-window-p window))
                (let ((dedicated (window-dedicated-p window)))
                  (set-window-dedicated-p window nil)
                  (unwind-protect
                      (progn
                        (set-window-buffer window buffer)
                        (set-buffer buffer)
                        (when (and (fboundp '+popup-buffer-mode)
                                   (equal (my/tab-line-buffer-group buffer)
                                          "Popup"))
                          (+popup-buffer-mode 1)))
                    (set-window-dedicated-p window dedicated)))
              (switch-to-buffer buffer))))
        (if (eq window (selected-window))
            (select-buffer)
          (with-selected-window window
            (select-buffer))))))

  (defun my/tab-line-tabs ()
    "Return native tab-line tabs for the current buffer's group."
    (when-let ((group (my/tab-line-buffer-group)))
      (mapcar
       (lambda (buffer)
         `(tab
           (name . ,(my/tab-line--tab-name buffer))
           (selected . ,(eq buffer (current-buffer)))
           (my-buffer . ,buffer)
           (select . ,(lambda ()
                        (my/tab-line--select-buffer buffer)))))
       (my/tab-line--group-buffers group))))

  (defun my/tab-line--buffers ()
    "Return the buffers represented by the current tab line."
    (mapcar (lambda (tab) (alist-get 'my-buffer tab))
            (my/tab-line-tabs)))

  (defun my/tab-line--switch (offset)
    "Switch OFFSET tabs within the current tab group."
    (let* ((buffers (my/tab-line--buffers))
           (position (seq-position buffers (current-buffer))))
      (when (and position (> (length buffers) 1))
        (my/tab-line--select-buffer
         (nth (mod (+ position offset) (length buffers)) buffers)))))

  (defun my/tab-line-next ()
    "Switch to the next buffer in the current tab group."
    (interactive)
    (my/tab-line--switch 1))

  (defun my/tab-line-previous ()
    "Switch to the previous buffer in the current tab group."
    (interactive)
    (my/tab-line--switch -1))

  (defun my/tab-line-select-number ()
    "Select the numbered tab indicated by the final key event."
    (interactive)
    (let* ((number (- last-command-event ?0))
           (buffer (nth (1- number) (my/tab-line--buffers))))
      (when buffer
        (my/tab-line--select-buffer buffer))))

  (defun my/tab-line--turn-on ()
    "Enable native tab-line only for buffers assigned to a tab group."
    (when (and (not (minibufferp))
               (my/tab-line-buffer-group))
      (tab-line-mode 1)))

  (define-globalized-minor-mode my/global-tab-line-mode
    tab-line-mode my/tab-line--turn-on)

  (my/tab-line--apply-zed-faces)
  (add-hook 'doom-load-theme-hook #'my/tab-line--apply-zed-faces 100)
  (my/global-tab-line-mode 1))

(after! indent-bars
  ;; Match Zed's Catppuccin Frappé indent guides: thin, continuous bars with
  ;; the current nesting level rendered a little brighter.
  (setq indent-bars-pattern "."
        indent-bars-width-frac 0.1
        indent-bars-pad-frac 0.1
        indent-bars-color '("#414559" :blend 0.6)
        indent-bars-color-by-depth nil
        indent-bars-highlight-current-depth '(:color "#626880")
        indent-bars-depth-update-delay 0
        indent-bars-display-on-blank-lines 'least))
;; ------------------------------ GUI -----------------------------------------
;; tweaks
(setq display-line-numbers-type 'relative)
;; (add-hook 'c-mode-common-hook 'display-line-numbers-mode)
(defun ishovkun/add-line-number-padding-h ()
  "Add one display-only character between line numbers and buffer text."
  (setq-local line-prefix " "
              wrap-prefix " "))
(add-hook 'prog-mode-hook #'ishovkun/add-line-number-padding-h)
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

(when (display-graphic-p)
  (load! "frame-status")
  (ishovkun-frame-status-enable))

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
  (setopt dirvish-quick-access-entries
          `(("h" "~/"                          "Home")
            ("e" ,user-emacs-directory         "Emacs user directory")
            ("c" "~/dev/"                      "Code")
            ("b" "~/build/"                    "Build")
            ("l" "~/Downloads/"                "Downloads")
            ("m" "/mnt/"                       "Mounted drives")
            ("t" "~/.local/share/Trash/files/" "Trash"))))
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
  (setq tramp-default-method "ssh")
  (setq tramp-use-ssh-controlmaster-options t)
  (setq tramp-ssh-controlmaster-options
        (concat "-o ControlMaster=auto "
                "-o ControlPath='tramp.%%C' "
                "-o ControlPersist=600"))
  (setq tramp-copy-size-limit (* 1024 1024))
  (setq tramp-inline-compress-start-size (* 1024 1024))
  (setq remote-file-name-inhibit-cache 60)
  (setq tramp-verbose 1)
  (setq tramp-shell-prompt-pattern "^[^$>\n]*[#$%>] *\\(\[[0-9;]*[a-zA-Z] *\\)*")
  (setq enable-remote-dir-locals t)
  (setq tramp-auto-save-directory (expand-file-name "tramp-autosave" doom-cache-dir))
  (make-directory tramp-auto-save-directory t)
  (setq projectile--mode-line "Projectile")
  (setq vc-ignore-dir-regexp
        (format "\\(%s\\)\\|\\(%s\\)"
                vc-ignore-dir-regexp
                tramp-file-name-regexp))
  (connection-local-set-profile-variables
   'ishovkun/remote-fast
   '((vc-handled-backends . nil)
     (magit-auto-revert-mode . nil)))
  (connection-local-set-profiles
   '(:application tramp) 'ishovkun/remote-fast))

;; Opt-in faster remote backend: use /rpc:host:/path instead of /ssh:host:/path.
;; Auto-deploys a Rust sidecar to the remote on first connect. Falls back to
;; regular TRAMP (/ssh:, /scp:) if anything goes sideways.
;; Disabled 2026-04-23: v0.8.0 binary vs. git-HEAD elisp version skew causes
;; "RPC error: Method not found: process.status" even on non-rpc paths.
;; Re-enable once upstream cuts a release including today's process.status fix.
;; (use-package! msgpack)
;; (use-package! tramp-rpc
;;   :after tramp)

;; google-c-style
(use-package! google-c-style
  :load-path "~/.doom.d/extra"
  :config
  (add-hook 'c-mode-common-hook 'google-set-c-style)
  (add-hook 'c-mode-common-hook 'google-make-newline-indent)
  )
;; disable realgud confirmations
(after! realgud (setq realgud-safe-mode 'nil))
;; --------------------------------- autocomplete ----------------------------
;; (use-package company-box :hook (company-mode . company-box-mode))
;; ----------------------------------- Deft ----------------------------------
(after! deft
 (setq deft-directory "~/notes")
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
      (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.0))
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

(after! org-appear
  ;; External edits can briefly leave a visited Org file in fundamental-mode
  ;; while org-appear's local command hooks or timer are still active.
  (defun my/org-appear-current-elem-only-in-org-mode (original &rest arguments)
    "Run org-appear's parser only in Org-derived buffers."
    (when (derived-mode-p 'org-mode)
      (apply original arguments)))

  (advice-remove #'org-appear--current-elem
                 #'my/org-appear-current-elem-only-in-org-mode)
  (advice-add #'org-appear--current-elem :around
              #'my/org-appear-current-elem-only-in-org-mode))

(after! org-download
  ;; Native Wayland region capture; Doom Doctor only checks legacy X11 tools.
  (setq org-download-screenshot-method "grim -g \"$(slurp)\" \"%s\""))

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
  :init
  (setq copilot-install-dir
        (expand-file-name ".cache/copilot/" doom-emacs-dir))
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
  ;; Treat any remote path as not-a-project — prevents projectile from
  ;; recursively indexing remote trees over TRAMP (catastrophically slow).
  (setq projectile-ignored-project-function #'file-remote-p)
  ;; Do not let ~/.git turn every nested directory into the same project.
  (setq projectile-project-root-files-bottom-up
        (remove ".git" projectile-project-root-files-bottom-up))
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

;; -------------------------------- AI agents (ACP) -------------------------------
;; agent-shell runs Claude Code / Codex in a native Emacs buffer over the Agent
;; Client Protocol — the same agents as Zed's claude-acp/codex-acp.
;;   M-x agent-shell                            ; pick an agent
;;   M-x agent-shell-anthropic-start-claude-code
;;   M-x agent-shell-openai-start-codex
;; Sessions persist under .agent-shell/ at the project root (auto-gitignored).
;; Requires the ACP CLIs on PATH; :login t reuses the existing CLI logins (as Zed
;; does) instead of API keys. Swap to (:api-key ...) if you'd rather use keys.
;; GUI/daemon Emacs doesn't reliably inherit the shell PATH, so make sure
;; ~/.local/bin (where claude-agent-acp / codex-acp live) is on exec-path & PATH.
(let ((local-bin (expand-file-name "~/.local/bin")))
  (add-to-list 'exec-path local-bin)
  (unless (member local-bin (split-string (or (getenv "PATH") "") path-separator))
    (setenv "PATH" (concat local-bin path-separator (getenv "PATH")))))
(use-package! agent-shell
  :config
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t))
  (setq agent-shell-openai-authentication
        (agent-shell-openai-make-authentication :login t))

  (defvar-local my/agent-shell-tab-edit-subscription nil
    "Agent Shell file-write subscription used for tab markers.")

  (defun my/agent-shell--subscribe-tab-edit-markers ()
    "Track files written by this Agent Shell in native tab-line."
    (when my/agent-shell-tab-edit-subscription
      (agent-shell-unsubscribe
       :subscription my/agent-shell-tab-edit-subscription))
    (setq my/agent-shell-tab-edit-subscription
          (agent-shell-subscribe-to
           :shell-buffer (current-buffer)
           :event 'file-write
           :on-event #'my/tab-line--mark-agent-edited)))

  (add-hook 'agent-shell-mode-hook
            #'my/agent-shell--subscribe-tab-edit-markers)
  ;; Reloading the config should also attach markers to existing conversations.
  (dolist (shell-buffer (agent-shell-buffers))
    (with-current-buffer shell-buffer
      (my/agent-shell--subscribe-tab-edit-markers)))

  ;; Cmd-R toggles the most recently used conversation without forcing Agent
  ;; Shell into a fixed side-window layout.  If its former window still exists,
  ;; reuse it; if that window was deleted, recreate an equivalent split.
  (defvar my/agent-shell-last-chat-buffer nil)
  (defvar my/agent-shell-last-chat-window nil)
  (defvar my/agent-shell-chat-return-buffer nil)
  (defvar my/agent-shell-chat-layout nil)

  (defun my/agent-shell--chat-window ()
    "Return a visible Agent Shell conversation window in the current frame."
    (seq-find
     (lambda (window)
       (my/tab-line--chat-buffer-p (window-buffer window)))
     (window-list nil 'nomini)))

  (defun my/agent-shell--window-layout (window)
    "Describe WINDOW's split side and size for later recreation."
    (when-let ((parent (window-parent window)))
      (let* ((horizontal (window-combination-p parent t))
             (before (window-prev-sibling window))
             (after (window-next-sibling window))
             (edges (window-edges window))
             (frame-midpoint
              (if horizontal
                  (/ (frame-width (window-frame window)) 2)
                (/ (frame-height (window-frame window)) 2)))
             (window-midpoint
              (if horizontal
                  (/ (+ (nth 0 edges) (nth 2 edges)) 2)
                (/ (+ (nth 1 edges) (nth 3 edges)) 2)))
             (side
              (if horizontal
                  (cond ((null before) 'left)
                        ((null after) 'right)
                        ((< window-midpoint frame-midpoint) 'left)
                        (t 'right))
                (cond ((null before) 'above)
                      ((null after) 'below)
                      ((< window-midpoint frame-midpoint) 'above)
                      (t 'below)))))
        (list :side side
              :size (if horizontal
                        (window-total-width window)
                      (window-total-height window))))))

  (defun my/agent-shell--remember-chat ()
    "Remember the selected Agent Shell conversation and its window."
    (when (my/tab-line--chat-buffer-p)
      (setq my/agent-shell-last-chat-buffer (current-buffer)
            my/agent-shell-last-chat-window (selected-window))
      (unless (one-window-p t)
        (when-let ((layout
                    (my/agent-shell--window-layout (selected-window))))
          (setq my/agent-shell-chat-layout layout)))))

  (defun my/agent-shell--fallback-chat-buffer ()
    "Return the most recently used live Agent Shell conversation."
    (or (and (buffer-live-p my/agent-shell-last-chat-buffer)
             (my/tab-line--chat-buffer-p
              my/agent-shell-last-chat-buffer)
             my/agent-shell-last-chat-buffer)
        (when-let ((shell-buffer (car (agent-shell-buffers))))
          (or (and (bound-and-true-p
                    agent-shell-prefer-viewport-interaction)
                   (agent-shell-viewport--buffer
                    :shell-buffer shell-buffer :existing-only t))
              shell-buffer))))

  (defun my/agent-shell--show-chat-buffer (buffer)
    "Show BUFFER in its former chat window or recreate its former split."
    (let ((origin (selected-window)))
      (setq my/agent-shell-chat-return-buffer (window-buffer origin))
      (cond
       ;; The former chat pane still exists but currently shows another buffer.
       ((window-live-p my/agent-shell-last-chat-window)
        (my/tab-line--select-buffer
         buffer my/agent-shell-last-chat-window)
        (select-window my/agent-shell-last-chat-window))
       ;; Recreate a deleted chat pane with its last known orientation and size.
       (my/agent-shell-chat-layout
        (let* ((side (plist-get my/agent-shell-chat-layout :side))
               (size (plist-get my/agent-shell-chat-layout :size))
               (window
                (condition-case nil
                    (split-window origin (- size) side)
                  (error nil))))
          (if window
              (progn
                (set-window-buffer window buffer)
                (setq my/agent-shell-last-chat-window window)
                (select-window window))
            (switch-to-buffer buffer))))
       ;; With no remembered layout, use the current window.
       (t
        (switch-to-buffer buffer)))))

  (defun my/agent-shell--toggle-chat-window ()
    "Toggle the most recently used Agent Shell conversation window."
    (if-let ((chat-window (my/agent-shell--chat-window)))
        (progn
          (with-selected-window chat-window
            (my/agent-shell--remember-chat))
          (if (one-window-p t)
              (if (buffer-live-p my/agent-shell-chat-return-buffer)
                  (switch-to-buffer my/agent-shell-chat-return-buffer)
                (previous-buffer))
            (delete-window chat-window)))
      (if-let ((chat-buffer (my/agent-shell--fallback-chat-buffer)))
          (my/agent-shell--show-chat-buffer chat-buffer)
        (call-interactively #'agent-shell))))

  (add-hook 'post-command-hook #'my/agent-shell--remember-chat)

  ;; Keep Evil yanks as normal text everywhere, including the system
  ;; clipboard.  When that same yank is pasted into an agent prompt, paste a
  ;; compact file/line reference instead (Zed-style).
  (defvar my/agent-shell-evil-yank-context nil)

  (defun my/agent-shell--remember-evil-yank
      (beg end _type register &optional _yank-handler)
    "Remember the file and line range most recently yanked by Evil."
    (setq my/agent-shell-evil-yank-context
          (when (and buffer-file-name (< beg end) (not (eq register ?_)))
            (let* ((project (project-current nil
                                             (file-name-directory
                                              buffer-file-name)))
                   (root (and project (project-root project)))
                   (path (if root
                             (file-relative-name buffer-file-name root)
                           buffer-file-name))
                   (last-pos
                    (save-excursion
                      (goto-char end)
                      (if (and (bolp) (> end beg))
                          (1- end)
                        end)))
                   (text
                    (condition-case nil
                        (evil-get-register (or register ?\") t)
                      (error nil))))
              (when (stringp text)
                (list :text (substring-no-properties text)
                      :path path
                      :line-start (line-number-at-pos beg)
                      :line-end (line-number-at-pos last-pos)))))))

  (defun my/agent-shell--prompt-buffer-p ()
    "Return non-nil when point is in an Agent Shell prompt buffer."
    (derived-mode-p 'agent-shell-mode 'agent-shell-viewport-edit-mode))

  (defun my/agent-shell--evil-paste-as-reference
      (original count &optional register yank-handler)
    "Paste a remembered Evil yank as a reference in Agent Shell."
    (let* ((context my/agent-shell-evil-yank-context)
           (text (condition-case nil
                     (if register
                         (evil-get-register register t)
                       (current-kill 0 t))
                   (error nil))))
      (if (and context
               (my/agent-shell--prompt-buffer-p)
               (stringp text)
               (equal (substring-no-properties text)
                      (plist-get context :text)))
          (let* ((reference
                  (format "%s:%d-%d"
                          (plist-get context :path)
                          (plist-get context :line-start)
                          (plist-get context :line-end)))
                 ;; Give Evil a temporary unnamed register.  The real kill
                 ;; ring and named registers remain unchanged.
                 (kill-ring (cons reference kill-ring))
                 (kill-ring-yank-pointer kill-ring)
                 (interprogram-paste-function nil))
            (funcall original count nil nil))
        (funcall original count register yank-handler))))

  (after! evil
    ;; Avoid stacking the advice when reloading Doom's config.
    (advice-remove #'evil-yank
                   #'my/agent-shell--remember-evil-yank)
    (advice-remove #'evil-paste-before
                   #'my/agent-shell--evil-paste-as-reference)
    (advice-remove #'evil-paste-after
                   #'my/agent-shell--evil-paste-as-reference)
    (advice-add #'evil-yank :after
                #'my/agent-shell--remember-evil-yank)
    (advice-add #'evil-paste-before :around
                #'my/agent-shell--evil-paste-as-reference)
    (advice-add #'evil-paste-after :around
                #'my/agent-shell--evil-paste-as-reference))

  ;; Permission banners use text-property keymaps upstream, so their y/!/n
  ;; shortcuts only work when point is exactly on a button and conflict with
  ;; Evil operators.  Resolve the latest pending permission from session state
  ;; instead, making these commands reliable from any Evil state and anywhere
  ;; in the shell or viewport.
  (defun my/agent-shell--pending-permission ()
    "Return the latest pending Agent Shell permission and its session data."
    (let* ((shell-buffer (agent-shell--shell-buffer :no-create t))
           (state (with-current-buffer shell-buffer
                    (agent-shell--state)))
           pending)
      (map-do
       (lambda (tool-call-id tool-call)
         (when (map-elt tool-call :permission-request-id)
           (setq pending
                 (list shell-buffer state tool-call-id tool-call))))
       (map-elt state :tool-calls))
      (or pending
          (user-error "No pending Agent Shell permission"))))

  (defun my/agent-shell--respond-to-permission (kind)
    "Respond to the latest pending permission using action KIND."
    (pcase-let* ((`(,shell-buffer ,state ,tool-call-id ,tool-call)
                  (my/agent-shell--pending-permission))
                 (action
                  (seq-find
                   (lambda (candidate)
                     (equal (map-elt candidate :kind) kind))
                   (map-elt tool-call :permission-actions))))
      (unless action
        (user-error "Permission does not offer %s"
                    (replace-regexp-in-string "_" " " kind)))
      (with-current-buffer shell-buffer
        (agent-shell--send-permission-response
         :client (map-elt state :client)
         :request-id (map-elt tool-call :permission-request-id)
         :option-id (map-elt action :option-id)
         :state state
         :tool-call-id tool-call-id
         :message-text (format "Selected: %s"
                               (map-elt action :option)))
        (when (equal kind "reject_once")
          ;; Match Agent Shell's built-in Reject button: reject, then stop so
          ;; there is a prompt where the request can be corrected.
          (agent-shell-interrupt t)))))

  (defun my/agent-shell-permission-allow-once ()
    "Allow the latest pending Agent Shell action once."
    (interactive)
    (my/agent-shell--respond-to-permission "allow_once"))

  (defun my/agent-shell-permission-allow-always ()
    "Always allow the latest pending Agent Shell action."
    (interactive)
    (my/agent-shell--respond-to-permission "allow_always"))

  (defun my/agent-shell-permission-reject ()
    "Reject the latest pending Agent Shell action and stop the turn."
    (interactive)
    (my/agent-shell--respond-to-permission "reject_once"))

  (defun my/agent-shell-permission-view-diff ()
    "View the diff attached to the latest pending Agent Shell action."
    (interactive)
    (pcase-let* ((`(,shell-buffer ,state ,tool-call-id ,tool-call)
                  (my/agent-shell--pending-permission))
                 (diffs (map-elt tool-call :diffs)))
      (unless diffs
        (user-error "Pending permission has no diff"))
      (with-current-buffer shell-buffer
        (funcall
         (agent-shell--make-diff-viewing-function
          :diffs diffs
          :actions (map-elt tool-call :permission-actions)
          :client (map-elt state :client)
          :request-id (map-elt tool-call :permission-request-id)
          :state state
          :tool-call-id tool-call-id)))))

  (defun my/agent-shell--permission-pending-p ()
    "Return non-nil when the current Agent Shell has a pending permission."
    (condition-case nil
        (progn
          (my/agent-shell--pending-permission)
          t)
      (error nil)))

  (defun my/agent-shell--call-major-binding (key fallback)
    "Invoke the major-mode binding for KEY, or FALLBACK when unbound."
    (let ((command (keymap-lookup (current-local-map) key)))
      (if (commandp command)
          (call-interactively command)
        (call-interactively fallback))))

  (defun my/agent-shell-permission-return ()
    "Allow once when permission is pending; otherwise preserve RET."
    (interactive)
    (if (my/agent-shell--permission-pending-p)
        (my/agent-shell-permission-allow-once)
      (my/agent-shell--call-major-binding "RET" #'newline)))

  (defun my/agent-shell--current-draft-p ()
    "Return non-nil when cancellation would overwrite an unsent draft."
    (or (condition-case nil
            (when-let* ((shell-buffer
                         (agent-shell--shell-buffer
                          :no-error t :no-create t)))
              (with-current-buffer shell-buffer
                (agent-shell--input)))
          (error nil))
        (and (derived-mode-p 'agent-shell-viewport-edit-mode)
             (not (string-empty-p
                   (string-trim
                    (buffer-substring-no-properties
                     (point-min) (point-max))))))))

  (defun my/agent-shell--last-submitted-input (shell-buffer)
    "Return the newest submitted input from SHELL-BUFFER history."
    (with-current-buffer shell-buffer
      (when (and (ring-p comint-input-ring)
                 (not (ring-empty-p comint-input-ring)))
        (substring-no-properties (ring-ref comint-input-ring 0)))))

  (defun my/agent-shell-interrupt-and-edit ()
    "Interrupt the active turn and restore its prompt for editing."
    (interactive)
    (let* ((shell-buffer (agent-shell--shell-buffer :no-create t))
           (input (my/agent-shell--last-submitted-input shell-buffer))
           token
           restored)
      (unless (and input (not (string-empty-p (string-trim input))))
        (user-error "No submitted prompt to restore"))
      (cl-labels
          ((restore-input
            ()
            (unless restored
              (setq restored t)
              (with-current-buffer shell-buffer
                (when token
                  (agent-shell-unsubscribe :subscription token))
                ;; Never overwrite text that appeared while cancellation was
                ;; in flight.
                (unless (agent-shell--input)
                  (let ((inhibit-read-only t))
                    (goto-char (point-max))
                    (insert input))
                  (when-let* ((window (get-buffer-window shell-buffer t)))
                    (set-window-point window (point-max))
                    (with-selected-window window
                      (evil-insert-state))))))))
        (setq token
              (agent-shell-subscribe-to
               :shell-buffer shell-buffer
               :event 'turn-complete
               :on-event (lambda (_event)
                           (restore-input))))
        (with-current-buffer shell-buffer
          (agent-shell-interrupt t)
          ;; Sessions without an established ACP turn stop synchronously and
          ;; do not emit turn-complete.
          (unless (shell-maker-busy)
            (restore-input))))))

  (defun my/agent-shell-cancel-submitted-prompt ()
    "Cancel and restore a submitted prompt before the agent starts replying."
    (interactive)
    (let ((shell-buffer
           (agent-shell--shell-buffer :no-error t :no-create t)))
      (if (and shell-buffer
               (not (my/agent-shell--current-draft-p))
               (with-current-buffer shell-buffer
                 (and (eq (agent-shell-status) 'busy)
                      ;; Input submission resets this to nil.  The first
                      ;; message/thought/tool update sets it, closing the
                      ;; brief terminal-style edit window.
                      (null (map-elt (agent-shell--state)
                                     :last-entry-type)))))
          (my/agent-shell-interrupt-and-edit)
        (keyboard-quit))))


  (defun my/agent-shell--navigate-permission (backward)
    "Move between permission buttons, wrapping according to BACKWARD."
    (let ((move (if backward
                    #'agent-shell-previous-permission-button
                  #'agent-shell-next-permission-button)))
      (or (funcall move)
          (progn
            (goto-char (if backward (point-max) (point-min)))
            (funcall move))
          (user-error "No permission buttons in this view"))))

  (defun my/agent-shell-permission-tab ()
    "Navigate permissions when pending; otherwise preserve TAB."
    (interactive)
    (if (my/agent-shell--permission-pending-p)
        (my/agent-shell--navigate-permission nil)
      (my/agent-shell--call-major-binding "TAB" #'indent-for-tab-command)))

  (defun my/agent-shell-permission-backtab ()
    "Navigate permissions backwards when pending; otherwise preserve backtab."
    (interactive)
    (if (my/agent-shell--permission-pending-p)
        (my/agent-shell--navigate-permission t)
      (my/agent-shell--call-major-binding "<backtab>"
                                           #'indent-for-tab-command)))

  (defun my/agent-shell--permission-button-label
      (original &rest arguments)
    "Show the Evil-friendly shortcuts in Agent Shell permission buttons."
    (let* ((char (plist-get arguments :char))
           (option (plist-get arguments :option))
           (label
            (cond
             ((equal option "view diff") "View (⌘G / gv)")
             ((equal char "y") (format "%s (RET / ⌘Y)" option))
             ((equal char "!") (format "%s (⇧⌘Y)" option))
             ((and option char) (format "%s (ESC)" option)))))
      (when label
        (setq arguments (plist-put arguments :text label)
              arguments (plist-put arguments :help label)))
      (apply original arguments)))

  (advice-remove #'agent-shell--make-permission-button
                 #'my/agent-shell--permission-button-label)
  (advice-add #'agent-shell--make-permission-button :around
              #'my/agent-shell--permission-button-label)

  ;; macOS binds ⌘Y globally to `ns-paste-secondary'.  Bind Command keys
  ;; directly in the major maps (for Emacs state) and in Evil's per-state
  ;; auxiliary maps so the Agent Shell commands reliably win there only.
  (dolist (map (list agent-shell-mode-map
                     agent-shell-viewport-edit-mode-map
                     agent-shell-viewport-view-mode-map))
    (define-key map (kbd "s-y")
                #'my/agent-shell-permission-allow-once)
    (define-key map (kbd "s-Y")
                #'my/agent-shell-permission-allow-always)
    (define-key map (kbd "s-g")
                #'my/agent-shell-permission-view-diff)
    (define-key map (kbd "C-g")
                #'my/agent-shell-cancel-submitted-prompt)
    (evil-define-key* '(normal motion visual insert) map
      (kbd "s-y") #'my/agent-shell-permission-allow-once
      (kbd "s-Y") #'my/agent-shell-permission-allow-always
      (kbd "s-g") #'my/agent-shell-permission-view-diff
      (kbd "C-g") #'my/agent-shell-cancel-submitted-prompt))

  (defun my/agent-shell--ns-paste-secondary
      (original &rest arguments)
    "Turn macOS secondary paste into approval only for pending agent prompts."
    (if (and (derived-mode-p 'agent-shell-mode
                             'agent-shell-viewport-edit-mode
                             'agent-shell-viewport-view-mode)
             (my/agent-shell--permission-pending-p))
        (my/agent-shell-permission-allow-once)
      (apply original arguments)))

  ;; Cocoa Emacs dispatches ⌘Y to this command from `ns-win.el'.  Advising
  ;; the dispatched command is more reliable than competing with that global
  ;; platform binding, while the mode/pending checks preserve normal ⌘Y
  ;; everywhere else.
  (when (fboundp 'ns-paste-secondary)
    (advice-remove #'ns-paste-secondary
                   #'my/agent-shell--ns-paste-secondary)
    (advice-add #'ns-paste-secondary :around
                #'my/agent-shell--ns-paste-secondary))

  (map! :map (agent-shell-mode-map
              agent-shell-viewport-edit-mode-map
              agent-shell-viewport-view-mode-map)
        ;; Default permission controls in normal, motion, visual, and insert.
        :nvim "RET" #'my/agent-shell-permission-return
        :nvim "<return>" #'my/agent-shell-permission-return
        :nvim "TAB" #'my/agent-shell-permission-tab
        :nvim "<tab>" #'my/agent-shell-permission-tab
        :nvim "<backtab>" #'my/agent-shell-permission-backtab
        ;; Explicit fallbacks are useful in terminal Emacs.
        :nvim "C-c a" #'my/agent-shell-permission-allow-once
        :nvim "C-c A" #'my/agent-shell-permission-allow-always
        :nvim "C-c x" #'my/agent-shell-permission-reject
        :nvim "C-c v" #'my/agent-shell-permission-view-diff
        ;; Evil navigation in normal/motion state.
        :nm "h" #'evil-backward-char
        :nm "j" #'evil-next-visual-line
        :nm "k" #'evil-previous-visual-line
        :nm "l" #'evil-forward-char
        :nm "gv" #'my/agent-shell-permission-view-diff
        :nm "]p" #'agent-shell-next-permission-button
        :nm "[p" #'agent-shell-previous-permission-button))

;; Give every GUI Emacs instance its own emacsclient socket (server<PID>)
;; so external tools — claude_approver's EmacsWatcher in particular — can
;; reach any instance, not just the daemon. The daemon keeps the default
;; "server" name.
(unless (daemonp)
  (setq server-name (format "server%d" (emacs-pid)))
  (server-start))
