;;; ~/.doom.d/autoload.el -*- lexical-binding: t; -*-

;;;###autodef
(defun spacemacs/alternate-buffer (&optional window)
  "Switch back and forth between current and last buffer in the
current window."
  (interactive)
  (let ((current-buffer (window-buffer window)))
    ;; if no window is found in the windows history, `switch-to-buffer' will
    ;; default to calling `other-buffer'.
    (switch-to-buffer
     (cl-find-if (lambda (buffer)
                   (not (eq buffer current-buffer)))
                 (mapcar #'car (window-prev-buffers window)))
     nil t)))
;;;###autodef
(defun switch-to-messages-buffer (&optional arg)
  "Switch to the `*Compilation*' buffer.
if prefix argument ARG is given, switch to it in an other, possibly new window."
  (interactive "P")
  (with-current-buffer (get-buffer "*Messages*")
    (goto-char (point-max))
    (if arg
        (switch-to-buffer-other-window (current-buffer))
      (switch-to-buffer (current-buffer)))))
;;;###autodef
(defun switch-to-compilation-buffer (&optional arg)
  "Switch to the `*Compilation*' buffer.
if prefix argument ARG is given, switch to it in an other, possibly new window."
  (interactive "P")
  (with-current-buffer (get-buffer "*compilation*")
    (goto-char (point-max))
    (if arg
        (switch-to-buffer-other-window (current-buffer))
      (switch-to-buffer (current-buffer)))))
;;;###autodef
  (defun switch-to-eshell-buffer (&optional arg)
    "Switch to the `*Compilation*' buffer.
if prefix argument ARG is given, switch to it in an other, possibly new window."
    (interactive "P")
    (with-current-buffer (get-buffer "*eshell*")
      (goto-char (point-max))
      (if arg
          (switch-to-buffer-other-window (current-buffer))
        (switch-to-buffer (current-buffer)))))
;;;###autodef
  (defun switch-to-shell-buffer (&optional arg)
    "Switch to the `*Shell*' buffer.
if prefix argument ARG is given, switch to it in an other, possibly new window."
    (interactive "P")
    (with-current-buffer (get-buffer "*shell*")
      (goto-char (point-max))
      (if arg
          (switch-to-buffer-other-window (current-buffer))
        (switch-to-buffer (current-buffer)))))
;;;###autodef
(defun true-color-p ()
      "Return non-nil on displays that support 256 colors."
      (or
        (display-graphic-p)
        (= (tty-display-color-cells) 16777216)))

;; BEGIN align functions
;;;###autodef
(defun align-repeat (start end regexp &optional justify-right after)
  "Repeat alignment with respect to the given regular expression.
If JUSTIFY-RIGHT is non nil justify to the right instead of the
left. If AFTER is non-nil, add whitespace to the left instead of
the right."
  (interactive "r\nsAlign regexp: ")
  (let* ((ws-regexp (if (string-empty-p regexp)
                        "\\(\\s-+\\)"
                      "\\(\\s-*\\)"))
         (complete-regexp (if after
                              (concat regexp ws-regexp)
                            (concat ws-regexp regexp)))
         (group (if justify-right -1 1)))

    (unless (use-region-p)
      (save-excursion
        (while (and
                (string-match-p complete-regexp (thing-at-point 'line))
                (= 0 (forward-line -1)))
          (setq start (point-at-bol))))
      (save-excursion
        (while (and
                (string-match-p complete-regexp (thing-at-point 'line))
                (= 0 (forward-line 1)))
          (setq end (point-at-eol)))))

    (align-regexp start end complete-regexp group 1 t)))

;;;###autodef
(defun align-repeat-decimal (start end)
  "Align a table of numbers on decimal points and dollar signs (both optional)"
  (interactive "r")
  (require 'align)
  (align-region start end nil
                '((nil (regexp . "\\([\t ]*\\)\\$?\\([\t ]+[0-9]+\\)\\.?")
                       (repeat . t)
                       (group 1 2)
                       (spacing 1 1)
                       (justify nil t)))
                nil))

(defmacro create-align-repeat-x (name regexp &optional justify-right default-after)
  (let ((new-func (intern (concat "align-repeat-" name))))
    `(defun ,new-func (start end switch)
       (interactive "r\nP")
       (let ((after (not (eq (if switch t nil) (if ,default-after t nil)))))
         (align-repeat start end ,regexp ,justify-right after)))))

(create-align-repeat-x "comma" "," nil t)
(create-align-repeat-x "semicolon" ";" nil t)
(create-align-repeat-x "colon" ":" nil t)
(create-align-repeat-x "equal" "=")
(create-align-repeat-x "math-oper" "[+\\-*/]")
(create-align-repeat-x "percent" "%")
(create-align-repeat-x "ampersand" "&")
(create-align-repeat-x "bar" "|")
(create-align-repeat-x "left-paren" "(")
(create-align-repeat-x "right-paren" ")" t)
(create-align-repeat-x "left-curly-brace" "{")
(create-align-repeat-x "right-curly-brace" "}" t)
(create-align-repeat-x "left-square-brace" "\\[")
(create-align-repeat-x "right-square-brace" "\\]" t)
(create-align-repeat-x "backslash" "\\\\")
;; END align functions

;;;###autodef
(defun duplicate-and-comment-line()
  (interactive)
  (move-beginning-of-line 1)
  (let ((oldpos (point)))
    (kill-line)
    (yank)
    (move-end-of-line 1)
    (let ((newpos (point)))
        (evil-commentary-line oldpos newpos)
        (open-line 1)
        (next-line 1)
        (yank)
    )
  )
)

;;;###autodef
;; (defun duplicate-and-comment-region(beg end)
;;   (interactive)
;;   ;; (kill beg end)
;;   ;; (yank)
;;   (evil-commentary beg end)
;;   (yank)
;;   )

;;;###autodef
(defun my-compilation-hook ()
  ;; the last 1 is to search all frames
  (when (not (get-buffer-window "*compilation*" 1))
    (save-selected-window
      (save-excursion
        (let* ((w (if (> (length (window-list)) 1)
                      (next-window)
                    (split-window-horizontally))
               ))
          (select-window w)
          (switch-to-buffer "*compilation*")
          )))))

;;;###autodef
(defun rename-file-and-buffer ()
  "Rename the current buffer and file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer is not visiting a file!")
      (let ((new-name (read-file-name "New name: " filename)))
        (cond
         ((vc-backend filename) (vc-rename-file filename new-name))
         (t
          (rename-file filename new-name t)
          (set-visited-file-name new-name t t)))))))
;;;###autodef
(defun my-counsel-ignore-extensions (&rest extensions)
  (format "\\`.*\\.\\(?:%s\\)\\'" (string-join extensions "\\|")))

;;;###autodef
(defun my-counsel-ignore-regexp-builder (&rest regexp-units)
  (mapconcat
   (lambda (unit)
     (format "\\(?:%s\\)" unit))
   regexp-units
   "\\|"))
;;;###autodef
(defun latex/build ()
  (interactive)
  (progn
    (let ((TeX-save-query nil))
      (TeX-save-document (TeX-master-file)))
    (TeX-command TeX-command-default 'TeX-master-file -1)))
    ;; (setq build-proc (TeX-command latex-build-command 'TeX-master-file -1))
    ;; ;; Sometimes, TeX-command returns nil causing an error in set-process-sentinel
    ;; (when build-proc
    ;;   (set-process-sentinel build-proc 'latex//build-sent
;;;###autodef
(defun copy-buffer-file-name-to-clipboard ()
  "Copies the buffer file name to the clipboard"
  (interactive)
  (let ((buf-name (buffer-file-name)))
    (if buf-name
        (with-temp-buffer
          (insert buf-name)
          (copy-region-as-kill (point-min) (point-max))
          (message "Copied %s to clipboard" buf-name))
      (message "Your buffer is not backed by a file"))))

;;;###autodef
(defun centaur-tabs-select-visible-1st-tab ()
  "Selects first centaur tab"
  (interactive)
  (centaur-tabs-select-visible-nth-tab 1))
;;;###autodef
(defun centaur-tabs-select-visible-2nd-tab ()
  "Selects second centaur tab"
  (interactive)
  (centaur-tabs-select-visible-nth-tab 2))
;;;###autodef
(defun centaur-tabs-select-visible-3rd-tab ()
  "Selects third centaur tab"
  (interactive)
  (centaur-tabs-select-visible-nth-tab 3))
;; ;;;###autodef
;; (defun setup-custom-doom-modeline ()
;;       (doom-modeline-set-modeline 'ishovkun-line 'default))
