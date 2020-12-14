;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; place your private configuration here
(setq doom-font (font-spec :family "Iosevka SS04" :size 14))
(when (string= (system-name) "space")
  ;; different scaling
  (setq doom-font (font-spec :family "Iosevka SS04" :size 28)))

(map!
  ;; window management
 (:map override
  :nv "M-k"         #'evil-window-up
  :nv "M-j"         #'evil-window-down
  :nv "M-l"         #'evil-window-right
  :nv "M-h"         #'evil-window-left
  )
  :nv "S-C-<left>"  #'shrink-window-horizontally
  :nv "S-C-<right>" #'enlarge-window-horizontally
  :nv "S-C-<down>"  #'shrink-window
  :nv "S-C-<up>"    #'enlarge-window
  ;; indenting
  :n  "<"           #'evil-shift-left-line
  :n  ">"           #'evil-shift-right-line
  :n "<tab>"        #'evil-indent-line
  :v "<tab>"        #'evil-indent
  ;; moving around
  :nv "C-e"         #'evil-scroll-up
  :nv "`"           #'evil-jump-item
  :i  "C-f"         #'evil-forward-char
  :i  "C-b"         #'evil-backward-char
  :nv "g l "        #'goto-line
  :nv "C-j"         #'scroll-up-line
  :nv "C-k"         #'scroll-down-line
  :nv "g s"         #'evil-avy-goto-char-timer
  :nv "g["          #'avy-goto-char-2-above
  :nv "g]"          #'avy-goto-char-2-below
  :n  "S"           #'avy-goto-char-in-line
  :nvi "M-`"        #'+popup/toggle
  (:after swiper :desc "Swiper" :n "SPC /" #'counsel-grep-or-swiper)
  ;; :nv "S"           #'evil-snipe-s
  (:map compilation-mode-map :desc "evil backward char" :nv "h" #'evil-backward-char)
  ;; ranger
  (:after ranger :desc "Invoke deer" :n  "-"   #'deer)
  (:after ranger :map ranger-mode-map
    "M-k" #'evil-window-up
    "M-j" #'evil-window-down
    "M-l" #'evil-window-right
    "M-h" #'evil-window-left
    )
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
    :desc "Recompile" :nv "<C-return>" #'recompile
    :desc "Recompile" :nv "C-<f9>" #'recompile ; in terminal
    )
  (:after tex :map LaTeX-mode-map :desc "Recompile" :nv "<C-return>" #'latex/build)
  ;; ivy
  (:after ivy :map ivy-mode-map
    :desc "Kill buffer" "C-d" #'ivy-switch-buffer-kill)
  ;; org
  (:after org :map org-mode-map
    :desc "Preview LaTeX" :niv "<M-return>" #'org-latex-preview)
  ;; c++
  (:map c++-mode-map
    :desc "Quick run" :niv "<M-return>" #'quickrun)
  ;; python
  (:map python-mode-map
    :desc "Quick run" :niv "<M-return>" #'quickrun)
)
(map! :leader
  (:when (featurep! :ui workspaces)
    (:prefix-map ("`" . "workspace")
      :desc "Display tab bar"           "`"   #'+workspace/display
      :desc "Switch workspace"          "."   #'+workspace/switch-to
      :desc "New workspace"             "n"   #'+workspace/new
      :desc "Load workspace from file"  "l"   #'+workspace/load
      :desc "Save workspace to file"    "s"   #'+workspace/save
      :desc "Delete session"            "x"   #'+workspace/kill-session
      :desc "Delete this workspace"     "d"   #'+workspace/delete
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
      :desc "Delete this workspace"     "d"   #'+workspace/delete
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
  (:prefix "w"
    :nv "d"   #'delete-window
    :nv "SPC" #'ace-swap-window
    :nv "1"   #'delete-other-windows
    :n "f"    #'make-frame-command
    :n "D"    #'delete-frame
    :nv "v"   #'split-window-right
    :nv "s"   #'split-window-below
    )
  ;; commenting
  :desc "comment single line" :n ";" #'evil-commentary-line
  :desc "comment block"       :v ";" #'evil-commentary
  ;; buffers
  :desc "Switch to previous buffer" :nv "<tab>" #'spacemacs/alternate-buffer
  (:after ivy :nv "SPC" #'+ivy/switch-workspace-buffer)
  (:prefix "b"
    :desc "kill current buffer"          :nv "d" #'kill-this-buffer
    :desc "switch to compilation buffer" :nv "c" #'switch-to-compilation-buffer
    :desc "switch to messages buffer"    :nv "m" #'switch-to-messages-buffer
    :desc "switch buffer"                :nv "b" #'+ivy/switch-buffer
    )
  ;; files
  (:prefix "f"
    (:desc "Rename file" :nv "R" #'rename-file-and-buffer)
    (:desc "Browse private config dir" :nv "p" #'doom/open-private-config)
    (:desc "Save buffer" :nv "s" #'save-buffer))

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
   )
  ;; projectile
  (:prefix "p"
    (:after projectile :map projectile-mode-map
      :desc "Project ag"        :nv "s" #'projectile-ag
      :desc "Project find file" :nv "f" #'+ivy/projectile-find-file
      :desc "Project replace"   :n  "R" #'projectile-replace
      )
    )
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
  )
  (:prefix "o"
    ;; debugging
    (:after realgud :desc "toggle debug shortcuts" :n "k" #'realgud-short-key-mode)
    :desc "Open vterm" :n "t" #'+vterm/here
    )
) ; end map leader
;; tab switching
;; (when (string= (system-name) "space")
;;   (map!
;;    (:after centaur-tabs :map override
;;     :nv "M-1"         #'centaur-tabs-select-visible-1st-tab
;;     :nv "M-2"         #'centaur-tabs-select-visible-2nd-tab
;;     :nv "M-3"         #'centaur-tabs-select-visible-3rd-tab
;;     )
;;    )  ;;
;; )
;; ------------------------------ GUI -----------------------------------------
;; tweaks
(setq display-line-numbers-type 'relative)
;; (setq confirm-kill-emacs)
(setq confirm-kill-emacs nil)

;; (use-package! ivy-rich
(after! ivy-rich
  (setq ivy-rich-display-transformers-list
        '(ivy-switch-buffer
          (:columns
           (;;(+ivy-rich-buffer-icon)
            (+ivy-rich-buffer-name (:width 30))
            (ivy-rich-switch-buffer-size (:width 7))
            (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right))
            (ivy-rich-switch-buffer-major-mode (:width 12 :face font-lock-variable-name-face))
            (ivy-rich-switch-buffer-project (:width 15 :face font-lock-keyword-face))
            (ivy-rich-switch-buffer-path (:width (lambda (x)
                                                   (ivy-rich-switch-buffer-shorten-path x
                                                   (ivy-rich-minibuffer-width 0.3))))))
           )))
  ;; (ivy-rich-mode nil)
  ;; (ivy-rich-mode +1)
)

(if window-system
  (setq window-divider-default-bottom-width 4 ; in pixels
        window-divider-default-right-width  4)
  (window-divider-mode +1)
)

;; set modes
(after! doom-modeline
  (progn
    (winum-mode)
    (setq doom-modeline-height 10
          ;; doom-modeline-buffer-file-name-style 'buffer-name ;; just the buffer name
          doom-modeline-buffer-file-name-style 'relative-from-project ;; name start from root
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
          )

    (if window-system
        (setq
         doom-modeline-icon t
         doom-modeline-major-mode-icon t
         ))

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
    ; filesize in modeline
    (remove-hook 'doom-modeline-mode-hook #'size-indication-mode)
    ;; my own modeline
    (doom-modeline-def-modeline 'ishovkun-line
      '(bar workspace-name window-number-evil matches buffer-info remote-host buffer-position word-count parrot selection-info)
      '(misc-info persp-name buffer-encoding major-mode indent-info process vcs lsp checker))

    ;; (doom-modeline-def-modeline 'ishovkun-line
    ;;   '(workspace-name window-number-evil matches buffer-info remote-host buffer-position word-count parrot selection-info)
    ;;   '(misc-info minor-modes buffer-encoding major-mode indent-info process vcs lsp checker))

    (defun setup-custom-doom-modeline ()
      (doom-modeline-set-modeline 'ishovkun-line 'default))

    (add-hook 'doom-modeline-mode-hook 'setup-custom-doom-modeline)

  ;;   (doom-modeline-def-modeline 'main
  ;; '(bar workspace-name window-number modals matches buffer-info remote-host buffer-position word-count parrot selection-info)
  ;; '(objed-state misc-info persp-name battery grip irc mu4e gnus github debug lsp minor-modes input-method indent-info buffer-encoding major-mode process vcs checker))
    ))

;;(use-package! mini-modeline
  ;;:after doom-modeline
  ;;config

    ;; (setq doom-modeline-icon nil)

  ;; (defun ivy-resize--minibuffer-setup-hook ()
  ;;   "Minibuffer setup hook."
  ;;   (add-hook 'post-command-hook #'ivy-resize--post-command-hook nil t))

  ;; (defun ivy-resize--post-command-hook ()
  ;;   "Hook run every command in minibuffer."
  ;;   (when mini-modeline-mode
  ;;     (shrink-window (1+ ivy-height))))  ; Plus 1 for the input field.

  ;; (add-hook 'minibuffer-setup-hook 'ivy-resize--minibuffer-setup-hook)
    ;;(add-hook 'mini-modeline-mode-hook 'my-setup-mini-modeline)
    ;; (mini-modeline-mode t)
  ;;)

;; evil yank to the end of line
(setq evil-want-Y-yank-to-eol t)
;; regular behavior of s
(after! evil-snipe
  (evil-snipe-mode -1)
  ;; (evil-snipe-mode)
  ;; (evil-snipe-override-mode 1)
  (add-hook 'ranger-mode-hook 'turn-off-evil-snipe-override-mode)
  (add-hook 'ranger-mode-hook 'turn-off-evil-snipe-mode)
  (add-hook 'magit-mode-hook 'turn-off-evil-snipe-override-mode))

(add-to-list 'custom-theme-load-path "~/.doom.d/themes/")
;; (load-theme 'one-dark t)
(load-theme 'nord t)
;; (load-theme 'doom-nord t)
;;
(if window-system
    (use-package! yascroll
      :config
      (setq yascroll:delay-to-hide nil)
      (add-hook 'prog-mode-hook 'yascroll-bar-mode)
      ))

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

    (ivy-posframe-mode 1)
))



;; ranger
(setq ranger-deer-show-details nil)
(setq ranger-show-hidden nil)

;; scroll one line at a time (less "jumpy" than defaults)
(setq mouse-wheel-scroll-amount '(2 ((shift) . 1))) ;; two lines at a time
(setq mouse-wheel-progressive-speed nil)            ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't)                  ;; scroll window under mouse
;; ----------------------------- c/c++ ----------------------------------
;; lsp
(after! lsp-ui
  (progn
    (setq lsp-ui-sideline-enable nil)
    (setq lsp-ui-doc-enable t)
    (setq lsp-ui-doc-position 'at-point)
    (setq lsp-ui-doc-max-width 150)
    (lsp-ui-doc-mode)
    )
  )
(after! lsp-mode
  (progn
;;     (after! lsp-clients (remhash 'clangd lsp-clients))
;;     (push 'company-lsp company-backends)
;;     (require 'cquery)
;;     ;; (set-company-backend! '(c-mode c++-mode objc-mode) 'company-lsp)
;;     ;; without this line yasnippet is fucked up
;;     (set-company-backend! '(c-mode c++-mode objc-mode) '(company-lsp company-yasnippet))
;;     (setq cquery-executable "/bin/cquery")
;;     (setq lsp-prefer-flymake nil)
;;     (with-eval-after-load 'projectile
;;       (setq projectile-project-root-files-top-down-recurring
;;             (append '("compile_commands.json"
;;                       ".cquery")
;;                     projectile-project-root-files-top-down-recurring)))
;;     (defun cquery//enable ()
;;   (condition-case nil
;;       (lsp)
;;     (user-error nil)))

;;   (use-package cquery
;;     :commands lsp
;;     :init (add-hook 'c-mode-hook #'cquery//enable)
;;           (add-hook 'c++-mode-hook #'cquery//enable))
     (setq lsp-enable-file-watchers nil)
     ;; (remhash 'clangd lsp-clients)
     (push 'company-lsp company-backends)
    ;; cquery
    ;; ;; (set-company-backend! '(c-mode c++-mode objc-mode) 'company-lsp)
    ;; ;; without this line yasnippet is fucked up
    ;; (set-company-backend! '(c-mode c++-mode) '(company-lsp company-yasnippet))
    ;; (setq cquery-executable "/usr/bin/cquery")
    ;; (setq lsp-prefer-flymake nil)

    ;; ccls
     ;; (setq ccls-sem-highlight-method 'font-lock)
     (setq ccls-executable "ccls")
    ;; (setq ccls-args '("--log-file=/tmp/ccls.log"))
     ;; https://github.com/MaskRay/Config/blob/master/home/.config/doom/modules/private/my-cc/config.el
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
     ))

;; google-c-style
(use-package! google-c-style
  :load-path "~/.doom.d/extra"
  :config (add-hook 'c-mode-common-hook 'google-set-c-style)
                 (add-hook 'c-mode-common-hook 'google-make-newline-indent))
;; disable realgud confirmations
(after! realgud (setq realgud-safe-mode 'nil))
;; (after! dap-mode (setq 'dap--debug-template-configurations 'dap-debug-template-configurations))
(setq dap--debug-template-configurations
      '(("LLDB Run Configuration" :type "lldb" :request "launch" :name "LLDB::Run" :target nil :cwd nil)
        ("GDB Run Configuration" :type "gdb" :request "launch" :name "GDB::Run" :target nil :cwd nil)))
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
  )))
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
  (add-hook 'compilation-mode-hook 'my-compilation-hook)
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
;; ----------------------------------- Shell ---------------------------------
;; --------------------------------- Fixes -----------------------------------
(setq evil-respect-visual-line-mode t)
(setq evil-move-cursor-back nil)
;; make compilation buffer stick to the frame
;; (push '("\\*compilation\\*" . (nil (reusable-frames . t))) display-buffer-alist)
(setq doom-private-dir "~/dotfiles/doom/.doom.d/")
;; (after! evil
;;   (add-to-list 'evil-emacs-state-modes 'flycheck-error-list-mode))
(after! quickrun (setq quickrun-timeout-seconds 1000))
;; really close the buffer on kill-current-buffer
;; -------------------------------- Projectile -------------------------------
(after! projectile
  (setq compilation-read-command nil)  ; no prompt in projectile-compile-project
  ;; . -> Build
  (projectile-register-project-type 'cmake '("CMakeLists.txt")
                                    :configure "cmake %s"
                                    :compile "cmake --build Debug"
                                    :test "ctest")
  (add-to-list 'projectile-globally-ignored-directories ".ccls-cache")
  )
;; (after! ivy
;;       (setq counsel-find-file-ignore-regexp "\\.o\\'"))
;; (after! ivy  (setq counsel-find-file-ignore-regexp
;;                    (my-counsel-ignore-regexp-builder
;;                     "\\`__pycache__/\\'"
;;                     (my-counsel-ignore-extensions "pyc" "elc" "so" "o"))))
(after! ivy
  (setq counsel-find-file-ignore-regexp
                   (my-counsel-ignore-regexp-builder
                    "\\`__pycache__/\\'"
                    "^.cquery"
                    "^.ccls-cache"
                    (my-counsel-ignore-extensions "pyc" "elc" "so" "o")))
  )

