;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; place your private configuration here
(setq doom-font (font-spec :family "Iosevka SS04" :size 15))
(when (string= (system-name) "space")
  ;; different scaling
  (setq doom-font (font-spec :family "Iosevka SS04" :size 31)))

(map!
  ;; window management
 (:map override
  :nv "M-k"         #'evil-window-up
  :nv "M-j"         #'evil-window-down
  :nv "M-l"         #'evil-window-right
  :nv "M-h"         #'evil-window-left)
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
  :nv "S"           #'evil-snipe-s
  (:map compilation-mode-map :desc "evil backward char" :nv "h" #'evil-backward-char)
  (:after avy :nv "g s"         #'evil-avy-goto-char-timer)
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
    (:after lsp-ui :map prog-mode-map
      :desc "Find references" :n "r" #'lsp-find-references)
    (:map override :desc "Copy and comment" :nv "y" #'duplicate-and-comment-line)
  ) ; end prefix g
  (:after projectile :map prog-mode-map :desc "Recompile" :nv "<C-return>" #'recompile)
  (:after tex :map LaTeX-mode-map :desc "Recompile" :nv "<C-return>" #'latex/build)
  ;; ivy
  (:after ivy :map ivy-mode-map
    :desc "Kill buffer" "C-d" #'ivy-switch-buffer-kill)
  ;; org
  (:after org :map org-mode-map
    :desc "Preview LaTeX" :niv "<M-return>" #'org-latex-preview)
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
    :desc "kill current buffer"          :nv "d" #'kill-current-buffer
    :desc "switch to compilation buffer" :nv "c" #'switch-to-compilation-buffer
    :desc "switch to messages buffer"    :nv "m" #'switch-to-messages-buffer
    :desc "switch buffer"                :nv "b" #'+ivy/switch-buffer
    )
  ;; files
  (:prefix "f"
    (:desc "Rename file" :nv "R" #'rename-file-and-buffer)
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
    )
  ;; compile
  (:prefix "c"
    :desc "recompile" :n "r" #'recompile
  )
  ;; toggles
  (:prefix "t"
    :desc "toggle line wrap" :n "L" #'toggle-truncate-lines
  )
  ;; debugging
  (:prefix "o" (:after realgud
   :desc "toggle debug shortcuts" :n "k" #'realgud-short-key-mode)
   :desc "Open vterm" :n "t" #'+vterm/here
    )
) ; end map leader
;; ------------------------------ GUI -----------------------------------------
;; tweaks
(setq display-line-numbers-type 'relative)
;; (setq confirm-kill-emacs)
(setq confirm-kill-emacs nil)

;; set modes
(after! doom-modeline
  (progn
    (winum-mode)
    ;; (doom-modeline-set-modeline 'minimal)
    (setq doom-modeline-height 10
        ;; shorter buffer names
        doom-modeline-buffer-file-name-style 'buffer-name
        ;; show icons
        doom-modeline-icon t
        ;; Whether display color icons for `major-mode'. It respects
        ;; `doom-modeline-icon' and `all-the-icons-color-icons'.
        doom-modeline-major-mode-icon t
        ;; If non-nil, a word count will be added to the selection-info modeline segment.
        doom-modeline-enable-word-count nil
    )
    (doom-modeline-def-segment window-number
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
    ))

;; add face for function call
(defface font-lock-method-call-face
  '((t . (:foreground "orangered" :bold t)))
  "Face to display method calls in.")
(font-lock-add-keywords 'c++-mode
                        `((,(concat
                              "\\<[_a-zA-Z][_a-zA-Z0-9]*\\>"       ; Object identifier
                              "\\s *"                              ; Optional white space
                              "\\(?:\\.\\|->\\)"                   ; Member access
                              "\\s *"                              ; Optional white space
                              "\\<\\([_a-zA-Z][_a-zA-Z0-9]*\\)\\>" ; Member identifier
                              "\\s *"                              ; Optional white space
                              "(")                                 ; Paren for method invocation
                            1 'font-lock-method-call-face t)))

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
(load-theme 'one-dark t)
;; (load-theme 'nord t)

;; postframe
(if window-system (progn
    (require 'ivy-posframe)
    ;; display at `ivy-posframe-style'
    (setq ivy-posframe-parameters
      '((left-fringe . 20)
        (right-fringe . 20)
        ))
    (setq ivy-posframe-display-functions-alist
      '((swiper          . nil)
        (counsel-ag      . nil)
        (complete-symbol . ivy-posframe-display-at-point)
        (t               . ivy-posframe-display-at-frame-center))
      )

    (ivy-posframe-mode 1)
    (setq ivy-posframe-border-width 2)
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
(setq lsp-ui-sideline-enable nil)
(setq lsp-ui-doc-enable t)
(setq lsp-ui-doc-position 'at-point)
(setq lsp-ui-doc-max-width 150)
(after! lsp-ui (lsp-ui-doc-mode))
(after! lsp
  (progn
    (remhash 'clangd lsp-clients)
    (push 'company-lsp company-backends)
    (require 'cquery)
    ;; (set-company-backend! '(c-mode c++-mode objc-mode) 'company-lsp)
    ;; without this line yasnippet is fucked up
    (set-company-backend! '(c-mode c++-mode objc-mode) '(company-lsp company-yasnippet))
    (setq cquery-executable "/usr/bin/cquery")
    (setq lsp-prefer-flymake nil)
    )
  )
(require 'dap-lldb)
;; google-c-style
(load "~/.doom.d/google-c-style.el")
(require 'google-c-style)
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)
;; (use-package google-c-style
;;   :config (progn (add-hook 'c-mode-common-hook 'google-set-c-style)
;;                  (add-hook 'c-mode-common-hook 'google-make-newline-indent)))
;; disable realgud confirmations
(after! realgud (setq realgud-safe-mode 'nil))
;; (after! dap-mode (setq 'dap--debug-template-configurations 'dap-debug-template-configurations))
(setq dap--debug-template-configurations
      '(("LLDB Run Configuration" :type "lldb" :request "launch" :name "LLDB::Run" :target nil :cwd nil)
        ("GDB Run Configuration" :type "gdb" :request "launch" :name "GDB::Run" :target nil :cwd nil)))
;; --------------------------------- autocomplete ----------------------------
;; (use-package company-box :hook (company-mode . company-box-mode))
;; ----------------------------------- Deft ----------------------------------
(setq deft-directory "~/Dropbox/enotes")
(setq deft-extensions '("org" "md"))
(setq deft-auto-save-interval 60.0)
(setq deft-use-filename-as-title nil)
(setq deft-use-filter-string-for-filename t)
(setq deft-file-naming-rules
      '((noslash . "-")
        (nospace . "-")
        (case-fn . downcase)))
;; ----------------------------------- Org ----------------------------------
(after! org
  (progn
    (setq org-directory "~/Dropbox/enotes")
    (when (string= (system-name) "space")
      (setq org-format-latex-options (plist-put org-format-latex-options :scale 3.0))
  )))
;; ----------------------------------- LaTeX ---------------------------------
(setq +latex-viewers '(okular))
;; --------------------------------- Compile ---------------------------------
(add-hook 'compilation-mode-hook 'my-compilation-hook)
;; truncate lines in compilation mode
(defun compilation-mode-hook-trucate-lines ()
  (setq truncate-lines nil) ;; automatically becomes buffer local
  (set (make-local-variable 'truncate-partial-width-windows) nil))
(add-hook 'compilation-mode-hook 'compilation-mode-hook-trucate-lines)
;; ------------------------- evil-commentary ---------------------------------
(require 'evil-commentary)
;; ----------------------------------- Shell ---------------------------------
;; --------------------------------- Fixes -----------------------------------
(setq evil-move-cursor-back nil)
;; make compilation buffer stick to the frame
(push '("\\*compilation\\*" . (nil (reusable-frames . t))) display-buffer-alist)
(setq doom-private-dir "~/dotfiles/doom/.doom.d/")

;; -------------------------------- Projectile -------------------------------
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
                    (my-counsel-ignore-extensions "pyc" "elc" "so" "o")))
  )


;; (setq +doom-dashboard--width 100)
;; (defun doom-dashboard-widget-banner ()
;;   (let ((point (point)))
;;     (mapc (lambda (line)
;;             (insert (propertize (+doom-dashboard--center +doom-dashboard--width line)
;;                                 'face 'font-lock-comment-face) " ")
;;             (insert "\n"))
;;           '(
;;             ;; "=================     ===============     ===============   ========  ========"
;; "                                       ,"
;; "                                      , `."
;; "                                       |   `."
;; "                                      `     `."
;; "                                        \\___   \  "
;; "                             ,---._   ,'   -`./"
;; "                          ,-\"    \"-/ /    o `._"
;; "                           `.         |  o ,-.  _ `"
;; "                             `.       ,  , `-' ,'  `"
;; "                               `----- | '`----\"    |"
;; "                                      \\       /    |"
;; "                                       \\           \""
;; "                                        `.        /_"
;; "                 .--,                     `._   _/| \ "
;; "  .-.    __,,,__/    |                    (  \".  '  \ "
;; "..  . /   \\-'`        `-./_                        \\   '.'.  . "
;; ".. |    |               `)                    |`    \"  | \\ "
;; " \\    `            `\\  ;                  | `.   `.,' ."
;; ". /       ,       ,     |                    |   `.   \  |"
;; ".  |      /     :   O /_                    |    ,`   | |"
;; " |          O  .--;__      '.                  |    `-`-\"  ,"
;; " |                (  )`.  |                 `          ,"
;; "\\                 `-` /  |                 `.     _,'"
;; " \\          ,_  _.-./`  /                     `.--\" |"
;; " .  .  \\        \\''-.(    |                        | || |  .-."
;; "..   |           '---'   /--.                      | |, `,'"
;; " ,--\\___..__          _.'   /--.            ___,' \       ,"
;; " \\          `-._  _`'/     '    '.         /      /------\" "
;; " .-' ` ' .       ``     '                  \\____,'"
;;      ))
;;     (when (and (stringp +doom-dashboard-banner-file)
;;                (display-graphic-p)
;;                (file-exists-p! +doom-dashboard-banner-file +doom-dashboard-banner-dir))
;;       (let* ((image (create-image (expand-file-name +doom-dashboard-banner-file
;;                                                     +doom-dashboard-banner-dir)
;;                                   'png nil))
;;              (size (image-size image nil))
;;              (margin (+ 1 (/ (- +doom-dashboard--width (car size)) 2))))
;;         (add-text-properties
;;          point (point) `(display ,image rear-nonsticky (display)))
;;         (when (> margin 0)
;;           (save-excursion
;;             (goto-char point)
;;             (insert (make-string (truncate margin) ? )))))
;;       (insert (make-string (or (cdr +doom-dashboard-banner-padding) 0) ?\n)))))
