;;; themes/substrata.el -*- lexical-binding: t; -*-

(deftheme substrata)
(let* ((class '((class color) (min-colors 89)))
      ;;                               GUI       TER
      ;; colors with names
      (red          (if (true-color-p) "#cf8164" "#cf8164"))
      (green        (if (true-color-p) "#76a065" "#76a065"))
      (gray        (if (true-color-p) "#6c6f82" "#6c6f82"))
      (yellow       (if (true-color-p) "#ab924c" "#ab924c"))
      (blue         (if (true-color-p) "#8296b0" "#8296b0"))
      (pink         (if (true-color-p) "#a18daf" "#a18daf"))
      (cyan         (if (true-color-p) "#659ea2" "#659ea2"))
      (light-red    (if (true-color-p) "#fe9f7c" "#fe9f7c"))
      (light-green  (if (true-color-p) "#92c47e" "#92c47e"))
      (light-yellow (if (true-color-p) "#d2b45f" "#d2b45f"))
      (light-blue   (if (true-color-p) "#a0b9d8" "#a0b9d8"))
      (light-pink   (if (true-color-p) "#c6aed7" "#c6aed7"))
      (light-cyan   (if (true-color-p) "#7dc2c7" "#7dc2c7"))
      (red-wash     (if (true-color-p) "#2d1d16" "#2d1d16"))
      (green-wash   (if (true-color-p) "#1c2316" "#1c2316"))
      (yellow-wash  (if (true-color-p) "#262011" "#262011"))
      (snow-storm      (if (true-color-p) "#d8dee9" "#d8dee9"))
      (snow-storm-light (if (true-color-p) "#eceff4" "#eceff4"))
      ;; Primary colors
      (bg           (if (true-color-p) "#191c25" "#191c25")) ;; main background
      (bg-light     (if (true-color-p) "#20222d" "#20222d")) ;; lighter than main
      (bg-lighter   (if (true-color-p) "#272935" "#272935")) ;; much lighter
      (bg-lightest  (if (true-color-p) "#2e313d" "#2e313d"))
      (invisible    (if (true-color-p) "#3c3f4e" "#3c3f4e"))
      (bg-dark      bg)
      (bg-darker      bg)
      (bg-dark-special     bg-darker) ;; solaire color
      (fg (if (true-color-p) "#9090a0" "#9090a0"))           ;; main foreground
      (fg-dim              gray)      ;; comments
      (fg-bright           snow-storm)
      ;; elements
      (builtin pink)
      (keyword blue)
      (const   pink)         ;; digits
      (comment gray)
      (func    blue)
      (str     cyan)
      (type    cyan)
      (region  bg-light)         ;; basically selection
      (var     blue)
      (warning yellow)
      (success green)      ;; bright green
      (search-current bg-lighter)      ;; current match
      (misc yellow-wash)      ;; latex equations
      )
  (custom-theme-set-faces
   'substrata
   `(default                      ((,class (:background ,bg :foreground ,fg))))
   `(font-lock-builtin-face       ((,class (:foreground ,builtin))))
   `(font-lock-comment-face       ((,class (:foreground ,comment :italic t))))
   `(font-lock-negation-char-face ((,class (:foreground ,const))))
   `(font-lock-reference-face     ((,class (:foreground ,const))))
   `(font-lock-constant-face      ((,class (:foreground ,const :bold ,class))))
   `(font-lock-doc-face           ((,class (:foreground ,comment))))
   `(font-lock-function-name-face ((,class (:foreground ,func :background ,bg))))
   `(font-lock-keyword-face       ((,class (:foreground ,keyword :bold ,class ))))
   `(font-lock-string-face        ((,class (:foreground ,str))))
   `(font-lock-type-face          ((,class (:foreground ,type ))))
   `(font-lock-variable-name-face ((,class (:foreground ,var))))
   `(font-lock-warning-face       ((,class (:foreground ,warning :background ,bg-light))))
   `(highlight                    ((,class (:foreground ,fg-bright :background ,bg-dark))))
   `(hl-line                      ((t      (:background ,bg-light))))
   `(fringe                       ((,class (:background ,bg :foreground ,const))))
   `(window-divider               ((,class (:background ,bg-dark :foreground ,bg-dark))))
   `(window-divider-first-pixel   ((,class (:background ,bg-dark :foreground ,bg-dark))))
   `(window-divider-last-pixel    ((,class (:background ,bg-dark :foreground ,bg-dark))))
   `(region                       ((,class (:foreground nil :background ,bg-lighter :distant-foreground ,comment :extend t))))
   `(isearch                      ((,class (:foreground ,fg :background ,search-current :bold t ))))
   `(show-paren-match-face        ((,class (:background ,warning))))
   `(whitespace-tab               ((,class (:background ,bg :foreground ,comment))))
   `(trailing-whitespace          ((,class (:background ,region))))
   ;; poweline
   `(spaceline-evil-visual             ((,class (:foreground ,fg :background ,bg))))
   `(doom-modeline-evil-operator-state ((,class (:foreground ,bg-dark :background ,keyword ))))
   `(doom-modeline-evil-normal-state   ((,class (:foreground ,bg-dark :background ,keyword ))))
   `(doom-modeline-evil-insert-state   ((,class (:foreground ,bg-dark :background ,str ))))
   `(doom-modeline-evil-visual-state   ((,class (:foreground ,bg-dark :background ,fg ))))
   `(doom-modeline-urgent              ((,class (:foreground ,warning :background ,bg-dark ))))
   `(doom-modeline-warning             ((,class (:foreground ,warning :background ,bg-dark ))))
   `(doom-modeline-buffer-modified     ((,class (:foreground ,warning :background ,bg-dark ))))
   `(success                           ((,class (:foreground ,success))))
   `(doom-modeline-lsp-error           ((,class (:foreground ,warning :background ,bg-dark ))))
   `(doom-modeline-lsp-warning         ((,class (:foreground ,warning :background ,bg-dark ))))
   `(compilation-mode-line-exit        ((,class (:foreground ,success :background ,bg-dark ))))
   `(compilation-mode-line-fail        ((,class (:foreground ,warning :background ,bg-dark ))))
   `(compilation-mode-line-run         ((,class (:foreground ,builtin :background ,bg-dark ))))
   ;; modeline git branch color
   `(doom-modeline-info  ((,class (:foreground ,success :weight bold))))
   ;; first thing on the right
   ;; `(mode-line ((,class (:box (:line-width 1 :color ,bg) :bold t :foreground ,builtin :background ,bg-dark))))
   `(mode-line ((,class (:bold t :foreground ,fg-bright :background ,bg-dark))))
   `(mode-line-inactive ((,class (:box (:line-width 1 :color ,bg-dark) :foreground ,fg :background ,bg-dark :weight bold))))
   `(mode-line-highlight ((,class (:foreground ,keyword :box nil :weight bold))))
   `(mode-line-emphasis ((,class (:foreground ,str))))
   `(spaceline-highlight-face-default ((,class (:box (:line-width 1 :color ,bg-dark) :foreground ,fg-bright :background ,bg-dark :weight bold))))
   `(powerline-active1 ((,class (:box (:line-width 1 :color ,bg-light) :bold t :foreground ,fg :background ,bg-light))))
   `(powerline-active2 ((,class (:box (:line-width 1 :color ,bg-dark) :bold t :foreground ,const :background ,bg-dark))))
   `(powerline-inactive1 ((,class (:box (:line-width 1 :color ,bg-dark) :bold t :foreground ,fg :background ,bg-dark))))
   `(powerline-inactive2 ((,class (:box (:line-width 1 :color ,bg-dark) :bold t :foreground ,fg :background ,bg-dark))))
   `(spaceline-highlight-face-evil-state ((,class (:bold t :foreground ,func :background ,bg))))
   `(spacemacs-hybrid-face ((t (:foreground ,bg :background ,str :inherit 'mode-line))))
   `(spacemacs-normal-face ((t (:foreground ,bg :background ,keyword :inherit 'mode-line))))
   ;; term
   `(term-color-black            ((t (:foreground ,bg :background ,bg))))
   `(term-color-red              ((t (:foreground ,warning :background ,warning))))
   `(term-color-green            ((t (:foreground ,str :background ,str))))
   `(term-color-yellow           ((t (:foreground ,misc :background ,misc))))
   `(term-color-blue             ((t (:foreground ,type :background ,type))))
   `(term-color-magenta          ((t (:foreground ,const :background ,const))))
   `(term-color-cyan             ((t (:foreground ,builtin :background ,builtin))))
   `(term-color-white            ((t (:foreground ,fg-bright :background ,fg-bright))))
   ;; term-color-black
   ;; `(error ((t (:foreground ,warning :background ,bg))))
   `(error ((t (:foreground ,warning))))
   ;; vterm
   `(vterm-color-default-fg ((,class (:foreground ,fg))))
   `(vterm-color-default-bg ((,class (:background ,bg))))
   ;; compilation
   `(compilation-error ((t (:foreground ,warning :background ,bg))))
   `(compilation-info ((t (:foreground ,keyword :background ,bg))))
   `(compilation-warning ((t (:foreground ,builtin :background ,bg))))
   ;; `(compilation-column-number ((t (:inherit ,comment))))
   ;; `(compilation-mode-line-exit ((t (:inherit ,keyword))))
   ;; `(compilation-mode-line-fail ((t (:inherit ,warning))))
   ;; evil
   `(evil-ex-lazy-highlight ((t (:background ,func :foreground ,bg))))
   ;; str
   ;; linum
   `(line-number ((,class (:box (:line-width 1 :color ,bg) :bold t :foreground ,comment :background ,bg))))
   `(line-number-current-line ((,class (:box (:line-width 1 :color ,bg) :bold t :foreground ,keyword :background ,bg ))))
   `(header-line ((,class (:bold t :background ,bg))))
   ;; `(company-tooltip-selection ((,class (:box (:line-width 1 :color ,bg) :bold t :foreground ,fg-bright :background ,bg-light))))
   ;; lsp
   '(cquery-sem-global-variable-face ((t (:underline t :weight extra-bold))))
   `(lsp-face-highlight-read         ((,class (:distant-foreground nil :foreground nil :background ,region))))
   '(lsp-face-highlight-textual      ((t (:distant-foreground nil :foreground nil :background "gray25"))))
   '(lsp-face-highlight-write        ((t (:distant-foreground nil :foreground nil :background "#402311"))))
   `(lsp-ui-sideline-symbol          ((t (:foreground ,var :box nil))))
   `(lsp-ui-doc-background           ((t (:foreground ,var :background ,bg-dark :box nil))))
   `(lsp-ui-doc-border               ((t (:foreground ,keyword))))
   `(lsp-ui-sideline-current-symbol  ((t (:foreground ,keyword :box nil))))
   ;;
   `(vertical-border ((,class (:foreground ,bg :background ,bg))))
   `(minibuffer-prompt ((,class (:bold t :foreground ,keyword, :background ,bg))))
   `(default-italic ((,class (:italic t))))
   `(link ((,class (:foreground ,const :underline t))))
   `(org-code ((,class (:foreground ,fg-dim))))
   `(org-hide ((,class (:foreground ,const))))
   `(org-level-1 ((,class (:bold t :foreground ,func :height 1.1))))
   `(org-level-2 ((,class (:bold t :foreground ,success))))
   `(org-level-3 ((,class (:bold t :foreground ,const))))
   `(org-level-4 ((,class (:bold nil :foreground ,keyword))))
   `(org-date ((,class (:underline t :foreground ,var))))
   `(org-footnote  ((,class (:underline t :foreground ,const))))
   `(org-link ((,class (:underline t :foreground ,type ))))
   `(org-special-keyword ((,class (:foreground ,func))))
   `(org-block ((,class (:foreground ,fg-bright))))
   `(org-quote ((,class (:inherit org-block :slant italic))))
   `(org-kbd ((,class (:foreground ,keyword :background ,bg))))
   `(org-verse ((,class (:inherit org-block :slant italic))))
   `(org-todo ((,class (:box (:line-width 1 :color ,fg-bright) :foreground ,keyword :bold t))))
   `(org-done ((,class (:box (:line-width 1 :color ,bg-dark) :bold t :foreground ,comment))))
   `(org-warning ((,class (:underline t :foreground ,warning))))
   `(org-agenda-structure ((,class (:weight bold :foreground ,fg-bright :box (:color ,const) :background ,bg-dark))))
   `(org-agenda-date ((,class (:foreground ,var :height 1.1 ))))
   `(org-agenda-date-weekend ((,class (:weight normal :foreground ,const))))
   `(org-agenda-date-today ((,class (:weight bold :foreground ,keyword :height 1.4))))
   `(org-agenda-done ((,class (:foreground ,bg))))
   `(org-scheduled ((,class (:foreground ,type))))
   `(org-scheduled-today ((,class (:foreground ,func :weight bold :height 1.2))))
   `(org-ellipsis ((,class (:foreground ,builtin))))
   `(org-verbatim ((,class (:foreground ,const))))
   `(org-document-info-keyword ((,class (:foreground ,func))))
   ;; LaTeX
   `(font-latex-sectioning-0-face ((,class (:foreground ,misc))))
   `(font-latex-sectioning-1-face ((,class (:foreground ,misc))))
   `(font-latex-sectioning-2-face ((,class (:foreground ,type :weight bold :height 1.8))))
   `(font-latex-sectioning-3-face ((,class (:foreground ,type :weight bold :height 1.5))))
   `(font-latex-sectioning-4-face ((,class (:foreground ,fg-bright :weight bold :height 1.3))))
   `(font-latex-sectioning-4-face ((,class (:foreground ,fg-bright :weight bold))))
   `(font-latex-warning-face ((,class (:foreground ,warning :weight bold))))
   `(font-latex-bold-face ((,class (:foreground ,type))))
   `(font-latex-italic-face ((,class (:foreground ,success :italic t))))
   `(font-latex-string-face ((,class (:foreground ,str))))
   `(font-latex-match-reference-keywords ((,class (:foreground ,const))))
   `(font-latex-match-variable-keywords ((,class (:foreground ,var))))
   `(org-latex-and-related ((,class (:foreground ,misc))))
   `(font-latex-math-face ((,class (:foreground ,misc)))) ;
   `(ido-only-match ((,class (:foreground ,warning))))
   `(org-sexp-date ((,class (:foreground ,const))))
   `(ido-first-match ((,class (:foreground ,keyword :bold t))))
   `(gnus-header-content ((,class (:foreground ,keyword))))
   `(gnus-header-from ((,class (:foreground ,var))))
   `(gnus-header-name ((,class (:foreground ,type))))
   `(gnus-header-subject ((,class (:foreground ,func :bold t))))
   `(mu4e-view-url-number-face ((,class (:foreground ,type))))
   `(mu4e-cited-1-face ((,class (:foreground ,fg-dim))))
   `(mu4e-cited-7-face ((,class (:foreground ,fg-bright))))
   `(mu4e-header-marks-face ((,class (:foreground ,type))))
   `(ffap ((,class (:foreground ,const))))
   `(js2-function-call ((,class (:foreground ,builtin))))
   `(js2-private-function-call ((,class (:foreground ,const))))
   `(js2-jsdoc-html-tag-delimiter ((,class (:foreground ,str))))
   `(js2-jsdoc-html-tag-name ((,class (:foreground ,keyword))))
   `(js2-external-variable ((,class (:inherit ,font-lock-variable-name-face))))
   `(js2-function-param ((,class (:inherit ,font-lock-variable-name-face))))
   `(js2-jsdoc-value ((,class (:foreground ,str))))
   `(js2-private-member ((,class (:foreground ,fg-bright))))
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
   `(undo-tree-visualizer-default-face ((,class :foreground ,fg-dim)))
   `(undo-tree-visualizer-unmodified-face ((,class :foreground ,var)))
   `(undo-tree-visualizer-register-face ((,class :foreground ,type)))
   `(slime-repl-inputed-output-face ((,class (:foreground ,type))))
   `(trailing-whitespace ((,class :foreground nil :background ,warning)))
   `(rainbow-delimiters-depth-1-face ((,class :foreground ,fg)))
   `(rainbow-delimiters-depth-2-face ((,class :foreground ,type)))
   `(rainbow-delimiters-depth-3-face ((,class :foreground ,var)))
   `(rainbow-delimiters-depth-4-face ((,class :foreground ,const)))
   `(rainbow-delimiters-depth-5-face ((,class :foreground ,keyword)))
   `(rainbow-delimiters-depth-6-face ((,class :foreground ,fg)))
   `(rainbow-delimiters-depth-7-face ((,class :foreground ,type)))
   `(rainbow-delimiters-depth-8-face ((,class :foreground ,var)))
   `(magit-item-highlight         ((,class :background ,bg-dark)))
   `(magit-section-heading        ((,class (:foreground ,keyword :weight bold))))
   `(magit-hunk-heading           ((,class (:background ,bg-dark))))
   `(magit-section-highlight      ((,class (:background ,bg-light))))
   `(magit-hunk-heading-highlight ((,class (:background ,bg-dark))))
   `(magit-diff-context-highlight ((,class (:background ,bg-dark :foreground ,fg-bright))))
   `(magit-diffstat-added         ((,class (:foreground ,type))))
   `(magit-diffstat-removed       ((,class (:foreground ,var))))
   `(magit-process-ok             ((,class (:foreground ,func :weight bold))))
   `(magit-process-ng             ((,class (:foreground ,warning :weight bold))))
   `(magit-branch                 ((,class (:foreground ,const :weight bold))))
   `(magit-log-author             ((,class (:foreground ,fg-bright))))
   `(magit-hash                   ((,class (:foreground ,fg-dim))))
   `(magit-diff-file-header       ((,class (:foreground ,fg-dim :background ,bg-dark))))
   `(magit-branch-local           ((,class (:foreground ,keyword :weight bold))))
   `(magit-branch-remote          ((,class (:foreground ,success :weight bold))))
   `(git-gutter-fr:added          ((,class (:foreground ,str))))
   `(git-gutter-fr:modified       ((,class (:foreground ,builtin))))
   `(git-gutter:added             ((,class (:foreground ,str))))
   `(git-gutter:modified          ((,class (:foreground ,builtin))))
   `(lazy-highlight ((,class (:foreground ,func :background ,bg-dark))))
   `(term ((,class (:foreground ,fg :background ,bg))))
   `(term-color-black ((,class (:foreground ,bg-dark :background ,bg-dark))))
   `(term-color-blue ((,class (:foreground ,func :background ,func))))
   `(term-color-red ((,class (:foreground ,keyword :background ,bg-dark))))
   `(term-color-green ((,class (:foreground ,type :background ,bg-dark))))
   `(term-color-yellow ((,class (:foreground ,var :background ,var))))
   `(term-color-magenta ((,class (:foreground ,builtin :background ,builtin))))
   `(term-color-cyan ((,class (:foreground ,str :background ,str))))
   `(term-color-white ((,class (:foreground ,fg-dim :background ,fg-dim))))
   `(rainbow-delimiters-unmatched-face ((,class :foreground ,warning)))
   ;; ediff
   `(ediff-even-diff-A    ((,class (:background ,bg-light))))
   `(ediff-even-diff-B    ((,class (:background ,bg-light))))
   `(ediff-odd-diff-A    ((,class (:background ,bg-light))))
   `(ediff-odd-diff-B    ((,class (:background ,bg-light))))
   ;; eclipse
   `(eclipse-font-lock-keyword-face ((,class (:foreground ,keyword :bold ,class ))))
   `(eclipse-font-lock-import-face ((,class (:foreground ,builtin :bold ,class ))))
   `(eclipse-font-lock-comment-face ((,class (:foreground ,comment :bold ,class ))))
   `(eclipse-font-lock-function-name-face ((,class (:foreground ,func :bold ,class ))))
   ;; helm
   `(helm-header ((,class (:foreground ,fg-dim :background ,bg :underline nil :box nil))))
   `(helm-source-header ((,class (:foreground ,fg-dim :background ,bg :underline nil :weight bold :height 1.2))))
   `(helm-selection ((,class (:background ,bg-light :underline nil))))
   `(helm-selection-line ((,class (:background ,bg-light))))
   `(helm-visible-mark ((,class (:foreground ,warning :background ,bg-dark))))
   `(helm-candidate-number ((,class (:foreground ,bg :background ,fg))))
   `(helm-separator ((,class (:foreground ,type :background ,bg))))
   `(helm-time-zone-current ((,class (:foreground ,builtin :background ,bg))))
   `(helm-time-zone-home ((,class (:foreground ,type :background ,bg))))
   `(helm-buffer-not-saved ((,class (:foreground ,type :background ,bg))))
   `(helm-buffer-directory ((,class (:foreground ,keyword :background ,bg))))
   `(helm-buffer-process ((,class (:foreground ,builtin :background ,bg))))
   `(helm-buffer-saved-out ((,class (:foreground ,fg :background ,bg))))
   `(helm-buffer-size ((,class (:foreground ,fg :background ,bg))))
   `(helm-ff-directory ((,class (:foreground ,func :background ,bg :weight bold))))
   `(helm-ff-file ((,class (:foreground ,fg :background ,bg :weight normal))))
   `(helm-ff-executable ((,class (:foreground ,keyword :background ,bg :weight normal))))
   `(helm-ff-invalid-symlink ((,class (:foreground ,success :background ,bg :weight bold))))
   `(helm-ff-symlink ((,class (:foreground ,keyword :background ,bg :weight bold))))
   `(helm-ff-prefix ((,class (:foreground ,bg :background ,keyword :weight normal))))
   `(helm-grep-cmd-line ((,class (:foreground ,fg :background ,bg))))
   `(helm-grep-file ((,class (:foreground ,fg :background ,bg))))
   `(helm-grep-finish ((,class (:foreground ,fg-dim :background ,bg))))
   `(helm-grep-lineno ((,class (:foreground ,fg :background ,bg))))
   `(helm-grep-match ((,class (:foreground nil :background nil :inherit helm-match))))
   `(helm-grep-running ((,class (:foreground ,func :background ,bg))))
   `(helm-moccur-buffer ((,class (:foreground ,func :background ,bg))))
   `(helm-source-go-package-godoc-description ((,class (:foreground ,str))))
   `(helm-bookmark-w3m ((,class (:foreground ,type))))

   ;; ivy
   `(ivy-current-match   ((,class (:background ,region :distant-foreground nil :extend t))))
   `(ivy-posframe-border ((,class (:background ,bg-dark))))
   `(ivy-posframe        ((,class (:background ,bg-dark))))
   ;; darken special buffers
   `(solaire-default-face        ((,class (:background ,bg-dark-special))))

   ;; `(ivy-separator       ((,class (:background ,black))))
    ;;; modify minibuffer-prompt to change posframe top line color
   ;; dired
   `(diredp-dir-heading           ((,class (:foreground ,str :background ,bg))))
   `(diredp-dir-name              ((,class (:foreground ,keyword :background ,bg :weight 'bold))))
   `(dired-directory              ((,class (:foreground ,keyword :background ,bg))))
   `(all-the-icons-dired-dir-face ((,class (:foreground ,keyword :background ,bg))))
   `(diredp-file-name             ((,class (:foreground ,fg :background ,bg))))
   `(diredp-file-suffix           ((,class (:foreground ,fg :background ,bg))))
   `(neo-file-link-face           ((,class (:foreground ,fg :background ,bg))))
   `(diredfl-file-name            ((,class (:foreground ,fg :background ,bg))))
   `(diredfl-file-suffix          ((,class (:foreground ,fg :background ,bg))))
   `(diredfl-dir-name             ((,class (:foreground ,keyword :bold t))))
   `(diredfl-symlink              ((,class (:foreground ,func :bold t))))
   ;; company
   `(company-echo-common ((,class (:foreground ,bg :background ,fg))))
   `(company-preview ((,class (:background ,bg :foreground ,keyword))))
   `(company-preview-common ((,class (:foreground ,bg-light :foreground ,keyword))))
   `(company-preview-search ((,class (:foreground ,type :background ,bg))))
   `(company-scrollbar-bg ((,class (:background ,bg-dark))))
   `(company-scrollbar-fg ((,class (:background ,keyword))))
   `(company-tooltip ((,class (:foreground ,fg-dim :background ,bg-dark :bold t))))
   `(company-tooltip-annotation ((,class (:foreground ,keyword))))
   `(company-tooltip-annotation-selection ((,class (:foreground ,bg-dark))))
   `(company-tooltip-common ((,class ( :foreground ,fg-dim :background ,bg-dark))))
   `(company-tooltip-common-selection ((,class (:foreground ,bg-dark :background ,keyword))))
   `(company-tooltip-mouse ((,class (:inherit highlight))))
   `(company-tooltip-selection ((,class (:background ,keyword :foreground ,bg-dark))))
   `(company-tooltip-search ((,class (:foreground ,fg-dim :weight bold))))
   `(company-tooltip-search-selection ((,class (:foreground ,keyword))))
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
   `(w3m-tab-background ((,class (:background ,bg-dark :foreground ,fg-bright))))
   `(w3m-tab-selected ((,class (:background ,bg-light :foreground ,builtin))))
   `(w3m-tab-selected-background ((,class (:background ,bg :foreground ,keyword))))
   `(w3m-tab-selected-retreiving ((,class (:background ,bg :foreground ,keyword))))
   `(w3m-tab-unselected ((,class (:background ,bg-dark :foreground ,fg))))
   `(w3m-header-line-location-title ((,class (:foreground ,func))))
   `(w3m-anchor ((,class (:foreground ,func))))
   `(w3m-form ((,class (:foreground ,str))))
   `(w3m-error ((,class (:foreground ,warning))))
   `(w3m-tab-selected-retrieving ((,class (:foreground ,const))))
   ;; ---- yascroll
   ;; `(yascroll:thumb-fringe ((,class (:background ,builtin :foreground ,builtin))))
   `(yascroll:thumb-fringe ((,class (:background ,region :foreground ,region))))
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
   ;; ------ EIN
   `(ein:cell-input-area ((t (:background ,bg))))
   `(ein:cell-input-prompt ((t (:background ,bg-dark))))
   `(ein:cell-output-area ((t (:background ,bg-light))))
   `(ein:cell-output-area-error ((t (:background ,bg :foreground ,warning))))
   ;; ------ cfw calendar
   `(cfw:face-title              ((t (:foreground ,keyword :background ,bg-dark :weight bold :height 2.0 :inherit variable-pitch))))
   `(cfw:face-header             ((t (:foreground ,fg-bright :background ,bg-dark :weight bold))))
   `(cfw:face-sunday             ((t :foreground ,comment :background ,bg-dark :weight bold)))
   `(cfw:face-saturday           ((t :foreground ,comment :background ,bg-dark :weight bold)))
   `(cfw:face-holiday            ((t :foreground ,builtin :weight bold :background ,bg-dark)))
   `(cfw:face-grid               ((t :foreground ,bg-light)))
   `(cfw:face-default-content    ((t :foreground ,fg)))
   `(cfw:face-periods            ((t :foreground ,str)))
   `(cfw:face-day-title          ((t :background ,bg-dark)))
   `(cfw:face-default-day        ((t :weight bold :inherit cfw:face-day-title)))
   `(cfw:face-annotation         ((t :foreground ,func :inherit cfw:face-day-title)))
   `(cfw:face-disable            ((t :foreground ,const :inherit cfw:face-day-title)))
   `(cfw:face-today-title        ((t :background ,type :weight bold)))
   `(cfw:face-today              ((t :background ,bg-lighter :weight bold)))
   `(cfw:face-select             ((t :background ,bg-light)))
   `(cfw:face-toolbar            ((t :foreground ,fg-dim :background ,bg)))
   `(cfw:face-toolbar-button-off ((t :foreground ,fg-dim :weight bold)))
   `(cfw:face-toolbar-button-on  ((t :foreground ,type :weight bold)))
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
   evil-insert-state-cursor       `(,str bar)
   ;; evil-lisp-state-cursor         `(,base0E box)
   ;; evil-motion-state-cursor       `(,base0E box)
   evil-normal-state-cursor       `(,keyword box)
   ;; evil-replace-state-cursor      `(,base08 hbar)
   evil-visual-state-cursor       `(,keyword box)
   ;; fci-rule-color                 `(,bg-light)
   fci-rule-color                 `,comment
   pdf-view-midnight-colors       `(,fg . ,bg))

  (custom-theme-set-variables
   'substrata
   `(ansi-color-names-vector (vector "black" ,warning ,str ,misc ,func ,const ,builtin ,fg-bright))
  ;;  ;; ["black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"]
   )

  )


;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'substrata)

;; Local Variables:
;; no-byte-compile: t
;; End:

;;; substrata-theme.el ends here
