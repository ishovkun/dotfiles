;; This file is not part of Emacs.

(deftheme one-dark)
(let* ((class '((class color) (min-colors 89)))
      ;;                               GUI       TER
      (bg          (if (true-color-p) "#282c34" "#1c1c1c")) ;; main background
      (bg-light    (if (true-color-p) "#2c323c" "#262626")) ;; lighter than main
      (bg-dark     (if (true-color-p) "#21252b" "#121212")) ;; darker than main background
      (bg4         (if (true-color-p) "#01657f" "#0087af"))
      (fg1         (if (true-color-p) "#abb2bf" "#bcbcbc"))
      (fg2         (if (true-color-p) "#ffffff" "#eeeeee"))
      (fg3         (if (true-color-p) "#4da089" "#008787"))
      (fg4         (if (true-color-p) "#d66083" "#d75f87"))
      (key2        (if (true-color-p) "#728e25" "#87af00"))
      ;; colors with names
      (magenta     (if (true-color-p) "#c586d8" "#ff87ff"))
      (magenta2    (if (true-color-p) "#81aaff" "#d75faf"))
      (lightgreen  (if (true-color-p) "#98be65" "#87af5f"))
      (blue        (if (true-color-p) "#51afef" "#5fafff"))
      (bright-blue (if (true-color-p) "#46D9FF" "#5fd7ff"))
      ;; (cyan         (if (true-color-p) "#43e0c8" "#46D9FF"))
      (bright-green (if (true-color-p) "#20db65" "#5fd75f"))
      (yellow      (if (true-color-p) "#ECBE7B" "#ecbe7b"))
      (orange      (if (true-color-p) "#da8548" "#dd8844"))
      (violet      (if (true-color-p) "#a9a1e1" "#8787d7"))
      (red         (if (true-color-p) "#ff005f" "#ff005f"))
      ;; elements
      (builtin magenta2)
      (keyword blue)
      (const   violet)
      (comment (if (true-color-p) "#5B6268" "#8a8a8a"))
      (func    magenta)
      (str     lightgreen)
      (type    bright-blue)
      (region  (if (true-color-p) "#3e4451" "#3a3a3a"))         ;; basically selection
      (var     lightgreen)
      (warning red)
      (success    bright-green)      ;; bright green
      )
  (custom-theme-set-faces
   'one-dark
   `(default                      ((,class (:background ,bg :foreground ,fg1))))
   `(font-lock-builtin-face       ((,class (:foreground ,builtin))))
   `(font-lock-comment-face       ((,class (:foreground ,comment :italic t))))
   `(font-lock-negation-char-face ((,class (:foreground ,const))))
   `(font-lock-reference-face     ((,class (:foreground ,const))))
   `(font-lock-constant-face      ((,class (:foreground ,const))))
   `(font-lock-doc-face           ((,class (:foreground ,comment))))
   `(font-lock-function-name-face ((,class (:foreground ,func :background ,bg))))
   `(font-lock-keyword-face       ((,class (:foreground ,keyword :bold ,class ))))
   `(font-lock-string-face        ((,class (:foreground ,str))))
   `(font-lock-type-face          ((,class (:foreground ,type ))))
   `(font-lock-variable-name-face ((,class (:foreground ,var :background ,bg))))
   `(font-lock-warning-face       ((,class (:foreground ,warning :background ,bg-light))))
   `(highlight                    ((,class (:foreground ,fg3 :background ,bg-dark))))
   `(hl-line                      ((,class (:background ,bg-light))))
   `(fringe                       ((,class (:background ,bg :foreground ,fg4))))
   `(window-divider               ((,class (:background ,bg-dark :foreground ,bg-dark))))
   `(region                       ((,class (:foreground nil :background ,region :distant-foreground ,comment))))
   `(isearch                      ((,class (:foreground ,warning :background ,bg-dark :bold t ))))
   `(show-paren-match-face        ((,class (:background ,warning))))
   `(whitespace-tab               ((,class (:background ,bg :foreground ,comment))))
   `(trailing-whitespace          ((,class (:background ,region))))
   ;; poweline
   `(spaceline-evil-visual ((,class (:foreground ,fg1 :background ,bg))))
   `(doom-modeline-evil-operator-state ((,class (:foreground ,bg-dark :background ,keyword ))))
   `(doom-modeline-evil-normal-state ((,class (:foreground ,bg-dark :background ,keyword ))))
   `(doom-modeline-evil-insert-state ((,class (:foreground ,bg-dark :background ,str ))))
   `(doom-modeline-evil-visual-state ((,class (:foreground ,bg-dark :background ,fg1 ))))
   `(doom-modeline-urgent ((,class (:foreground ,warning :background ,bg-dark ))))
   `(doom-modeline-warning ((,class (:foreground ,warning :background ,bg-dark ))))
   `(doom-modeline-buffer-modified ((,class (:foreground ,warning :background ,bg-dark ))))
   `(success                ((,class (:foreground ,success))))
   `(doom-modeline-lsp-error   ((,class (:foreground ,warning :background ,bg-dark ))))
   `(doom-modeline-lsp-warning ((,class (:foreground ,warning :background ,bg-dark ))))
   `(compilation-mode-line-exit ((,class (:foreground ,success :background ,bg-dark ))))
   `(compilation-mode-line-fail ((,class (:foreground ,warning :background ,bg-dark ))))
   `(compilation-mode-line-run ((,class (:foreground ,builtin :background ,bg-dark ))))
   ;; modeline git branch color
   `(doom-modeline-info  ((,class (:foreground ,success :weight bold))))
   ;; first thing on the right
   `(mode-line ((,class (:box (:line-width 1 :color ,bg) :bold t :foreground ,builtin :background ,bg-dark))))
   `(mode-line-inactive ((,class (:box (:line-width 1 :color ,bg-dark) :foreground ,fg1 :background ,bg-dark :weight bold))))
   `(mode-line-highlight ((,class (:foreground ,keyword :box nil :weight bold))))
   `(mode-line-emphasis ((,class (:foreground ,str))))
   `(spaceline-highlight-face-default ((,class (:box (:line-width 1 :color ,bg-dark) :foreground ,fg3 :background ,bg-dark :weight bold))))
   `(powerline-active1 ((,class (:box (:line-width 1 :color ,bg-light) :bold t :foreground ,fg1 :background ,bg-light))))
   `(powerline-active2 ((,class (:box (:line-width 1 :color ,bg-dark) :bold t :foreground ,fg4 :background ,bg-dark))))
   `(powerline-inactive1 ((,class (:box (:line-width 1 :color ,bg-dark) :bold t :foreground ,fg1 :background ,bg-dark))))
   `(powerline-inactive2 ((,class (:box (:line-width 1 :color ,bg-dark) :bold t :foreground ,fg1 :background ,bg-dark))))
   `(spaceline-highlight-face-evil-state ((,class (:bold t :foreground ,func :background ,bg))))
   `(spacemacs-hybrid-face ((t (:foreground ,bg :background ,str :inherit 'mode-line))))
   `(spacemacs-normal-face ((t (:foreground ,bg :background ,keyword :inherit 'mode-line))))
   ;; term
   `(term-color-black ((,class (:bold t :foreground ,bg :background ,str))))
   `(term-color-yellow ((,class (:bold t :foreground ,warning :background ,bg))))
   `(term-color-red ((,class (:bold t :foreground ,warning :background ,warning))))
   ;; term-color-black
   `(error ((t (:foreground ,warning :background ,bg))))
   ;; vterm
   `(vterm-color-default-fg ((,class (:foreground ,fg1))))
   `(vterm-color-default-bg ((,class (:background ,bg))))
   ;; compilation
   `(compilation-error ((t (:foreground ,warning :background ,bg))))
   `(compilation-info ((t (:foreground ,keyword :background ,bg))))
   `(compilation-warning ((t (:foreground ,builtin :background ,bg))))
   ;; evil
   `(evil-ex-lazy-highlight ((t (:background ,region))))
   ;; str
   ;; linum
   `(line-number ((,class (:box (:line-width 1 :color ,bg-light) :bold t :foreground ,comment :background ,bg-light))))
   `(line-number-current-line ((,class (:box (:line-width 1 :color ,bg-light) :bold t :foreground ,keyword :background ,bg-light ))))
   `(header-line ((,class (:bold t :background ,bg))))
   ;; `(company-tooltip-selection ((,class (:box (:line-width 1 :color ,bg) :bold t :foreground ,fg3 :background ,bg-light))))
   ;; lsp
   '(cquery-sem-global-variable-face ((t (:underline t :weight extra-bold))))
   `(lsp-face-highlight-read         ((,class (:distant-foreground nil :foreground nil :background ,region))))
   '(lsp-face-highlight-textual      ((t (:distant-foreground nil :foreground nil :background "gray25"))))
   '(lsp-face-highlight-write        ((t (:distant-foreground nil :foreground nil :background "#402311"))))
   `(lsp-ui-sideline-symbol          ((t (:foreground ,var :box nil))))
   `(lsp-ui-sideline-current-symbol  ((t (:foreground ,keyword :box nil))))
   ;;
   `(vertical-border ((,class (:foreground ,bg :background ,bg))))
   `(minibuffer-prompt ((,class (:bold t :foreground ,keyword, :background ,bg))))
   `(default-italic ((,class (:italic t))))
   `(link ((,class (:foreground ,const :underline t))))
   `(org-code ((,class (:foreground ,fg2))))
   `(org-hide ((,class (:foreground ,fg4))))
   `(org-level-1 ((,class (:bold t :foreground ,func :height 1.1))))
   `(org-level-2 ((,class (:bold t :foreground ,success))))
   `(org-level-3 ((,class (:bold t :foreground ,fg4))))
   `(org-level-4 ((,class (:bold nil :foreground ,key2))))
   `(org-date ((,class (:underline t :foreground ,var))))
   `(org-footnote  ((,class (:underline t :foreground ,fg4))))
   `(org-link ((,class (:underline t :foreground ,type ))))
   `(org-special-keyword ((,class (:foreground ,func))))
   `(org-block ((,class (:foreground ,fg3))))
   `(org-quote ((,class (:inherit org-block :slant italic))))
   `(org-kbd ((,class (:foreground ,keyword :background ,bg4))))
   `(org-verse ((,class (:inherit org-block :slant italic))))
   `(org-todo ((,class (:box (:line-width 1 :color ,fg3) :foreground ,keyword :bold t))))
   `(org-done ((,class (:box (:line-width 1 :color ,bg-dark) :bold t :foreground ,comment))))
   `(org-warning ((,class (:underline t :foreground ,warning))))
   `(org-agenda-structure ((,class (:weight bold :foreground ,fg3 :box (:color ,fg4) :background ,bg-dark))))
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
   `(font-latex-italic-face ((,class (:foreground ,success :italic t))))
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
   `(js3-function-param-face ((,class (:foreground ,success))))
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
   `(magit-item-highlight         ((,class :background ,bg-dark)))
   `(magit-section-heading        ((,class (:foreground ,keyword :weight bold))))
   `(magit-hunk-heading           ((,class (:background ,bg-dark))))
   `(magit-section-highlight      ((,class (:background ,bg-light))))
   `(magit-hunk-heading-highlight ((,class (:background ,bg-dark))))
   `(magit-diff-context-highlight ((,class (:background ,bg-dark :foreground ,fg3))))
   `(magit-diffstat-added         ((,class (:foreground ,type))))
   `(magit-diffstat-removed       ((,class (:foreground ,var))))
   `(magit-process-ok             ((,class (:foreground ,func :weight bold))))
   `(magit-process-ng             ((,class (:foreground ,warning :weight bold))))
   `(magit-branch                 ((,class (:foreground ,const :weight bold))))
   `(magit-log-author             ((,class (:foreground ,fg3))))
   `(magit-hash                   ((,class (:foreground ,fg2))))
   `(magit-diff-file-header       ((,class (:foreground ,fg2 :background ,bg-dark))))
   `(magit-branch-local           ((,class (:foreground ,blue :weight bold))))
   `(magit-branch-remote          ((,class (:foreground ,success :weight bold))))
   `(git-gutter-fr:added          ((,class (:foreground ,lightgreen))))
   `(git-gutter-fr:modified       ((,class (:foreground ,builtin))))
   `(git-gutter:added             ((,class (:foreground ,lightgreen))))
   `(git-gutter:modified          ((,class (:foreground ,builtin))))
   `(lazy-highlight ((,class (:foreground ,func :background ,bg-dark))))
   `(term ((,class (:foreground ,fg1 :background ,bg))))
   `(term-color-black ((,class (:foreground ,bg-dark :background ,bg-dark))))
   `(term-color-blue ((,class (:foreground ,func :background ,func))))
   `(term-color-red ((,class (:foreground ,keyword :background ,bg-dark))))
   `(term-color-green ((,class (:foreground ,type :background ,bg-dark))))
   `(term-color-yellow ((,class (:foreground ,var :background ,var))))
   `(term-color-magenta ((,class (:foreground ,builtin :background ,builtin))))
   `(term-color-cyan ((,class (:foreground ,str :background ,str))))
   `(term-color-white ((,class (:foreground ,fg2 :background ,fg2))))
   `(rainbow-delimiters-unmatched-face ((,class :foreground ,warning)))
   ;; ediff
   `(ediff-even-diff-A    ((,class (:background ,bg-light))))
   `(ediff-even-diff-B    ((,class (:background ,bg-light))))
   `(ediff-odd-diff-A    ((,class (:background ,bg-light))))
   `(ediff-odd-diff-B    ((,class (:background ,bg-light))))
   ;; helm
   `(helm-header ((,class (:foreground ,fg2 :background ,bg :underline nil :box nil))))
   `(helm-source-header ((,class (:foreground ,fg2 :background ,bg4 :underline nil :weight bold :height 1.2))))
   `(helm-selection ((,class (:background ,bg-light :underline nil))))
   `(helm-selection-line ((,class (:background ,bg-light))))
   `(helm-visible-mark ((,class (:foreground ,warning :background ,bg-dark))))
   `(helm-candidate-number ((,class (:foreground ,bg :background ,fg1))))
   `(helm-separator ((,class (:foreground ,type :background ,bg))))
   `(helm-time-zone-current ((,class (:foreground ,builtin :background ,bg))))
   `(helm-time-zone-home ((,class (:foreground ,type :background ,bg))))
   `(helm-buffer-not-saved ((,class (:foreground ,type :background ,bg))))
   `(helm-buffer-directory ((,class (:foreground ,keyword :background ,bg))))
   `(helm-buffer-process ((,class (:foreground ,builtin :background ,bg))))
   `(helm-buffer-saved-out ((,class (:foreground ,fg1 :background ,bg))))
   `(helm-buffer-size ((,class (:foreground ,fg1 :background ,bg))))
   `(helm-ff-directory ((,class (:foreground ,func :background ,bg :weight bold))))
   `(helm-ff-file ((,class (:foreground ,fg1 :background ,bg :weight normal))))
   `(helm-ff-executable ((,class (:foreground ,key2 :background ,bg :weight normal))))
   `(helm-ff-invalid-symlink ((,class (:foreground ,success :background ,bg :weight bold))))
   `(helm-ff-symlink ((,class (:foreground ,keyword :background ,bg :weight bold))))
   `(helm-ff-prefix ((,class (:foreground ,bg :background ,keyword :weight normal))))
   `(helm-grep-cmd-line ((,class (:foreground ,fg1 :background ,bg))))
   `(helm-grep-file ((,class (:foreground ,fg1 :background ,bg))))
   `(helm-grep-finish ((,class (:foreground ,fg2 :background ,bg))))
   `(helm-grep-lineno ((,class (:foreground ,fg1 :background ,bg))))
   `(helm-grep-match ((,class (:foreground nil :background nil :inherit helm-match))))
   `(helm-grep-running ((,class (:foreground ,func :background ,bg))))
   `(helm-moccur-buffer ((,class (:foreground ,func :background ,bg))))
   `(helm-source-go-package-godoc-description ((,class (:foreground ,str))))
   `(helm-bookmark-w3m ((,class (:foreground ,type))))
   ;; ivy
   ;; `(ivy-posframe-border ((,class (:inherit highlight :background ,fg1))))
   `(ivy-posframe-border ((,class (:inherit highlight :background ,bg-dark))))
   ;; `(ivy-posframe        ((,class (:inherit default :background ,bg-dark))))
   `(ivy-posframe        ((,t (:background ,bg-dark))))
   `(ivy-separator       ((,class (:background ,bg-dark))))
    ;;; modify minibuffer-prompt to change posframe top line color
   ;; dired
   `(diredp-dir-heading           ((,class (:foreground ,str :background ,bg))))
   `(diredp-dir-name              ((,class (:foreground ,keyword :background ,bg :weight 'bold))))
   `(dired-directory              ((,class (:foreground ,keyword :background ,bg))))
   `(all-the-icons-dired-dir-face ((,class (:foreground ,keyword :background ,bg))))
   `(diredp-file-name             ((,class (:foreground ,fg1 :b-ackground ,bg))))
   `(diredp-file-suffix           ((,class (:foreground ,fg1 :background ,bg))))
   `(neo-file-link-face           ((,class (:foreground ,fg1 :background ,bg))))
   `(diredfl-file-name            ((,class (:foreground ,fg1 :background ,bg))))
   `(diredfl-file-suffix          ((,class (:foreground ,fg1 :background ,bg))))
   `(diredfl-dir-name             ((,class (:foreground ,blue :bold t))))
   `(diredfl-symlink              ((,class (:foreground ,func :bold t))))
   ;; company
   `(company-echo-common ((,class (:foreground ,bg :background ,fg1))))
   `(company-preview ((,class (:background ,bg :foreground ,key2))))
   `(company-preview-common ((,class (:foreground ,bg-light :foreground ,blue))))
   `(company-preview-search ((,class (:foreground ,type :background ,bg))))
   `(company-scrollbar-bg ((,class (:background ,bg-dark))))
   `(company-scrollbar-fg ((,class (:background ,blue))))
   `(company-tooltip ((,class (:foreground ,fg2 :background ,bg-dark :bold t))))
   `(company-tooltip-annotation ((,class (:foreground ,blue))))
   `(company-tooltip-annotation-selection ((,class (:foreground ,bg-dark))))
   `(company-tooltip-common ((,class ( :foreground ,fg2 :background ,bg-dark))))
   `(company-tooltip-common-selection ((,class (:foreground ,bg-dark :background ,blue))))
   `(company-tooltip-mouse ((,class (:inherit highlight))))
   `(company-tooltip-selection ((,class (:background ,blue :foreground ,bg-dark))))
   `(company-tooltip-search ((,class (:foreground ,fg2 :weight bold))))
   `(company-tooltip-search-selection ((,class (:foreground ,blue))))
   ;; company-box
   `(company-box-background ((,class (:background ,bg-dark))))
   `(company-template-field ((,class (:inherit region))))
   `(web-mode-builtin-face ((,class (:inherit ,font-lock-builtin-face))))
   `(web-mode-comment-face ((,class (:inherit ,font-lock-comment-face))))
   `(web-mode-constant-face ((,class (:inherit ,font-lock-constant-face))))
   `(web-mode-keyword-face ((,class (:foreground ,keyword))))
   `(web-mode-doctype-face ((,class (:inherit ,font-lock-comment-face))))
   `(web-mode-function-name-face ((,class (:inherit ,font-lock-function-name-face))))
   `(font-lock-method-call-face ((,class (:foreground ,func :background ,bg))))
   `(web-mode-string-face ((,class (:foreground ,str))))
   `(web-mode-type-face ((,class (:inherit ,font-lock-type-face))))
   `(web-mode-html-attr-name-face ((,class (:foreground ,func))))
   `(web-mode-html-attr-value-face ((,class (:foreground ,keyword))))
   `(web-mode-warning-face ((,class (:inherit ,font-lock-warning-face))))
   `(web-mode-html-tag-face ((,class (:foreground ,builtin))))
   ;; w3m
   `(w3m-tab-background ((,class (:background ,bg-dark :foreground ,fg3))))
   `(w3m-tab-selected ((,class (:background ,bg-light :foreground ,builtin))))
   `(w3m-tab-selected-background ((,class (:background ,bg :foreground ,keyword))))
   `(w3m-tab-selected-retreiving ((,class (:background ,bg :foreground ,keyword))))
   `(w3m-tab-unselected ((,class (:background ,bg-dark :foreground ,fg1))))
   `(w3m-header-line-location-title ((,class (:foreground ,func))))
   `(w3m-anchor ((,class (:foreground ,func))))
   `(w3m-form ((,class (:foreground ,str))))
   `(w3m-error ((,class (:foreground ,warning))))
   `(w3m-tab-selected-retrieving ((,class (:foreground ,const))))
   ;; ----
   `(jde-java-font-lock-package-face ((t (:foreground ,var))))
   `(jde-java-font-lock-public-face ((t (:foreground ,keyword))))
   `(jde-java-font-lock-private-face ((t (:foreground ,keyword))))
   `(jde-java-font-lock-constant-face ((t (:foreground ,const))))
   `(jde-java-font-lock-modifier-face ((t (:foreground ,success))))
   `(jde-jave-font-lock-protected-face ((t (:foreground ,keyword))))
   `(jde-java-font-lock-number-face ((t (:foreground ,var))))
   `(eclipse-font-lock-keyword-face ((t (:foreground ,keyword))))
   `(eclipse-font-lock-comment-face ((t (:foreground ,comment))))
   `(eclipse-font-lock-import-face ((t (:foreground ,builtin))))
   `(eclipse-font-lock-fnutt-face ((t (:foreground ,func))))
   ;; ---- Man
   `(Man-overstrike ((t (:foreground ,type))))
   `(Man-underline ((t (:foreground ,keyword :underline t))))
   ;; --- pdf-view
   `(pdf-view-region ((t (:foreground ,bg-dark :background ,keyword))))
   );; end custom-set-face

  (setq
   ;; evil-emacs-state-cursor        `(,base00 box)
   ;; evil-evilified-state-cursr     `(,base0A box)
   evil-hybrid-state-cursor       `(,str bar)
   ;; evil-iedit-state-cursor        `(,base08 box)
   ;; evil-iedir-insert-state-cursor `(,base08 bar)
   evil-insert-state-cursor       `(,lightgreen bar)
   ;; evil-lisp-state-cursor         `(,base0E box)
   ;; evil-motion-state-cursor       `(,base0E box)
   evil-normal-state-cursor       `(,keyword box)
   ;; evil-replace-state-cursor      `(,base08 hbar)
   evil-visual-state-cursor       `(,keyword box)
   ;; fci-rule-color                 `(,bg-light)
   fci-rule-color                 `,comment
   pdf-view-midnight-colors       `(,fg1 . ,bg)
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
