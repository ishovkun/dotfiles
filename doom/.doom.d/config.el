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

(defun my/agent-shell-conversations ()
  "Open one global popup for live and resumable Agent Shell conversations."
  (interactive)
  (require 'agent-shell)
  (my/agent-shell--select-conversation))

(defun my/agent-shell-new-conversation ()
  "Start a fresh conversation for the relevant Agent Shell context.

Reuse the current or project Agent Shell's agent and directory.  If no shell
exists yet, fall back to Agent Shell's normal agent chooser."
  (interactive)
  (require 'agent-shell)
  (if-let ((shell-buffer
            (or (and (derived-mode-p 'my/agent-shell-composer-mode)
                     (boundp 'my/agent-shell-composer-shell-buffer)
                     (buffer-local-value
                      'my/agent-shell-composer-shell-buffer
                      (current-buffer)))
                (agent-shell-shell-buffer :no-error t :no-create t))))
      (let* ((state (buffer-local-value 'agent-shell--state shell-buffer))
             (location (buffer-local-value 'default-directory shell-buffer)))
        ;; Do not ask Agent Shell to display a new conversation in the
        ;; dedicated composer window.
        (when-let ((shell-window (get-buffer-window shell-buffer t)))
          (select-window shell-window))
        (agent-shell--new-shell
         :location location
         :config (map-elt state :agent-config)))
    (call-interactively #'agent-shell-new-shell)))

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
  (when (fboundp 'my/org-refresh-right-tags-after-font-scale)
    (my/org-refresh-right-tags-after-font-scale))
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
  (when (facep 'header-line)
    (set-face-attribute 'header-line nil
                        :height (* 0.92 my/ui-font-scale)))
  (when-let ((window (active-minibuffer-window)))
    (with-current-buffer (window-buffer window)
      (my/minibuffer-apply-ui-font-scale)))
  (force-mode-line-update t)
  (when (fboundp 'tab-line-force-update)
    (tab-line-force-update t))
  (when (fboundp 'ishovkun-frame-status-refresh-theme)
    (ishovkun-frame-status-refresh-theme)))

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
  "Increase status, tab, breadcrumb, and minibuffer font size."
  (interactive)
  (my/ui-font-size-adjust 1))

(defun my/ui-font-size-decrease ()
  "Decrease status, tab, breadcrumb, and minibuffer font size."
  (interactive)
  (my/ui-font-size-adjust -1))

(add-hook 'minibuffer-setup-hook #'my/minibuffer-apply-ui-font-scale)
(add-hook 'after-change-major-mode-hook #'my/buffer-font-size--apply)
(add-hook 'doom-load-theme-hook #'my/ui-font-size--apply 110)

(defun my/counsel-imenu-dwim ()
  "Jump via `counsel-imenu', degrading gracefully with no imenu index.
Modes that set up no imenu leave `imenu-create-index-function' nil, so
plain `counsel-imenu' does (funcall nil) and dies with the cryptic
\"Symbol's function definition is void: nil\".  Give a clear message
instead."
  (interactive)
  (if (functionp imenu-create-index-function)
      (call-interactively #'counsel-imenu)
    (user-error "No imenu index in %s — nothing for `gs' to jump to"
                major-mode)))

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
  :nvi "M-'"        #'my/agent-shell-conversations
  :nvi "s-'"        #'my/agent-shell-conversations
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
  :nv "gs"          #'my/counsel-imenu-dwim
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
    :desc "Scroll down one line" :nv "C-j" #'scroll-up-line
    :desc "Scroll up one line"   :nv "C-k" #'scroll-down-line
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
  :desc "Open project buffer or file" :nv "SPC" #'my/project-picker
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
    :desc "New agent conversation" :nv "/" #'my/agent-shell-new-conversation
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

;; Doom's markdown module caps the preview body at 740px, which truncates wide
;; tables and forces horizontal scrolling.  Widen the body and let tables use
;; the full window while keeping prose at a readable measure.
(after! markdown-mode
  (setq markdown-xhtml-header-content
        (concat "<meta name='viewport' content='width=device-width, initial-scale=1'>"
                "<style>"
                " body { box-sizing: border-box; max-width: none; width: auto;"
                "        margin: 24px; padding: 0; }"
                " table { border-collapse: collapse; width: max-content; }"
                " td, th { white-space: nowrap; padding: 2px 10px;"
                "          border: 1px solid #d0d7de; }"
                "</style>")))

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
  (defface my/tab-line-separator '((t :background "gray50" :foreground "gray50"))
    "Face for the 1px separator between tab-line tabs.")

  (setq tab-line-close-button-show nil
        tab-line-new-button-show nil
        tab-line-separator
        (propertize " " 'display '(space :width (1)) 'face 'my/tab-line-separator)
        tab-line-switch-cycling t
        tab-line-tabs-function #'my/tab-line-tabs)

  (defvar-local my/tab-line-agent-edited nil
    "Non-nil when Agent Shell was the last writer of this buffer.")

  (defun my/tab-line--apply-zed-faces (&rest _)
    "Style native tab-line tabs using colors from the active theme."
    (let ((family (face-attribute 'default :family nil t))
          (height (* 0.92 my/ui-font-scale))
          (faces '(tab-line tab-line-tab tab-line-tab-inactive
                   tab-line-tab-current tab-line-highlight)))
      ;; Vertical padding scales with the tab-line character height so that the
      ;; tabs remain proportional across different font sizes and DPI settings.
      ;; The underline position equals -(box-pad) to land at the box bottom edge.
      (let* ((box-pad (max 4 (round (* (frame-char-height) height 0.27))))
             (box-pad- (- box-pad)))
      (if (memq 'catppuccin custom-enabled-themes)
          (progn
            ;; Clear color and box overrides left by another theme.  The
            ;; Catppuccin theme owns those attributes; this hook owns metrics.
            (dolist (face faces)
              (face-spec-recalc face nil))
            (set-face-attribute 'tab-line nil
                                :family family
                                :height height
                                :weight 'normal
                                :width 'normal
                                :slant 'normal
                                :box nil)
            (dolist (face '(tab-line-tab tab-line-tab-inactive
                            tab-line-tab-current tab-line-highlight))
              (set-face-attribute face nil
                                  :weight 'normal
                                  :width 'normal
                                  :slant 'normal))
            ;; Override hardcoded pixel values from the theme with scaled ones.
            (let ((border-c (face-attribute 'tab-line-tab :overline nil t))
                  (inactive-c (face-attribute 'tab-line-tab :background nil t))
                  (current-c (face-attribute 'tab-line-tab-current :background nil t))
                  (hover-c (face-attribute 'tab-line-highlight :background nil t)))
              (dolist (face '(tab-line-tab tab-line-tab-inactive))
                (set-face-attribute face nil
                                    :box `(:line-width (1 . ,box-pad) :color ,inactive-c)
                                    :underline `(:color ,border-c :style line :position ,box-pad-)))
              (set-face-attribute 'tab-line-tab-current nil
                                  :box `(:line-width (1 . ,box-pad) :color ,current-c)
                                  :underline nil)
              (set-face-attribute 'tab-line-highlight nil
                                  :box `(:line-width (1 . ,box-pad) :color ,hover-c)
                                  :underline `(:color ,border-c :style line :position ,box-pad-))
              (set-face-attribute 'my/tab-line-separator nil
                                  :background border-c
                                  :foreground border-c)))
        (cl-labels
            ((theme-color (face attribute fallback)
               (let ((value (face-attribute face attribute nil t)))
                 (if (or (null value) (eq value 'unspecified)) fallback value))))
          (let* ((default-bg (theme-color 'default :background "#000000"))
                 (default-fg (theme-color 'default :foreground "#ffffff"))
                 (bar-bg (theme-color 'mode-line-inactive :background default-bg))
                 (bar-fg (theme-color 'mode-line-inactive :foreground default-fg))
                 (inactive-bg default-bg)
                 (inactive-fg bar-fg)
                 (current-bg (theme-color 'region :background bar-bg))
                 (current-fg default-fg)
                 (hover-bg (theme-color 'highlight :background current-bg))
                 (hover-fg (theme-color 'highlight :foreground current-fg))
                 (border-color (theme-color 'vertical-border :foreground bar-fg)))
        ;; Pin every metric that can change glyph width.  In particular,
        ;; `tab-line-tab-current' does not inherit `tab-line-tab' by default,
        ;; which lets themes render the active title with a different font.
            (set-face-attribute 'tab-line nil
                                :family family
                                :background bar-bg
                                :foreground bar-fg
                                :height height
                                :weight 'normal
                                :width 'normal
                                :slant 'normal
                                :box nil)
            (set-face-attribute 'my/tab-line-separator nil
                                :background border-color
                                :foreground border-color)
            (set-face-attribute 'tab-line-tab nil
                                :inherit 'tab-line
                                :background inactive-bg
                                :foreground inactive-fg
                                :weight 'normal
                                :width 'normal
                                :slant 'normal
                                :overline border-color
                                :underline `(:color ,border-color :style line :position ,box-pad-)
                                :box `(:line-width (1 . ,box-pad) :color ,inactive-bg))
            (set-face-attribute 'tab-line-tab-inactive nil
                                :inherit 'tab-line-tab
                                :background inactive-bg
                                :foreground inactive-fg
                                :weight 'normal
                                :width 'normal
                                :slant 'normal
                                :overline border-color
                                :underline `(:color ,border-color :style line :position ,box-pad-)
                                :box `(:line-width (1 . ,box-pad) :color ,inactive-bg))
            (set-face-attribute 'tab-line-tab-current nil
                                :inherit 'tab-line-tab
                                :background current-bg
                                :foreground current-fg
                                :weight 'normal
                                :width 'normal
                                :slant 'normal
                                :overline border-color
                                :underline nil
                                :box `(:line-width (1 . ,box-pad) :color ,current-bg))
            (set-face-attribute 'tab-line-highlight nil
                                :inherit 'tab-line-tab
                                :background hover-bg
                                :foreground hover-fg
                                :weight 'normal
                                :width 'normal
                                :slant 'normal
                                :overline border-color
                                :underline `(:color ,border-color :style line :position ,box-pad-)
                                :box `(:line-width (1 . ,box-pad) :color ,hover-bg))))))))

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
             (delete-dups
              (cons (current-buffer) (copy-sequence candidates))))))
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
  (add-hook 'enable-theme-functions #'my/tab-line--apply-zed-faces 100)
  (my/global-tab-line-mode 1))

(use-package! breadcrumb
  :init
  (setq breadcrumb-project-max-length 0.5
        breadcrumb-imenu-max-length 0.4
        breadcrumb-project-crumb-separator " › "
        breadcrumb-imenu-crumb-separator " › ")
  :config
  (defun my/breadcrumb--header-line ()
    "Render one path and semantic breadcrumb chain for the current window."
    (let ((parts
           (delq nil
                 (mapcar
                  (lambda (crumbs)
                    (unless (string-empty-p (or crumbs "")) crumbs))
                  (list (breadcrumb-project-crumbs)
                        (breadcrumb-imenu-crumbs))))))
      (when parts
        (let ((text
               (concat
                " "
                (string-join
                 parts (propertize " › " 'face 'breadcrumb-face)))))
          ;; Header lines share the font baseline with their underline.  Raise
          ;; only the glyphs so the rule remains at the bottom of the padded
          ;; row instead of sitting directly beneath the letters.
          (add-text-properties
           0 (length text) '(display (raise 0.18)) text)
          text))))

  ;; Keep Breadcrumb's project/Imenu caching and mode lifecycle; replace only
  ;; its hard-coded separator between the path and semantic groups.
  (advice-remove #'breadcrumb--header-line #'my/breadcrumb--header-line)
  (advice-add #'breadcrumb--header-line :override
              #'my/breadcrumb--header-line)
  (breadcrumb-mode 1)
  (my/ui-font-size--apply))

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

;; Make `SPC SPC' behave like Zed's project picker.  Use Emacs's local VC
;; project backend here instead of Projectile: Projectile intentionally ignores
;; bare .git roots below (otherwise ~/.git claims every directory), while the VC
;; backend still resolves the nearest local repository correctly.
(defvar my/project-picker-history nil)

(defun my/project-picker--active-files (root)
  "Return recently active file buffers beneath ROOT as relative paths."
  (delete-dups
   (delq nil
         (mapcar
          (lambda (buffer)
            (when-let ((file (buffer-local-value 'buffer-file-name buffer)))
              (when (ignore-errors (file-in-directory-p file root))
                (file-relative-name file root))))
          (buffer-list)))))

(defun my/project-picker--project-files (project root)
  "Return PROJECT files as paths relative to ROOT."
  (let ((project-files-relative-names t))
    (delete-dups
     (mapcar (lambda (file)
               (file-relative-name (expand-file-name file root) root))
             (project-files project)))))

(defun my/project-picker--candidates (project root)
  "Return open files first, then remaining PROJECT files beneath ROOT."
  (let* ((active (my/project-picker--active-files root))
         (active-set (make-hash-table :test #'equal))
         (files (my/project-picker--project-files project root)))
    (dolist (file active)
      (puthash file t active-set))
    (append
     (mapcar (lambda (file)
               (propertize file 'my/project-picker-kind 'buffer))
             active)
     (mapcar (lambda (file)
               (propertize file 'my/project-picker-kind 'file))
             (seq-remove (lambda (file) (gethash file active-set)) files)))))

(defun my/project-picker ()
  "Open an active buffer or another file in the current local project."
  (interactive)
  (require 'project)
  (require 'ivy)
  (if-let ((project (and (not (file-remote-p default-directory))
                         (project-current nil))))
      (let* ((root (file-name-as-directory
                    (expand-file-name (project-root project))))
             (candidates (my/project-picker--candidates project root))
             (current (when-let ((file buffer-file-name))
                        (when (ignore-errors (file-in-directory-p file root))
                          (file-relative-name file root)))))
        (ivy-read
         (format "[%s] Open: "
                 (file-name-nondirectory (directory-file-name root)))
         candidates
         :require-match t
         :sort nil
         :history 'my/project-picker-history
         :preselect (and current (regexp-quote current))
         :action (lambda (candidate)
                   (find-file
                    (expand-file-name
                     (substring-no-properties candidate) root)))
         :caller 'my/project-picker))
    (+ivy/switch-workspace-buffer)))

(after! ivy
  (defun my/project-picker--transformer (candidate)
    "Render CANDIDATE and retain which project-picker section it belongs to."
    (let* ((kind (get-text-property 0 'my/project-picker-kind candidate))
           (file (substring-no-properties candidate))
           (rendered
            (if (and (display-graphic-p)
                     (fboundp 'nerd-icons-icon-for-file))
                (concat (nerd-icons-icon-for-file file) " " file)
              file)))
      (add-text-properties 0 (length rendered)
                           `(my/project-picker-kind ,kind)
                           rendered)
      (when (eq kind 'file)
        (add-face-text-property 0 (length rendered) 'ivy-virtual nil rendered))
      rendered))

  (defun my/project-picker--add-divider (formatted-candidates)
    "Draw the breadcrumb rule above the first line of FORMATTED-CANDIDATES."
    (let* ((underline (face-attribute 'header-line :underline nil t))
           (color (or (face-background 'ivy-posframe-border nil t)
                      (and (listp underline)
                           (plist-get underline :color))
                      (face-foreground 'breadcrumb-face nil t)
                      (face-background 'ivy-current-match nil t)
                      (face-foreground 'default nil t)))
           (rule-face `(:overline ,color))
           (fringe-face 'my/ivy-posframe-divider-fringe)
           (rendered (copy-sequence formatted-candidates))
           (line-end (or (string-match-p "\n" rendered)
                         (length rendered))))
      (when (facep fringe-face)
        (set-face-attribute fringe-face nil
                            :foreground color
                            :background
                            (face-background 'ivy-posframe nil t)))
      ;; Apply this after Ivy has painted `ivy-current-match'.  Its Colir
      ;; blending otherwise reconstructs the selected candidate's face and
      ;; discards our overline from the glyphs while leaving the stretch intact.
      (add-face-text-property 0 line-end rule-face t rendered)
      (concat (propertize
               " " 'display
               `(left-fringe my/ivy-posframe-divider-bitmap ,fringe-face))
              (propertize
               " " 'display
               `(right-fringe my/ivy-posframe-divider-bitmap ,fringe-face))
              (substring rendered 0 line-end)
              (propertize
               " "
               'display '(space :align-to (- right-fringe 0))
               'face rule-face)
              (substring rendered line-end))))

  (defun my/project-picker--format (candidates)
    "Format CANDIDATES with a non-selectable project-files divider."
    (let ((boundary
           (cl-position 'file candidates
                        :key (lambda (candidate)
                               (get-text-property
                                0 'my/project-picker-kind candidate)))))
      (if (not (and boundary (> boundary 0)))
          (+ivy-format-function-line-or-arrow candidates)
        (let ((buffer-candidates (cl-subseq candidates 0 boundary))
              (file-candidates (nthcdr boundary candidates)))
          (concat
           (let ((ivy--window-index ivy--window-index))
             (+ivy-format-function-line-or-arrow buffer-candidates))
           (my/project-picker--add-divider
            (let ((ivy--window-index (- ivy--window-index boundary)))
              (+ivy-format-function-line-or-arrow file-candidates))))))))

  (ivy-configure 'my/project-picker
    :display-transformer-fn #'my/project-picker--transformer
    :format-fn #'my/project-picker--format))

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
          doom-modeline-indent-info nil
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
      (let* ((state (or evil-state 'normal))
             (face
              (if (doom-modeline--active)
                  (pcase state
                    ((or 'insert 'hybrid) 'doom-modeline-evil-insert-state)
                    ('emacs 'doom-modeline-evil-emacs-state)
                    ('motion 'doom-modeline-evil-motion-state)
                    ('visual 'doom-modeline-evil-visual-state)
                    ('operator 'doom-modeline-evil-operator-state)
                    ('replace 'doom-modeline-evil-replace-state)
                    (_ 'doom-modeline-evil-normal-state))
                'mode-line-inactive)))
        (propertize (format " %s " (upcase (symbol-name state)))
                    'face face))))
  ;; filesize in modeline
  (remove-hook 'doom-modeline-mode-hook #'size-indication-mode)
  ;; my own modeline
  (doom-modeline-def-modeline 'ishovkun-line
    '(bar workspace-name fancy-modals matches remote-host buffer-position word-count parrot selection-info)
    '(misc-info persp-name buffer-encoding major-mode process vcs lsp check))

    (defun setup-custom-doom-modeline ()
      (doom-modeline-set-modeline 'ishovkun-line 'default))

    (add-hook 'doom-modeline-mode-hook 'setup-custom-doom-modeline)
  )  ;; end use-package doom-modeline

(when (display-graphic-p)
  (load! "statusbar/frame-status")
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

;; Render Ivy in a floating child frame.  `window-system' is nil while an
;; Emacs daemon loads this file, even though graphical frames may be created
;; later, so enable it per frame rather than skipping its configuration.
(defconst my/ivy-posframe-corner-radius 12
  "Corner radius, in pixels, for the native Ivy Posframe mask.")

(defconst my/ivy-posframe-horizontal-padding 12
  "Horizontal padding, in pixels, inside Ivy's Posframe.")

(defconst my/ivy-posframe-top-offset 50
  "Distance, in pixels, between the frame top and Ivy's Posframe.")

(define-fringe-bitmap
  'my/ivy-posframe-divider-bitmap
  (vector (1- (ash 1 my/ivy-posframe-horizontal-padding)))
  1 my/ivy-posframe-horizontal-padding 'top)

(defface my/ivy-posframe-divider-fringe
  '((t (:inherit ivy-posframe-border)))
  "Face used for the project-picker divider inside Posframe fringes."
  :group 'ivy-posframe)

(defun my/ivy-posframe--load-native-styler ()
  "Build and load the macOS Ivy Posframe styling module when available."
  (when (and (eq system-type 'darwin)
             (featurep 'dynamic-modules))
    (condition-case error-data
        (let* ((source
                (expand-file-name "native/ivy-posframe-ns.m" doom-user-dir))
               (header
                (expand-file-name "../../../include/emacs-module.h"
                                  invocation-directory))
               (compiler (executable-find "clang"))
               (digest
                (with-temp-buffer
                  (insert-file-contents-literally source)
                  (secure-hash 'sha256 (current-buffer))))
               (module
                (expand-file-name
                 (format "ivy-posframe-ns-%d-%s%s"
                         emacs-major-version (substring digest 0 12)
                         module-file-suffix)
                 doom-cache-dir)))
          (unless (file-exists-p module)
            (unless (and compiler (file-exists-p header))
              (error "clang or emacs-module.h is unavailable"))
            (make-directory (file-name-directory module) t)
            (with-temp-buffer
              (let ((status
                     (call-process
                      compiler nil t nil
                      "-O2" "-Wall" "-Wextra" "-fPIC"
                      "-bundle" "-undefined" "dynamic_lookup"
                      (concat "-I" (file-name-directory header))
                      "-framework" "Cocoa"
                      "-framework" "QuartzCore"
                      "-o" module source)))
                (unless (zerop status)
                  (error "native module build failed: %s"
                         (string-trim (buffer-string)))))))
          (unless (fboundp 'my/ivy-posframe--style-native-frames)
            (module-load module))
          (fboundp 'my/ivy-posframe--style-native-frames))
      (error
       (message "Ivy Posframe native rounding unavailable: %s"
                (error-message-string error-data))
       nil))))

(defface my/ivy-posframe-background
  '((t (:inherit ivy-posframe :extend t)))
  "Face used to normalize Ivy Posframe background surfaces."
  :group 'ivy-posframe)

(defface my/ivy-posframe-padding
  '((t (:inherit my/ivy-posframe-background :height 0.4 :extend t
        :box nil :underline nil :overline nil)))
  "Face used for the vertical padding inside Ivy's Posframe."
  :group 'ivy-posframe)

(use-package! ivy-posframe
  :after ivy
  :config
  (my/ivy-posframe--load-native-styler)

  (defun my/ivy-posframe--frame-top-center-offset (info)
    "Position Ivy Posframe below the frame top according to INFO."
    (let ((position (posframe-poshandler-frame-top-center info)))
      (cons (car position)
            (+ (cdr position) my/ivy-posframe-top-offset))))

  (defun my/ivy-posframe-display-at-frame-top-center (string)
    "Display STRING centered below the top of the current frame."
    (ivy-posframe--display
     string #'my/ivy-posframe--frame-top-center-offset))

  (setq ivy-posframe-display-functions-alist
        '((swiper          . nil)
          (counsel-ag      . nil)
          (complete-symbol . ivy-posframe-display-at-point)
          (t               . my/ivy-posframe-display-at-frame-top-center))
        ivy-fixed-height-minibuffer nil
        ivy-posframe-border-width
        (if (fboundp 'my/ivy-posframe--style-native-frames) 0 1)
        ivy-posframe-parameters `((title . "ivy-posframe")
                                  (min-width . 50)
                                  (min-height . ,ivy-height)
                                  (left-fringe . ,my/ivy-posframe-horizontal-padding)
                                  (right-fringe . ,my/ivy-posframe-horizontal-padding)
                                  ,@(when (eq system-type 'darwin)
                                      '((undecorated . t)
                                        (undecorated-round . nil)))))

  (defun my/ivy-posframe--add-padding (args)
    "Add theme-aware padding to Ivy Posframe call ARGS."
    (if (not (equal (car args) ivy-posframe-buffer))
        args
      (let ((background (face-background 'ivy-posframe nil t)))
        (set-face-attribute 'my/ivy-posframe-background nil
                            :background background)
        (set-face-attribute 'my/ivy-posframe-padding nil
                            :foreground background
                            :background background)
        (with-current-buffer (get-buffer-create ivy-posframe-buffer)
          ;; Solaire otherwise prepends its ordinary-buffer background to the
          ;; fringe and header faces after our Posframe remaps.
          (when (bound-and-true-p solaire-mode)
            (solaire-mode -1))
          (setq-local header-line-format nil
                      mode-line-format " "
                      face-remapping-alist
                      (append
                       '((default my/ivy-posframe-background default)
                         (mode-line my/ivy-posframe-padding mode-line)
                         (mode-line-inactive
                          my/ivy-posframe-padding mode-line-inactive)
                         (fringe my/ivy-posframe-background fringe))
                       (seq-remove
                        (lambda (entry)
                          (memq (car entry)
                                '(default header-line mode-line
                                  mode-line-inactive fringe)))
                        face-remapping-alist)))))
      (append args '(:respect-mode-line t))))

  (advice-remove 'posframe-show #'my/ivy-posframe--add-padding)
  (advice-add 'posframe-show :filter-args #'my/ivy-posframe--add-padding)

  (defun my/ivy-posframe--style-rounded-frame (&rest _)
    "Apply the native rounded mask to the visible Ivy Posframe."
    (let ((background (face-background 'ivy-posframe nil t)))
      (when-let* ((buffer (get-buffer ivy-posframe-buffer))
                  (frame (buffer-local-value 'posframe--frame buffer))
                  ((frame-live-p frame)))
        (set-face-attribute 'default frame :background background)
        (set-face-attribute 'fringe frame
                            :foreground background :background background)
        (set-face-attribute 'header-line frame :background background)
        (set-face-attribute 'mode-line frame :background background)
        (set-face-attribute 'mode-line-inactive frame :background background)
        (set-face-attribute 'my/ivy-posframe-background frame
                            :background background)
        (set-face-attribute 'my/ivy-posframe-padding frame
                            :foreground background :background background)))
    (when (fboundp 'my/ivy-posframe--style-native-frames)
      (when-let ((rgb (color-values
                       (face-background 'ivy-posframe-border nil t))))
        (apply #'my/ivy-posframe--style-native-frames
               my/ivy-posframe-corner-radius
               (mapcar (lambda (component)
                         (round (/ component 257.0)))
                       rgb)))))

  (advice-remove 'ivy-posframe--display
                 #'my/ivy-posframe--style-rounded-frame)
  (advice-add 'ivy-posframe--display :after
              #'my/ivy-posframe--style-rounded-frame)

  (defun my/ivy-posframe-enable-on-graphical-frame (&optional frame)
    "Enable floating Ivy menus when FRAME is graphical."
    (when (display-graphic-p frame)
      (ivy-posframe-mode 1)))

  (add-hook 'after-make-frame-functions
            #'my/ivy-posframe-enable-on-graphical-frame)
  (my/ivy-posframe-enable-on-graphical-frame (selected-frame)))

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
          ;; GNU ELPA Breadcrumb provides the universal project/Imenu header.
          lsp-headerline-breadcrumb-enable nil
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

;; Use basedpyright as the Python language server so `gs' (counsel-imenu over
;; LSP document symbols) shows exactly the class/function outline Zed does —
;; Zed's Python extension runs basedpyright too.  The variable only exists on
;; newer lsp-pyright, so guard it; without it lsp-pyright falls back to plain
;; `pyright', whose document-symbol tree is identical for outline purposes.
(after! lsp-pyright
  (when (boundp 'lsp-pyright-langserver-command)
    (setq lsp-pyright-langserver-command "basedpyright")))

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
  (setq deft-directory "~/notes"
        deft-extensions '("org" "md")
        deft-auto-save-interval 60.0
        deft-use-filename-as-title nil
        deft-use-filter-string-for-filename t
        deft-file-naming-rules
        '((noslash . "-")
          (nospace . "-")
          (case-fn . downcase)))

  (defun my/deft-edit-filter ()
    "Enter insert state to append to Deft's live filter."
    (interactive)
    (evil-insert-state))

  (defun my/deft-start-filter ()
    "Clear Deft's current filter and enter insert state."
    (interactive)
    (deft-filter-clear)
    (evil-insert-state))

  (defun my/deft-next-result ()
    "Move to the next Deft result, wrapping at the end."
    (interactive)
    (unless (forward-button 1 t nil t)
      (message "No Deft results.")))

  (defun my/deft-previous-result ()
    "Move to the previous Deft result, wrapping at the beginning."
    (interactive)
    (unless (backward-button 1 t nil t)
      (message "No Deft results.")))

  (defun my/deft-first-result ()
    "Move to the first Deft result."
    (interactive)
    (goto-char (point-min))
    (unless (forward-button 1 nil nil t)
      (message "No Deft results.")))

  (defun my/deft-last-result ()
    "Move to the last Deft result."
    (interactive)
    (goto-char (point-max))
    (unless (backward-button 1 nil nil t)
      (message "No Deft results.")))

  (defun my/deft-disable-evil-snipe ()
    "Keep Evil Snipe from shadowing Deft's browser bindings."
    (when (fboundp 'evil-snipe-local-mode)
      (evil-snipe-local-mode -1))
    (when (fboundp 'evil-snipe-override-local-mode)
      (evil-snipe-override-local-mode -1)))

  ;; Deft treats printable characters as filter input.  Keep that behavior in
  ;; insert state, and make normal state a conventional results browser.
  (set-evil-initial-state! 'deft-mode 'insert)
  (add-hook 'deft-mode-hook #'my/deft-disable-evil-snipe)
  (after! evil-snipe
    (add-to-list 'evil-snipe-disabled-modes 'deft-mode))
  (evil-define-key* '(normal motion) deft-mode-map
    (kbd "i")          #'my/deft-edit-filter
    (kbd "I")          #'my/deft-edit-filter
    (kbd "a")          #'my/deft-edit-filter
    (kbd "A")          #'my/deft-edit-filter
    (kbd "/")          #'my/deft-start-filter
    (kbd "j")          #'my/deft-next-result
    (kbd "k")          #'my/deft-previous-result
    (kbd "C-j")        #'my/deft-next-result
    (kbd "C-k")        #'my/deft-previous-result
    (kbd "gj")         #'my/deft-next-result
    (kbd "gk")         #'my/deft-previous-result
    (kbd "gg")         #'my/deft-first-result
    (kbd "G")          #'my/deft-last-result
    (kbd "RET")        #'deft-complete
    (kbd "<return>")   #'deft-complete
    (kbd "o")          #'deft-complete
    (kbd "O")          #'deft-open-file-other-window
    (kbd "q")          #'quit-window
    (kbd "gr")         #'deft-refresh
    (kbd "c")          #'deft-filter-clear
    (kbd "d")          #'deft-delete-file
    (kbd "D")          #'deft-archive-file
    (kbd "r")          #'deft-rename-file
    (kbd "n")          #'deft-new-file
    (kbd "N")          #'deft-new-file-named
    (kbd "f")          #'deft-find-file
    (kbd "s")          #'deft-toggle-sort-method
    (kbd "t")          #'deft-toggle-incremental-search)
  (evil-define-key* 'insert deft-mode-map
    (kbd "RET")        #'deft-complete
    (kbd "<return>")   #'deft-complete
    (kbd "C-j")        #'my/deft-next-result
    (kbd "C-k")        #'my/deft-previous-result
    (kbd "C-n")        #'my/deft-next-result
    (kbd "C-p")        #'my/deft-previous-result
    (kbd "DEL")        #'deft-filter-decrement
    (kbd "<backspace>") #'deft-filter-decrement
    (kbd "M-DEL")      #'deft-filter-decrement-word
    (kbd "M-<backspace>") #'deft-filter-decrement-word
    (kbd "C-w")        #'deft-filter-decrement-word
    (kbd "C-u")        #'deft-filter-clear))
;; ----------------------------------- Org ----------------------------------
(after! org
  (progn
    (defun my/org-insert-today ()
      "Insert today as an active Org timestamp without prompting.
In normal state, insert after the cursor (like `a'), because leaving insert
state moves point back onto the last typed char (e.g. the space after `*')."
      (interactive)
      (when (and (bound-and-true-p evil-local-mode)
                 (evil-normal-state-p)
                 (not (eolp)))
        (forward-char))
      (org-insert-time-stamp (current-time)))

    (defun my/org-set-todo-state (state)
      "Set the current Org heading to workflow STATE."
      (org-todo state))

    (defun my/org-todo-todo ()
      "Mark the current Org heading TODO."
      (interactive)
      (my/org-set-todo-state "TODO"))

    (defun my/org-todo-start ()
      "Mark the current Org heading STRT (shown as PROGRESS)."
      (interactive)
      (my/org-set-todo-state "STRT"))

    (defun my/org-todo-wait ()
      "Mark the current Org heading WAIT."
      (interactive)
      (my/org-set-todo-state "WAIT"))

    (defun my/org-todo-hold ()
      "Mark the current Org heading HOLD."
      (interactive)
      (my/org-set-todo-state "HOLD"))

    (defun my/org-todo-kill ()
      "Mark the current Org heading KILL."
      (interactive)
      (my/org-set-todo-state "KILL"))

    (defun my/org-todo-done ()
      "Mark the current Org heading DONE without adding a timestamp."
      (interactive)
      (my/org-set-todo-state "DONE"))

    (defun my/org-todo-done-with-today ()
      "Mark the current Org heading DONE and prefix its title with today."
      (interactive)
      (save-excursion
        (org-back-to-heading t)
        (my/org-set-todo-state "DONE")
        (org-back-to-heading t)
        (let ((heading (org-get-heading t t t t)))
          (unless (string-match-p
                   (concat "\\`" org-ts-regexp "\\(?:[[:space:]]\\|\\'\\)")
                   heading)
            (org-edit-headline
             (concat (format-time-string
                      (concat "<" (car org-time-stamp-formats) ">"))
                     (unless (string-empty-p heading) " ")
                     heading))))))

    (map! :map org-mode-map
          :localleader
          "p" #'org-priority
          "`" #'my/org-insert-today
          (:prefix ("t" . "todo state")
           :desc "Choose/cycle state" "RET" #'org-todo
           :desc "TODO" "t" #'my/org-todo-todo
           :desc "PROGRESS" "s" #'my/org-todo-start
           :desc "WAIT" "w" #'my/org-todo-wait
           :desc "HOLD" "h" #'my/org-todo-hold
           :desc "KILL" "k" #'my/org-todo-kill
           :desc "DONE + today" "d" #'my/org-todo-done-with-today
           :desc "DONE (no timestamp)" "D" #'my/org-todo-done))

    ;; Keep real Org TODO states while displaying their mirrored tag on the
    ;; right in todos.org.  Either `org-todo' or tag selection can change it.
    (defconst my/org-right-status-tags
      '("TODO" "STRT" "WAIT" "HOLD" "KILL" "DONE"))

    ;; Org keywords cannot contain spaces, so keep Doom's STRT in the file and
    ;; only change what the right-aligned badge says.
    (defconst my/org-right-status-labels
      '(("STRT" . "PROGRESS")))

    (defconst my/org-right-uppercase-markers '("bug" "feature"))

    (defvar-local my/org--syncing-right-status nil)
    (defvar-local my/org--right-status-display-installed nil)
    (defvar-local my/org--right-tag-display-installed nil)
    (defvar-local my/org--active-timestamp-display-installed nil)

    (defun my/org-match-active-timestamp-brackets (limit)
      "Style level-one active timestamp headings and hide brackets up to LIMIT."
      (when (re-search-forward (concat "^\\* +" org-ts-regexp) limit t)
        (let ((begin (1- (match-beginning 1)))
              (end (1+ (match-end 1)))
              (inhibit-read-only t))
          (with-silent-modifications
            ;; A journal date is the heading text, so derive all of its visual
            ;; attributes from the theme's level-one heading face.
            (put-text-property begin end 'face 'org-level-1)
            (put-text-property begin (1+ begin) 'display "")
            (put-text-property (1- end) end 'display ""))
          t)))

    (defun my/org-active-timestamp-display-setup ()
      "Hide timestamp brackets without replacing native Org heading faces."
      (unless my/org--active-timestamp-display-installed
        (setq-local my/org--active-timestamp-display-installed t)
        (add-to-list (make-local-variable 'font-lock-extra-managed-props)
                     'display)
        (font-lock-add-keywords
         nil '((my/org-match-active-timestamp-brackets (0 nil))) 'append))
      (font-lock-flush))

    (defun my/org-right-status-buffer-p ()
      (and buffer-file-name
           (file-equal-p buffer-file-name
                         (expand-file-name "~/notes/todos.org"))))

    (defun my/org-sync-right-status-tag-from-todo ()
      (when (and (my/org-right-status-buffer-p)
                 (org-at-heading-p)
                 (not my/org--syncing-right-status))
        (let* ((my/org--syncing-right-status t)
               (state (org-get-todo-state))
               (tags (seq-remove
                      (lambda (tag)
                        (member tag my/org-right-status-tags))
                      (org-get-tags nil t))))
          (org-set-tags (if state (cons state tags) tags)))))

    (defun my/org-sync-todo-from-right-status-tag ()
      (when (and (my/org-right-status-buffer-p)
                 (org-at-heading-p)
                 (not my/org--syncing-right-status))
        (let* ((my/org--syncing-right-status t)
               (state (seq-find
                       (lambda (tag) (member tag (org-get-tags nil t)))
                       my/org-right-status-tags))
               (current (org-get-todo-state)))
          (unless (equal state current)
            (org-todo (or state 'none))))))

    (defun my/org-match-native-status (limit)
      (when (my/org-right-status-buffer-p)
        (let ((case-fold-search nil)
              (status-regexp (regexp-opt my/org-right-status-tags)))
          (when (re-search-forward
                 (concat "^\\*+ +\\(" status-regexp "\\(?: +\\|$\\)\\)")
                 limit t)
            ;; `org-modern--todo' paints padding with `display' on the first
            ;; and last keyword characters.  A display replacement wins over
            ;; invisibility, leaving the first status character on screen, so
            ;; remove that chrome before hiding the native keyword.
            (remove-text-properties
             (match-beginning 1) (match-end 1) '(display nil))
            (add-text-properties
             (match-beginning 1) (match-end 1)
             '(invisible my/org-native-status
               rear-nonsticky (invisible)))
            t))))

    (defun my/org-right-status-face (status)
      "Return the same face Org Modern uses for native STATUS keywords."
      (if (and (bound-and-true-p org-modern-mode)
               (facep 'org-modern-label))
          (if-let ((face (and (boundp 'org-modern-todo-faces)
                              (or (cdr (assoc status org-modern-todo-faces))
                                  (cdr (assq t org-modern-todo-faces))))))
              `(:inherit (,face org-modern-label))
            (if (member status org-not-done-keywords)
                'org-modern-todo
              'org-modern-done))
        (if (member status org-done-keywords) 'org-done 'org-todo)))

    (defun my/org-right-marker-face (tag)
      "Return one full-size badge face for right-aligned TAG."
      (if (member tag my/org-right-status-tags)
          (my/org-right-status-face tag)
        ;; Type tags such as bug/feature should use the same substantial pill
        ;; as an active status instead of Org Modern's smaller generic label.
        (if (bound-and-true-p org-modern-mode)
            'org-modern-todo
          'org-todo)))

    (defun my/org-right-tags-pixel-width (begin end)
      "Return rendered width of tags between BEGIN and END.

Use the live window when available so buffer-local font remapping from M-=
is included in the measurement."
      (if-let ((window (get-buffer-window (current-buffer) t)))
          (car (window-text-pixel-size window begin end))
        (string-pixel-width (buffer-substring begin end))))

    (defun my/org-refresh-right-tags-after-font-scale ()
      "Refontify right-aligned tags after shared buffer zoom changes."
      (dolist (buffer (buffer-list))
        (with-current-buffer buffer
          (when (my/org-right-status-buffer-p)
            (font-lock-flush)
            ;; Hidden buffers will fontify after they acquire a window, when
            ;; `my/org-right-tags-pixel-width' can measure their live scale.
            (when (get-buffer-window buffer t)
              (font-lock-ensure))))))

    (defun my/org-match-right-aligned-tags (limit)
      (when (and (my/org-right-status-buffer-p)
                 (re-search-forward org-tag-line-re limit t))
        (let* ((tag-begin (match-beginning 1))
               (tag-end (match-end 1))
               (padding-begin
                (save-excursion
                  (goto-char tag-begin)
                  (skip-chars-backward " \t")
                  (point)))
               ;; Preserve the final display properties when measuring.
               (tag-width
                (progn
                  (save-excursion
                    ;; Hide the source-syntax colons at both edges.  Interior
                    ;; colons become a narrow transparent gap so adjacent
                    ;; marker backgrounds remain visually distinct.
                    (goto-char tag-begin)
                    (while (search-forward ":" tag-end t)
                      (let ((colon (1- (point))))
                        (put-text-property
                         colon (point) 'display
                         (if (and (> colon tag-begin)
                                  (< colon (1- tag-end)))
                             '(space :width 0.5)
                           ""))))
                    ;; Mirrored workflow states should be visually identical
                    ;; to their native TODO/DONE keyword.  Type markers use
                    ;; that same full-size badge treatment as well.
                    (goto-char tag-begin)
                    (while (re-search-forward "[^:]+" tag-end t)
                      (let ((tag (match-string-no-properties 0))
                            (marker-begin (match-beginning 0))
                            (marker-end (match-end 0)))
                        (put-text-property
                         marker-begin marker-end 'face
                         (my/org-right-marker-face tag))
                        ;; One shared string over the whole span renders once,
                        ;; replacing e.g. STRT with PROGRESS.  It is set
                        ;; before measuring, so right alignment uses its width.
                        (when-let ((label (cdr (assoc tag my/org-right-status-labels))))
                          (put-text-property
                           marker-begin marker-end 'display
                           (propertize label 'face
                                       (my/org-right-marker-face tag))))
                        ;; Keep canonical Org tags lowercase in the file, but
                        ;; render type badges in the same all-caps vocabulary
                        ;; as workflow statuses.
                        (when (member tag my/org-right-uppercase-markers)
                          (dotimes (index (- marker-end marker-begin))
                            (let* ((position (+ marker-begin index))
                                   (letter
                                    (upcase
                                     (string (char-after position)))))
                              (put-text-property
                               position (1+ position) 'display
                               (concat
                                (if (= index 0) " " "")
                                letter
                                (if (= position (1- marker-end)) " " "")))))))))
                  ;; Landing on (or within a pixel of) the right edge makes
                  ;; Emacs wrap the final badge glyph.  One pixel of slack is
                  ;; not enough: org-modern's pill renders a hair wider than the
                  ;; measured source text, so lines land at exactly the edge and
                  ;; spill.  Reserve a whole character of slack, which scales
                  ;; with the live font size (buffer zoom via M-=).
                  (+ (my/org-right-tags-pixel-width tag-begin tag-end)
                     (if-let ((window (get-buffer-window (current-buffer) t)))
                         (frame-char-width (window-frame window))
                       10)))))
          (when (< padding-begin tag-begin)
            (add-text-properties
             padding-begin tag-begin
             `(display
               (space :align-to (- right (,tag-width)))
               rear-nonsticky (display))))
          t)))

    (defun my/org-right-status-display-setup ()
      (when (my/org-right-status-buffer-p)
        ;; Keep one ordinary source space before tags.  Alignment is purely a
        ;; display property, so it follows each window's live right edge.
        (setq-local org-auto-align-tags nil)
        (setq-local org-tags-column 0)
        (unless my/org--right-status-display-installed
          (setq-local my/org--right-status-display-installed t)
          (add-to-invisibility-spec 'my/org-native-status)
          (add-to-list (make-local-variable 'font-lock-extra-managed-props)
                       'invisible)
          (font-lock-add-keywords
           nil '((my/org-match-native-status (0 nil))) 'append))
        (unless my/org--right-tag-display-installed
          (setq-local my/org--right-tag-display-installed t)
          (add-to-list (make-local-variable 'font-lock-extra-managed-props)
                       'display)
          (font-lock-add-keywords
           nil '((my/org-match-right-aligned-tags (0 nil))) 'append))
        (font-lock-flush)))

    (add-hook 'org-after-todo-state-change-hook
              #'my/org-sync-right-status-tag-from-todo)
    (add-hook 'org-after-tags-change-hook
              #'my/org-sync-todo-from-right-status-tag)
    (add-hook 'org-mode-hook #'my/org-right-status-display-setup)

    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (derived-mode-p 'org-mode)
          (my/org-right-status-display-setup))))

    (setq org-directory "~/Dropbox/enotes")
     (setq org-agenda-files (list org-directory))
    (when (string= (system-name) "space")
      (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.0))
      )
    ;; Let native Org compose timestamps with their surrounding heading face.
    ;; Org Modern's timestamp pill forces a tiny 0.8-height label with its own
    ;; dark background, hiding `org-level-1' sizing in journal date headings.
    (setq org-modern-timestamp nil)
    (add-hook 'org-mode-hook #'org-modern-mode)
    (add-hook 'org-mode-hook #'my/org-active-timestamp-display-setup t)
    (add-hook 'org-agenda-finalize-hook #'org-modern-agenda)
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
        ;; The picker always offers "＋ New conversation…" as its first row, so
        ;; it covers the empty-history case too; no need for the bare provider
        ;; chooser anymore.
        (my/agent-shell--select-conversation))))

  ;; Cmd-' is the global conversation switcher.  Live Agent Shell buffers and
  ;; top-level Codex/Claude histories from every working directory share one
  ;; popup; the directory is only a column, never a filter.  The history cache
  ;; is memory-only and contains metadata plus a short title, not transcripts.
  (defconst my/agent-shell--codex-history-directory
    (expand-file-name "~/.codex/sessions"))
  (defconst my/agent-shell--claude-history-directory
    (expand-file-name "~/.claude/projects"))
  (defconst my/agent-shell--zed-database
    (expand-file-name
     "~/Library/Application Support/Zed/db/0-stable/db.sqlite"))
  (defconst my/agent-shell--title-overrides-file
    (expand-file-name "agent-shell-title-overrides.el" doom-cache-dir))
  (defconst my/agent-shell--history-read-limit (* 768 1024))
  (defvar my/agent-shell--history-cache (make-hash-table :test #'equal))
  (defvar my/agent-shell--zed-title-cache nil)
  (defvar my/agent-shell--title-overrides nil)
  (defvar my/agent-shell--title-overrides-loaded nil)
  (defvar my/agent-shell--active-conversation-choices nil)
  (defvar my/agent-shell-conversation-history nil)

  (defun my/agent-shell--normalized-title (text)
    "Return TEXT as a compact one-line conversation title."
    (when (stringp text)
      (let ((title (string-trim
                    (replace-regexp-in-string
                     "[[:space:]\n\r]+" " "
                     (substring-no-properties text)))))
        (unless (string-empty-p title)
          title))))

  (defun my/agent-shell--history-preamble-p (text)
    "Return non-nil when TEXT is injected session setup, not a user prompt."
    (string-match-p
     (rx string-start
         "<"
         (or "recommended_plugins"
             "environment_context"
             "permissions instructions"
             "apps_instructions"
             "plugins_instructions"
             "skills_instructions"
             "system-reminder"
             "ide_opened_file"
             "local-command-caveat"
             "local-command-stdout"
             "local-command-stderr"
             "command-name"
             "command-message")
         ">")
     text))

  (defun my/agent-shell--history-message-text (payload)
    "Extract user-visible text from a Codex message PAYLOAD."
    (my/agent-shell--normalized-title
     (mapconcat
      (lambda (content)
        (if (and (listp content)
                 (member (map-elt content 'type)
                         '("input_text" "text")))
            (or (map-elt content 'text) "")
          ""))
      (append (or (map-elt payload 'content) '()) nil)
      " ")))

  (defun my/agent-shell--history-file-signature (file)
    "Return a cheap cache signature for Codex history FILE."
    (when-let ((attributes (file-attributes file 'string)))
      (list (file-attribute-size attributes)
            (file-attribute-modification-time attributes))))

  (defun my/agent-shell--load-title-overrides ()
    "Load persistent Emacs conversation title overrides once."
    (unless my/agent-shell--title-overrides-loaded
      (setq my/agent-shell--title-overrides-loaded t)
      (when (file-readable-p my/agent-shell--title-overrides-file)
        (condition-case error-data
            (with-temp-buffer
              (insert-file-contents my/agent-shell--title-overrides-file)
              (goto-char (point-min))
              (let ((value (read (current-buffer))))
                (when (listp value)
                  (setq my/agent-shell--title-overrides value))))
          (error
           (display-warning
            'agent-shell
            (format "Could not read conversation title overrides: %s"
                    (error-message-string error-data))
            :warning)))))
    my/agent-shell--title-overrides)

  (defun my/agent-shell--title-key (entry)
    "Return the persistent title key for conversation ENTRY."
    (cons (plist-get entry :config-id) (plist-get entry :id)))

  (defun my/agent-shell--local-title-override (entry)
    "Return the Emacs title override for conversation ENTRY."
    (alist-get (my/agent-shell--title-key entry)
               (my/agent-shell--load-title-overrides)
               nil nil #'equal))

  (defun my/agent-shell--save-title-overrides ()
    "Persist Emacs conversation title overrides atomically."
    (let* ((directory (file-name-directory
                       my/agent-shell--title-overrides-file))
           (temporary-file nil))
      (make-directory directory t)
      (setq temporary-file
            (make-temp-file
             (expand-file-name ".agent-shell-title-overrides-" directory)))
      (unwind-protect
          (let ((coding-system-for-write 'utf-8-unix))
            (with-temp-file temporary-file
              (insert ";; Local Agent Shell conversation titles.\n")
              (prin1 my/agent-shell--title-overrides (current-buffer))
              (insert "\n"))
            (rename-file temporary-file
                         my/agent-shell--title-overrides-file t)
            (setq temporary-file nil))
        (when (and temporary-file (file-exists-p temporary-file))
          (delete-file temporary-file)))))

  (defun my/agent-shell--set-title-override (entry title)
    "Persist TITLE as the Emacs override for conversation ENTRY."
    (let ((key (my/agent-shell--title-key entry)))
      (unless (and (cdr key) (stringp (cdr key)))
        (user-error "Conversation has no session ID yet"))
      (my/agent-shell--load-title-overrides)
      (setf (alist-get key my/agent-shell--title-overrides
                       nil nil #'equal)
            title)
      (my/agent-shell--save-title-overrides)))

  (defun my/agent-shell--zed-database-signature ()
    "Return a cache signature for Zed's database and live WAL."
    (list (my/agent-shell--history-file-signature
           my/agent-shell--zed-database)
          (my/agent-shell--history-file-signature
           (concat my/agent-shell--zed-database "-wal"))))

  (defun my/agent-shell--read-zed-title-overrides ()
    "Return a session-ID hash table of Zed's renamed conversation titles.

Zed's SQLite database is queried read-only.  The cache invalidates whenever
the database or its write-ahead log changes."
    (let ((signature (my/agent-shell--zed-database-signature)))
      (if (and my/agent-shell--zed-title-cache
               (equal signature (car my/agent-shell--zed-title-cache)))
          (cdr my/agent-shell--zed-title-cache)
        (let ((titles (make-hash-table :test #'equal))
              (success nil))
          (when (and (file-readable-p my/agent-shell--zed-database)
                     (executable-find "sqlite3"))
            (condition-case nil
                (with-temp-buffer
                  (when (zerop
                         (call-process
                          "sqlite3" nil t nil
                          "-readonly" "-json"
                          my/agent-shell--zed-database
                          (concat
                           "SELECT session_id, title_override "
                           "FROM sidebar_threads "
                           "WHERE session_id IS NOT NULL "
                           "AND title_override IS NOT NULL "
                           "AND trim(title_override) <> '';")))
                    (goto-char (point-min))
                    (dolist (row
                             (if (eobp)
                                 nil
                               (json-parse-buffer
                                :object-type 'alist :array-type 'list
                                :null-object nil :false-object nil)))
                      (when-let* ((session-id (map-elt row 'session_id))
                                  (title (my/agent-shell--normalized-title
                                          (map-elt row 'title_override))))
                        (puthash session-id title titles)))
                    (setq success t)))
              (error nil)))
          (if success
              (progn
                (setq my/agent-shell--zed-title-cache
                      (cons signature titles))
                titles)
            (or (cdr-safe my/agent-shell--zed-title-cache) titles))))))

  (defun my/agent-shell--apply-title-overrides (entry zed-titles)
    "Return a copy of ENTRY with Emacs or Zed title overrides applied."
    (let* ((copy (copy-sequence entry))
           (local-title (my/agent-shell--local-title-override entry))
           (zed-title (and (plist-get entry :id)
                           (gethash (plist-get entry :id) zed-titles)))
           (title (or local-title zed-title)))
      (when title
        (setq copy (plist-put copy :title title)
              copy (plist-put copy :title-source
                              (if local-title 'emacs 'zed))))
      copy))

  (defun my/agent-shell--parse-history-file (file)
    "Return popup metadata from Codex history FILE.

Only the beginning of FILE is inspected, stopping after session metadata and
the first real user prompt.  Internal subagent sessions are excluded."
    (let (id cwd created title ignored)
      (condition-case nil
          (with-temp-buffer
            (insert-file-contents
             file nil 0 my/agent-shell--history-read-limit)
            (goto-char (point-min))
            (catch 'finished
              (while (not (eobp))
                (let* ((line (buffer-substring-no-properties
                              (line-beginning-position) (line-end-position)))
                       (record
                        (condition-case nil
                            (json-parse-string
                             line :object-type 'alist :array-type 'list
                             :null-object nil :false-object nil)
                          (error nil)))
                       (type (and record (map-elt record 'type)))
                       (payload (and record (map-elt record 'payload))))
                  (cond
                   ((equal type "session_meta")
                    (let ((source (map-elt payload 'source)))
                      ;; Codex represents internal delegated runs with an
                      ;; object-valued source.  They are implementation detail,
                      ;; not conversations the user should switch to.
                      (if (consp source)
                          (progn
                            (setq ignored t)
                            (throw 'finished nil))
                        (setq id (or (map-elt payload 'id)
                                     (map-elt payload 'session_id)
                                     (map-elt payload 'sessionId))
                              cwd (map-elt payload 'cwd)
                              created (map-elt payload 'timestamp)))))
                   ((and (equal type "response_item")
                         (equal (map-elt payload 'type) "message")
                         (equal (map-elt payload 'role) "user"))
                    (when-let ((text
                                (my/agent-shell--history-message-text payload)))
                      (unless (my/agent-shell--history-preamble-p text)
                        (setq title text)
                        (when id
                          (throw 'finished t))))))
                  (forward-line 1)))))
        (error (setq ignored t)))
      (when (and (not ignored) (stringp id) (stringp cwd))
        (let* ((attributes (file-attributes file 'string))
               (modified (and attributes
                              (file-attribute-modification-time attributes))))
          (list :kind 'history
                :id id
                :cwd (file-name-as-directory (expand-file-name cwd))
                :title (or title "Untitled conversation")
                :time (or modified
                          (and created
                               (condition-case nil
                                   (date-to-time created)
                                 (error nil)))
                          '(0 0 0 0))
                :config-id 'codex
                :file file)))))

  (defun my/agent-shell--cached-history-entry (file)
    "Return cached popup metadata for Codex history FILE."
    (let* ((signature (my/agent-shell--history-file-signature file))
           (cached (gethash file my/agent-shell--history-cache :missing)))
      (if (and (not (eq cached :missing))
               (equal signature (car cached)))
          (cdr cached)
        (let ((entry (my/agent-shell--parse-history-file file)))
          (puthash file (cons signature entry)
                   my/agent-shell--history-cache)
          entry))))

  (defun my/agent-shell--codex-history-entries ()
    "Return resumable top-level Codex sessions from every directory."
    (when (file-directory-p my/agent-shell--codex-history-directory)
      (delq nil
            (mapcar
             #'my/agent-shell--cached-history-entry
             (directory-files-recursively
              my/agent-shell--codex-history-directory
              (rx "rollout-" (+ any) ".jsonl" string-end))))))

  (defun my/agent-shell--claude-message-text (message)
    "Extract user-visible text from a Claude MESSAGE object."
    (let ((content (map-elt message 'content)))
      (my/agent-shell--normalized-title
       (cond
        ((stringp content) content)
        ((listp content)
         (mapconcat
          (lambda (part)
            (if (and (listp part)
                     (equal (map-elt part 'type) "text"))
                (or (map-elt part 'text) "")
              ""))
          content " "))
        (t "")))))

  (defun my/agent-shell--claude-clean-title (text)
    "Remove Claude's injected reminder blocks from user TEXT."
    (when text
      (let ((clean text))
        (dolist (tag '("system-reminder" "ide_opened_file" "ide_selection"))
          (setq clean
                (replace-regexp-in-string
                 (format "<%s>.*?</%s>" tag tag) " " clean)))
        (my/agent-shell--normalized-title clean))))

  (defun my/agent-shell--parse-claude-history-file (file)
    "Return popup metadata from top-level Claude history FILE."
    (unless (string-match-p (rx "/subagents/") file)
      (let (id cwd created title ignored)
        (condition-case nil
            (with-temp-buffer
              (insert-file-contents
               file nil 0 my/agent-shell--history-read-limit)
              (goto-char (point-min))
              (catch 'finished
                (while (not (eobp))
                  (let* ((line (buffer-substring-no-properties
                                (line-beginning-position) (line-end-position)))
                         (record
                          (condition-case nil
                              (json-parse-string
                               line :object-type 'alist :array-type 'list
                               :null-object nil :false-object nil)
                            (error nil))))
                    (when (and record (equal (map-elt record 'type) "user"))
                      (if (map-elt record 'isSidechain)
                          (progn
                            (setq ignored t)
                            (throw 'finished nil))
                        (setq id (or (map-elt record 'sessionId) id)
                              cwd (or (map-elt record 'cwd) cwd)
                              created (or (map-elt record 'timestamp) created))
                        (unless (map-elt record 'isMeta)
                          (when-let* ((message (map-elt record 'message))
                                      (text (my/agent-shell--claude-clean-title
                                             (my/agent-shell--claude-message-text
                                              message))))
                            (unless (my/agent-shell--history-preamble-p text)
                              (setq title text)
                              (when (and id cwd)
                                (throw 'finished t)))))))
                    (forward-line 1)))))
          (error (setq ignored t)))
        (when (and (not ignored) (stringp id) (stringp cwd))
          (let* ((attributes (file-attributes file 'string))
                 (modified (and attributes
                                (file-attribute-modification-time attributes))))
            (list :kind 'history
                  :id id
                  :cwd (file-name-as-directory (expand-file-name cwd))
                  :title (or title "Untitled conversation")
                  :time (or modified
                            (and created
                                 (condition-case nil
                                     (date-to-time created)
                                   (error nil)))
                            '(0 0 0 0))
                  :config-id 'claude-code
                  :file file))))))

  (defun my/agent-shell--cached-claude-history-entry (file)
    "Return cached popup metadata for Claude history FILE."
    (let* ((signature (my/agent-shell--history-file-signature file))
           (cached (gethash file my/agent-shell--history-cache :missing)))
      (if (and (not (eq cached :missing))
               (equal signature (car cached)))
          (cdr cached)
        (let ((entry (my/agent-shell--parse-claude-history-file file)))
          (puthash file (cons signature entry)
                   my/agent-shell--history-cache)
          entry))))

  (defun my/agent-shell--claude-history-entries ()
    "Return resumable top-level Claude sessions from every directory."
    (when (file-directory-p my/agent-shell--claude-history-directory)
      (delq nil
            (mapcar
             #'my/agent-shell--cached-claude-history-entry
             (directory-files-recursively
              my/agent-shell--claude-history-directory
              (rx ".jsonl" string-end))))))

  (defun my/agent-shell--history-entries ()
    "Return resumable Codex and Claude sessions, newest first."
    (seq-sort
     (lambda (a b)
       (time-less-p (plist-get b :time) (plist-get a :time)))
     (append (my/agent-shell--codex-history-entries)
             (my/agent-shell--claude-history-entries))))

  (defun my/agent-shell--live-entry (shell-buffer)
    "Return popup metadata for live Agent Shell SHELL-BUFFER."
    (with-current-buffer shell-buffer
      (let* ((state agent-shell--state)
             (title (map-nested-elt state '(:session :title)))
             (config (map-elt state :agent-config)))
        (list :kind 'live
              :id (map-nested-elt state '(:session :id))
              :cwd default-directory
              :title (or (my/agent-shell--normalized-title title)
                         (buffer-name shell-buffer))
              :time (or buffer-display-time (current-time))
              :status (agent-shell-status :shell-buffer shell-buffer)
              :config-id (map-elt config :identifier)
              :shell shell-buffer))))

  (defun my/agent-shell--conversation-entries ()
    "Return live and historical conversations for the global popup."
    (let* ((zed-titles (my/agent-shell--read-zed-title-overrides))
           (history
            (mapcar (lambda (entry)
                      (my/agent-shell--apply-title-overrides
                       entry zed-titles))
                    (my/agent-shell--history-entries)))
           (live
            (mapcar (lambda (shell-buffer)
                      (my/agent-shell--apply-title-overrides
                       (my/agent-shell--live-entry shell-buffer)
                       zed-titles))
                    (agent-shell-buffers)))
           (live-ids (delq nil (mapcar (lambda (entry)
                                         (plist-get entry :id))
                                       live))))
      (append live
              (seq-remove
               (lambda (entry)
                 (member (plist-get entry :id) live-ids))
               history))))

  (defun my/agent-shell--popup-path (directory)
    "Return DIRECTORY in a compact but unambiguous popup form."
    (directory-file-name
     (abbreviate-file-name (expand-file-name directory))))

  (defun my/agent-shell--popup-column (value width face)
    "Format VALUE to WIDTH columns using FACE."
    (let* ((short (truncate-string-to-width value width nil nil "…"))
           (padding (make-string (max 0 (- width (string-width short))) ?\s)))
      (propertize (concat short padding) 'face face)))

  (defun my/agent-shell--popup-status (entry)
    "Return the status label and face for popup ENTRY."
    (if (eq (plist-get entry :kind) 'history)
        (cons "↩ PREV" 'shadow)
      (pcase (plist-get entry :status)
        ('busy (cons "● BUSY" 'warning))
        ('blocked (cons "● WAIT" 'error))
        (_ (cons "● LIVE" 'success)))))

  (defun my/agent-shell--popup-agent (entry)
    "Return the short agent name for popup ENTRY."
    (pcase (plist-get entry :config-id)
      ('codex "Codex")
      ('claude-code "Claude")
      (identifier (capitalize (format "%s" (or identifier 'agent))))))

  (defun my/agent-shell--popup-time (entry)
    "Return a human-readable timestamp for popup ENTRY."
    (agent-shell--format-session-date
     (format-time-string "%Y-%m-%dT%H:%M:%SZ"
                         (plist-get entry :time) t)))

  (defun my/agent-shell--conversation-choices (entries)
    "Return unique display-choice alists for conversation ENTRIES."
    (let* ((path-width
            (min 42
                 (max 8
                      (apply #'max
                             (mapcar
                              (lambda (entry)
                                (string-width
                                 (my/agent-shell--popup-path
                                  (plist-get entry :cwd))))
                              entries)))))
           (title-width 58)
           (seen (make-hash-table :test #'equal))
           choices)
      (dolist (entry entries (nreverse choices))
        (pcase-let* ((`(,status . ,status-face)
                       (my/agent-shell--popup-status entry))
                      (base
                       (concat
                        (my/agent-shell--popup-column status 7 status-face)
                        "  "
                        (my/agent-shell--popup-column
                         (my/agent-shell--popup-agent entry)
                         6 'font-lock-keyword-face)
                        "  "
                        (my/agent-shell--popup-column
                         (my/agent-shell--popup-path
                          (plist-get entry :cwd))
                         path-width 'agent-shell-session-directory)
                        "  "
                        (my/agent-shell--popup-column
                         (plist-get entry :title)
                         title-width 'agent-shell-session-title)
                        "  "
                        (propertize (my/agent-shell--popup-time entry)
                                    'face 'agent-shell-session-date)))
                      (count (1+ (gethash base seen 0)))
                      (label (if (= count 1)
                                 base
                               (concat base
                                       (propertize (format "  #%d" count)
                                                   'face 'shadow)))))
          (puthash base count seen)
          (push (cons label entry) choices)))))

  (defun my/agent-shell--shell-for-session-id (session-id)
    "Return a live Agent Shell buffer for SESSION-ID, if one exists."
    (and session-id
         (seq-find
          (lambda (shell-buffer)
            (with-current-buffer shell-buffer
              (equal session-id
                     (map-nested-elt agent-shell--state
                                     '(:session :id)))))
          (agent-shell-buffers))))

  (defun my/agent-shell--current-shell-for-rename ()
    "Return the current or most recently used live Agent Shell buffer."
    (or (and (my/tab-line--chat-buffer-p)
             (my/tab-line--shell-for-chat-buffer (current-buffer)))
        (and (buffer-live-p my/agent-shell-last-chat-buffer)
             (my/tab-line--shell-for-chat-buffer
              my/agent-shell-last-chat-buffer))
        (car (agent-shell-buffers))))

  (defun my/agent-shell--rename-entry (entry)
    "Prompt for and persist a new title for conversation ENTRY."
    (let* ((current-title (or (plist-get entry :title)
                              "Untitled conversation"))
           (short-title (truncate-string-to-width current-title 48 nil nil "…"))
           (new-title
            (my/agent-shell--normalized-title
             (read-string (format "Rename \"%s\" to: " short-title)
                          nil nil current-title))))
      (unless new-title
        (user-error "Conversation title cannot be empty"))
      (my/agent-shell--set-title-override entry new-title)
      (when-let ((shell-buffer
                  (or (and (buffer-live-p (plist-get entry :shell))
                           (plist-get entry :shell))
                      (my/agent-shell--shell-for-session-id
                       (plist-get entry :id)))))
        (with-current-buffer shell-buffer
          (agent-shell--set-session-title new-title)))
      (message "Conversation renamed to: %s" new-title)
      new-title))

  (defun my/agent-shell-rename-conversation ()
    "Rename the current Agent Shell conversation persistently."
    (interactive)
    (let ((shell-buffer (my/agent-shell--current-shell-for-rename)))
      (unless shell-buffer
        (user-error "No live Agent Shell conversation"))
      (let ((zed-titles (my/agent-shell--read-zed-title-overrides)))
        (my/agent-shell--rename-entry
         (my/agent-shell--apply-title-overrides
          (my/agent-shell--live-entry shell-buffer) zed-titles)))))

  (defun my/agent-shell--keep-local-session-title (original title)
    "Apply a persistent local title override around ORIGINAL TITLE update."
    (let* ((session-id (map-nested-elt agent-shell--state '(:session :id)))
           (config-id (map-nested-elt
                       agent-shell--state '(:agent-config :identifier)))
           (entry (list :id session-id :config-id config-id)))
      (funcall original
               (or (and session-id
                        (my/agent-shell--local-title-override entry))
                   title))))

  (advice-remove #'agent-shell--set-session-title
                 #'my/agent-shell--keep-local-session-title)
  (advice-add #'agent-shell--set-session-title :around
              #'my/agent-shell--keep-local-session-title)

  (defun my/agent-shell--display-buffer-for-shell (shell-buffer)
    "Return the user-facing buffer associated with SHELL-BUFFER."
    (or (and (buffer-live-p my/agent-shell-last-chat-buffer)
             (eq shell-buffer
                 (my/tab-line--shell-for-chat-buffer
                  my/agent-shell-last-chat-buffer))
             my/agent-shell-last-chat-buffer)
        (and (my/tab-line--chat-buffer-p)
             (eq shell-buffer
                 (my/tab-line--shell-for-chat-buffer (current-buffer)))
             (current-buffer))
        (and agent-shell-prefer-viewport-interaction
             (agent-shell-viewport--buffer
              :shell-buffer shell-buffer :existing-only t))
        shell-buffer))

  (defun my/agent-shell--config-for-entry (entry)
    "Return the installed Agent Shell configuration for ENTRY."
    (seq-find
     (lambda (config)
       (eq (map-elt config :identifier)
           (plist-get entry :config-id)))
     (agent-shell--resolved-agent-configs)))

  (defun my/agent-shell--open-conversation (entry)
    "Open live or historical conversation ENTRY in the remembered layout."
    (let ((session-id (plist-get entry :id)))
      (if-let ((shell-buffer
                (or (and (eq (plist-get entry :kind) 'live)
                         (plist-get entry :shell))
                    (my/agent-shell--shell-for-session-id session-id))))
          (my/agent-shell--show-chat-buffer
           (my/agent-shell--display-buffer-for-shell shell-buffer))
        (let* ((cwd (plist-get entry :cwd))
               (config (my/agent-shell--config-for-entry entry)))
          (unless (file-directory-p cwd)
            (user-error "Conversation directory no longer exists: %s" cwd))
          (unless config
            (user-error "%s Agent Shell configuration is unavailable"
                        (my/agent-shell--popup-agent entry)))
          (let* ((default-directory cwd)
                 (agent-shell-cwd-function (let ((directory cwd))
                                             (lambda () directory)))
                 (shell-buffer
                  (agent-shell--start
                   :config config
                   :session-id session-id
                   :new-session t
                   :no-focus t)))
            (with-current-buffer shell-buffer
              ;; ACP bootstrapping continues asynchronously, so retain the
              ;; exact original directory beyond this command's dynamic let.
              (setq-local agent-shell-cwd-function
                          (let ((directory cwd))
                            (lambda () directory)))
              (agent-shell--set-session-title (plist-get entry :title)))
            (my/agent-shell--show-chat-buffer
             (or (and agent-shell-prefer-viewport-interaction
                      (agent-shell-viewport--buffer
                       :shell-buffer shell-buffer))
                 shell-buffer)))))))

  (defun my/agent-shell--entry-for-popup-choice (choice)
    "Return the conversation entry represented by popup CHOICE."
    (cdr (assoc-string choice
                       my/agent-shell--active-conversation-choices t)))

  (defun my/agent-shell--open-popup-choice (choice)
    "Ivy action that opens CHOICE, or starts a new named conversation."
    (if-let ((entry (my/agent-shell--entry-for-popup-choice choice)))
        (if (eq (plist-get entry :kind) 'new)
            (my/agent-shell--create-named-conversation)
          (my/agent-shell--open-conversation entry))
      (user-error "No conversation selected")))

  (defun my/agent-shell--rename-popup-choice (choice)
    "Ivy action that persistently renames conversation CHOICE."
    (if-let ((entry (my/agent-shell--entry-for-popup-choice choice)))
        (if (eq (plist-get entry :kind) 'new)
            (user-error "Nothing to rename: this starts a new conversation")
          (my/agent-shell--rename-entry entry))
      (user-error "No conversation selected")))

  ;; A synthetic first row in the picker that starts a brand-new conversation
  ;; with a name the user types, instead of only resuming existing ones.
  (defconst my/agent-shell--new-conversation-choice
    (propertize "＋  New conversation…" 'face 'font-lock-keyword-face)
    "Synthetic picker label that starts a fresh, custom-named conversation.")

  (defun my/agent-shell--project-directory ()
    "Return a sensible working directory for a new conversation."
    (or (when-let ((project (project-current nil)))
          (expand-file-name (project-root project)))
        default-directory))

  (defun my/agent-shell--persist-new-title (shell-buffer title attempts)
    "Register TITLE as a persistent override once SHELL-BUFFER has a session id.
Agent Shell assigns the ACP session id asynchronously, so poll briefly (up
to ~10s) until it lands, then store the override and reapply the title so it
survives the agent's own later naming."
    (when (and (buffer-live-p shell-buffer) (< attempts 50))
      (if-let ((session-id
                (with-current-buffer shell-buffer
                  (map-nested-elt agent-shell--state '(:session :id)))))
          (with-current-buffer shell-buffer
            (let ((config-id (map-nested-elt
                              agent-shell--state '(:agent-config :identifier))))
              (my/agent-shell--set-title-override
               (list :config-id config-id :id session-id) title)
              (agent-shell--set-session-title title)))
        (run-with-timer 0.2 nil #'my/agent-shell--persist-new-title
                        shell-buffer title (1+ attempts)))))

  (defun my/agent-shell--create-named-conversation ()
    "Prompt for a title, pick an agent, and start a fresh named conversation."
    (require 'agent-shell)
    (let* ((title (my/agent-shell--normalized-title
                   (read-string "New conversation title: ")))
           (location (my/agent-shell--project-directory))
           (shell-buffer
            (let ((default-directory location))
              ;; :config nil lets Agent Shell resolve the preferred agent or
              ;; prompt for one, exactly as its own new-shell command does.
              (agent-shell--new-shell :location location :no-display t))))
      (when title
        (with-current-buffer shell-buffer
          (agent-shell--set-session-title title))
        (my/agent-shell--persist-new-title shell-buffer title 0))
      (my/agent-shell--show-chat-buffer
       (or (and agent-shell-prefer-viewport-interaction
                (agent-shell-viewport--buffer :shell-buffer shell-buffer))
           shell-buffer))))

  (defun my/agent-shell--select-conversation ()
    "Resume a conversation, or start a fresh named one, from one global popup."
    (let* ((entries (my/agent-shell--conversation-entries))
           (choices (cons (cons my/agent-shell--new-conversation-choice
                                '(:kind new))
                          (my/agent-shell--conversation-choices entries)))
           (labels (mapcar #'car choices)))
      (setq my/agent-shell--active-conversation-choices choices)
      (if (fboundp 'ivy-read)
          (ivy-read "Conversations: " labels
                    :require-match t
                    :sort nil
                    :history 'my/agent-shell-conversation-history
                    :caller 'my/agent-shell-conversations
                    :action #'my/agent-shell--open-popup-choice)
        (my/agent-shell--open-popup-choice
         (completing-read "Conversations: " labels nil t)))))

  (when (fboundp 'ivy-add-actions)
    (ivy-add-actions
     'my/agent-shell-conversations
     '(("r" my/agent-shell--rename-popup-choice "rename"))))

  (map! :map (agent-shell-mode-map
              agent-shell-viewport-edit-mode-map
              agent-shell-viewport-view-mode-map)
        :localleader
        :desc "Rename conversation" :n "r"
        #'my/agent-shell-rename-conversation)

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
    (derived-mode-p 'agent-shell-mode
                    'agent-shell-viewport-edit-mode
                    'my/agent-shell-composer-mode))

  ;; Keep a staged follow-up inside the transcript, after all streaming
  ;; output.  It does not enter Agent Shell's native queue until the current
  ;; turn has finished, so the user can keep editing or cancel it meanwhile.
  (defface my/agent-shell-input-region-face
    '((t (:inherit default :extend t)))
    "Face for the Agent Shell input region embedded in the transcript.")

  (defvar-local my/agent-shell--inline-queue-start nil)
  (defvar-local my/agent-shell--inline-queue-content-start nil)
  (defvar-local my/agent-shell--inline-queue-content-end nil)
  (defvar-local my/agent-shell--inline-queue-end nil)
  (defvar-local my/agent-shell--inline-queue-queued-p nil)
  (defvar-local my/agent-shell--inline-queue-subscription nil)
  (defvar-local my/agent-shell--inline-queue-overlay nil)
  (defvar-local my/agent-shell--inline-input-padding-overlay nil)
  (defvar-local my/agent-shell--historical-user-prompt-overlays nil)

  (defun my/agent-shell--face-includes-p (face target)
    "Return non-nil when FACE contains TARGET anywhere in its face tree."
    (or (eq face target)
        (and (consp face)
             (or (my/agent-shell--face-includes-p (car face) target)
                 (my/agent-shell--face-includes-p (cdr face) target)))))

  (defun my/agent-shell--next-end-of-prompt-marker (position limit)
    "Return the next Shell Maker prompt-end marker from POSITION to LIMIT."
    (let ((position position)
          found)
      (while (and (< position limit) (not found))
        (if (get-text-property position 'shell-maker--marker)
            (setq found position)
          (setq position
                (next-single-property-change
                 position 'shell-maker--marker nil limit))))
      found))

  (defun my/agent-shell--refresh-historical-user-prompts ()
    "Paint completed user prompts like the live editable input region."
    (when (and (derived-mode-p 'agent-shell-mode)
               (stringp comint-prompt-regexp)
               (not (string-empty-p comint-prompt-regexp)))
      (mapc #'delete-overlay
            my/agent-shell--historical-user-prompt-overlays)
      (setq my/agent-shell--historical-user-prompt-overlays nil)
      (save-excursion
        (save-restriction
          (widen)
          (let ((limit (point-max)))
            (goto-char (point-min))
            ;; A just-created Comint buffer can temporarily use the zero-width
            ;; regexp `^'.  Always advance past a zero-width match so bootstrap
            ;; buffers remain finite until Agent Shell installs its real prompt.
            (while (and (< (point) limit)
                        (re-search-forward comint-prompt-regexp limit t))
              (let ((start (match-beginning 0))
                    (prompt-end (match-end 0)))
                ;; Match only actual Comint prompts, not prompt-like text in an
                ;; agent response.  A completed prompt must also have Shell
                ;; Maker's invisible end marker; the live input has none.
                (when (my/agent-shell--face-includes-p
                       (get-text-property start 'font-lock-face)
                       'comint-highlight-prompt)
                  (when-let ((end
                              (my/agent-shell--next-end-of-prompt-marker
                               prompt-end limit)))
                    (let ((overlay
                           (make-overlay start end (current-buffer))))
                      (overlay-put overlay 'face
                                   'my/agent-shell-input-region-face)
                      (overlay-put overlay 'evaporate t)
                      (overlay-put overlay
                                   'my/agent-shell-historical-user-prompt t)
                      (push overlay
                            my/agent-shell--historical-user-prompt-overlays))))
                (when (= start prompt-end)
                  (goto-char (min limit (1+ prompt-end)))))))))))

  (defun my/agent-shell--after-end-of-prompt-marker (&rest _)
    "Refresh historical user prompt backgrounds after a submission."
    (when (derived-mode-p 'agent-shell-mode)
      (my/agent-shell--refresh-historical-user-prompts)))

  (defcustom my/agent-shell-stall-timeout 180
    "Seconds without ACP activity before recovering a busy prompt."
    :type 'integer
    :group 'agent-shell)

  (defcustom my/agent-shell-stall-check-interval 10
    "Seconds between Agent Shell stall checks."
    :type 'integer
    :group 'agent-shell)

  (defcustom my/agent-shell-recovery-retry-limit 3
    "Maximum automatic reconnect attempts for one recovery snapshot."
    :type 'integer
    :group 'agent-shell)

  (defcustom my/agent-shell-recovery-retry-delay 5
    "Seconds before retrying a failed automatic recovery."
    :type 'number
    :group 'agent-shell)

  (defvar-local my/agent-shell--last-acp-activity-time nil)
  (defvar-local my/agent-shell--stall-watchdog-timer nil)
  (defvar-local my/agent-shell--auto-recovery-in-progress nil)

  (defun my/agent-shell--note-acp-activity (client)
    "Record incoming protocol activity for CLIENT's Agent Shell buffer."
    (when-let ((shell-buffer (and client
                                  (map-elt client :context-buffer))))
      (when (buffer-live-p shell-buffer)
        (with-current-buffer shell-buffer
          (setq my/agent-shell--last-acp-activity-time (current-time))))))

  (defun my/acp--incoming-message-description (arguments)
    "Return a compact description of an ACP routing call ARGUMENTS."
    (let* ((message (plist-get arguments :message))
           (object (and message (map-elt message :object)))
           (id (and object (or (map-elt object 'id)
                               (map-elt object :id))))
           (method (and object (or (map-elt object 'method)
                                   (map-elt object :method)))))
      (cond
       (method (format "%s%s" method (if id (format " id=%s" id) "")))
       (id (format "response id=%s" id))
       (t "unidentified message"))))

  (defun my/acp--route-incoming-message-safely (original &rest arguments)
    "Route an ACP message without allowing one callback to wedge its queue.

`acp.el' drains its private message queue from a zero-delay timer.  If a
response callback signals, that timer exits before clearing its private busy
flag, so all later ACP messages remain queued forever.  Keep the dispatcher
alive, retain the error on the client for diagnosis, and surface a warning."
    (let ((client (plist-get arguments :client)))
      (my/agent-shell--note-acp-activity client)
      (condition-case error-data
          (apply original arguments)
      ((error quit)
       (let* ((description
               (my/acp--incoming-message-description arguments))
              (warning
               (format "ACP callback failed while routing %s: %S"
                       description error-data)))
         (when client
           (ignore-errors
             (map-put! client :my/last-routing-error
                       (list :time (current-time)
                             :message description
                             :error error-data)))
           (ignore-errors
             (acp--log client "ROUTING CALLBACK ERROR" "%s" warning)))
         (condition-case nil
             (display-warning 'agent-shell warning :error)
           (error (message "%s" warning)))
         ;; The dispatcher itself can now continue, but a failed prompt
         ;; callback may have left Agent Shell's request state busy.  Recheck
         ;; after the rest of this ACP batch has had a chance to finish.
         (when-let ((shell-buffer (and client
                                       (map-elt client :context-buffer))))
           (when (and (buffer-live-p shell-buffer)
                      (fboundp 'my/agent-shell--stall-watchdog-tick))
             (run-at-time
              1 nil #'my/agent-shell--stall-watchdog-tick
              shell-buffer t))))
       nil))))

  (advice-remove #'acp--route-incoming-message
                 #'my/acp--route-incoming-message-safely)
  (advice-add #'acp--route-incoming-message :around
              #'my/acp--route-incoming-message-safely)

  (defun my/agent-shell--pending-requests (&optional shell-buffer)
    "Return SHELL-BUFFER's native pending-request FIFO."
    (when-let ((buffer (or shell-buffer (current-buffer))))
      (when (buffer-live-p buffer)
        (with-current-buffer buffer
          (condition-case nil
              (map-elt (agent-shell--state) :pending-requests)
            (error nil))))))

  (defun my/agent-shell--pending-index-at-point ()
    "Return the native pending-request index represented at point."
    (or (get-text-property (point) 'my/agent-shell-pending-index)
        (and (> (point) (point-min))
             (get-text-property (1- (point))
                                'my/agent-shell-pending-index))))

  (defun my/agent-shell--inline-queue-active-p (&optional shell-buffer)
    "Return non-nil when SHELL-BUFFER has a live inline follow-up."
    (with-current-buffer (or shell-buffer (current-buffer))
      (and (markerp my/agent-shell--inline-queue-start)
           (marker-position my/agent-shell--inline-queue-start)
           (markerp my/agent-shell--inline-queue-content-start)
           (marker-position my/agent-shell--inline-queue-content-start)
           (markerp my/agent-shell--inline-queue-content-end)
           (marker-position my/agent-shell--inline-queue-content-end)
           (markerp my/agent-shell--inline-queue-end)
           (marker-position my/agent-shell--inline-queue-end))))

  (defun my/agent-shell--inline-queue-text (&optional shell-buffer)
    "Return SHELL-BUFFER's staged follow-up without text properties."
    (with-current-buffer (or shell-buffer (current-buffer))
      (when (my/agent-shell--inline-queue-active-p)
        (buffer-substring-no-properties
         my/agent-shell--inline-queue-content-start
         my/agent-shell--inline-queue-content-end))))

  (defun my/agent-shell--inline-queue-has-text-p (&optional shell-buffer)
    "Return non-nil when SHELL-BUFFER's inline input is non-empty."
    (when-let ((text (my/agent-shell--inline-queue-text shell-buffer)))
      (not (string-empty-p (string-trim text)))))

  (defun my/agent-shell--insert-input-sentinel ()
    "Insert the invisible editable boundary before the protected footer."
    (insert (propertize " "
                        'display ""
                        'my/agent-shell-input-sentinel t
                        'rear-nonsticky t)))

  (defun my/agent-shell--repair-input-sentinel (&rest _)
    "Restore the embedded input sentinel if an edit deleted it."
    (when (and (my/agent-shell--inline-queue-active-p)
               (not (get-text-property
                     my/agent-shell--inline-queue-content-end
                     'my/agent-shell-input-sentinel)))
      (let ((inhibit-modification-hooks t)
            (inhibit-read-only t)
            (at-end (= (point)
                       my/agent-shell--inline-queue-content-end))
            (saved-point (copy-marker (point) t)))
        (save-excursion
          (goto-char my/agent-shell--inline-queue-content-end)
          (set-marker-insertion-type
           my/agent-shell--inline-queue-content-end nil)
          (my/agent-shell--insert-input-sentinel)
          (set-marker-insertion-type
           my/agent-shell--inline-queue-content-end t))
        (goto-char (if at-end
                       my/agent-shell--inline-queue-content-end
                     saved-point))
        (set-marker saved-point nil))))

  (defun my/agent-shell--insert-inline-queue-block (text &optional point-offset)
    "Append an inline queue block containing TEXT to the current shell.

POINT-OFFSET, when non-nil, restores point that many characters into TEXT."
    (let ((inhibit-read-only t)
          (symbol (if my/agent-shell--inline-queue-queued-p "⏳" "✎"))
          (pending (my/agent-shell--pending-requests))
          visual-start)
      (goto-char (point-max))
      (setq my/agent-shell--inline-queue-start (copy-marker (point) nil))
      (unless (bolp)
        (insert (propertize "\n" 'read-only t
                            'rear-nonsticky '(read-only)
                            'my/agent-shell-inline-queue t)))
      (setq visual-start (point))
      ;; Native pending requests are real queue content, so keep them visible
      ;; and selectable.  Unlike the hint below, these lines are deliberately
      ;; tangible: `i' pulls one back into the composer and C-c removes it.
      (cl-loop for prompt in pending
               for index from 0
               do
               (let ((start (point))
                     (preview
                      (truncate-string-to-width
                       (replace-regexp-in-string
                        "[\n\r]+" " ↵ " (string-trim prompt))
                       100 nil nil "…")))
                 (insert (format " ⏳  %d · %s\n" (1+ index) preview))
                 (add-text-properties
                  start (point)
                  `(read-only t
                    rear-nonsticky (read-only field face font-lock-face
                                              my/agent-shell-pending-index)
                    field output
                    font-lock-face font-lock-comment-face
                    my/agent-shell-pending-index ,index
                    my/agent-shell-inline-queue t))))
      (insert (propertize
               (format
                " %s  %s\n"
                symbol
                (if my/agent-shell--inline-queue-queued-p
                    "Queued · edit freely · C-c unqueue · C-RET force-send"
                  (if pending
                      (format
                       "Prompt · %d queued · type + RET enqueue · empty RET force FIFO · ⇧RET newline · C-c interrupt · C-RET force-send"
                       (length pending))
                    "Prompt · RET send/queue · ⇧RET newline · C-c interrupt · C-RET force-send")))
               'read-only t
               'rear-nonsticky '(read-only field face
                                  font-lock-face)
               'field 'output
               'font-lock-face 'font-lock-comment-face
               'my/agent-shell-inline-queue t))
      (setq my/agent-shell--inline-queue-content-start
            (copy-marker (point) nil))
      (insert (or text ""))
      (let ((content-end (point)))
        ;; Keep an editable zero-width sentinel between an empty draft and the
        ;; protected footer.  Without it, Emacs treats insertion at that exact
        ;; boundary as an attempt to modify the read-only footer.
        (my/agent-shell--insert-input-sentinel)
        (insert (propertize
                 "\n"
                 'read-only t
                 'field 'output
                 'font-lock-face 'font-lock-comment-face
                 'my/agent-shell-inline-queue t))
        ;; Set this after inserting the read-only footer; an insertion-type-t
        ;; marker created beforehand would advance past the footer too.
        (setq my/agent-shell--inline-queue-content-end
              (copy-marker content-end t)))
      (setq my/agent-shell--inline-queue-end (copy-marker (point) nil))
      (when (overlayp my/agent-shell--inline-queue-overlay)
        (delete-overlay my/agent-shell--inline-queue-overlay))
      (setq my/agent-shell--inline-queue-overlay
            (make-overlay visual-start
                          my/agent-shell--inline-queue-end
                          (current-buffer) nil t))
      (overlay-put my/agent-shell--inline-queue-overlay
                   'face 'my/agent-shell-input-region-face)
      (when (overlayp my/agent-shell--inline-input-padding-overlay)
        (delete-overlay my/agent-shell--inline-input-padding-overlay))
      (setq my/agent-shell--inline-input-padding-overlay
            (make-overlay my/agent-shell--inline-queue-content-start
                          my/agent-shell--inline-queue-end
                          (current-buffer) nil t))
      (let ((prefix
             (propertize " " 'face 'my/agent-shell-input-region-face)))
        (overlay-put my/agent-shell--inline-input-padding-overlay
                     'line-prefix prefix)
        (overlay-put my/agent-shell--inline-input-padding-overlay
                     'wrap-prefix prefix))
      (overlay-put my/agent-shell--inline-input-padding-overlay
                   'evaporate t)
      (goto-char (+ (marker-position
                     my/agent-shell--inline-queue-content-start)
                    (min (or point-offset (length (or text "")))
                         (length (or text "")))))))

  (defun my/agent-shell--relocate-inline-queue (&optional force)
    "Keep the current inline follow-up after all newly streamed output.

When FORCE is non-nil, rebuild it even if it is already last; this refreshes
the draft/queued symbol and help text."
    (when (my/agent-shell--inline-queue-active-p)
      (let* ((text (my/agent-shell--inline-queue-text))
             (inside (and (>= (point) my/agent-shell--inline-queue-content-start)
                          (<= (point) my/agent-shell--inline-queue-content-end)))
             (offset (and inside
                          (- (point)
                             my/agent-shell--inline-queue-content-start)))
             (saved-point (and (not inside) (copy-marker (point) t))))
        (when (or force
                  (< my/agent-shell--inline-queue-end (point-max)))
          (let ((inhibit-read-only t))
            (with-silent-modifications
              (when (overlayp my/agent-shell--inline-queue-overlay)
                (delete-overlay my/agent-shell--inline-queue-overlay)
                (setq my/agent-shell--inline-queue-overlay nil))
              (when (overlayp my/agent-shell--inline-input-padding-overlay)
                (delete-overlay my/agent-shell--inline-input-padding-overlay)
                (setq my/agent-shell--inline-input-padding-overlay nil))
              (delete-region my/agent-shell--inline-queue-start
                             my/agent-shell--inline-queue-end)
              (my/agent-shell--insert-inline-queue-block text offset)))
          (unless inside
            (goto-char saved-point))
          (when saved-point
            (set-marker saved-point nil))))))

  (defun my/agent-shell--take-pending-request (index)
    "Remove and return native pending request INDEX from the current shell."
    (let ((pending (my/agent-shell--pending-requests)))
      (unless (and (integerp index) (>= index 0) (< index (length pending)))
        (user-error "No queued request here"))
      (let ((prompt (nth index pending)))
        (map-put! (agent-shell--state) :pending-requests
                  (append (seq-take pending index)
                          (seq-drop pending (1+ index))))
        prompt)))

  (defun my/agent-shell-edit-pending-request-at-point ()
    "Move the queued request at point back into the editable composer."
    (interactive)
    (let ((index (my/agent-shell--pending-index-at-point)))
      (unless index
        (user-error "No queued request here"))
      (when (my/agent-shell--inline-queue-has-text-p)
        (user-error "Finish or clear the current draft before editing the queue"))
      (let ((prompt (my/agent-shell--take-pending-request index)))
        (my/agent-shell--relocate-inline-queue t)
        (goto-char my/agent-shell--inline-queue-content-end)
        (insert prompt)
        (message "Queued request moved back to the composer"))))

  (defun my/agent-shell-remove-pending-request-at-point ()
    "Remove the queued request represented at point."
    (interactive)
    (let ((index (my/agent-shell--pending-index-at-point)))
      (unless index
        (user-error "No queued request here"))
      (my/agent-shell--take-pending-request index)
      (my/agent-shell--relocate-inline-queue t)
      (goto-char my/agent-shell--inline-queue-content-end)
      (message "Queued request removed")))

  (defun my/agent-shell--native-input-range ()
    "Return the verified native input range, or nil during bootstrapping.

The range begins at the end of the current Comint prompt, never at
`comint-accum-marker'.  Agent Shell can leave that marker at the beginning of
the buffer while it is loading a session, which otherwise makes the welcome
text and restored transcript look like an unsent prompt."
    (condition-case nil
        (when-let* ((state (agent-shell--state))
                    ((eq (map-elt state :buffer) (current-buffer)))
                    (prompt comint-last-prompt)
                    ((consp prompt))
                    (start-marker (car prompt))
                    (end-marker (cdr prompt))
                    ((markerp start-marker))
                    ((markerp end-marker))
                    ((eq (marker-buffer start-marker) (current-buffer)))
                    ((eq (marker-buffer end-marker) (current-buffer)))
                    (start (marker-position start-marker))
                    (end (marker-position end-marker))
                    ((< start end))
                    ((<= end (point-max)))
                    ((stringp comint-prompt-regexp))
                    ((not (string-empty-p comint-prompt-regexp)))
                    (process (get-buffer-process (current-buffer)))
                    (process-marker (process-mark process))
                    ((markerp process-marker))
                    ((eq (marker-buffer process-marker) (current-buffer)))
                    ((= (marker-position process-marker) end))
                    ((save-excursion
                       (save-match-data
                         (goto-char start)
                         (and (looking-at comint-prompt-regexp)
                              (= (match-end 0) end)))))
                    ((agent-shell--live-input-prompt-p prompt))
                    ((not (text-property-any end (point-max)
                                             'field 'output)))
                    ((not (text-property-not-all end (point-max)
                                                 'read-only nil))))
          (cons end (point-max)))
      (error nil)))

  (defun my/agent-shell--native-input-text ()
    "Return only verified native prompt text, without properties."
    (when-let ((range (my/agent-shell--native-input-range)))
      (buffer-substring-no-properties (car range) (cdr range))))

  (defun my/agent-shell--take-shell-input ()
    "Remove and return verified native input, or nil if absent or unsafe."
    (when-let* ((range (my/agent-shell--native-input-range))
                (input (buffer-substring-no-properties
                        (car range) (cdr range)))
                ((not (string-empty-p (string-trim input)))))
      (let ((inhibit-read-only t))
        (delete-region (car range) (cdr range)))
      input))

  (defun my/agent-shell--inline-queue-insert (text)
    "Insert TEXT into the current shell's inline follow-up."
    (unless (my/agent-shell--inline-queue-active-p)
      (unless (my/agent-shell--ensure-inline-input)
        (user-error "Agent session is still starting")))
    (unless (and (>= (point) my/agent-shell--inline-queue-content-start)
                 (<= (point) my/agent-shell--inline-queue-content-end))
      (goto-char my/agent-shell--inline-queue-content-end))
    (insert text))

  (defun my/agent-shell--ensure-inline-input (&optional focus migrate-native)
    "Ensure the current shell has one embedded input region.

When FOCUS is non-nil, move into the editable region without disturbing a
cursor already inside it.  When MIGRATE-NATIVE is non-nil, preserve any old
Comint draft while switching interfaces.  Never create or migrate the custom
input while Agent Shell is bootstrapping and has no trustworthy live prompt."
    (when (derived-mode-p 'agent-shell-mode)
      (let* ((active (my/agent-shell--inline-queue-active-p))
             (native-range (and (not active)
                                (my/agent-shell--native-input-range)))
             (native-text (and native-range
                               (buffer-substring-no-properties
                                (car native-range) (cdr native-range)))))
        ;; A non-empty native draft must be migrated atomically.  If this call
        ;; was not authorized to migrate it, leave both it and the transcript
        ;; untouched until the next migration-aware command.
        (when (or active
                  (and native-range
                       (or migrate-native
                           (string-empty-p (string-trim native-text)))))
          (unless active
            (my/agent-shell--insert-inline-queue-block
             (and migrate-native (my/agent-shell--take-shell-input))))
          (my/agent-shell--hide-native-prompt (current-buffer))
          (when focus
            (unless (and (>= (point) my/agent-shell--inline-queue-content-start)
                         (<= (point) my/agent-shell--inline-queue-content-end))
              (goto-char my/agent-shell--inline-queue-content-end)))
          my/agent-shell--inline-queue-content-end))))

  (defun my/agent-shell--disarm-inline-queue ()
    "Stop waiting to accept the current shell's inline follow-up."
    (when my/agent-shell--inline-queue-subscription
      (agent-shell-unsubscribe
       :subscription my/agent-shell--inline-queue-subscription)
      (setq my/agent-shell--inline-queue-subscription nil)))

  (defun my/agent-shell--delete-inline-queue (&optional keep-subscription)
    "Delete the current shell's inline follow-up.

Unless KEEP-SUBSCRIPTION is non-nil, also stop its event subscription."
    (when (my/agent-shell--inline-queue-active-p)
      (unless keep-subscription
        (my/agent-shell--disarm-inline-queue))
      (let ((inhibit-read-only t))
        (when (overlayp my/agent-shell--inline-queue-overlay)
          (delete-overlay my/agent-shell--inline-queue-overlay)
          (setq my/agent-shell--inline-queue-overlay nil))
        (when (overlayp my/agent-shell--inline-input-padding-overlay)
          (delete-overlay my/agent-shell--inline-input-padding-overlay)
          (setq my/agent-shell--inline-input-padding-overlay nil))
        (delete-region my/agent-shell--inline-queue-start
                       my/agent-shell--inline-queue-end))
      (dolist (marker (list my/agent-shell--inline-queue-start
                            my/agent-shell--inline-queue-content-start
                            my/agent-shell--inline-queue-content-end
                            my/agent-shell--inline-queue-end))
        (when (markerp marker)
          (set-marker marker nil)))
      (setq my/agent-shell--inline-queue-start nil
            my/agent-shell--inline-queue-content-start nil
            my/agent-shell--inline-queue-content-end nil
            my/agent-shell--inline-queue-end nil
            my/agent-shell--inline-queue-queued-p nil)))

  (defun my/agent-shell--submit-inline-prompt (shell-buffer prompt)
    "Submit or enqueue PROMPT and immediately restore an empty input.

When SHELL-BUFFER is busy, or already has pending requests, append PROMPT to
its native FIFO.  Otherwise submit it immediately."
    (with-current-buffer shell-buffer
      (let ((enqueue (or (shell-maker-busy)
                         (my/agent-shell--pending-requests shell-buffer))))
        (my/agent-shell--delete-inline-queue)
        (condition-case error-data
            (progn
              (if enqueue
                  (agent-shell--enqueue-request :prompt prompt)
                (agent-shell-queue-request prompt))
              ;; Output advice may already have restored the input region.
              (unless (my/agent-shell--inline-queue-active-p)
                (my/agent-shell--insert-inline-queue-block ""))
              (my/agent-shell--hide-native-prompt shell-buffer)
              (goto-char my/agent-shell--inline-queue-content-end)
              (when enqueue
                (message "Request queued at FIFO position %d"
                         (length (my/agent-shell--pending-requests
                                  shell-buffer)))))
          (error
           ;; A failed submission must never eat the user's draft.
           (unless (my/agent-shell--inline-queue-active-p)
             (my/agent-shell--insert-inline-queue-block prompt))
           (signal (car error-data) (cdr error-data)))))))

  (defun my/agent-shell--force-next-pending-request ()
    "Force the first native pending request through, preserving FIFO order."
    (let* ((shell-buffer (current-buffer))
           (pending (my/agent-shell--pending-requests shell-buffer)))
      (unless pending
        (user-error "Nothing to send"))
      (if (shell-maker-busy)
          (progn
            ;; Do not reorder the queue: the existing head remains the next
            ;; request resumed after interruption.
            (my/agent-shell--interrupt-for-forced-request shell-buffer)
            (message "Interrupted active turn; force-submitting FIFO head"))
        (agent-shell--process-pending-request))))

  (defun my/agent-shell--queue-inline-prompt ()
    "Apply the embedded composer's default FIFO Return behavior.

Non-empty input is submitted immediately when idle or appended to the native
queue when busy.  Empty input force-submits the existing FIFO head."
    (my/agent-shell--ensure-inline-input t t)
    (if (my/agent-shell--inline-queue-has-text-p)
      (my/agent-shell--submit-inline-prompt
       (current-buffer) (my/agent-shell--inline-queue-text))
      (my/agent-shell--force-next-pending-request)))

  (defun my/agent-shell--unqueue-inline-prompt ()
    "Unqueue the inline prompt without deleting its editable text."
    (if my/agent-shell--inline-queue-queued-p
        (progn
          (my/agent-shell--disarm-inline-queue)
          (setq my/agent-shell--inline-queue-queued-p nil)
          (my/agent-shell--relocate-inline-queue t)
          (message "Queued follow-up canceled; draft remains editable"))
      (keyboard-quit)))

  (defun my/agent-shell--accept-inline-queue-if-ready (shell-buffer)
    "Submit SHELL-BUFFER's queued inline follow-up once the agent is ready."
    (when (buffer-live-p shell-buffer)
      (with-current-buffer shell-buffer
        (when (and my/agent-shell--inline-queue-queued-p
                   (my/agent-shell--inline-queue-active-p)
                   (not (shell-maker-busy)))
          (let ((prompt (my/agent-shell--inline-queue-text)))
            (if (string-empty-p (string-trim prompt))
                (my/agent-shell--unqueue-inline-prompt)
              (my/agent-shell--submit-inline-prompt
               shell-buffer prompt)))))))

  (defun my/agent-shell--arm-inline-queue (shell-buffer)
    "Arrange for SHELL-BUFFER's inline follow-up to be accepted when ready."
    (with-current-buffer shell-buffer
      (unless my/agent-shell--inline-queue-subscription
        (setq my/agent-shell--inline-queue-subscription
              (agent-shell-subscribe-to
               :shell-buffer shell-buffer
               :on-event
               (lambda (event)
                 (when (memq (map-elt event :event)
                             '(turn-complete error clean-up))
                   ;; Completion events fire before every callback has
                   ;; returned.  Accept only after Shell Maker is idle.
                   (run-at-time
                    0 nil
                    (lambda ()
                      (my/agent-shell--accept-inline-queue-if-ready
                       shell-buffer))))))))))

  (defun my/agent-shell--around-process-pending-request
      (original &rest arguments)
    "Let Agent Shell process native pending requests around inline input."
    (if (not (and (derived-mode-p 'agent-shell-mode)
                  (my/agent-shell--inline-queue-active-p)))
        (apply original arguments)
      (let* ((text (my/agent-shell--inline-queue-text))
             (queued my/agent-shell--inline-queue-queued-p)
             (inside (and (>= (point) my/agent-shell--inline-queue-content-start)
                          (<= (point) my/agent-shell--inline-queue-content-end)))
             (offset (and inside
                          (- (point)
                             my/agent-shell--inline-queue-content-start))))
        (my/agent-shell--delete-inline-queue t)
        (unwind-protect
            (apply original arguments)
          (when (derived-mode-p 'agent-shell-mode)
            ;; Output advice can create a temporary empty region during the
            ;; native submission.  Replace it with the preserved user draft.
            (when (my/agent-shell--inline-queue-active-p)
              (my/agent-shell--delete-inline-queue t))
            (setq my/agent-shell--inline-queue-queued-p queued)
            (my/agent-shell--insert-inline-queue-block text offset))))))

  (defun my/agent-shell--around-fragment-update (original &rest arguments)
    "Keep the inline follow-up and its cursors stable across a fragment update.

Agent Shell restores point from a numeric position after updating a fragment.
When streamed output grows above our inline composer, that position becomes
stale and lands in the response.  Capture offsets inside the composer before
the update, then restore those offsets after relocating the composer."
    (let* ((state (plist-get arguments :state))
           (shell-buffer (and state (map-elt state :buffer)))
           (point-offset
            (and (buffer-live-p shell-buffer)
                 (with-current-buffer shell-buffer
                   (when (and (my/agent-shell--inline-queue-active-p)
                              (>= (point)
                                  my/agent-shell--inline-queue-content-start)
                              (<= (point)
                                  my/agent-shell--inline-queue-content-end))
                     (- (point)
                        my/agent-shell--inline-queue-content-start)))))
           (window-offsets
            (and (buffer-live-p shell-buffer)
                 (with-current-buffer shell-buffer
                   (when (my/agent-shell--inline-queue-active-p)
                     (delq
                      nil
                      (mapcar
                       (lambda (window)
                         (let ((position (window-point window)))
                           (when (and
                                  (>= position
                                      my/agent-shell--inline-queue-content-start)
                                  (<= position
                                      my/agent-shell--inline-queue-content-end))
                             (list
                              :window window
                              :offset
                              (- position
                                 my/agent-shell--inline-queue-content-start)
                              ;; Point offsets keep the cursor in the draft,
                              ;; but they do not keep it on the same display
                              ;; row.  Upstream restores `window-start' while
                              ;; streaming because our protected footer means
                              ;; point is not literally at `point-max'.  Once
                              ;; enough output arrives, redisplay recenters the
                              ;; draft.  Remember its row only while it is
                              ;; visible so deliberate scrollback still wins.
                              :screen-row
                              (and (pos-visible-in-window-p
                                    position window)
                                   (count-screen-lines
                                    (window-start window) position
                                    nil window))))))
                       (get-buffer-window-list shell-buffer nil t))))))))
      (prog1 (apply original arguments)
        (when (buffer-live-p shell-buffer)
          (with-current-buffer shell-buffer
            (my/agent-shell--relocate-inline-queue)
            (when (my/agent-shell--inline-queue-active-p)
              (let* ((start (marker-position
                             my/agent-shell--inline-queue-content-start))
                     (end (marker-position
                           my/agent-shell--inline-queue-content-end))
                     (restore-position
                      (lambda (offset)
                        (+ start (min offset (- end start))))))
                (when point-offset
                  (goto-char (funcall restore-position point-offset)))
                (dolist (entry window-offsets)
                  (let ((window (plist-get entry :window)))
                    (when (and (window-live-p window)
                               (eq (window-buffer window) shell-buffer))
                      (let ((position
                             (funcall restore-position
                                      (plist-get entry :offset))))
                        (set-window-point window position)
                        (when-let ((row (plist-get entry :screen-row)))
                          ;; This runs from asynchronous process callbacks.
                          ;; Never select the window here: doing so outside the
                          ;; command loop can leave Evil with a nil state.
                          (let ((start
                                 (save-excursion
                                   (goto-char position)
                                   (vertical-motion (- row) window)
                                   (point))))
                            (set-window-start window start t))))))))))))))

  (defun my/agent-shell--after-shell-output (process _string)
    "Move an inline follow-up after Shell Maker appends raw output."
    (when-let ((shell-buffer (process-buffer process)))
      (when (buffer-live-p shell-buffer)
        (with-current-buffer shell-buffer
          (when (derived-mode-p 'agent-shell-mode)
            (my/agent-shell--relocate-inline-queue)
            (my/agent-shell--ensure-editable-input-boundary))))))

  (defun my/agent-shell--ensure-editable-input-boundary ()
    "Prevent the protected transcript from making the live prompt sticky.

Agent Shell sometimes represents its fresh prompt as a zero-width boundary.
The preceding response character is read-only; unless that property is made
rear-nonsticky, Emacs also rejects insertion immediately after it."
    (when (and (derived-mode-p 'agent-shell-mode)
               (> (point-max) (point-min)))
      (let* ((position (1- (point-max)))
             (existing (get-text-property position 'rear-nonsticky))
             (rear-nonsticky
              (delete-dups
               (append (if (listp existing) existing (and existing (list existing)))
                       '(read-only field front-sticky
                         inhibit-line-move-field-capture font-lock-face)))))
        (with-silent-modifications
          (put-text-property position (point-max)
                             'rear-nonsticky rear-nonsticky)))))

  (defun my/agent-shell--focus-editable-input ()
    "Keep Evil insert state inside the embedded Agent Shell input region."
    (when (derived-mode-p 'agent-shell-mode)
      (if (my/agent-shell--pending-index-at-point)
          (my/agent-shell-edit-pending-request-at-point)
        (my/agent-shell--ensure-inline-input t t))))

  (defun my/agent-shell--keep-normal-cursor-in-inline-input ()
    "Keep an Insert-to-Normal transition inside the inline prompt.

Evil moves point back one character when Insert state exits.  At the start of
an empty prompt that crosses into the protected header, whose intangible text
then sends point much farther back into the transcript.  Restore the nearest
editable prompt boundary only for a transition directly from Insert state;
subsequent Normal-state motion remains unrestricted."
    (when (and (derived-mode-p 'agent-shell-mode)
               (eq evil-previous-state 'insert)
               (my/agent-shell--inline-queue-active-p))
      (let ((start (marker-position
                    my/agent-shell--inline-queue-content-start))
            (end (marker-position
                  my/agent-shell--inline-queue-content-end)))
        (unless (<= start (point) end)
          (goto-char (if (< (point) start) start end))))))

  (defun my/agent-shell--keep-cursor-out-of-inline-footer (window)
    "Keep WINDOW's cursor on the editable side of inline prompt padding."
    (when (window-live-p window)
      (with-current-buffer (window-buffer window)
        (when (and (derived-mode-p 'agent-shell-mode)
                   (my/agent-shell--inline-queue-active-p))
          (let ((position (window-point window)))
            ;; `cursor-intangible-mode' skips ordinary protected spans, but at
            ;; end-of-buffer it has no later tangible position to choose.  The
            ;; inline footer is always at that edge, so explicitly keep point
            ;; at the editable boundary instead of below the painted prompt.
            (when (and (> position my/agent-shell--inline-queue-content-end)
                       (<= position my/agent-shell--inline-queue-end))
              (set-window-point
               window my/agent-shell--inline-queue-content-end)))))))

  (defun my/agent-shell--enable-inline-queue-editing ()
    "Route Evil insert state into Agent Shell's embedded input region."
    ;; The hint and padding are display chrome, not transcript or input.
    ;; Make normal/Evil/mouse motion jump across them instead of allowing
    ;; point to become stranded in read-only text.
    (cursor-intangible-mode 1)
    (add-hook 'pre-redisplay-functions
              #'my/agent-shell--keep-cursor-out-of-inline-footer t t)
    (add-hook 'evil-insert-state-entry-hook
              #'my/agent-shell--focus-editable-input nil t)
    (add-hook 'evil-normal-state-entry-hook
              #'my/agent-shell--keep-normal-cursor-in-inline-input nil t)
    (add-hook 'after-change-functions
              #'my/agent-shell--repair-input-sentinel nil t)
    (my/agent-shell--refresh-historical-user-prompts))

  (add-hook 'agent-shell-mode-hook
            #'my/agent-shell--enable-inline-queue-editing)

  (advice-remove #'agent-shell--update-fragment
                 #'my/agent-shell--after-fragment-update)
  (advice-remove #'agent-shell--update-fragment
                 #'my/agent-shell--around-fragment-update)
  (advice-add #'agent-shell--update-fragment :around
              #'my/agent-shell--around-fragment-update)
  (advice-remove #'shell-maker--output-filter
                 #'my/agent-shell--after-shell-output)
  (advice-add #'shell-maker--output-filter :after
              #'my/agent-shell--after-shell-output)
  (advice-remove #'shell-maker-insert-end-of-prompt-marker
                 #'my/agent-shell--after-end-of-prompt-marker)
  (advice-add #'shell-maker-insert-end-of-prompt-marker :after
              #'my/agent-shell--after-end-of-prompt-marker)

  ;; A Zed-style composer lives in its own small window below the transcript.
  ;; Shell Maker remains responsible for the read-only conversation buffer;
  ;; user editing never touches its Comint prompt boundary.
  (defvar-local my/agent-shell--composer-buffer nil)
  (defvar-local my/agent-shell-composer-shell-buffer nil)
  (defvar-local my/agent-shell-composer-queued-p nil)
  (defvar-local my/agent-shell-composer-subscription nil)
  (defvar my/agent-shell--syncing-composer-windows nil)

  (defvar my/agent-shell-composer-mode-map
    (let ((map (make-sparse-keymap)))
      map)
    "Keymap for `my/agent-shell-composer-mode'.")

  (define-derived-mode my/agent-shell-composer-mode text-mode "Agent Input"
    "Major mode for the dedicated Agent Shell prompt composer."
    (visual-line-mode 1)
    (setq-local mode-line-format nil
                cursor-type 'bar
                header-line-format
                '(:eval
                  (propertize
                   (if my/agent-shell-composer-queued-p
                       " ⏳ Queued — edit freely · C-c unqueues · C-RET force-sends "
                     " ✎ Prompt — RET sends · ⇧RET adds a line · C-c interrupts · C-RET force-sends ")
                   'face 'mode-line-emphasis)))
    (when (fboundp 'display-line-numbers-mode)
      (display-line-numbers-mode -1))
    (when-let ((background (face-background 'highlight nil t)))
      (face-remap-add-relative 'default `(:background ,background))))

  (defun my/agent-shell--composer-live-p (&optional shell-buffer)
    "Return non-nil when SHELL-BUFFER has an associated live composer."
    (with-current-buffer (or shell-buffer (current-buffer))
      (and (buffer-live-p my/agent-shell--composer-buffer)
           my/agent-shell--composer-buffer)))

  (defun my/agent-shell--composer-buffer (&optional shell-buffer create)
    "Return SHELL-BUFFER's composer, creating it when CREATE is non-nil."
    (let ((shell-buffer (or shell-buffer (current-buffer))))
      (with-current-buffer shell-buffer
        (or (my/agent-shell--composer-live-p)
            (when create
              (let ((composer
                     (generate-new-buffer
                      (format "%s [input]" (buffer-name shell-buffer)))))
                (setq my/agent-shell--composer-buffer composer)
                (with-current-buffer composer
                  (my/agent-shell-composer-mode)
                  (setq my/agent-shell-composer-shell-buffer shell-buffer)
                  (add-hook
                   'kill-buffer-hook
                   (lambda ()
                     (when (fboundp 'my/agent-shell--disarm-composer)
                       (ignore-errors
                         (my/agent-shell--disarm-composer composer)))
                     (when (buffer-live-p shell-buffer)
                       (with-current-buffer shell-buffer
                         (setq my/agent-shell--composer-buffer nil))))
                   nil t))
                (add-hook
                 'kill-buffer-hook
                 (lambda ()
                   (when (buffer-live-p composer)
                     (kill-buffer composer)))
                 nil t)
                composer))))))

  (defun my/agent-shell--composer-window (&optional shell-buffer)
    "Return the live composer window associated with SHELL-BUFFER."
    (when-let ((composer
                (my/agent-shell--composer-buffer
                 (or shell-buffer (current-buffer)))))
      (get-buffer-window composer t)))

  (defun my/agent-shell--composer-text (&optional composer-buffer)
    "Return COMPOSER-BUFFER's prompt without text properties."
    (with-current-buffer (or composer-buffer (current-buffer))
      (buffer-substring-no-properties (point-min) (point-max))))

  (defun my/agent-shell--composer-has-text-p (&optional composer-buffer)
    "Return non-nil when COMPOSER-BUFFER contains non-whitespace text."
    (not (string-empty-p
          (string-trim
           (my/agent-shell--composer-text composer-buffer)))))

  (defun my/agent-shell--composer-clear (&optional composer-buffer)
    "Erase COMPOSER-BUFFER and reset its queued state."
    (with-current-buffer (or composer-buffer (current-buffer))
      (let ((inhibit-read-only t))
        (erase-buffer))
      (setq my/agent-shell-composer-queued-p nil)
      (force-mode-line-update t)))

  (defun my/agent-shell--migrate-old-prompt (shell-buffer composer-buffer)
    "Move any unsent shell or legacy inline prompt into COMPOSER-BUFFER."
    (let (text queued)
      (with-current-buffer shell-buffer
        (cond
         ((my/agent-shell--inline-queue-active-p)
          (setq text (my/agent-shell--inline-queue-text)
                queued my/agent-shell--inline-queue-queued-p)
          (my/agent-shell--delete-inline-queue))
         ((my/agent-shell--native-input-text)
          (setq text (my/agent-shell--take-shell-input)))))
      (when (and text (not (string-empty-p text)))
        (with-current-buffer composer-buffer
          (unless (= (point-min) (point-max))
            (goto-char (point-max))
            (insert "\n"))
          (insert text)
          (setq my/agent-shell-composer-queued-p
                (or my/agent-shell-composer-queued-p queued))
          (goto-char (point-max)))
        (when queued
          (if (with-current-buffer shell-buffer (shell-maker-busy))
            (my/agent-shell--arm-composer composer-buffer)
            (my/agent-shell--accept-composer-if-ready composer-buffer))))))

  (defun my/agent-shell--hide-native-prompt (shell-buffer)
    "Hide SHELL-BUFFER's terminal prompt; input belongs in its composer."
    (with-current-buffer shell-buffer
      (add-to-invisibility-spec 'my/agent-shell-native-prompt)
      (when-let* ((prompt comint-last-prompt)
                  (start (marker-position (car prompt)))
                  (end (marker-position (cdr prompt)))
                  ((< start end)))
        (with-silent-modifications
          (put-text-property start end 'invisible
                             'my/agent-shell-native-prompt)))))

  (defun my/agent-shell--show-composer (shell-buffer &optional select)
    "Show SHELL-BUFFER's composer directly below it.

When SELECT is non-nil, focus the composer and enter Evil insert state."
    (when (buffer-live-p shell-buffer)
      (when-let ((shell-window (get-buffer-window shell-buffer t)))
        (let* ((composer (my/agent-shell--composer-buffer shell-buffer t))
               (composer-window (get-buffer-window composer t)))
          (my/agent-shell--migrate-old-prompt shell-buffer composer)
          (my/agent-shell--hide-native-prompt shell-buffer)
          (unless (window-live-p composer-window)
            (setq composer-window
                  (condition-case nil
                      (split-window shell-window -6 'below)
                    (error
                     (display-buffer-in-side-window
                      composer
                      '((side . bottom) (window-height . 6))))))
            (set-window-buffer composer-window composer)
            (set-window-dedicated-p composer-window t)
            (set-window-parameter composer-window
                                  'my/agent-shell-composer-shell
                                  shell-buffer)
            (set-window-margins composer-window 1 1))
          (when select
            (select-window composer-window)
            (when (fboundp 'evil-insert-state)
              (evil-insert-state)))
          composer-window))))

  (defun my/agent-shell--focus-composer (&optional shell-buffer)
    "Focus the dedicated composer for SHELL-BUFFER."
    (let ((shell-buffer
           (or shell-buffer
               (and (derived-mode-p 'my/agent-shell-composer-mode)
                    my/agent-shell-composer-shell-buffer)
               (agent-shell--shell-buffer :no-create t))))
      (or (my/agent-shell--show-composer shell-buffer t)
          (user-error "Agent Shell is not visible"))))

  (defun my/agent-shell--disarm-composer (composer-buffer)
    "Stop waiting to accept COMPOSER-BUFFER's queued prompt."
    (when (buffer-live-p composer-buffer)
      (with-current-buffer composer-buffer
        (when my/agent-shell-composer-subscription
          (when (buffer-live-p my/agent-shell-composer-shell-buffer)
            (with-current-buffer my/agent-shell-composer-shell-buffer
              (agent-shell-unsubscribe
               :subscription
               (buffer-local-value
                'my/agent-shell-composer-subscription composer-buffer))))
          (setq my/agent-shell-composer-subscription nil)))))

  (defun my/agent-shell--accept-composer-if-ready (composer-buffer)
    "Submit COMPOSER-BUFFER's queued prompt when its shell becomes ready."
    (when (buffer-live-p composer-buffer)
      (with-current-buffer composer-buffer
        (let ((shell-buffer my/agent-shell-composer-shell-buffer))
          (when (and my/agent-shell-composer-queued-p
                     (buffer-live-p shell-buffer)
                     (not (with-current-buffer shell-buffer
                            (shell-maker-busy))))
            (let ((prompt (my/agent-shell--composer-text composer-buffer)))
              (if (string-empty-p (string-trim prompt))
                  (progn
                    (my/agent-shell--disarm-composer composer-buffer)
                    (setq my/agent-shell-composer-queued-p nil)
                    (force-mode-line-update t))
                (with-current-buffer shell-buffer
                  (agent-shell-queue-request prompt))
                (my/agent-shell--disarm-composer composer-buffer)
                (my/agent-shell--composer-clear composer-buffer))))))))

  (defun my/agent-shell--arm-composer (composer-buffer)
    "Arrange for COMPOSER-BUFFER's queued prompt to run when ready."
    (with-current-buffer composer-buffer
      (unless my/agent-shell-composer-subscription
        (let ((shell-buffer my/agent-shell-composer-shell-buffer))
          (setq my/agent-shell-composer-subscription
                (agent-shell-subscribe-to
                 :shell-buffer shell-buffer
                 :on-event
                 (lambda (event)
                   (when (memq (map-elt event :event)
                               '(turn-complete error))
                     (run-at-time
                      0 nil
                      (lambda ()
                        (my/agent-shell--accept-composer-if-ready
                         composer-buffer)))))))))))

  (defun my/agent-shell-composer-submit ()
    "Send or queue the current dedicated composer prompt."
    (interactive)
    (unless (derived-mode-p 'my/agent-shell-composer-mode)
      (user-error "Not in an Agent Shell composer"))
    (unless (my/agent-shell--composer-has-text-p)
      (user-error "Nothing to send"))
    (let ((shell-buffer my/agent-shell-composer-shell-buffer)
          (composer-buffer (current-buffer)))
      (if (with-current-buffer shell-buffer (shell-maker-busy))
          (progn
            (setq my/agent-shell-composer-queued-p t)
            (my/agent-shell--arm-composer composer-buffer)
            (force-mode-line-update t)
            (message "Follow-up queued — edit it here or C-c to unqueue"))
        (let ((prompt (my/agent-shell--composer-text)))
          (with-current-buffer shell-buffer
            (agent-shell-queue-request prompt))
          (my/agent-shell--disarm-composer composer-buffer)
          (my/agent-shell--composer-clear composer-buffer)))))

  (defun my/agent-shell-composer-unqueue ()
    "Cancel queueing while preserving the editable composer text."
    (interactive)
    (unless (derived-mode-p 'my/agent-shell-composer-mode)
      (user-error "Not in an Agent Shell composer"))
    (if my/agent-shell-composer-queued-p
        (progn
          (my/agent-shell--disarm-composer (current-buffer))
          (setq my/agent-shell-composer-queued-p nil)
          (force-mode-line-update t)
          (message "Queued follow-up canceled; draft remains editable"))
      (keyboard-quit)))

  (defun my/agent-shell-composer-force-submit ()
    "Interrupt the active turn and submit the composer prompt next."
    (interactive)
    (unless (derived-mode-p 'my/agent-shell-composer-mode)
      (user-error "Not in an Agent Shell composer"))
    (unless (my/agent-shell--composer-has-text-p)
      (user-error "Nothing to force-submit"))
    (let ((shell-buffer my/agent-shell-composer-shell-buffer)
          (composer-buffer (current-buffer))
          (prompt (my/agent-shell--composer-text)))
      (my/agent-shell--force-prompt shell-buffer prompt)
      (my/agent-shell--disarm-composer composer-buffer)
      (my/agent-shell--composer-clear composer-buffer)))

  (defun my/agent-shell--sync-composer-windows ()
    "Keep a composer below the visible Agent Shell and nowhere else."
    (unless my/agent-shell--syncing-composer-windows
      (let ((my/agent-shell--syncing-composer-windows t))
        (dolist (window (window-list nil nil))
          (when-let ((shell-buffer
                      (window-parameter window
                                        'my/agent-shell-composer-shell)))
            (unless (get-buffer-window shell-buffer t)
              (set-window-dedicated-p window nil)
              (set-window-parameter window
                                    'my/agent-shell-composer-shell nil)
              (if (window-parent window)
                  (delete-window window)
                (set-window-buffer
                 window
                 (or (and (buffer-live-p
                           my/agent-shell-chat-return-buffer)
                          my/agent-shell-chat-return-buffer)
                     (other-buffer (window-buffer window) t)))))))
        (cond
         ((derived-mode-p 'agent-shell-mode)
          (my/agent-shell--show-composer (current-buffer)))
         ((derived-mode-p 'my/agent-shell-composer-mode)
          (when (buffer-live-p my/agent-shell-composer-shell-buffer)
            (my/agent-shell--show-composer
             my/agent-shell-composer-shell-buffer)))))))

  ;; The embedded input region supersedes the separate composer window.
  (remove-hook 'post-command-hook #'my/agent-shell--sync-composer-windows)
  (advice-remove #'shell-maker--output-filter
                 #'my/agent-shell--after-shell-output)
  (defun my/agent-shell--after-shell-output (process _string)
    "Keep the embedded input after streamed Agent Shell output."
    (when-let ((shell-buffer (process-buffer process)))
      (when (buffer-live-p shell-buffer)
        (with-current-buffer shell-buffer
          (when (derived-mode-p 'agent-shell-mode)
            (if (my/agent-shell--inline-queue-active-p)
                (my/agent-shell--relocate-inline-queue)
              (my/agent-shell--ensure-inline-input))
            (my/agent-shell--hide-native-prompt shell-buffer))))))
  (advice-add #'shell-maker--output-filter :after
              #'my/agent-shell--after-shell-output)
  (advice-remove #'agent-shell--update-fragment
                 #'my/agent-shell--after-fragment-update)
  (advice-remove #'agent-shell--update-fragment
                 #'my/agent-shell--around-fragment-update)
  (advice-add #'agent-shell--update-fragment :around
              #'my/agent-shell--around-fragment-update)
  (advice-remove #'agent-shell--process-pending-request
                 #'my/agent-shell--around-process-pending-request)
  (advice-add #'agent-shell--process-pending-request :around
              #'my/agent-shell--around-process-pending-request)

  (defun my/agent-shell--sync-inline-input ()
    "Keep a visible Agent Shell's embedded input available and focused.

While Evil is in Insert state, point must remain inside the editable input.
Commands such as backspace at an empty prompt can otherwise leave point in
the protected prompt header without changing Evil state."
    (when (derived-mode-p 'agent-shell-mode)
      (my/agent-shell--ensure-inline-input nil t)
      (when (and (bound-and-true-p evil-local-mode)
                 (eq evil-state 'insert)
                 (my/agent-shell--inline-queue-active-p))
        (let ((start (marker-position
                      my/agent-shell--inline-queue-content-start))
              (end (marker-position
                    my/agent-shell--inline-queue-content-end)))
          (unless (<= start (point) end)
            (goto-char (if (< (point) start) start end)))))))

  (add-hook 'post-command-hook #'my/agent-shell--sync-inline-input)

  (defun my/agent-shell--retire-composer-window
      (shell-buffer &optional focus)
    "Move SHELL-BUFFER's separate composer into its embedded input region."
    (when (buffer-live-p shell-buffer)
      (let* ((composer
              (buffer-local-value 'my/agent-shell--composer-buffer
                                  shell-buffer))
             (text (and (buffer-live-p composer)
                        (my/agent-shell--composer-text composer)))
             (queued (and (buffer-live-p composer)
                          (buffer-local-value
                           'my/agent-shell-composer-queued-p composer)))
             (composer-window (and (buffer-live-p composer)
                                   (get-buffer-window composer t)))
             (shell-window (get-buffer-window shell-buffer t)))
        (when (buffer-live-p composer)
          (my/agent-shell--disarm-composer composer)
          (when (window-live-p composer-window)
            (set-window-dedicated-p composer-window nil)
            (set-window-parameter composer-window
                                  'my/agent-shell-composer-shell nil)
            (cond
             ((and (window-live-p shell-window)
                   (window-parent composer-window))
              (select-window shell-window)
              (delete-window composer-window))
             ((not (window-live-p shell-window))
              (set-window-buffer composer-window shell-buffer)
              (setq shell-window composer-window))))
          (kill-buffer composer))
        (with-current-buffer shell-buffer
          (my/agent-shell--ensure-inline-input nil t)
          (when (and text (not (string-empty-p text)))
            (goto-char my/agent-shell--inline-queue-content-end)
            (insert text))
          (when queued
            (setq my/agent-shell--inline-queue-queued-p t)
            (my/agent-shell--arm-inline-queue shell-buffer)
            (my/agent-shell--relocate-inline-queue t))
          (when focus
            (when-let ((window (get-buffer-window shell-buffer t)))
              (select-window window))
            (my/agent-shell--ensure-inline-input t t)
            (when (fboundp 'evil-insert-state)
              (evil-insert-state)))))))

  (defun my/agent-shell-self-insert-or-compose (count)
    "Insert COUNT characters in Agent Shell's embedded input region."
    (interactive "p")
    (if (derived-mode-p 'agent-shell-mode)
        (progn
          (my/agent-shell--ensure-inline-input t t)
          (my/agent-shell--inline-queue-insert
           (make-string count last-command-event)))
      (self-insert-command count)))

  (defun my/agent-shell-yank-or-compose (&optional argument)
    "Paste clipboard text into Agent Shell's embedded input region."
    (interactive "*P")
    (when (derived-mode-p 'agent-shell-mode)
      (my/agent-shell--ensure-inline-input t t))
    (yank argument))

  (defun my/agent-shell--evil-paste-as-reference
      (original count &optional register yank-handler)
    "Paste a remembered Evil yank as a reference in Agent Shell."
    (let* ((context my/agent-shell-evil-yank-context)
           (text (condition-case nil
                     (if register
                         (evil-get-register register t)
                       (current-kill 0 t))
                   (error nil))))
      (let ((reference
             (when (and context
                        (my/agent-shell--prompt-buffer-p)
                        (stringp text)
                        (equal (substring-no-properties text)
                               (plist-get context :text)))
               (format "%s:%d-%d"
                       (plist-get context :path)
                       (plist-get context :line-start)
                       (plist-get context :line-end)))))
        (when (derived-mode-p 'agent-shell-mode)
          (my/agent-shell--ensure-inline-input t t))
        (if (and reference (my/agent-shell--prompt-buffer-p))
            (let* (;; Give Evil a temporary unnamed register.  The real
                   ;; kill ring and named registers remain unchanged.
                   (kill-ring (cons reference kill-ring))
                   (kill-ring-yank-pointer kill-ring)
                   (interprogram-paste-function nil))
              (funcall original count nil nil))
          (funcall original count register yank-handler)))))

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
  (defun my/agent-shell--context-shell-buffer (&optional no-error)
    "Return the Agent Shell buffer associated with the current editing view."
    (let ((shell-buffer
           (cond
            ((derived-mode-p 'my/agent-shell-composer-mode)
             my/agent-shell-composer-shell-buffer)
            ((derived-mode-p 'agent-shell-mode)
             (current-buffer))
            (t
             (condition-case nil
                 (agent-shell--shell-buffer :no-error t :no-create t)
               (error nil))))))
      (if (buffer-live-p shell-buffer)
          shell-buffer
        (unless no-error
          (user-error "No associated Agent Shell buffer")))))

  (defun my/agent-shell--pending-permission ()
    "Return the latest pending Agent Shell permission and its session data."
    (let* ((shell-buffer (my/agent-shell--context-shell-buffer))
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

  (defun my/agent-shell--viewport-draft ()
    "Return the current viewport draft, or nil when it is empty."
    (when (derived-mode-p 'agent-shell-viewport-edit-mode)
      (let ((draft (string-trim (buffer-substring (point-min) (point-max)))))
        (unless (string-empty-p draft)
          draft))))

  (defun my/agent-shell-newline ()
    "Insert a newline in the editable Agent Shell input."
    (interactive)
    (cond
     ((derived-mode-p 'my/agent-shell-composer-mode)
      (newline))
     ((derived-mode-p 'agent-shell-mode)
      (my/agent-shell--ensure-inline-input t t)
      (newline))
     (t
      (newline))))

  (defun my/agent-shell-open-below (count)
    "Open a new prompt line below point and enter Evil Insert state.

Keep Evil's ordinary `o' behavior, including COUNT and repeat bookkeeping,
but constrain its end-of-line insertion to the editable Agent Shell prompt.
The protected prompt footer otherwise makes `evil-open-below' target the UI
boundary instead of inserting the same real newline as Shift-Return."
    (interactive "p")
    (if (not (derived-mode-p 'agent-shell-mode))
        (evil-open-below count)
      (unless (my/agent-shell--ensure-inline-input t t)
        (user-error "Agent session is still starting"))
      (let ((input-end (marker-position
                        my/agent-shell--inline-queue-content-end)))
        ;; `o' opens below the current prompt line.  On the final line, clamp
        ;; to the marker before the invisible sentinel and read-only footer.
        (goto-char (min (line-end-position) input-end))
        (let ((evil-auto-indent nil))
          (cl-letf (((symbol-function 'evil-insert-newline-below)
                     (lambda ()
                       (my/agent-shell--inline-queue-insert "\n"))))
            (evil-open-below count))))))

  (defun my/agent-shell-delete-to-line-start ()
    "Delete backward within the current editable Agent Shell line.

Unlike `comint-kill-input', never delete earlier prompt lines."
    (interactive)
    (when (derived-mode-p 'agent-shell-mode)
      (my/agent-shell--ensure-inline-input t t))
    (let ((begin (max (line-beginning-position)
                      (if (and (derived-mode-p 'agent-shell-mode)
                               (my/agent-shell--inline-queue-active-p))
                          (marker-position
                           my/agent-shell--inline-queue-content-start)
                        (point-min)))))
      (when (< begin (point))
        (delete-region begin (point)))))

  (defun my/agent-shell-submit-or-queue ()
    "Submit or queue the current prompt using FIFO Return behavior.

Non-empty input appends to the queue while busy.  With empty input and a
non-empty queue, force-submit its first request."
    (interactive)
    (cond
     ((derived-mode-p 'my/agent-shell-composer-mode)
      (my/agent-shell-composer-submit))
     ((derived-mode-p 'agent-shell-viewport-edit-mode)
      (call-interactively #'agent-shell-viewport-compose-send))
     ((derived-mode-p 'agent-shell-mode)
      (my/agent-shell--queue-inline-prompt))
     (t
      (my/agent-shell--call-major-binding "RET" #'newline))))

  (defun my/agent-shell--prepend-pending-request (shell-buffer prompt)
    "Put PROMPT first in SHELL-BUFFER's pending request queue."
    (with-current-buffer shell-buffer
      (let ((state (agent-shell--state)))
        ;; Existing conversations created before Agent Shell gained queueing
        ;; may not have this state slot yet.
        (unless (assq :pending-requests state)
          (nconc state (list (cons :pending-requests nil))))
        (map-put! state :pending-requests
                  (cons prompt (map-elt state :pending-requests))))))

  (defun my/agent-shell--resume-pending-if-ready (shell-buffer)
    "Start SHELL-BUFFER's first pending request once it is no longer busy."
    (when (buffer-live-p shell-buffer)
      (with-current-buffer shell-buffer
        (when (and (not (shell-maker-busy))
                   (map-elt (agent-shell--state) :pending-requests))
          (agent-shell--process-pending-request)))))

  (defun my/agent-shell--active-prompt-request-p (state)
    "Return non-nil when STATE has an in-flight session prompt."
    (seq-some
     (lambda (request)
       (equal (or (map-elt request :method)
                  (map-elt request 'method))
              "session/prompt"))
     (map-elt state :active-requests)))

  (defun my/agent-shell--pending-permission-p (state)
    "Return non-nil when STATE is legitimately waiting for user approval."
    (let (pending)
      (map-do
       (lambda (_tool-call-id tool-call)
         (when (map-elt tool-call :permission-request-id)
           (setq pending t)))
       (map-elt state :tool-calls))
      pending))

  (defun my/agent-shell--seconds-since-activity (state)
    "Return seconds since STATE or its buffer last saw ACP activity."
    (let ((times (delq nil
                       (list my/agent-shell--last-acp-activity-time
                             (map-elt state :last-activity-time)))))
      (when times
        (- (float-time)
           (apply #'max (mapcar #'float-time times))))))

  (defun my/agent-shell--stalled-p (&optional force)
    "Return non-nil when the current Agent Shell needs recovery.

FORCE ignores the inactivity timeout, but retains all state and permission
guards.  It is used after a protocol callback itself failed."
    (condition-case nil
        (let* ((state (agent-shell--state))
               (client (map-elt state :client))
               (process (and client (map-elt client :process)))
               (age (my/agent-shell--seconds-since-activity state)))
          (and (derived-mode-p 'agent-shell-mode)
               (not my/agent-shell--auto-recovery-in-progress)
               (eq (agent-shell-status) 'busy)
               (shell-maker-busy)
               (map-nested-elt state '(:session :id))
               (not (my/agent-shell--pending-permission-p state))
               (or (my/agent-shell--active-prompt-request-p state)
                   force)
               (or force
                   (not (and process (process-live-p process)))
                   (and age (> age my/agent-shell-stall-timeout)))))
      (error nil)))

  (defun my/agent-shell--stop-stall-watchdog ()
    "Stop the current Agent Shell buffer's stall watchdog."
    (when (timerp my/agent-shell--stall-watchdog-timer)
      (cancel-timer my/agent-shell--stall-watchdog-timer))
    (setq my/agent-shell--stall-watchdog-timer nil))

  (defun my/agent-shell--schedule-recovery-retry (buffer-name)
    "Retry BUFFER-NAME's retained recovery snapshot after a short delay."
    (when-let ((snapshot
                (alist-get buffer-name
                           my/agent-shell--recovery-snapshots
                           nil nil #'equal)))
      (when (< (or (plist-get snapshot :recovery-attempt) 0)
               my/agent-shell-recovery-retry-limit)
        (run-at-time
         my/agent-shell-recovery-retry-delay nil
         (lambda ()
           (when-let ((buffer (get-buffer buffer-name)))
             (with-current-buffer buffer
               (unless my/agent-shell--auto-recovery-in-progress
                 (setq my/agent-shell--auto-recovery-in-progress t)
                 (my/agent-shell--run-auto-recovery buffer)))))))))

  (defun my/agent-shell--run-auto-recovery (shell-buffer)
    "Recover stalled SHELL-BUFFER, reporting but containing failures."
    (when (buffer-live-p shell-buffer)
      (let ((buffer-name (buffer-name shell-buffer)))
        (condition-case error-data
            (my/agent-shell-recover-stalled-session shell-buffer)
          (error
           (when (buffer-live-p shell-buffer)
             (with-current-buffer shell-buffer
               (setq my/agent-shell--auto-recovery-in-progress nil)))
           (display-warning
            'agent-shell
            (format "Automatic Agent Shell recovery failed: %S" error-data)
            :error)
           (my/agent-shell--schedule-recovery-retry buffer-name))))))

  (defun my/agent-shell--stall-watchdog-tick (shell-buffer &optional force)
    "Recover SHELL-BUFFER automatically when it is demonstrably stalled.

FORCE requests an immediate guarded check after an ACP callback error."
    (when (buffer-live-p shell-buffer)
      (with-current-buffer shell-buffer
        (when (my/agent-shell--stalled-p force)
          (setq my/agent-shell--auto-recovery-in-progress t)
          (message "Agent Shell stopped receiving ACP activity; reconnecting...")
          (run-at-time 0 nil #'my/agent-shell--run-auto-recovery
                       shell-buffer)))))

  (defun my/agent-shell--start-stall-watchdog ()
    "Monitor the current Agent Shell and recover silent transport stalls."
    (my/agent-shell--stop-stall-watchdog)
    (setq my/agent-shell--stall-watchdog-timer
          (run-with-timer
           my/agent-shell-stall-check-interval
           my/agent-shell-stall-check-interval
           #'my/agent-shell--stall-watchdog-tick
           (current-buffer)))
    (add-hook 'kill-buffer-hook
              #'my/agent-shell--stop-stall-watchdog nil t))

  (add-hook 'agent-shell-mode-hook #'my/agent-shell--start-stall-watchdog)

  (defvar my/agent-shell--recovery-snapshots nil
    "Local drafts and queues waiting for a stalled-session recovery.")

  (defun my/agent-shell--recovery-snapshot (shell-buffer)
    "Capture SHELL-BUFFER's local-only state before restarting it."
    (with-current-buffer shell-buffer
      (let* ((inline (my/agent-shell--inline-queue-active-p))
             (native-range (and (not inline)
                                (my/agent-shell--native-input-range)))
             (draft (cond
                     (inline (my/agent-shell--inline-queue-text))
                     (native-range
                      (buffer-substring-no-properties
                       (car native-range) (cdr native-range)))
                     (t "")))
             (offset
              (cond
               ((and inline
                     (>= (point) my/agent-shell--inline-queue-content-start)
                     (<= (point) my/agent-shell--inline-queue-content-end))
                (- (point) my/agent-shell--inline-queue-content-start))
               ((and native-range
                     (>= (point) (car native-range))
                     (<= (point) (cdr native-range)))
                (- (point) (car native-range)))
               (t (length draft)))))
        (list :buffer-name (buffer-name)
              :default-directory default-directory
              :agent-config (map-elt (agent-shell--state) :agent-config)
              :session-id (map-nested-elt (agent-shell--state)
                                          '(:session :id))
              :draft draft
              :draft-offset offset
              :queued my/agent-shell--inline-queue-queued-p
              :pending-requests
              (copy-sequence (my/agent-shell--pending-requests
                              shell-buffer))))))

  (defun my/agent-shell--recovery-config (snapshot)
    "Return SNAPSHOT's agent config, with a legacy snapshot fallback."
    (or (plist-get snapshot :agent-config)
        ;; Snapshots made before agent config preservation was added can still
        ;; be recovered from the provider-specific buffer name.  New snapshots
        ;; never need this fallback.
        (let ((name (plist-get snapshot :buffer-name)))
          (cond
           ((and (stringp name) (string-prefix-p "Claude" name))
            (require 'agent-shell-anthropic)
            (agent-shell-anthropic-make-claude-code-config))
           ((and (stringp name) (string-prefix-p "Codex" name))
            (require 'agent-shell-openai)
            (agent-shell-openai-make-codex-config))))))

  (defun my/agent-shell--restore-recovery-snapshot (shell-buffer snapshot)
    "Restore local-only SNAPSHOT state into reconnected SHELL-BUFFER."
    (when (buffer-live-p shell-buffer)
      (with-current-buffer shell-buffer
        (when (my/agent-shell--inline-queue-active-p)
          (my/agent-shell--delete-inline-queue))
        (map-put! (agent-shell--state) :pending-requests
                  (copy-sequence (plist-get snapshot :pending-requests)))
        (setq my/agent-shell--inline-queue-queued-p
              (plist-get snapshot :queued))
        (my/agent-shell--insert-inline-queue-block
         (plist-get snapshot :draft)
         (plist-get snapshot :draft-offset))
        (my/agent-shell--hide-native-prompt shell-buffer)
        (when my/agent-shell--inline-queue-queued-p
          (my/agent-shell--arm-inline-queue shell-buffer)))))

  (defun my/agent-shell-recover-stalled-session (&optional shell-buffer)
    "Restart and resume a stalled ACP session without losing local input.

The current inline/native draft and native FIFO are snapshotted before the
wedged transport is shut down.  Agent Shell then reconnects to the same ACP
session.  Once initialization finishes, the draft and FIFO are restored and
an already-accepted queued request resumes automatically.  A failed reconnect
keeps the snapshot in memory so a retry cannot silently discard it."
    (interactive)
    (let* ((shell-buffer (or shell-buffer
                             (my/agent-shell--context-shell-buffer)))
           (buffer-name (buffer-name shell-buffer))
           (saved (alist-get buffer-name
                             my/agent-shell--recovery-snapshots
                             nil nil #'equal))
           (snapshot (or saved
                         (my/agent-shell--recovery-snapshot shell-buffer)))
           (config (my/agent-shell--recovery-config snapshot))
           (directory (or (plist-get snapshot :default-directory)
                          (buffer-local-value 'default-directory
                                              shell-buffer)))
           (session-id (plist-get snapshot :session-id)))
      (unless session-id
        (user-error "This Agent Shell has no session to resume"))
      (unless config
        (error "Recovery snapshot has no Agent Shell configuration"))
      (setq snapshot (plist-put snapshot :agent-config config)
            snapshot (plist-put snapshot :default-directory directory)
            snapshot
            (plist-put snapshot :recovery-attempt
                       (1+ (or (plist-get snapshot :recovery-attempt) 0))))
      (with-current-buffer shell-buffer
        (setq my/agent-shell--auto-recovery-in-progress t)
        (setq default-directory directory)
        ;; A previous restart may have failed after replacing the old buffer.
        ;; Rehydrate the one field upstream `agent-shell-restart' needs so the
        ;; retained snapshot can retry from that partial buffer.
        (when (derived-mode-p 'agent-shell-mode)
          (map-put! (agent-shell--state) :agent-config config)))
      (setf (alist-get buffer-name my/agent-shell--recovery-snapshots
                       nil nil #'equal)
            snapshot)
      (let* ((windows (get-buffer-window-list shell-buffer nil t))
             (new-shell-buffer
              (if (with-current-buffer shell-buffer
                    (derived-mode-p 'agent-shell-mode))
                  (progn
                    ;; `agent-shell-restart' normally asks before killing an
                    ;; active request.  Automatic recovery is that decision,
                    ;; so bypass only its active-request confirmation.
                    (cl-letf (((symbol-function
                                'agent-shell--active-requests-p)
                               (lambda (&rest _arguments) nil)))
                      (with-current-buffer shell-buffer
                        (let ((shell-maker-prompt-before-killing-buffer nil))
                          (agent-shell-restart :session-id session-id))))
                    (get-buffer buffer-name))
                ;; A failed startup can leave a fundamental-mode placeholder
                ;; behind.  Rebuild directly from the retained snapshot rather
                ;; than requiring that partial buffer to be a working shell.
                (when (buffer-live-p shell-buffer)
                  (kill-buffer shell-buffer))
                (let ((default-directory directory))
                  (let ((new-buffer
                         (agent-shell--start
                          :config config
                          :session-strategy 'new
                          :session-id session-id
                          :new-session t
                          :no-focus t)))
                    (shell-maker-set-buffer-name new-buffer buffer-name)
                    (if-let ((live-windows
                              (seq-filter #'window-live-p windows)))
                        (dolist (window live-windows)
                          (set-window-buffer window new-buffer))
                      (agent-shell--display-buffer new-buffer))
                    new-buffer))))
            subscription
            restored
            retry-scheduled)
        (unless (buffer-live-p new-shell-buffer)
          (error "Agent Shell restart failed; recovery snapshot retained"))
        (cl-labels
            ((restore-after-init
              ()
              (unless restored
                (setq restored t)
                (when subscription
                  (agent-shell-unsubscribe :subscription subscription))
                (my/agent-shell--restore-recovery-snapshot
                 new-shell-buffer snapshot)
                (setq my/agent-shell--recovery-snapshots
                      (assoc-delete-all
                       buffer-name my/agent-shell--recovery-snapshots))
                (when (plist-get snapshot :pending-requests)
                  (run-at-time
                   0 nil #'my/agent-shell--resume-pending-if-ready
                   new-shell-buffer))
                (message "Agent session recovered; local draft and queue restored"))))
          (setq subscription
                (agent-shell-subscribe-to
                 :shell-buffer new-shell-buffer
                 :on-event
                 (lambda (event)
                   (pcase (map-elt event :event)
                     ('init-finished
                      (restore-after-init))
                     ('error
                      (unless (or restored retry-scheduled)
                        (setq retry-scheduled t)
                        (when subscription
                          (agent-shell-unsubscribe
                           :subscription subscription))
                        (my/agent-shell--schedule-recovery-retry
                         buffer-name))))))))
        (message "Restarting and resuming Agent Shell session %s..."
                 session-id))))

  (defun my/agent-shell--interrupt-for-forced-request (shell-buffer)
    "Interrupt SHELL-BUFFER, then resume its frontmost forced request."
    (let (subscription finished)
      (cl-labels
          ((resume-when-ready
            ()
            (when (and (not finished) (buffer-live-p shell-buffer))
              (with-current-buffer shell-buffer
                ;; `error' is emitted before Shell Maker clears its busy
                ;; flag.  An unrelated request can also error first, so keep
                ;; the subscription armed until this turn is genuinely idle.
                (unless (shell-maker-busy)
                  (setq finished t)
                  (when subscription
                    (agent-shell-unsubscribe :subscription subscription))
                  (my/agent-shell--resume-pending-if-ready shell-buffer)))))
           (resume-after-event
            ()
            ;; ACP cancellation can finish through either `turn-complete'
            ;; or `error'.  Defer until the event callback has returned.
            (run-at-time 0 nil (lambda () (resume-when-ready)))))
        (setq subscription
              (agent-shell-subscribe-to
               :shell-buffer shell-buffer
               :on-event
               (lambda (event)
                 (when (memq (map-elt event :event)
                             '(turn-complete error clean-up))
                   (resume-after-event)))))
        (with-current-buffer shell-buffer
          (agent-shell-interrupt t)
          ;; Pre-session and already-finished turns may stop synchronously.
          (unless (shell-maker-busy)
            (resume-when-ready))))))

  (defun my/agent-shell--force-prompt (shell-buffer prompt)
    "Run PROMPT next in SHELL-BUFFER, interrupting its active turn if needed."
    (if (with-current-buffer shell-buffer (shell-maker-busy))
        (progn
          (my/agent-shell--prepend-pending-request shell-buffer prompt)
          (my/agent-shell--interrupt-for-forced-request shell-buffer)
          (message "Interrupted active turn; force-submitting next"))
      (with-current-buffer shell-buffer
        (agent-shell-queue-request prompt))))

  (defun my/agent-shell-force-submit ()
    "Interrupt the active turn and submit the current draft next.

The forced draft is placed at the front of Agent Shell's native queue, ahead
of ordinary queued follow-ups.  With no active turn, submit normally."
    (interactive)
    (cond
     ((derived-mode-p 'my/agent-shell-composer-mode)
      (my/agent-shell-composer-force-submit))
     ((derived-mode-p 'agent-shell-viewport-edit-mode)
      (let* ((viewport-buffer (current-buffer))
             (shell-buffer (agent-shell--shell-buffer :no-create t))
             (prompt (or (my/agent-shell--viewport-draft)
                         (user-error "Nothing to submit"))))
        (if (with-current-buffer shell-buffer (shell-maker-busy))
            (progn
              (my/agent-shell--prepend-pending-request shell-buffer prompt)
              (agent-shell-viewport--initialize)
              (if agent-shell-viewport-dismiss-on-send
                  (agent-shell-viewport--dismiss viewport-buffer)
                (agent-shell-viewport-view-last))
              (my/agent-shell--interrupt-for-forced-request shell-buffer)
              (message "Interrupted active turn; force-submitting next"))
          (call-interactively #'agent-shell-viewport-compose-send))))
     ((derived-mode-p 'agent-shell-mode)
      (my/agent-shell--ensure-inline-input t t)
      (let ((prompt (my/agent-shell--inline-queue-text))
            (shell-buffer (current-buffer)))
        (unless (and prompt
                     (not (string-empty-p (string-trim prompt))))
          (user-error "Nothing to force-submit"))
        (my/agent-shell--delete-inline-queue)
        (condition-case error-data
            (progn
              (my/agent-shell--force-prompt shell-buffer prompt)
              (unless (my/agent-shell--inline-queue-active-p)
                (my/agent-shell--insert-inline-queue-block ""))
              (my/agent-shell--hide-native-prompt shell-buffer)
              (goto-char my/agent-shell--inline-queue-content-end))
          (error
           (unless (my/agent-shell--inline-queue-active-p)
             (my/agent-shell--insert-inline-queue-block prompt))
           (signal (car error-data) (cdr error-data))))))
     ((derived-mode-p 'agent-shell-viewport-view-mode)
      (agent-shell-viewport-reply)
      (message "Type the replacement prompt, then press Command-Return"))
     (t
      (user-error "Not in an Agent Shell prompt"))))

  (defun my/agent-shell-permission-return ()
    "Allow once when appropriate; otherwise submit or queue the prompt."
    (interactive)
    (if (and (my/agent-shell--permission-pending-p)
             ;; A composed follow-up wins over the permission shortcut.  This
             ;; allows RET to queue it, or force the FIFO head with empty
             ;; input, even while the current turn is blocked.
             (not (my/agent-shell--viewport-draft))
             (not (let ((shell-buffer
                         (my/agent-shell--context-shell-buffer t)))
                    (and shell-buffer
                         (with-current-buffer shell-buffer
                           (or (my/agent-shell--inline-queue-has-text-p)
                               (my/agent-shell--pending-requests
                                shell-buffer)))))))
        (my/agent-shell-permission-allow-once)
      (my/agent-shell-submit-or-queue)))

  (defun my/agent-shell--current-draft-p ()
    "Return non-nil when cancellation would overwrite an unsent draft."
    (let ((shell-buffer (my/agent-shell--context-shell-buffer t)))
      (or (and shell-buffer
               (with-current-buffer shell-buffer
                 (my/agent-shell--inline-queue-has-text-p)))
          ;; Keep this fallback only for a native prompt that has not yet been
          ;; migrated during a live config reload.
          (condition-case nil
              (when shell-buffer
                (with-current-buffer shell-buffer
                  (my/agent-shell--native-input-text)))
            (error nil))
          (and (derived-mode-p 'agent-shell-viewport-edit-mode)
               (not (string-empty-p
                     (string-trim
                      (buffer-substring-no-properties
                       (point-min) (point-max)))))))))

  (defun my/agent-shell--last-submitted-input (shell-buffer)
    "Return the newest submitted input from SHELL-BUFFER history."
    (with-current-buffer shell-buffer
      (when (and (ring-p comint-input-ring)
                 (not (ring-empty-p comint-input-ring)))
        (substring-no-properties (ring-ref comint-input-ring 0)))))

  (defun my/agent-shell-interrupt-and-edit ()
    "Interrupt the active turn and restore its prompt for editing."
    (interactive)
    (let* ((shell-buffer (my/agent-shell--context-shell-buffer))
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
                  (agent-shell-unsubscribe :subscription token)))
              (with-current-buffer shell-buffer
                (my/agent-shell--ensure-inline-input nil t)
                ;; Never overwrite text typed while cancellation was in flight.
                (unless (my/agent-shell--inline-queue-has-text-p)
                  (goto-char my/agent-shell--inline-queue-content-end)
                  (insert input))
                (when-let ((window (get-buffer-window shell-buffer t)))
                  (select-window window))
                (my/agent-shell--ensure-inline-input t t)
                (when (fboundp 'evil-insert-state)
                  (evil-insert-state))))))
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
    "Unqueue a follow-up or interrupt the active Agent Shell turn.

A just-submitted prompt is restored for editing when no response has arrived
yet.  Any separate draft already being edited is preserved unchanged."
    (interactive)
    (let ((shell-buffer (my/agent-shell--context-shell-buffer t)))
      (cond
       ((and (derived-mode-p 'agent-shell-mode)
             (my/agent-shell--pending-index-at-point))
        (my/agent-shell-remove-pending-request-at-point))
       ((and shell-buffer
             (buffer-local-value
              'my/agent-shell--inline-queue-queued-p shell-buffer))
        ;; Unqueue without destroying text; it remains an editable draft.
        (with-current-buffer shell-buffer
          (my/agent-shell--unqueue-inline-prompt)
          (my/agent-shell--ensure-inline-input t t)))
       ((and shell-buffer
             (with-current-buffer shell-buffer
               (eq (agent-shell-status) 'busy)))
        (if (and (not (my/agent-shell--current-draft-p))
                 (with-current-buffer shell-buffer
                   ;; Submission resets this to nil.  Before the first
                   ;; response entry, interrupt-and-edit can restore it.
                   (null (map-elt (agent-shell--state) :last-entry-type))))
            (my/agent-shell-interrupt-and-edit)
          (with-current-buffer shell-buffer
            (agent-shell-interrupt t))
          (message "Agent interrupted; current draft preserved")))
       (t
        (keyboard-quit)))))


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
                     agent-shell-viewport-view-mode-map
                     my/agent-shell-composer-mode-map))
    (define-key map (kbd "s-y")
                #'my/agent-shell-permission-allow-once)
    (define-key map (kbd "s-Y")
                #'my/agent-shell-permission-allow-always)
    (define-key map (kbd "s-g")
                #'my/agent-shell-permission-view-diff)
    (define-key map (kbd "C-g") nil)
    (define-key map (kbd "C-c")
                #'my/agent-shell-cancel-submitted-prompt)
    (dolist (key '("M-N" "M-S-n"))
      (define-key map (kbd key) #'my/agent-shell-new-conversation))
    (dolist (key '("s-RET" "s-<return>" "C-RET" "C-<return>"))
      (define-key map (kbd key) #'my/agent-shell-force-submit))
    (evil-define-key* '(normal motion visual insert) map
      (kbd "s-y") #'my/agent-shell-permission-allow-once
      (kbd "s-Y") #'my/agent-shell-permission-allow-always
      (kbd "s-g") #'my/agent-shell-permission-view-diff
      (kbd "C-g") nil
      (kbd "C-c") #'my/agent-shell-cancel-submitted-prompt)
    (dolist (key '("M-N" "M-S-n"))
      (evil-define-key* '(normal motion visual insert) map
        (kbd key) #'my/agent-shell-new-conversation))
    (dolist (key '("s-RET" "s-<return>" "C-RET" "C-<return>"))
      (evil-define-key* '(normal motion visual insert) map
        (kbd key) #'my/agent-shell-force-submit)))

  ;; Comint normally binds insert-state C-u to `comint-kill-input', which
  ;; erases every line in a multiline prompt.  Keep Vim's line-local behavior
  ;; in Agent Shell without changing normal-state C-u scrolling.
  (evil-define-key* 'insert agent-shell-mode-map
    (kbd "C-u") #'my/agent-shell-delete-to-line-start)
  (evil-define-key* 'insert agent-shell-viewport-edit-mode-map
    (kbd "C-u") #'my/agent-shell-delete-to-line-start)
  (evil-define-key* 'insert my/agent-shell-composer-mode-map
    (kbd "C-u") #'my/agent-shell-delete-to-line-start)

  ;; Evil's stock `o' follows the physical line into the protected prompt
  ;; footer.  Open below within the editable transcript prompt instead.
  (evil-define-key* 'normal agent-shell-mode-map
    (kbd "o") #'my/agent-shell-open-below)

  ;; Transcript output is read-only.  Redirect typed text into the embedded
  ;; gray input region at the bottom of the same buffer.
  ;; Agent Shell binds plain n/p for item navigation in its major map, which
  ;; otherwise shadows self-insert even in Evil insert state.  Keep navigation
  ;; in normal/motion state and let insert state type both characters.
  (dolist (key '("n" "p"))
    (define-key agent-shell-mode-map (kbd key) nil))
  (evil-define-key* '(normal motion) agent-shell-mode-map
    (kbd "n") #'agent-shell-next-item
    (kbd "p") #'agent-shell-previous-item)
  (define-key agent-shell-mode-map [remap self-insert-command]
              #'my/agent-shell-self-insert-or-compose)
  (define-key agent-shell-mode-map (kbd "s-v")
              #'my/agent-shell-yank-or-compose)

  ;; Transitional bindings let a live config reload migrate an old composer
  ;; without trapping the user there.
  (define-key my/agent-shell-composer-mode-map (kbd "RET")
              #'my/agent-shell-permission-return)
  (define-key my/agent-shell-composer-mode-map (kbd "<return>")
              #'my/agent-shell-permission-return)

  ;; Zed-style prompt editing: Return sends, Shift-Return inserts a newline.
  (dolist (key '("S-RET" "S-<return>"))
    (define-key agent-shell-mode-map (kbd key) #'my/agent-shell-newline)
    (define-key agent-shell-viewport-edit-mode-map
                (kbd key) #'my/agent-shell-newline)
    (define-key my/agent-shell-composer-mode-map
                (kbd key) #'my/agent-shell-newline)
    (evil-define-key* '(normal motion visual insert)
      agent-shell-mode-map (kbd key) #'my/agent-shell-newline)
    (evil-define-key* '(normal motion visual insert)
      agent-shell-viewport-edit-mode-map
      (kbd key) #'my/agent-shell-newline)
    (evil-define-key* '(normal motion visual insert)
      my/agent-shell-composer-mode-map
      (kbd key) #'my/agent-shell-newline))

  (defun my/agent-shell--ns-paste-secondary
      (original &rest arguments)
    "Turn macOS secondary paste into approval only for pending agent prompts."
    (if (and (derived-mode-p 'agent-shell-mode
                             'agent-shell-viewport-edit-mode
                             'agent-shell-viewport-view-mode
                             'my/agent-shell-composer-mode)
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
              agent-shell-viewport-view-mode-map
              my/agent-shell-composer-mode-map)
        ;; Default permission controls in normal, motion, visual, and insert.
        :nvim "RET" #'my/agent-shell-permission-return
        :nvim "<return>" #'my/agent-shell-permission-return
        :nvim "TAB" #'my/agent-shell-permission-tab
        :nvim "<tab>" #'my/agent-shell-permission-tab
        :nvim "<backtab>" #'my/agent-shell-permission-backtab
        ;; Evil navigation in normal/motion state.
        :nm "h" #'evil-backward-char
        :nm "j" #'evil-next-visual-line
        :nm "k" #'evil-previous-visual-line
        :nm "l" #'evil-forward-char
        :nm "gv" #'my/agent-shell-permission-view-diff
        :nm "]p" #'agent-shell-next-permission-button
        :nm "[p" #'agent-shell-previous-permission-button)

  ;; A config reload may find an existing instance of the short-lived separate
  ;; composer design.  Fold it back into its owning transcript without losing
  ;; a draft or queued state.
  (dolist (shell-buffer (agent-shell-buffers))
    (when (buffer-live-p shell-buffer)
      (with-current-buffer shell-buffer
        (my/agent-shell--enable-inline-queue-editing)
        (my/agent-shell--start-stall-watchdog))
      (run-at-time
       0 nil #'my/agent-shell--retire-composer-window shell-buffer
       (and (buffer-live-p
             (buffer-local-value 'my/agent-shell--composer-buffer
                                 shell-buffer))
            (eq (window-buffer (selected-window))
                (buffer-local-value 'my/agent-shell--composer-buffer
                                    shell-buffer)))))))

;; Give every GUI Emacs instance its own emacsclient socket (server<PID>)
;; so external tools — claude_approver's EmacsWatcher in particular — can
;; reach any instance, not just the daemon. The daemon keeps the default
;; "server" name.
(unless (daemonp)
  (setq server-name (format "server%d" (emacs-pid)))
  (server-start))

;; [[ / ]] move by function (methods inside classes too, via the major
;; mode's beginning/end-of-defun), while { / } take over evil's vim-style
;; section motions that [[ / ]] had by default.
(after! evil
  (evil-define-motion my/evil-backward-defun (count)
    "Go to the beginning of the current defun; repeat for previous ones."
    :type exclusive
    :jump t
    (beginning-of-defun (or count 1)))

  (evil-define-motion my/evil-forward-defun (count)
    "Go to the end of the current defun; repeat for following ones."
    :type inclusive
    :jump t
    (end-of-defun (or count 1)))

  (map! :m "[[" #'my/evil-backward-defun
        :m "]]" #'my/evil-forward-defun
        :m "{"  #'evil-backward-section-begin
        :m "}"  #'evil-forward-section-begin))
