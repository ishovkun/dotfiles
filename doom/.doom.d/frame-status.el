;;; frame-status.el -*- lexical-binding: t; -*-

(defvar ishovkun-frame-status-buffer " *frame-status*")
(defvar ishovkun-frame-status-message "")
(defvar ishovkun-frame-status-input "")
(defvar ishovkun-frame-status-input-point 0)
(defvar ishovkun-frame-status-source-window nil)
(defvar-local ishovkun-frame-status-face-cookie nil)
(defvar-local ishovkun-frame-status-minibuffer-face-cookie nil)
(defvar-local ishovkun-frame-status-minibuffer-overlay nil)
(defvar-local ishovkun-frame-status-saved-cursor-type nil)
(defvar-local ishovkun-frame-status-saved-cursor-local-p nil)
(defvar ishovkun-frame-status-allow-selection nil)
(defvar ishovkun-frame-status-original-command-error-function nil)

(defface ishovkun-frame-status-workspace-hover
  '((t (:inherit doom-modeline-highlight)))
  "Hover face for the workspace button.")
(defface ishovkun-frame-status-interpreter-hover
  '((t (:inherit doom-modeline-highlight)))
  "Hover face for the interpreter button.")
(defface ishovkun-frame-status-indent-hover
  '((t (:inherit doom-modeline-highlight)))
  "Hover face for the indentation button.")
(defface ishovkun-frame-status-vcs-hover
  '((t (:inherit doom-modeline-highlight)))
  "Hover face for the version-control button.")

(defconst ishovkun-frame-status-navigation-commands
  '(evil-window-left evil-window-right evil-window-up evil-window-down
    windmove-left windmove-right windmove-up windmove-down))

(defun ishovkun-frame-status--select-window (original window &rest args)
  "Make the dedicated status WINDOW non-selectable."
  (if (and (eq (window-buffer window) (get-buffer ishovkun-frame-status-buffer))
           (not ishovkun-frame-status-allow-selection)
           (memq this-command ishovkun-frame-status-navigation-commands))
      (selected-window)
    (apply original window args)))

(defun ishovkun-frame-status--restore-focus ()
  "Return focus after a mouse action in the status window."
  (when (and (eq (current-buffer) (get-buffer ishovkun-frame-status-buffer))
             (window-live-p ishovkun-frame-status-source-window))
    (let ((ishovkun-frame-status-allow-selection t))
      (select-window ishovkun-frame-status-source-window))))

(defvar ishovkun-frame-status-action-map nil)
(setq ishovkun-frame-status-action-map
      (let ((map (make-sparse-keymap)))
        (define-key map [down-mouse-1] #'ignore)
        (define-key map [mouse-1] #'ishovkun-frame-status--mouse-dispatch)
        (define-key map [mode-line down-mouse-1] #'ignore)
        (define-key map [mode-line mouse-1]
                    #'ishovkun-frame-status--mouse-dispatch)
        map))

(defun ishovkun-frame-status--buttonize (text action help hover-face)
  "Make TEXT invoke ACTION with HELP on mouse-1."
  (when (> (length text) 0)
    (add-text-properties
     0 (length text)
     `(keymap ,ishovkun-frame-status-action-map
       local-map ,ishovkun-frame-status-action-map
       ishovkun-frame-status-action ,action
       help-echo ,help
       mouse-face ,hover-face)
     text)))

(defun ishovkun-frame-status--adapt-keymaps (text)
  "Make mode-line keymaps in TEXT usable in an ordinary buffer."
  (let ((position 0))
    (while (< position (length text))
      (let* ((next (next-single-property-change position 'local-map text (length text)))
             (map (get-text-property position 'local-map text))
             (text-map (and (keymapp map) (lookup-key map [mode-line])))
             (click-map (and (keymapp text-map)
                             (ishovkun-frame-status--click-map text-map))))
        (when (keymapp text-map)
          (add-text-properties
           position next
           `(keymap ,click-map
             local-map ,click-map
             ishovkun-frame-status-mouse-map ,text-map)
           text))
        (setq position next))))
  text)

(defun ishovkun-frame-status--click-map (source-map)
  "Return an ordinary-buffer mouse map dispatching SOURCE-MAP actions."
  (let ((map (make-sparse-keymap)))
    (dolist (event '(down-mouse-1 mouse-1 down-mouse-2 mouse-2
                     down-mouse-3 mouse-3))
      (let ((binding (lookup-key source-map (vector event))))
        (when (and binding (not (numberp binding)))
          (define-key map (vector event)
                      #'ishovkun-frame-status--mouse-dispatch)
          (define-key map (vector 'mode-line event)
                      #'ishovkun-frame-status--mouse-dispatch))))
    map))

(defun ishovkun-frame-status--mouse-dispatch (event)
  "Run the Doom mode-line action at mouse EVENT in the source window."
  (interactive "e")
  (let* ((start (event-start event))
         (window (posn-window start))
         (position (posn-point start))
         (position (if (consp position) (car position) position))
         (source-map
          (and (windowp window) (integer-or-marker-p position)
               (with-current-buffer (window-buffer window)
                 (get-text-property position
                                    'ishovkun-frame-status-mouse-map))))
         (action
          (and (windowp window) (integer-or-marker-p position)
               (with-current-buffer (window-buffer window)
                 (get-text-property position
                                    'ishovkun-frame-status-action))))
         (binding (and (keymapp source-map)
                       (lookup-key source-map (vector (car event))))))
    (when (and (or action binding)
               (window-live-p ishovkun-frame-status-source-window))
      (let ((ishovkun-frame-status-allow-selection t)
            (last-input-event event))
        (with-selected-window ishovkun-frame-status-source-window
          (cond (action (call-interactively action))
                ((keymapp binding)
                 (require 'tmm)
                 (tmm-prompt binding))
                ((commandp binding) (call-interactively binding))))))))

(defun ishovkun-frame-status--indent-width-variable ()
  "Return the indentation-width variable for the current major mode."
  (or (seq-find (lambda (variable)
                  (and (boundp variable) (numberp (symbol-value variable))))
                (cdr (assq major-mode doom-modeline-indent-alist)))
      'tab-width))

(defun ishovkun-frame-status--indent-width ()
  "Return the effective indentation width in the current buffer."
  (symbol-value (ishovkun-frame-status--indent-width-variable)))

(defun ishovkun-frame-status--set-indent (width tabs)
  "Use WIDTH columns and select tabs when TABS is non-nil."
  (set (make-local-variable (ishovkun-frame-status--indent-width-variable)) width)
  (setq-local tab-width width
              indent-tabs-mode tabs)
  (ishovkun-frame-status-render))

(defun ishovkun-frame-status-select-indent ()
  "Choose indentation style and width through completion."
  (interactive)
  (let* ((current-width (ishovkun-frame-status--indent-width))
         (current (format "%d-column %s" current-width
                          (if indent-tabs-mode "tabs" "spaces")))
         (choice (completing-read
                  "Indentation: "
                  '("2-column spaces" "4-column spaces" "8-column spaces"
                    "2-column tabs" "4-column tabs" "8-column tabs"
                    "Custom width")
                  nil t nil nil current))
         (tabs (string-suffix-p "tabs" choice))
         (width (if (string= choice "Custom width")
                    (read-number "Indentation width: " current-width)
                  (string-to-number choice))))
    (ishovkun-frame-status--set-indent width tabs)))

(defun ishovkun-frame-status--python-interpreters ()
  "Return useful Python interpreter candidates for the current project."
  (let* ((root (and (fboundp 'doom-project-root) (doom-project-root)))
         (project-python (and root (expand-file-name ".venv/bin/python" root)))
         (system-pythons
          (seq-filter
           (lambda (path)
             (and (file-executable-p path)
                  (string-match-p
                   "\\`python\\(?:[0-9]+\\(?:\\.[0-9]+\\)*\\)?\\'"
                   (file-name-nondirectory path))))
           (file-expand-wildcards "/usr/bin/python*" t))))
    (delete-dups
     (delq nil
           (append (list (and project-python
                              (file-executable-p project-python)
                              project-python)
                         (executable-find python-shell-interpreter)
                         (executable-find "python3")
                         (executable-find "python"))
                   system-pythons)))))

(defun ishovkun-frame-status-select-interpreter ()
  "Choose the current buffer's Python interpreter through completion."
  (interactive)
  (if (derived-mode-p 'python-mode 'python-ts-mode)
      (let* ((candidates (ishovkun-frame-status--python-interpreters))
             (current (or (executable-find python-shell-interpreter)
                          python-shell-interpreter))
             (interpreter
              (completing-read "Python interpreter: " candidates nil t
                               nil nil current)))
        (setq-local python-shell-interpreter interpreter)
        (when (boundp 'doom-modeline-env--command)
          (setq-local doom-modeline-env--command interpreter))
        (when (fboundp 'doom-modeline-update-env)
          (doom-modeline-update-env))
        (ishovkun-frame-status-render))
    (call-interactively #'describe-mode)))

(defconst ishovkun-frame-status-left
  '(bar workspace-name window-number-evil matches buffer-info remote-host
    buffer-position word-count parrot selection-info))
(defconst ishovkun-frame-status-right
  '(misc-info persp-name buffer-encoding major-mode indent-info process vcs lsp check))

(defun ishovkun-frame-status-apply-state-faces (&rest _)
  "Turn Doom's Evil state labels into theme-colored badges."
  (let ((keyword (face-foreground 'font-lock-keyword-face nil t))
        (string (face-foreground 'font-lock-string-face nil t))
        (replace (face-foreground 'error nil t))
        (foreground (face-background 'default nil t)))
    (dolist (face '(doom-modeline-evil-normal-state doom-modeline-evil-visual-state
                    doom-modeline-evil-motion-state doom-modeline-evil-operator-state))
      (when (facep face)
        (set-face-attribute face nil :foreground foreground :background keyword)))
    (dolist (face '(doom-modeline-evil-insert-state doom-modeline-evil-emacs-state))
      (when (facep face)
        (set-face-attribute face nil :foreground foreground :background string)))
    (when (facep 'doom-modeline-evil-replace-state)
      (set-face-attribute 'doom-modeline-evil-replace-state nil
                          :foreground foreground :background replace))))

(defun ishovkun-frame-status--remap-minibuffer-background (buffer background)
  "Set BUFFER's minibuffer background to BACKGROUND."
  (with-current-buffer buffer
    (when ishovkun-frame-status-minibuffer-face-cookie
      (face-remap-remove-relative
       ishovkun-frame-status-minibuffer-face-cookie))
    (setq ishovkun-frame-status-minibuffer-face-cookie
          (face-remap-add-relative 'default `(:background ,background)))
    (when (overlayp ishovkun-frame-status-minibuffer-overlay)
      (overlay-put ishovkun-frame-status-minibuffer-overlay 'face
                   `(:foreground ,background :background ,background)))))

(defun ishovkun-frame-status-refresh-theme (&rest _)
  "Refresh all status and hidden-minibuffer colors from the active theme."
  (ishovkun-frame-status-apply-state-faces)
  (let ((background (face-background 'mode-line-active nil t)))
    (when-let ((buffer (get-buffer ishovkun-frame-status-buffer)))
      (with-current-buffer buffer
        (when ishovkun-frame-status-face-cookie
          (face-remap-remove-relative ishovkun-frame-status-face-cookie))
        (setq ishovkun-frame-status-face-cookie
              (face-remap-add-relative 'default `(:background ,background)))))
    (dolist (buffer (buffer-list))
      (when (with-current-buffer buffer (minibufferp))
        (ishovkun-frame-status--remap-minibuffer-background
         buffer background)))
    (dolist (face '(window-divider window-divider-first-pixel
                    window-divider-last-pixel))
      (when (facep face)
        (set-face-attribute face nil
                            :foreground background :background background))))
  (when (get-buffer-window ishovkun-frame-status-buffer)
    (ishovkun-frame-status-render)))

(defun ishovkun-frame-status--segments (segments)
  (mapconcat
   (lambda (segment)
     (let ((text
            (copy-sequence
             (cl-letf (((symbol-function 'doom-modeline--active) (lambda () t)))
               (format-mode-line
                `((:eval (,(intern (format "doom-modeline-segment--%s" segment))))))))))
       (ishovkun-frame-status--adapt-keymaps text)
       (pcase segment
         ((or 'workspace-name 'persp-name)
          (ishovkun-frame-status--buttonize
           text #'persp-switch "mouse-1: Switch workspace"
           'ishovkun-frame-status-workspace-hover))
         ('major-mode
          (ishovkun-frame-status--buttonize
           text #'ishovkun-frame-status-select-interpreter
           "mouse-1: Select Python interpreter"
           'ishovkun-frame-status-interpreter-hover))
         ('indent-info
          (ishovkun-frame-status--buttonize
           text #'ishovkun-frame-status-select-indent
           "mouse-1: Change indentation style and width"
           'ishovkun-frame-status-indent-hover))
         ('vcs
          (ishovkun-frame-status--buttonize
           text #'magit-branch-checkout "mouse-1: Switch Git branch"
           'ishovkun-frame-status-vcs-hover)))
       ;; Keep Doom's intentional badge backgrounds for the Evil state and
       ;; match counter; flatten only ordinary segments onto the bar face.
       (unless (memq segment '(window-number-evil matches))
         (add-face-text-property
          0 (length text)
          `(:background ,(face-background 'mode-line-active nil t)) nil text))
       text))
   segments ""))

(defun ishovkun-frame-status--input-with-cursor ()
  "Return the mirrored minibuffer input with a visible cursor at point."
  (let* ((text (copy-sequence ishovkun-frame-status-input))
         (position (min (max 0 ishovkun-frame-status-input-point)
                        (length text))))
    (if (< position (length text))
        (add-face-text-property position (1+ position) 'cursor nil text)
      (setq text (concat text (propertize " " 'face 'cursor))))
    text))

(defun ishovkun-frame-status--minibuffer-overlay-suffix ()
  "Return transient strings displayed after the minibuffer contents."
  ;; The upper bound is deliberately one past `point-max': Evil's echo
  ;; annotation is a zero-width overlay there, which ordinary overlap
  ;; queries otherwise omit.
  (let ((overlays (overlays-in (point-min) (1+ (point-max)))))
    (mapconcat
     (lambda (overlay) (or (overlay-get overlay 'after-string) ""))
     (sort overlays
           (lambda (left right)
             (< (overlay-start left) (overlay-start right))))
     "")))

(defun ishovkun-frame-status-render ()
  (let* ((candidate (or (minibuffer-selected-window) (selected-window)))
         (source (if (eq (window-buffer candidate)
                         (get-buffer ishovkun-frame-status-buffer))
                     ishovkun-frame-status-source-window candidate))
           (window (get-buffer-window ishovkun-frame-status-buffer))
           (left (with-selected-window source
                   (ishovkun-frame-status--segments ishovkun-frame-status-left)))
           (right (with-selected-window source
                    (ishovkun-frame-status--segments ishovkun-frame-status-right)))
           (middle (if (active-minibuffer-window)
                       (ishovkun-frame-status--input-with-cursor)
                     ishovkun-frame-status-message))
           (padding (max 1 (- (window-body-width window)
                              (string-width left) (string-width middle)
                              (string-width right) 2))))
      (when window
        (setq ishovkun-frame-status-source-window source)
        (with-current-buffer ishovkun-frame-status-buffer
          (let ((inhibit-read-only t))
            (erase-buffer)
            (insert left " " middle (make-string padding ?\s) right))))))

(defun ishovkun-frame-status--display-message (text)
  "Display echo-area TEXT in the status bar and suppress the echo area."
  (setq ishovkun-frame-status-message
        (if (or (null text)
                (string-match-p
                 "\\`-- \\(?:INSERT\\|NORMAL\\|VISUAL\\|REPLACE\\) --\\'"
                 text))
            ""
          text))
  (ishovkun-frame-status-render)
  t)

(defun ishovkun-frame-status--clear-message ()
  "Clear the status message without touching the echo area."
  (setq ishovkun-frame-status-message "")
  (ishovkun-frame-status-render)
  'dont-clear-message)

(defun ishovkun-frame-status--show-help (help)
  "Show HELP while the mouse is over an annotated status item."
  (setq ishovkun-frame-status-message (or help ""))
  (ishovkun-frame-status-render))

(defun ishovkun-frame-status--command-error (data context signal)
  "Route quit DATA to the status bar; delegate all other command errors."
  (if (eq (car-safe data) 'quit)
      (progn
        (setq ishovkun-frame-status-message "Quit")
        (ishovkun-frame-status-render))
    (funcall (or ishovkun-frame-status-original-command-error-function
                 #'command-error-default-function)
             data context signal)))

(defun ishovkun-frame-status--hide-mode-line ()
  "Remove the mode line from the current buffer."
  (setq-local mode-line-format nil))

(defun ishovkun-frame-status--hide-all-mode-lines ()
  "Remove per-window mode lines from existing and future buffers."
  (setq-default mode-line-format nil)
  (dolist (buffer (buffer-list))
    (when (buffer-live-p buffer)
      (with-current-buffer buffer
        (ishovkun-frame-status--hide-mode-line))))
  (force-mode-line-update t))

(defun ishovkun-frame-status--pin-window-height (window)
  "Keep the status WINDOW at one physical row."
  (window-preserve-size window nil nil)
  (with-current-buffer (window-buffer window)
    (setq-local truncate-lines t
                window-size-fixed nil))
  (let* ((window-resize-pixelwise t)
         (row-height (with-selected-window window (line-pixel-height)))
         (target-height (+ row-height (window-bottom-divider-width window)))
         (delta (- target-height (window-pixel-height window))))
    (unless (zerop delta)
      (window-resize window delta nil t t)))
  (with-current-buffer (window-buffer window)
    (setq-local window-size-fixed 'height))
  (window-preserve-size window nil t))

(defun ishovkun-frame-status--input-update (&rest _)
  (let ((contents (buffer-substring-no-properties (point-min) (point-max))))
    (setq ishovkun-frame-status-input-point (- (point) (point-min))
          ishovkun-frame-status-input
          (concat contents
                  (ishovkun-frame-status--minibuffer-overlay-suffix))))
  (when (overlayp ishovkun-frame-status-minibuffer-overlay)
    (move-overlay ishovkun-frame-status-minibuffer-overlay
                  (point-min) (point-max) (current-buffer)))
  (ishovkun-frame-status-render))

(defun ishovkun-frame-status--minibuffer-setup ()
  (unless (overlayp ishovkun-frame-status-minibuffer-overlay)
    (setq-local ishovkun-frame-status-saved-cursor-local-p
                (local-variable-p 'cursor-type)
                ishovkun-frame-status-saved-cursor-type cursor-type
                ishovkun-frame-status-minibuffer-overlay
                (make-overlay (point-min) (point-max) nil nil t))
    (overlay-put ishovkun-frame-status-minibuffer-overlay 'priority 1001)
    (overlay-put ishovkun-frame-status-minibuffer-overlay 'face
                 `(:foreground ,(face-background 'mode-line-active nil t)
                   :background ,(face-background 'mode-line-active nil t))))
  (ishovkun-frame-status--remap-minibuffer-background
   (current-buffer) (face-background 'mode-line-active nil t))
  (setq-local cursor-type nil)
  (add-hook 'after-change-functions #'ishovkun-frame-status--input-update nil t)
  (add-hook 'post-command-hook #'ishovkun-frame-status--input-update nil t)
  (ishovkun-frame-status--input-update))

(defun ishovkun-frame-status--evil-ex-echo-update (&rest _)
  "Mirror Evil's transient Ex/search annotation after it is displayed."
  (when-let ((window (active-minibuffer-window)))
    (with-current-buffer (window-buffer window)
      (ishovkun-frame-status--input-update))))

(defun ishovkun-frame-status--minibuffer-exit ()
  (when (overlayp ishovkun-frame-status-minibuffer-overlay)
    (delete-overlay ishovkun-frame-status-minibuffer-overlay)
    (setq ishovkun-frame-status-minibuffer-overlay nil))
  (if ishovkun-frame-status-saved-cursor-local-p
      (setq-local cursor-type ishovkun-frame-status-saved-cursor-type)
    (kill-local-variable 'cursor-type))
  (setq ishovkun-frame-status-input ""
        ishovkun-frame-status-input-point 0)
  (run-at-time 0 nil #'ishovkun-frame-status-render))

(defun ishovkun-frame-status-enable ()
  (remove-hook 'enable-theme-functions #'ishovkun-frame-status-apply-state-faces)
  (add-hook 'enable-theme-functions #'ishovkun-frame-status-refresh-theme)
  (let ((buffer (get-buffer-create ishovkun-frame-status-buffer)))
    (with-current-buffer buffer
      (setq-local mode-line-format nil cursor-type nil buffer-read-only t))
    (let ((window (display-buffer-in-side-window
                   buffer '((side . bottom) (slot . -100) (window-height . 1)))))
      (set-window-dedicated-p window t)
      (set-window-parameter window 'no-other-window t)
      (ishovkun-frame-status--pin-window-height window)))
  (ishovkun-frame-status--hide-all-mode-lines)
  (add-hook 'after-change-major-mode-hook
            #'ishovkun-frame-status--hide-mode-line 100)
  (advice-add #'select-window :around #'ishovkun-frame-status--select-window)
  (add-hook 'post-command-hook #'ishovkun-frame-status-render)
  (add-hook 'post-command-hook #'ishovkun-frame-status--restore-focus 100)
  (add-hook 'minibuffer-setup-hook #'ishovkun-frame-status--minibuffer-setup)
  (add-hook 'minibuffer-exit-hook #'ishovkun-frame-status--minibuffer-exit)
  (when (boundp 'doom-modeline-after-update-env-hook)
    (add-hook 'doom-modeline-after-update-env-hook
              #'ishovkun-frame-status-render))
  (advice-remove #'message #'ishovkun-frame-status--message)
  (add-hook 'set-message-functions
            #'ishovkun-frame-status--display-message -100)
  (setq clear-message-function #'ishovkun-frame-status--clear-message
        show-help-function #'ishovkun-frame-status--show-help)
  (unless (eq command-error-function #'ishovkun-frame-status--command-error)
    (setq ishovkun-frame-status-original-command-error-function
          command-error-function))
  (setq command-error-function #'ishovkun-frame-status--command-error)
  (when (fboundp 'evil-ex-echo)
    (advice-add #'evil-ex-echo :after
                #'ishovkun-frame-status--evil-ex-echo-update))
  (ishovkun-frame-status-refresh-theme))

(provide 'frame-status)
