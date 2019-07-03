;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:fetcher github :repo "username/repo"))
;; (package! builtin-package :disable t)

;;; Code:
;; (package! doom-themes :ignore t)
(package! winum)
(package! ivy-posframe :recipe (:fetcher git :url "https://github.com/tumashu/ivy-posframe.git"))
(disable-packages! irony rtags)
(package! cquery)
(package! google-c-style) ; google c/c++ coding style
;; (package! company-box)
(package! company-lsp)

;;; packages.el ends here