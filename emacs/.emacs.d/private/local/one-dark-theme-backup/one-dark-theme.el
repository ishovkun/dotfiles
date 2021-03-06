;; This file is not part of Emacs.

(deftheme one-dark)
(let ((class '((class color) (min-colors 89)))
      (bg1 "#282c34")       ;; main background
      (bg2 "#2c323c")       ;; lighter than main
      (bg3 "#21252b")       ;; darker than main background
      (bg4 "#01657f")
      (fg1 "#abb2bf")
      (fg2 "#ffffff")
      (fg3 "#4da089")
      (fg4 "#d66083")
      (key2 "#728e25")
      (key3 "#20db65")      ;; bright green
      (builtin "#c678dd")   ;; magenta
      ;; (builtin "#7ba7ee")   ;; bluish with tint of magenta
      (keyword "#51afef")   ;; blue
      (const   "#a9a1e1")
      ;; (const   "#7ba7ee")
      (comment "#5B6268")
      (func    "#c586d8")   ;; magenta
      (str     "#98be65")   ;; light green
      (type    "#46D9FF")   ;; cyan
      (region    "#3e4451") ;; whitish
      (var     "#98be65")   ;; same as string
      (warning "#7ba7ee"))  ;; red
  (custom-theme-set-faces
   'one-dark
   `(default ((,class (:background ,bg1 :foreground ,fg1))))
   `(font-lock-builtin-face ((,class (:foreground ,builtin))))
   `(font-lock-comment-face ((,class (:foreground ,comment :italic t))))
   `(font-lock-negation-char-face ((,class (:foreground ,const))))
   `(font-lock-reference-face ((,class (:foreground ,const))))
   `(font-lock-constant-face ((,class (:foreground ,const))))
   `(font-lock-doc-face ((,class (:foreground ,comment))))
   `(font-lock-function-name-face ((,class (:foreground ,func :background ,bg1))))
   `(font-lock-keyword-face ((,class (:bold ,class :foreground ,keyword))))
   `(font-lock-string-face ((,class (:foreground ,str))))
   `(font-lock-type-face ((,class (:foreground ,type ))))
   `(font-lock-variable-name-face ((,class (:foreground ,var :background ,bg1))))
   `(font-lock-warning-face ((,class (:foreground ,warning :background ,bg2))))
   `(highlight ((,class (:foreground ,fg3 :background ,bg3))))
   `(hl-line ((,class (:background  ,bg2))))
   `(fringe ((,class (:background ,bg1 :foreground ,fg4))))
   ;; `(cursor ((,class (:background ,fg1))))
   `(region ((,class (:foreground nil :background ,region :distant-foreground ,comment))))
   `(spaceline-evil-visual ((,class (:foreground ,fg1 :background ,bg1 ))))
   `(show-paren-match-face ((,class (:background ,warning))))
   `(isearch ((,class (:bold t :foreground ,warning :background ,bg3))))
   ;; poweline
   ;; first thing on the right
   `(mode-line ((,class (:box (:line-width 1 :color ,bg1) :bold t :foreground ,builtin :background ,bg1))))
   `(mode-line-inactive ((,class (:box (:line-width 1 :color ,bg3) :foreground ,fg1 :background ,bg3 :weight bold))))
   `(mode-line-highlight ((,class (:foreground ,keyword :box nil :weight bold))))
   `(spaceline-highlight-face-default ((,class (:box (:line-width 1 :color ,bg3) :foreground ,fg3 :background ,bg3 :weight bold))))
   `(powerline-active1 ((,class (:box (:line-width 1 :color ,bg2) :bold t :foreground ,fg1 :background ,bg2))))
   `(powerline-active2 ((,class (:box (:line-width 1 :color ,bg3) :bold t :foreground ,fg4 :background ,bg3))))
   `(powerline-inactive1 ((,class (:box (:line-width 1 :color ,bg3) :bold t :foreground ,fg1 :background ,bg3))))
   `(powerline-inactive2 ((,class (:box (:line-width 1 :color ,bg3) :bold t :foreground ,fg1 :background ,bg3))))
   `(spaceline-highlight-face-evil-state ((,class (:bold t :foreground ,func :background ,bg1))))
   `(mode-line-emphasis ((,class (:foreground ,str))))
   `(spacemacs-hybrid-face ((t (:foreground ,bg1 :background ,str :inherit 'mode-line))))
   `(spacemacs-normal-face ((t (:foreground ,bg1 :background ,keyword :inherit 'mode-line))))
   ;; term
   `(term-color-black ((,class (:bold t :foreground ,bg1 :background ,str))))
   `(term-color-yellow ((,class (:bold t :foreground ,warning :background ,bg1))))
   `(term-color-red ((,class (:bold t :foreground ,warning :background ,warning))))
   ;; term-color-black
   ;; compilation
   `(compilation-error ((t (:foreground ,warning :background ,bg1))))
   `(compilation-info ((t (:foreground ,keyword :background ,bg1))))
   `(compilation-warning ((t (:foreground ,builtin :background ,bg1))))
   ;; str
   ;; linum
   ;; `(linum-relative-current-face ((,class (:box (:line-width 1 :color ,bg2) :bold t :foreground ,keyword :background ,bg2 ))))
   ;; `(linum ((,class (:box (:line-width 1 :color ,bg2) :bold t :foreground ,comment :background ,bg2))))
   `(line-number ((,class (:box (:line-width 1 :color ,bg2) :bold t :foreground ,comment :background ,bg2))))
   `(line-number-current-line ((,class (:box (:line-width 1 :color ,bg2) :bold t :foreground ,keyword :background ,bg2 ))))
   `(header-line ((,class (:bold t :background ,bg1))))
   `(company-tooltip-common-selection ((,class (:box (:line-width 1 :color ,bg1) :bold t :foreground ,fg3 :background ,bg1))))
   `(company-tooltip-mouse ((,class (:box (:line-width 1 :color ,bg1) :bold t :foreground ,fg3 :background ,bg1))))
   `(company-tooltip-search ((,class (:box (:line-width 1 :color ,bg1) :bold t :foreground ,fg3 :background ,bg1))))
   `(company-tooltip-search-selection ((,class (:box (:line-width 1 :color ,bg1) :bold t :foreground ,fg3 :background ,bg1))))
   `(company-tooltip-selection ((,class (:box (:line-width 1 :color ,bg1) :bold t :foreground ,fg3 :background ,bg2))))
   ;; lsp
   '(cquery-sem-global-variable-face ((t (:underline t :weight extra-bold))))
   '(lsp-face-highlight-read ((t (:distant-foreground nil :foreground nil :background "#234011"))))
   '(lsp-face-highlight-textual ((t (:distant-foreground nil :foreground nil :background "gray25"))))
   '(lsp-face-highlight-write ((t (:distant-foreground nil :foreground nil :background "#402311"))))
   '(lsp-ui-sideline-current-symbol ((t (:foreground ,keyword :box nil))))
   '(lsp-ui-sideline-symbol ((t (:foreground ,var :box nil))))
   ;;
   `(vertical-border ((,class (:foreground ,bg1 :background ,bg1))))
   `(minibuffer-prompt ((,class (:bold t :foreground ,keyword, :background ,bg1))))
   `(default-italic ((,class (:italic t))))
   `(link ((,class (:foreground ,const :underline t))))
   `(org-code ((,class (:foreground ,fg2))))
   `(org-hide ((,class (:foreground ,fg4))))
   `(org-level-1 ((,class (:bold t :foreground ,func :height 1.1))))
   `(org-level-2 ((,class (:bold t :foreground ,key3))))
   `(org-level-3 ((,class (:bold t :foreground ,fg4))))
   `(org-level-4 ((,class (:bold nil :foreground ,bg4))))
   `(org-date ((,class (:underline t :foreground ,var) )))
   `(org-footnote  ((,class (:underline t :foreground ,fg4))))
   `(org-link ((,class (:underline t :foreground ,type ))))
   `(org-special-keyword ((,class (:foreground ,func))))
   `(org-block ((,class (:foreground ,fg3))))
   `(org-quote ((,class (:inherit org-block :slant italic))))
   `(org-kbd ((,class (:foreground ,keyword :background ,bg4))))
   `(org-verse ((,class (:inherit org-block :slant italic))))
   `(org-todo ((,class (:box (:line-width 1 :color ,fg3) :foreground ,keyword :bold t))))
   `(org-done ((,class (:box (:line-width 1 :color ,bg3) :bold t :foreground ,comment))))
   `(org-warning ((,class (:underline t :foreground ,warning))))
   `(org-agenda-structure ((,class (:weight bold :foreground ,fg3 :box (:color ,fg4) :background ,bg3))))
   `(org-agenda-date ((,class (:foreground ,var :height 1.1 ))))
   `(org-agenda-date-weekend ((,class (:weight normal :foreground ,fg4))))
   `(org-agenda-date-today ((,class (:weight bold :foreground ,keyword :height 1.4))))
   `(org-agenda-done ((,class (:foreground ,bg4))))
   `(org-scheduled ((,class (:foreground ,type))))
   `(org-scheduled-today ((,class (:foreground ,func :weight bold :height 1.2))))
   `(org-ellipsis ((,class (:foreground ,builtin))))
   `(org-verbatim ((,class (:foreground ,fg4))))
   `(org-document-info-keyword ((,class (:foreground ,func))))
   `(font-latex-bold-face ((,class (:foreground ,type))))
   `(font-latex-italic-face ((,class (:foreground ,key3 :italic t))))
   `(font-latex-string-face ((,class (:foreground ,str))))
   `(font-latex-match-reference-keywords ((,class (:foreground ,const))))
   `(font-latex-match-variable-keywords ((,class (:foreground ,var))))
   `(ido-only-match ((,class (:foreground ,warning))))
   `(org-sexp-date ((,class (:foreground ,fg4))))
   `(ido-first-match ((,class (:foreground ,keyword :bold t))))
   `(gnus-header-content ((,class (:foreground ,keyword))))
   `(gnus-header-from ((,class (:foreground ,var))))
   `(gnus-header-name ((,class (:foreground ,type))))
   `(gnus-header-subject ((,class (:foreground ,func :bold t))))
   `(mu4e-view-url-number-face ((,class (:foreground ,type))))
   `(mu4e-cited-1-face ((,class (:foreground ,fg2))))
   `(mu4e-cited-7-face ((,class (:foreground ,fg3))))
   `(mu4e-header-marks-face ((,class (:foreground ,type))))
   `(ffap ((,class (:foreground ,fg4))))
   `(js2-function-call ((,class (:foreground ,builtin))))
   `(js2-private-function-call ((,class (:foreground ,const))))
   `(js2-jsdoc-html-tag-delimiter ((,class (:foreground ,str))))
   `(js2-jsdoc-html-tag-name ((,class (:foreground ,key2))))
   `(js2-external-variable ((,class (:inherit ,font-lock-variable-name-face))))
   `(js2-function-param ((,class (:inherit ,font-lock-variable-name-face))))
   `(js2-jsdoc-value ((,class (:foreground ,str))))
   `(js2-private-member ((,class (:foreground ,fg3))))
   `(js3-warning-face ((,class (:underline ,keyword))))
   `(js3-error-face ((,class (:underline ,warning))))
   `(js3-external-variable-face ((,class (:foreground ,var))))
   `(js3-function-param-face ((,class (:foreground ,key3))))
   `(js3-jsdoc-tag-face ((,class (:foreground ,keyword))))
   `(js3-instance-member-face ((,class (:foreground ,const))))
   `(warning ((,class (:foreground ,warning))))
   `(ac-completion-face ((,class (:underline t :foreground ,keyword))))
   `(info-quoted-name ((,class (:foreground ,builtin))))
   `(info-string ((,class (:foreground ,str))))
   `(icompletep-determined ((,class :foreground ,builtin)))
   `(undo-tree-visualizer-current-face ((,class :foreground ,builtin)))
   `(undo-tree-visualizer-default-face ((,class :foreground ,fg2)))
   `(undo-tree-visualizer-unmodified-face ((,class :foreground ,var)))
   `(undo-tree-visualizer-register-face ((,class :foreground ,type)))
   `(slime-repl-inputed-output-face ((,class (:foreground ,type))))
   `(trailing-whitespace ((,class :foreground nil :background ,warning)))
   `(rainbow-delimiters-depth-1-face ((,class :foreground ,fg1)))
   `(rainbow-delimiters-depth-2-face ((,class :foreground ,type)))
   `(rainbow-delimiters-depth-3-face ((,class :foreground ,var)))
   `(rainbow-delimiters-depth-4-face ((,class :foreground ,const)))
   `(rainbow-delimiters-depth-5-face ((,class :foreground ,keyword)))
   `(rainbow-delimiters-depth-6-face ((,class :foreground ,fg1)))
   `(rainbow-delimiters-depth-7-face ((,class :foreground ,type)))
   `(rainbow-delimiters-depth-8-face ((,class :foreground ,var)))
   `(magit-item-highlight ((,class :background ,bg3)))
   `(magit-section-heading        ((,class (:foreground ,keyword :weight bold))))
   `(magit-hunk-heading           ((,class (:background ,bg3))))
   `(magit-section-highlight      ((,class (:background ,bg2))))
   `(magit-hunk-heading-highlight ((,class (:background ,bg3))))
   `(magit-diff-context-highlight ((,class (:background ,bg3 :foreground ,fg3))))
   `(magit-diffstat-added   ((,class (:foreground ,type))))
   `(magit-diffstat-removed ((,class (:foreground ,var))))
   `(magit-process-ok ((,class (:foreground ,func :weight bold))))
   `(magit-process-ng ((,class (:foreground ,warning :weight bold))))
   `(magit-branch ((,class (:foreground ,const :weight bold))))
   `(magit-log-author ((,class (:foreground ,fg3))))
   `(magit-hash ((,class (:foreground ,fg2))))
   `(magit-diff-file-header ((,class (:foreground ,fg2 :background ,bg3))))
   `(lazy-highlight ((,class (:foreground ,func :background ,bg3))))
   `(term ((,class (:foreground ,fg1 :background ,bg1))))
   `(term-color-black ((,class (:foreground ,bg3 :background ,bg3))))
   `(term-color-blue ((,class (:foreground ,func :background ,func))))
   `(term-color-red ((,class (:foreground ,keyword :background ,bg3))))
   `(term-color-green ((,class (:foreground ,type :background ,bg3))))
   `(term-color-yellow ((,class (:foreground ,var :background ,var))))
   `(term-color-magenta ((,class (:foreground ,builtin :background ,builtin))))
   `(term-color-cyan ((,class (:foreground ,str :background ,str))))
   `(term-color-white ((,class (:foreground ,fg2 :background ,fg2))))
   `(rainbow-delimiters-unmatched-face ((,class :foreground ,warning)))
   `(helm-header ((,class (:foreground ,fg2 :background ,bg1 :underline nil :box nil))))
   `(helm-source-header ((,class (:foreground ,fg2 :background ,bg4 :underline nil :weight bold :height 1.2))))
   `(helm-selection ((,class (:background ,bg2 :underline nil))))
   `(helm-selection-line ((,class (:background ,bg2))))
   `(helm-visible-mark ((,class (:foreground ,warning :background ,bg3))))
   `(helm-candidate-number ((,class (:foreground ,bg1 :background ,fg1))))
   `(helm-separator ((,class (:foreground ,type :background ,bg1))))
   `(helm-time-zone-current ((,class (:foreground ,builtin :background ,bg1))))
   `(helm-time-zone-home ((,class (:foreground ,type :background ,bg1))))
   `(helm-buffer-not-saved ((,class (:foreground ,type :background ,bg1))))
   `(helm-buffer-directory ((,class (:foreground ,keyword :background ,bg1))))
   `(helm-buffer-process ((,class (:foreground ,builtin :background ,bg1))))
   `(helm-buffer-saved-out ((,class (:foreground ,fg1 :background ,bg1))))
   `(helm-buffer-size ((,class (:foreground ,fg1 :background ,bg1))))
   `(helm-ff-directory ((,class (:foreground ,func :background ,bg1 :weight bold))))
   `(helm-ff-file ((,class (:foreground ,fg1 :background ,bg1 :weight normal))))
   `(helm-ff-executable ((,class (:foreground ,key2 :background ,bg1 :weight normal))))
   `(helm-ff-invalid-symlink ((,class (:foreground ,key3 :background ,bg1 :weight bold))))
   `(helm-ff-symlink ((,class (:foreground ,keyword :background ,bg1 :weight bold))))
   `(helm-ff-prefix ((,class (:foreground ,bg1 :background ,keyword :weight normal))))
   `(helm-grep-cmd-line ((,class (:foreground ,fg1 :background ,bg1))))
   `(helm-grep-file ((,class (:foreground ,fg1 :background ,bg1))))
   `(helm-grep-finish ((,class (:foreground ,fg2 :background ,bg1))))
   `(helm-grep-lineno ((,class (:foreground ,fg1 :background ,bg1))))
   `(helm-grep-match ((,class (:foreground nil :background nil :inherit helm-match))))
   `(helm-grep-running ((,class (:foreground ,func :background ,bg1))))
   `(helm-moccur-buffer ((,class (:foreground ,func :background ,bg1))))
   `(helm-source-go-package-godoc-description ((,class (:foreground ,str))))
   `(helm-bookmark-w3m ((,class (:foreground ,type))))
   `(diredp-dir-heading ((,class (:foreground ,str :background ,bg1))))
   `(diredp-dir-name ((,class (:foreground ,keyword :background ,bg1))))
   `(diredp-file-name ((,class (:foreground ,fg1 :b-ackground ,bg1))))
   `(diredp-file-suffix ((,class (:foreground ,fg1 :background ,bg1))))
   `(neo-file-link-face ((,class (:foreground ,fg1 :background ,bg1))))
   `(company-echo-common ((,class (:foreground ,bg1 :background ,fg1))))
   `(company-preview ((,class (:background ,bg1 :foreground ,key2))))
   `(company-preview-common ((,class (:foreground ,bg2 :foreground ,fg3))))
   `(company-preview-search ((,class (:foreground ,type :background ,bg1))))
   `(company-scrollbar-bg ((,class (:background ,bg3))))
   `(company-scrollbar-fg ((,class (:foreground ,keyword))))
   `(company-tooltip ((,class (:foreground ,fg2 :background ,bg1 :bold t))))
   `(company-tooltop-annotation ((,class (:foreground ,const))))
   `(company-tooltip-common ((,class ( :foreground ,fg3))))
   `(company-tooltip-common-selection ((,class (:foreground ,str))))
   `(company-tooltip-mouse ((,class (:inherit highlight))))
   `(company-tooltip-selection ((,class (:background ,bg3 :foreground ,fg3))))
   `(company-template-field ((,class (:inherit region))))
   `(web-mode-builtin-face ((,class (:inherit ,font-lock-builtin-face))))
   `(web-mode-comment-face ((,class (:inherit ,font-lock-comment-face))))
   `(web-mode-constant-face ((,class (:inherit ,font-lock-constant-face))))
   `(web-mode-keyword-face ((,class (:foreground ,keyword))))
   `(web-mode-doctype-face ((,class (:inherit ,font-lock-comment-face))))
   `(web-mode-function-name-face ((,class (:inherit ,font-lock-function-name-face))))
   `(font-lock-method-call-face ((,class (:foreground ,func :background ,bg1))))
   `(web-mode-string-face ((,class (:foreground ,str))))
   `(web-mode-type-face ((,class (:inherit ,font-lock-type-face))))
   `(web-mode-html-attr-name-face ((,class (:foreground ,func))))
   `(web-mode-html-attr-value-face ((,class (:foreground ,keyword))))
   `(web-mode-warning-face ((,class (:inherit ,font-lock-warning-face))))
   `(web-mode-html-tag-face ((,class (:foreground ,builtin))))
   `(jde-java-font-lock-package-face ((t (:foreground ,var))))
   `(jde-java-font-lock-public-face ((t (:foreground ,keyword))))
   `(jde-java-font-lock-private-face ((t (:foreground ,keyword))))
   `(jde-java-font-lock-constant-face ((t (:foreground ,const))))
   `(jde-java-font-lock-modifier-face ((t (:foreground ,key3))))
   `(jde-jave-font-lock-protected-face ((t (:foreground ,keyword))))
   `(jde-java-font-lock-number-face ((t (:foreground ,var))))
   );; end custom-set-face

  (setq
   ;; evil-emacs-state-cursor        `(,base00 box)
   ;; evil-evilified-state-cursr     `(,base0A box)
   evil-hybrid-state-cursor       `(,str bar)
   ;; evil-iedit-state-cursor        `(,base08 box)
   ;; evil-iedir-insert-state-cursor `(,base08 bar)
   ;; evil-insert-state-cursor       `(,base0D bar)
   ;; evil-lisp-state-cursor         `(,base0E box)
   ;; evil-motion-state-cursor       `(,base0E box)
   evil-normal-state-cursor       `(,keyword box)
   ;; evil-replace-state-cursor      `(,base08 hbar)
   evil-visual-state-cursor       `(,keyword box)
   ;; fci-rule-color                 `(,bg2)
   fci-rule-color                 `,comment
   pdf-view-midnight-colors       `(,fg1 . ,bg1)
   )  ;; end set cursors
  )


;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'one-dark)

;; Local Variables:
;; no-byte-compile: t
;; End:

;;; one-dark-theme.el ends here
