;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:fetcher github :repo "username/repo"))
;; (package! builtin-package :disable t)

;;; Code:
;; (package! doom-themes :ignore t)
(package! winum)
(package! ivy-posframe :recipe (:host github :repo "tumashu/ivy-posframe"))
(disable-packages! irony rtags)
(package! cquery)
(package! ccls)
(package! google-c-style) ; google c/c++ coding style
(package! company-lsp)
(package! evil-commentary)              ; easily comment lines
(package! yascroll)
;; (package! evil-swap-keys :recipe (:host github :repo "wbolster/evil-swap-keys"))
(package! evil-terminal-cursor-changer)
(package! dap-lldb :recipe (:host github :repo "emacs-lsp/dap-mode"))
(package! alert)
(package! org-wild-notifier)
(package! mini-modeline :recipe (:host github :repo "kiennq/emacs-mini-modeline"))
(package! lsp-treemacs)
(package! awesome-tab :recipe (:host github :repo "manateelazycat/awesome-tab"))
;;; packages.el ends here
