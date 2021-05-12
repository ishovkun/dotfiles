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
(package! evil-commentary)
(package! yascroll)
(package! evil-swap-keys :recipe (:host github :repo "wbolster/evil-swap-keys"))
(package! evil-terminal-cursor-changer)
(package! dap-lldb :recipe (:host github :repo "emacs-lsp/dap-mode"))
;; (package! eaf :recipe (:host github
;;                        :repo "manateelazycat/emacs-application-framework"
;;                        :files ("*")
;;                        :no-byte-compile t))
;;; packages.el ends here
