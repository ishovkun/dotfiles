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
(defvar ishovkun-frame-status--ensuring-window nil)
(defvar ishovkun-frame-status--pinning-window nil)
(defvar ishovkun-frame-status--render-timer nil)
(defconst ishovkun-frame-status-text-raise -0.12
  "Display raise that optically centers status text in its row.")

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

(defun ishovkun-frame-status--top-level-frame (&optional frame)
  "Return the top-level editor frame containing FRAME."
  (let ((frame (or frame (selected-frame))))
    (while (frame-parent frame)
      (setq frame (frame-parent frame)))
    frame))

(defun ishovkun-frame-status--remove-popup-windows ()
  "Remove status windows accidentally created inside child frames."
  (dolist (frame (frame-list))
    (when (frame-parent frame)
      (when-let ((window (get-buffer-window ishovkun-frame-status-buffer frame)))
        (delete-window window)))))

(defun ishovkun-frame-status--tab-font-size-face ()
  "Return status text metrics matching the native tab bar."
  ;; Resolve the tab bar's relative height against `default'.  An absolute
  ;; height takes precedence over Doom's nested relative face heights instead
  ;; of multiplying with them at non-default UI scales.
  (let ((height (face-attribute 'tab-line :height nil 'default)))
    (unless (eq height 'unspecified)
      `(:height ,height))))

(defun ishovkun-frame-status--apply-tab-font-size (text face)
  "Return a copy of TEXT using the tab-bar height in FACE."
  (let ((text (copy-sequence (or text ""))))
    (when (> (length text) 0)
      (add-face-text-property 0 (length text) face nil text))
    text))

(defun ishovkun-frame-status--center-text-baseline (start end)
  "Optically center ordinary status text between START and END."
  ;; `raise' is a display spec, not a face attribute.  Add it only to ordinary
  ;; text runs so image glyphs, Nerd Font icons, and alignment spaces retain
  ;; their own `display' properties.
  (let ((position start))
    (while (< position end)
      (let ((next (next-single-property-change
                   position 'display nil end)))
        (unless (get-text-property position 'display)
          (add-text-properties
           position next
           `(display (raise ,ishovkun-frame-status-text-raise))))
        (setq position next)))))

(defun ishovkun-frame-status--single-line (text)
  "Return TEXT with whitespace collapsed onto one display line."
  (when text
    (string-trim
     (replace-regexp-in-string "[[:space:]]+" " " (format "%s" text)))))

(defun ishovkun-frame-status--remove-line-breaks (text)
  "Return a copy of TEXT with line breaks replaced by spaces.
Unlike `ishovkun-frame-status--single-line', preserve text properties such as
the fake minibuffer cursor."
  (let ((text (copy-sequence (or text ""))))
    (subst-char-in-string ?\n ?\s text t)
    (subst-char-in-string ?\r ?\s text t)
    text))

(defun ishovkun-frame-status--truncate-pixels (text width face)
  "Truncate TEXT with an ellipsis so it occupies at most WIDTH pixels."
  (cond
   ((<= width 0) "")
   ((<= (string-pixel-width text) width) text)
   (t
    (let* ((ellipsis
            (ishovkun-frame-status--apply-tab-font-size "…" face))
           (budget (- width (string-pixel-width ellipsis))))
      (if (<= budget 0)
          ""
        (let ((low 0)
              (high (length text)))
          (while (< low high)
            (let ((middle (/ (+ low high 1) 2)))
              (if (<= (string-pixel-width (substring text 0 middle)) budget)
                  (setq low middle)
                (setq high (1- middle)))))
          (concat (substring text 0 low) ellipsis)))))))

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
  '(bar workspace-name fancy-modals matches remote-host
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
  (when-let ((window (get-buffer-window ishovkun-frame-status-buffer)))
    (ishovkun-frame-status-render)
    (ishovkun-frame-status--pin-window-height window)))

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
       (unless (memq segment '(fancy-modals matches))
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
         (frame (ishovkun-frame-status--top-level-frame
                 (window-frame source)))
         (window (or (get-buffer-window ishovkun-frame-status-buffer
                                        frame)
                     (ishovkun-frame-status--ensure-window frame))))
    (when (and (window-live-p window) (window-live-p source))
      (let* ((size-face (ishovkun-frame-status--tab-font-size-face))
             (left
              (ishovkun-frame-status--apply-tab-font-size
               (with-selected-window source
                 (ishovkun-frame-status--segments
                  ishovkun-frame-status-left))
               size-face))
             (right
              (ishovkun-frame-status--apply-tab-font-size
               (with-selected-window source
                 (ishovkun-frame-status--segments
                  ishovkun-frame-status-right))
               size-face))
             (middle-full
              (ishovkun-frame-status--apply-tab-font-size
               ;; Help display can transiently make Emacs report an active
               ;; minibuffer.  Enforce one physical line after choosing the
               ;; input/message branch so neither path can bypass it.
               (ishovkun-frame-status--remove-line-breaks
                (if (active-minibuffer-window)
                    (ishovkun-frame-status--input-with-cursor)
                  (ishovkun-frame-status--single-line
                   ishovkun-frame-status-message)))
               size-face))
             (separator (propertize " " 'face size-face))
             (right-width (string-pixel-width right))
             (middle-width
              (max 0 (- (window-body-width window t)
                        (string-pixel-width left)
                        (string-pixel-width separator)
                        ;; Preserve a visible gap before the right section.
                        (string-pixel-width separator)
                        right-width)))
             (middle
              (ishovkun-frame-status--truncate-pixels
               middle-full middle-width size-face))
             (right-spacer
              (propertize
               " "
               'face size-face
               'display `(space :align-to (- right (,right-width))))))
        (setq ishovkun-frame-status-source-window source)
        (with-current-buffer ishovkun-frame-status-buffer
          (let ((inhibit-read-only t))
            (erase-buffer)
            ;; A pixel-valued display spacer remains exact when the shared
            ;; tab/status font scale changes.  Character-column padding does
            ;; not, because it is measured before those faces are rendered.
            (insert left separator middle right-spacer right)
            ;; Measure the natural line before lowering the glyphs.  A
            ;; negative display raise otherwise expands the line by the same
            ;; number of pixels it moves the text, defeating the centering.
            (set-window-parameter
             window 'ishovkun-frame-status-row-height
             (cdr (window-text-pixel-size
                   window (point-min) (point-max))))
            (ishovkun-frame-status--center-text-baseline
             (point-min) (point-max))))))))

(defun ishovkun-frame-status--run-deferred-render ()
  "Render after a help/redisplay callback has returned to the event loop."
  (setq ishovkun-frame-status--render-timer nil)
  (ishovkun-frame-status-render)
  (when-let ((window (get-buffer-window ishovkun-frame-status-buffer)))
    (force-window-update window)))

(defun ishovkun-frame-status--schedule-render ()
  "Schedule one coalesced status render for the next event-loop pass."
  (when (timerp ishovkun-frame-status--render-timer)
    (cancel-timer ishovkun-frame-status--render-timer))
  (setq ishovkun-frame-status--render-timer
        (run-at-time 0 nil #'ishovkun-frame-status--run-deferred-render)))

(defun ishovkun-frame-status--display-message (text)
  "Display echo-area TEXT in the status bar and suppress the echo area."
  (setq ishovkun-frame-status-message
        (if (or (null text)
                (string-match-p
                 "\\`-- \\(?:INSERT\\|NORMAL\\|VISUAL\\|REPLACE\\) --\\'"
                 text))
            ""
          (ishovkun-frame-status--single-line text)))
  (ishovkun-frame-status-render)
  t)

(defun ishovkun-frame-status--clear-message ()
  "Clear the status message without touching the echo area."
  (setq ishovkun-frame-status-message "")
  (ishovkun-frame-status-render)
  'dont-clear-message)

(defun ishovkun-frame-status--show-help (help)
  "Show HELP while the mouse is over an annotated status item."
  (setq ishovkun-frame-status-message
        (or (ishovkun-frame-status--single-line help) ""))
  ;; `show-help-function' runs as part of Emacs's own help redisplay.  Writing
  ;; the status buffer synchronously there can leave the window showing a
  ;; stale partial frame even though the buffer contents are already correct.
  (ishovkun-frame-status--schedule-render))

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
  (when (and (window-live-p window)
             (not ishovkun-frame-status--pinning-window))
    (let ((ishovkun-frame-status--pinning-window t))
      ;; Resizing fires `window-configuration-change-hook', which can call us
      ;; again.  The guard prevents nested preserve/resize operations while a
      ;; UI font-scale command is changing the row's pixel height.
      (condition-case nil
          (progn
            (window-preserve-size window nil nil)
            (with-current-buffer (window-buffer window)
              (setq-local truncate-lines t
                          window-size-fixed nil))
            (let* ((window-resize-pixelwise t)
                   (row-height
                    (or (window-parameter
                         window 'ishovkun-frame-status-row-height)
                        (with-selected-window window (line-pixel-height))))
                   (target-height
                    (+ row-height (window-bottom-divider-width window)))
                   (delta (- target-height (window-pixel-height window))))
              (unless (zerop delta)
                (window-resize window delta nil t t))))
        (error nil))
      (when (window-live-p window)
        (with-current-buffer (window-buffer window)
          (setq-local window-size-fixed 'height))
        (window-preserve-size window nil t)))))

(defun ishovkun-frame-status--ensure-window (&optional frame)
  "Restore the frame status window if a saved window layout removed it."
  (setq frame (ishovkun-frame-status--top-level-frame frame))
  (when (and (frame-live-p frame)
             (display-graphic-p frame)
             (not ishovkun-frame-status--ensuring-window))
    (let ((ishovkun-frame-status--ensuring-window t)
          (window (get-buffer-window ishovkun-frame-status-buffer frame)))
      (ishovkun-frame-status--remove-popup-windows)
      (unless (window-live-p window)
        (let ((buffer (get-buffer-create ishovkun-frame-status-buffer)))
          (with-current-buffer buffer
            (setq-local mode-line-format nil
                        cursor-type nil
                        buffer-read-only t))
          (with-selected-frame frame
            (setq window
                  (display-buffer-in-side-window
                   buffer
                   '((side . bottom) (slot . -100) (window-height . 1)))))))
      (when (window-live-p window)
        (set-window-dedicated-p window t)
        (set-window-parameter window 'no-other-window t)
        (ishovkun-frame-status--pin-window-height window))
      ;; Doom's session restoration can restore its default mode line at the
      ;; same time that it replaces the window configuration.
      (unless (null (default-value 'mode-line-format))
        (ishovkun-frame-status--hide-all-mode-lines))
      window)))

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
  (remove-hook 'enable-theme-functions #'ishovkun-frame-status-refresh-theme)
  (add-hook 'enable-theme-functions #'ishovkun-frame-status-refresh-theme 110)
  (ishovkun-frame-status--ensure-window)
  (ishovkun-frame-status--hide-all-mode-lines)
  (add-hook 'after-change-major-mode-hook
            #'ishovkun-frame-status--hide-mode-line 100)
  (add-hook 'window-configuration-change-hook
            #'ishovkun-frame-status--ensure-window 100)
  (add-hook 'window-setup-hook #'ishovkun-frame-status--ensure-window 100)
  (add-hook 'emacs-startup-hook #'ishovkun-frame-status--ensure-window 100)
  (when (boundp 'doom-after-init-hook)
    (add-hook 'doom-after-init-hook #'ishovkun-frame-status--ensure-window 100))
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
