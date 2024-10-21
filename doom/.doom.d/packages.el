;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:fetcher github :repo "username/repo"))
;; (package! builtin-package :disable t)

;;; Code:
(package! winum)
(package! ivy-posframe :recipe (:host github :repo "tumashu/ivy-posframe"))
(disable-packages! irony rtags)
(package! cquery)
(package! ccls)
(package! google-c-style)
(package! company-lsp)
(package! evil-commentary)              ; easily comment lines
;; (package! yascroll)
;; (package! evil-swap-keys :recipe (:host github :repo "wbolster/evil-swap-keys"))
(package! evil-terminal-cursor-changer)
;; (package! dap-lldb :recipe (:host github :repo "emacs-lsp/dap-mode"))
;; (package! alert)
;; (package! org-wild-notifier)
;; (package! mini-modeline :recipe (:host github :repo "kiennq/emacs-mini-modeline"))
;; (package! lsp-treemacs)

;; (package! codeium :recipe (:host github :repo "Exafunction/codeium.el"))

(package! highlight2clipboard)
(package! highlight-indent-guides )

;; temporary fix after doom update
;; run thes sync to have those updated (mind the flags)
;; doom sync -u
;; (package! transient
;;       :pin "c2bdf7e12c530eb85476d3aef317eb2941ab9440"
;;       :recipe (:host github :repo "magit/transient"))

;; (package! with-editor
;;           :pin "bbc60f68ac190f02da8a100b6fb67cf1c27c53ab"
;;           :recipe (:host github :repo "magit/with-editor"))
(package! transient :recipe (:host github :repo "magit/transient"))

(package! centaur-tabs)
;; (package! ranger)

;; (package! transient :pin "c2bdf7e12c530eb85476d3aef317eb2941ab9440")
;; (package! with-editor :pin "bbc60f68ac190f02da8a100b6fb67cf1c27c53ab")

(package! doom-snippets :disable t)

(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el" "dist")))
;; (package! awesome-tab :recipe (:host github :repo "manateelazycat/awesome-tab"))
;; (package! centaur-tabs)
;; (package! rmsbolt)
(package! org-modern)

;;; packages.el ends here
