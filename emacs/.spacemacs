;; -*- mode: emacs-lisp; lexical-binding: t -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

(defun dotspacemacs/layers ()
  "Layer configuration:
This function should only modify configuration layer settings."
  (setq-default
   ;; Base distribution to use. This is a layer contained in the directory
   ;; `+distribution'. For now available distributions are `spacemacs-base'
   ;; or `spacemacs'. (default 'spacemacs)
   dotspacemacs-distribution 'spacemacs

   ;; Lazy installation of layers (i.e. layers are installed only when a file
   ;; with a supported type is opened). Possible values are `all', `unused'
   ;; and `nil'. `unused' will lazy install only unused layers (i.e. layers
   ;; not listed in variable `dotspacemacs-configuration-layers'), `all' will
   ;; lazy install any layer that support lazy installation even the layers
   ;; listed in `dotspacemacs-configuration-layers'. `nil' disable the lazy
   ;; installation feature and you have to explicitly list a layer in the
   ;; variable `dotspacemacs-configuration-layers' to install it.
   ;; (default 'unused)
   dotspacemacs-enable-lazy-installation 'unused

   ;; If non-nil then Spacemacs will ask for confirmation before installing
   ;; a layer lazily. (default t)
   dotspacemacs-ask-for-lazy-installation t

   ;; If non-nil layers with lazy install support are lazy installed.
   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (i.e. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()

   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(yaml
     html
     javascript
     cmake
     ;; ----------------------------------------------------------------
     ;; Example of useful layers you may want to use right away.
     ;; Uncomment some layer names and press `SPC f e R' (Vim style) or
     ;; `M-m f e R' (Emacs style) to install them.
     ;; ----------------------------------------------------------------
     helm
     ;; ivy
     markdown
     semantic
     auto-completion
     emacs-lisp
     git
     (latex :variables latex-enable-auto-fill nil)
     python
     (c-c++ :variables
            ;; c-c++-enable-clang-support t
            c-c++-backend 'lsp-cquery
            c-c++-adopt-subprojects t
            c-c++-lsp-executable "/usr/bin/cquery"
            c-c++-default-mode-for-headers 'c++-mode
            lsp-project-blacklist "/usr"
            c-c++-enable-google-style t)
     imenu-list
     ;; ycmd
     lsp
     dap
     ;; neotree
     (spell-checking :variables spell-checking-enable-by-default nil)
     (auto-completion :variables
                      auto-completion-enable-snippets-in-popup t
                      auto-completion-enable-help-tooltip t
                      auto-completion-enable-sort-by-usage t)
     spell-checking
     syntax-checking
     ;; markdown
     ranger
     org
     deft                               ; notes
     ;; google-calendar
     shell
     ;; (shell :variables
     ;;        shell-default-position 'bottom
     ;;        shell-default-height 30)     ;; syntax-checking
     version-control
     ;; w3m
     pdf
     )

   ;; List of additional packages that will be installed without being
   ;; wrapped in a layer. If you need some configuration for these
   ;; packages, then consider creating a layer. You can also put the
   ;; configuration in `dotspacemacs/user-config'.
   ;; To use a local version of a package, use the `:location' property:
   ;; '(your-package :location "~/path/to/your-package/")
   ;; Also include the dependencies as they will not be resolved automatically.
   dotspacemacs-additional-packages '(darkroom
                                      ag
                                      all-the-icons
                                      all-the-icons-dired
                                      doom-themes)
   ;; A list of packages that cannot be updated.
   dotspacemacs-frozen-packages '()

   ;; A list of packages and/or extensions that will not be install and loaded.
   dotspacemacs-excluded-packages '(wolfram-mode window-purpose)

   ;; Defines the behaviour of Spacemacs when installing packages.
   ;; Possible values are `used-only', `used-but-keep-unused' and `all'.
   ;; `used-only' installs only explicitly used packages and deletes any unused
   ;; packages as well as their unused dependencies. `used-but-keep-unused'
   ;; installs only the used packages but won't delete unused ones. `all'
   ;; installs *all* packages supported by Spacemacs and never uninstalls them.
   ;; (default is `used-only')
   dotspacemacs-install-packages 'used-only))

(defun dotspacemacs/init ()
  "Initialization:
This function is called at the very beginning of Spacemacs startup,
before layer configuration.
It should only modify the values of Spacemacs settings."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; If non-nil then enable support for the portable dumper. You'll need
   ;; to compile Emacs 27 from source following the instructions in file
   ;; EXPERIMENTAL.org at to root of the git repository.
   ;; (default nil)
   dotspacemacs-enable-emacs-pdumper nil

   ;; File path pointing to emacs 27.1 executable compiled with support
   ;; for the portable dumper (this is currently the branch pdumper).
   ;; (default "emacs-27.0.50")
   dotspacemacs-emacs-pdumper-executable-file "emacs-27.0.50"

   ;; Name of the Spacemacs dump file. This is the file will be created by the
   ;; portable dumper in the cache directory under dumps sub-directory.
   ;; To load it when starting Emacs add the parameter `--dump-file'
   ;; when invoking Emacs 27.1 executable on the command line, for instance:
   ;;   ./emacs --dump-file=~/.emacs.d/.cache/dumps/spacemacs.pdmp
   ;; (default spacemacs.pdmp)
   dotspacemacs-emacs-dumper-dump-file "spacemacs.pdmp"

   ;; If non-nil ELPA repositories are contacted via HTTPS whenever it's
   ;; possible. Set it to nil if you have no way to use HTTPS in your
   ;; environment, otherwise it is strongly recommended to let it set to t.
   ;; This variable has no effect if Emacs is launched with the parameter
   ;; `--insecure' which forces the value of this variable to nil.
   ;; (default t)
   dotspacemacs-elpa-https t

   ;; Maximum allowed time in seconds to contact an ELPA repository.
   ;; (default 5)
   dotspacemacs-elpa-timeout 5

   ;; Set `gc-cons-threshold' and `gc-cons-percentage' when startup finishes.
   ;; This is an advanced option and should not be changed unless you suspect
   ;; performance issues due to garbage collection operations.
   ;; (default '(100000000 0.1))
   dotspacemacs-gc-cons '(100000000 0.1)

   ;; If non-nil then Spacelpa repository is the primary source to install
   ;; a locked version of packages. If nil then Spacemacs will install the
   ;; latest version of packages from MELPA. (default nil)
   dotspacemacs-use-spacelpa nil

   ;; If non-nil then verify the signature for downloaded Spacelpa archives.
   ;; (default nil)
   dotspacemacs-verify-spacelpa-archives nil

   ;; If non-nil then spacemacs will check for updates at startup
   ;; when the current branch is not `develop'. Note that checking for
   ;; new versions works via git commands, thus it calls GitHub services
   ;; whenever you start Emacs. (default nil)
   dotspacemacs-check-for-update nil

   ;; If non-nil, a form that evaluates to a package directory. For example, to
   ;; use different package directories for different Emacs versions, set this
   ;; to `emacs-version'. (default 'emacs-version)
   dotspacemacs-elpa-subdirectory 'emacs-version

   ;; One of `vim', `emacs' or `hybrid'.
   ;; `hybrid' is like `vim' except that `insert state' is replaced by the
   ;; `hybrid state' with `emacs' key bindings. The value can also be a list
   ;; with `:variables' keyword (similar to layers). Check the editing styles
   ;; section of the documentation for details on available variables.
   ;; (default 'vim)
   dotspacemacs-editing-style 'hybrid

   ;; If non-nil output loading progress in `*Messages*' buffer. (default nil)
   dotspacemacs-verbose-loading nil

   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed. (default 'official)
   dotspacemacs-startup-banner 'official

   ;; List of items to show in startup buffer or an association list of
   ;; the form `(list-type . list-size)`. If nil then it is disabled.
   ;; Possible values for list-type are:
   ;; `recents' `bookmarks' `projects' `agenda' `todos'.
   ;; List sizes may be nil, in which case
   ;; `spacemacs-buffer-startup-lists-length' takes effect.
   dotspacemacs-startup-lists '((recents . 5)
                                (projects . 7))

   ;; True if the home buffer should respond to resize events. (default t)
   dotspacemacs-startup-buffer-responsive t

   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'text-mode

   ;; Initial message in the scratch buffer, such as "Welcome to Spacemacs!"
   ;; (default nil)
   dotspacemacs-initial-scratch-message nil

   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press `SPC T n' to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes
   '(
     ;; (palenight :location local)
     (one-dark :location local)
     ;; (cobalt2 :location local)
     doom-vibrant
     solarized-dark
     ;; dracula-theme
     spacemacs-dark
     solarized-dark
     spacemacs-light
     solarized-light
     monokai
     zenburn)

   ;; Set the theme for the Spaceline. Supported themes are `spacemacs',
   ;; `all-the-icons', `custom', `doom', `vim-powerline' and `vanilla'. The
   ;; first three are spaceline themes. `doom' is the doom-emacs mode-line.
   ;; `vanilla' is default Emacs mode-line. `custom' is a user defined themes,
   ;; refer to the DOCUMENTATION.org for more info on how to create your own
   ;; spaceline theme. Value can be a symbol or list with additional properties.
   ;; (default '(spacemacs :separator wave :separator-scale 1.5))
   ;; other separators at
   ;; https://github.com/syl20bnr/spacemacs/blob/develop/doc/DOCUMENTATION.org#powerline-separators
   dotspacemacs-mode-line-theme '(doom :separator arrow :separator-scale 1.1)
   ;; dotspacemacs-mode-line-theme '(spacemacs :separator arrow :separator-scale 1.1)
   ;; dotspacemacs-mode-line-theme '(all-the-icons :separator arrow :separator-scale 1.1)

   ;; If non-nil the cursor color matches the state color in GUI Emacs.
   ;; (default t)
   dotspacemacs-colorize-cursor-according-to-state t

   ;; Default font. `powerline-scale' allows to quickly tweak the mode-line
   ;; size to make separators look not too crappy.
   dotspacemacs-default-font '(
                    ;; ------------- inconsolata ------------------
                    ;; "Inconsolata"
                    ;; "Inconsolata LGC" ;; aur otf-inconsolata-lgc-git
                    ;; :size 28          ;; Inconsolata Laptop
                    ;; :size 16          ;; Inconsolata Desktop
                    ;; ------------- iosevka ------------------
                    "Iosevka SS04" ;; aur ttf-iosevka-ss04
                    :size 31       ;; iosevka Laptop
                    :weight bold
                    ;; :width extra-condensed
                    :powerline-scale 1.0)
   ;; The leader key
   dotspacemacs-leader-key "SPC"

   ;; The key used for Emacs commands `M-x' (after pressing on the leader key).
   ;; (default "SPC")
   ;; dotspacemacs-emacs-command-key "SPC"
   dotspacemacs-emacs-command-key ""

   ;; The key used for Vim Ex commands (default ":")
   dotspacemacs-ex-command-key ":"

   ;; The leader key accessible in `emacs state' and `insert state'
   ;; (default "M-m")
   dotspacemacs-emacs-leader-key "M-m"

   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it. (default ",")
   dotspacemacs-major-mode-leader-key ","

   ;; Major mode leader key accessible in `emacs state' and `insert state'.
   ;; (default "C-M-m")
   dotspacemacs-major-mode-emacs-leader-key "C-M-m"

   ;; These variables control whether separate commands are bound in the GUI to
   ;; the key pairs `C-i', `TAB' and `C-m', `RET'.
   ;; Setting it to a non-nil value, allows for separate commands under `C-i'
   ;; and TAB or `C-m' and `RET'.
   ;; In the terminal, these pairs are generally indistinguishable, so this only
   ;; works in the GUI. (default nil)
   dotspacemacs-distinguish-gui-tab nil

   ;; Name of the default layout (default "Default")
   dotspacemacs-default-layout-name "Default"

   ;; If non-nil the default layout name is displayed in the mode-line.
   ;; (default nil)
   dotspacemacs-display-default-layout nil

   ;; If non-nil then the last auto saved layouts are resumed automatically upon
   ;; start. (default nil)
   dotspacemacs-auto-resume-layouts nil

   ;; If non-nil, auto-generate layout name when creating new layouts. Only has
   ;; effect when using the "jump to layout by number" commands. (default nil)
   dotspacemacs-auto-generate-layout-names nil

   ;; Size (in MB) above which spacemacs will prompt to open the large file
   ;; literally to avoid performance issues. Opening a file literally means that
   ;; no major mode or minor modes are active. (default is 1)
   dotspacemacs-large-file-size 1

   ;; Location where to auto-save files. Possible values are `original' to
   ;; auto-save the file in-place, `cache' to auto-save the file to another
   ;; file stored in the cache directory and `nil' to disable auto-saving.
   ;; (default 'cache)
   dotspacemacs-auto-save-file-location 'cache

   ;; Maximum number of rollback slots to keep in the cache. (default 5)
   dotspacemacs-max-rollback-slots 5

   ;; If non-nil, `helm' will try to minimize the space it uses. (default nil)
   dotspacemacs-helm-resize nil

   ;; if non-nil, the helm header is hidden when there is only one source.
   ;; (default nil)
   dotspacemacs-helm-no-header nil

   ;; define the position to display `helm', options are `bottom', `top',
   ;; `left', or `right'. (default 'bottom)
   dotspacemacs-helm-position 'top

   ;; Controls fuzzy matching in helm. If set to `always', force fuzzy matching
   ;; in all non-asynchronous sources. If set to `source', preserve individual
   ;; source settings. Else, disable fuzzy matching in all sources.
   ;; (default 'always)
   dotspacemacs-helm-use-fuzzy 'always

   ;; If non-nil, the paste transient-state is enabled. While enabled, pressing
   ;; `p' several times cycles through the elements in the `kill-ring'.
   ;; (default nil)
   dotspacemacs-enable-paste-transient-state nil

   ;; Which-key delay in seconds. The which-key buffer is the popup listing
   ;; the commands bound to the current keystroke sequence. (default 0.4)
   dotspacemacs-which-key-delay 0.4

   ;; Which-key frame position. Possible values are `right', `bottom' and
   ;; `right-then-bottom'. right-then-bottom tries to display the frame to the
   ;; right; if there is insufficient space it displays it at the bottom.
   ;; (default 'bottom)
   dotspacemacs-which-key-position 'bottom

   ;; Control where `switch-to-buffer' displays the buffer. If nil,
   ;; `switch-to-buffer' displays the buffer in the current window even if
   ;; another same-purpose window is available. If non-nil, `switch-to-buffer'
   ;; displays the buffer in a same-purpose window even if the buffer can be
   ;; displayed in the current window. (default nil)
   dotspacemacs-switch-to-buffer-prefers-purpose nil

   ;; If non-nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil to boost the loading time. (default t)
   dotspacemacs-loading-progress-bar t

   ;; If non-nil the frame is fullscreen when Emacs starts up. (default nil)
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup nil

   ;; If non-nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil

   ;; If non-nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default nil) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup t
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-active-transparency 90

   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-inactive-transparency 90

   ;; If non-nil show the titles of transient states. (default t)
   dotspacemacs-show-transient-state-title t

   ;; If non-nil show the color guide hint for transient state keys. (default t)
   dotspacemacs-show-transient-state-color-guide t

   ;; If non-nil unicode symbols are displayed in the mode line.
   ;; If you use Emacs as a daemon and wants unicode characters only in GUI set
   ;; the value to quoted `display-graphic-p'. (default t)
   dotspacemacs-mode-line-unicode-symbols t

   ;; If non-nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters point
   ;; when it reaches the top or bottom of the screen. (default t)
   dotspacemacs-smooth-scrolling t

   ;; Control line numbers activation.
   ;; If set to `t' or `relative' line numbers are turned on in all `prog-mode' and
   ;; `text-mode' derivatives. If set to `relative', line numbers are relative.
   ;; This variable can also be set to a property list for finer control:
   ;; '(:relative nil
   ;;   :disabled-for-modes dired-mode
   ;;                       doc-view-mode
   ;;                       markdown-mode
   ;;                       org-mode
   ;;                       pdf-view-mode
   ;;                       text-mode
   ;;   :size-limit-kb 1000)
   ;; (default nil)
   dotspacemacs-line-numbers 'relative

   ;; Code folding method. Possible values are `evil' and `origami'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'evil

   ;; If non-nil `smartparens-strict-mode' will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode nil

   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc…
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis nil

   ;; Select a scope to highlight delimiters. Possible values are `any',
   ;; `current', `all' or `nil'. Default is `all' (highlight any scope and
   ;; emphasis the current one). (default 'all)
   dotspacemacs-highlight-delimiters 'all

   ;; If non-nil, start an Emacs server if one is not already running.
   ;; (default nil)
   dotspacemacs-enable-server nil

   ;; Set the emacs server socket location.
   ;; If nil, uses whatever the Emacs default is, otherwise a directory path
   ;; like \"~/.emacs.d/server\". It has no effect if
   ;; `dotspacemacs-enable-server' is nil.
   ;; (default nil)
   dotspacemacs-server-socket-dir nil

   ;; If non-nil, advise quit functions to keep server open when quitting.
   ;; (default nil)
   dotspacemacs-persistent-server nil

   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `rg', `ag', `pt', `ack' and `grep'.
   ;; (default '("rg" "ag" "pt" "ack" "grep"))
   dotspacemacs-search-tools '("rg" "ag" "pt" "ack" "grep")

   ;; Format specification for setting the frame title.
   ;; %a - the `abbreviated-file-name', or `buffer-name'
   ;; %t - `projectile-project-name'
   ;; %I - `invocation-name'
   ;; %S - `system-name'
   ;; %U - contents of $USER
   ;; %b - buffer name
   ;; %f - visited file name
   ;; %F - frame name
   ;; %s - process status
   ;; %p - percent of buffer above top of window, or Top, Bot or All
   ;; %P - percent of buffer above bottom of window, perhaps plus Top, or Bot or All
   ;; %m - mode name
   ;; %n - Narrow if appropriate
   ;; %z - mnemonics of buffer, terminal, and keyboard coding systems
   ;; %Z - like %z, but including the end-of-line format
   ;; (default "%I@%S")
   dotspacemacs-frame-title-format "%I@%S"

   ;; Format specification for setting the icon title format
   ;; (default nil - same as frame-title-format)
   dotspacemacs-icon-title-format nil

   ;; Delete whitespace while saving buffer. Possible values are `all'
   ;; to aggressively delete empty line and long sequences of whitespace,
   ;; `trailing' to delete only the whitespace at end of lines, `changed' to
   ;; delete only whitespace for changed lines or `nil' to disable cleanup.
   ;; (default nil)
   dotspacemacs-whitespace-cleanup 'trailing

   ;; Either nil or a number of seconds. If non-nil zone out after the specified
   ;; number of seconds. (default nil)
   dotspacemacs-zone-out-when-idle nil

   ;; Run `spacemacs/prettify-org-buffer' when
   ;; visiting README.org files of Spacemacs.
   ;; (default nil)
   dotspacemacs-pretty-docs nil))

(defun dotspacemacs/user-env ()
  "Environment variables setup.
This function defines the environment variables for your Emacs session. By
default it calls `spacemacs/load-spacemacs-env' which loads the environment
variables declared in `~/.spacemacs.env' or `~/.spacemacs.d/.spacemacs.env'.
See the header of this file for more information."
  (spacemacs/load-spacemacs-env))

(defun dotspacemacs/user-init ()
  "Initialization for user code:
This function is called immediately after `dotspacemacs/init', before layer
configuration.
It is mostly for variables that should be set before packages are loaded.
If you are unsure, try setting them in `dotspacemacs/user-config' first."
  )

(defun dotspacemacs/user-load ()
  "Library to load while dumping.
This function is called only while dumping Spacemacs configuration. You can
`require' or `load' the libraries of your choice that will be included in the
dump."
  )

(defun dotspacemacs/user-config ()
  "Configuration function for user code.
This function is called at the very end of Spacemacs initialization after
layers configuration.
This is the place where most of your configurations should be done. Unless it is
explicitly specified that a variable should be set before a package is loaded,
you should place your code here."

  ;; Some global settings
  (delete-selection-mode t)
  ;; no lock files
  (setq create-lockfiles nil)
  ;; ------------------- Text editing in emacs mode --------------------------
  (defun insert-new-line-below ()
    "inserts a new line below and moves cursor to its beginning"
    (interactive)
    (let ((oldpos (point)))
      (end-of-line)
      (newline-and-indent)))

  (defun insert-new-line-above ()
    "inserts a new line above and moves cursor to its beginning"
    (interactive)
    (let ((oldpos (point)))
      (beginning-of-line)
      (newline)
      (previous-line)
      (indent-for-tab-command)))

  (defun scroll-up-half-page ()
    (interactive)
    (evil-scroll-up nil)
    (evil-scroll-line-to-center
     (line-number-at-pos)))

  (defvar ao/v-dired-omit t
    "If dired-omit-mode enabled by default. Don't setq me.")

  ;; (defun ao/dired-omit-switch ()
  ;;   "this function is a small enhancement for `dired-omit-mode', which will
  ;;  \"remember\" omit state across Dired buffers."
  ;;   (interactive)
  ;;   (if (eq ao/v-dired-omit t)
  ;;       (setq ao/v-dired-omit nil)
  ;;     (setq ao/v-dired-omit t))
  ;;   (ao/dired-omit-caller)
  ;;   (when (equal major-mode 'dired-mode)
  ;;     (revert-buffer)))

  ;; (defun ao/dired-omit-caller ()
  ;;   (if ao/v-dired-omit
  ;;       (setq dired-omit-mode t)
  ;;     (setq dired-omit-mode nil)))

  ;; (defun ao/dired-back-to-top()
  ;;   "Move to the first file."
  ;;   (interactive)
  ;;   (beginning-of-buffer)
  ;;   (dired-next-line 2))

  ;; (defun ao/dired-jump-to-bottom()
  ;;   "Move to last file."
  ;;   (interactive)
  ;;   (end-of-buffer)
  ;;   (dired-next-line -1))

  (defun align-before-last-item (start end)
    (interactive "r")
    (align-regexp start end (concat "\\(\\s-*\\)" "[a-zA-Z_]+[;,]$")))

  (defun term-send-return()
    "send return"
    (interactive)
    (if (equal (point) (point-max))
      (comint-send-input)
      (progn (evil-goto-line)
       (evil-end-of-line))
      ))
  ;;----------------------------------------
  (defun switch-to-compilation-buffer (&optional arg)
    "Switch to the `*Compilation*' buffer.
if prefix argument ARG is given, switch to it in an other, possibly new window."
    (interactive "P")
    (with-current-buffer (get-buffer "*compilation*")
      (goto-char (point-max))
      (if arg
          (switch-to-buffer-other-window (current-buffer))
        (switch-to-buffer (current-buffer)))))

  (defun switch-to-eshell-buffer (&optional arg)
    "Switch to the `*Compilation*' buffer.
if prefix argument ARG is given, switch to it in an other, possibly new window."
    (interactive "P")
    (with-current-buffer (get-buffer "*eshell*")
      (goto-char (point-max))
      (if arg
          (switch-to-buffer-other-window (current-buffer))
        (switch-to-buffer (current-buffer)))))

  (defun switch-to-shell-buffer (&optional arg)
    "Switch to the `*Shell*' buffer.
if prefix argument ARG is given, switch to it in an other, possibly new window."
    (interactive "P")
    (with-current-buffer (get-buffer "*shell*")
      (goto-char (point-max))
      (if arg
          (switch-to-buffer-other-window (current-buffer))
        (switch-to-buffer (current-buffer)))))

  (defun switch-to-w3m-buffer (&optional arg)
    "Switch to the `*w3m*' buffer.
if prefix argument ARG is given, switch to it in an other, possibly new window."
    (interactive "P")
    (with-current-buffer (get-buffer "*w3m*")
      (goto-char (point-max))
      (if arg
          (switch-to-buffer-other-window (current-buffer))
        (switch-to-buffer (current-buffer)))))

  (defun kill-all-dired-buffers ()
    "Kill all dired buffers."
    (interactive)
    (save-excursion
      (let ((count 0))
        (dolist (buffer (buffer-list))
          (set-buffer buffer)
          (when (equal major-mode 'ranger-mode)
            (setq count (1+ count))
            (kill-buffer buffer)))
        (message "Killed %i dired buffer(s)." count)))
    (ranger-close))

	;; clear these weird carrige returns produced by windows editors (^M)
	(defun delete-fucking-ms ()
		(interactive)
		(save-excursion
			(goto-char 0)
			(while (search-forward "\r" nil :noerror)
				(replace-match ""))))

  (defun evil-paste-after-from-0 ()
    (interactive)
    (let ((evil-this-register ?0))
      (call-interactively 'evil-paste-after)))
  ;; ------------------- dealii prm ------------------------------------------
  ;; (load-file "~/.emacs.d/private/local/prm-mode/prm-mode.el")
  ;; (require 'prm-mode)
  ;; (add-to-list 'auto-mode-alist '("\\.prm$" . prm-mode))
  ;; --------------------- Eclipse .DATA -------------------------------------
  (load-file "~/.emacs.d/private/local/eclipse-mode.el")
  (require 'eclipse)
  ;; (autoload 'eclipse-mode "eclipse" "Enter ECLIPSE mode." t)
  (setq auto-mode-alist (cons '("\\.DATA\\'" . eclipse-mode) auto-mode-alist))
  (setq auto-mode-alist (cons '("\\.data\\'" . eclipse-mode) auto-mode-alist))
  (setq auto-mode-alist (cons '("\\.INC\\'" . eclipse-mode) auto-mode-alist))
  (setq auto-mode-alist (cons '("\\.inc\\'" . eclipse-mode) auto-mode-alist))
  (autoload 'eclipse-shell "eclipse" "Interactive ECLIPSE mode." t)
  ;; -------------------------- Javascript -----------------------------------
  (setq auto-mode-alist (cons '("\\.qml\\'" . javascript-mode) auto-mode-alist))
  ;; ------------------- term cursor -------------------------------------
  (unless (display-graphic-p)
    (load-file "~/.emacs.d/private/term-cursor.el/term-cursor.el")
    (require 'term-cursor)
    (global-term-cursor-mode)
    )
  ;; ------------------- silver searcher -------------------------------------
  (require 'ag)
  (define-key evil-normal-state-map (kbd "SPC p s") 'projectile-ag)
  (define-key evil-normal-state-map (kbd "SPC p S") 'ag-project-files)
  (define-key ag-mode-map (kbd "n") #'evil-search-next)
  ;; --------------------------- Python --------------------------------------
  ;; (if (eq system-type 'gnu/linux)
  ;;     (progn
  ;;       (setenv "PYTHONPATH" "/home/ishovkun/Dropbox/MyPython/")
  ;;       (setq python-shell-interpreter "/usr/bin/ipython3")
  ;;       )
  ;;   (message "not linux")
  ;;   )

  ;; (if (eq system-type 'windows-nt)
  ;;     (progn
  ;;       (setenv "PYTHONPATH" "c:/Users/is6645/Dropbox/MyPython/")
  ;;       (setq python-shell-interpreter
  ;;             "c:/Users/is6645/Documents/Soft/anaconda/Scripts/ipython.exe")
  ;;       )
  ;;   (message "not windows")
  ;;   )
  ;; ----------------------------- FCI ---------------------------------------
  (require 'fill-column-indicator)
  ;; (define-globalized-minor-mode
  ;;   global-fci-mode fci-mode (lambda () (fci-mode 1)))
  (add-hook 'python-mode-hook  (fci-mode 1))
  (add-hook 'freefem++-mode-hook  (fci-mode 1))
  (add-hook 'org-mode-hook  (fci-mode 1))
  (add-hook 'freefem++-mode-hook 'linum-mode)
  (add-hook 'text-mode-hook (lambda () (fci-mode -1)))
  (add-hook 'prog-mode-hook  (lambda () (fci-mode 1)))
  ;; ---------------------------- Deft ---------------------------------------
  (setq deft-directory "~/Dropbox/enotes")
  (setq deft-extensions '("org" "md"))
  ;; deft-auto-save-interval (default: 1.0).
  (setq deft-auto-save-interval 60.0)

  (setq deft-auto-save-buffers nil)
  (setq deft-use-filename-as-title nil)
  (setq deft-use-filter-string-for-filename t)
  (setq deft-file-naming-rules
        '((noslash . "-")
          (nospace . "-")
          (case-fn . downcase)))
  ;; to customize format: M-x customize-variables deft-time-format
  ;; set to " %m-%d"
  ;; ---------------------------- LaTeX --------------------------------------
  (auctex-latexmk-setup)
  (set-default 'preview-scale-function 3.0)
  (spacemacs/toggle-auto-fill-mode-off)
  ;; (setq latex-enable-auto-fill -1)
  ;; (word-wrap) ;; as opposed to characer wrap
  (add-hook 'text-mode-hook #'toggle-word-wrap)
  (add-hook 'text-mode-hook (lambda () (auto-fill-mode -1)))
  ;; bigger latex fragment
  (add-hook 'org-mode-hook (lambda ()
                             (plist-put org-format-latex-options :scale 3.0)
                             ))
  (setq org-startup-with-inline-images t)
  (evil-define-key 'normal org-mode-map (kbd ", .") 'org-toggle-latex-fragment)
  (evil-define-key 'normal latex-mode-map (kbd ", q") 'org-toggle-latex-fragment)
  (add-hook 'latex-mode-hook (lambda ()
                             (plist-put org-format-latex-options :scale 3.0)
                             ))
  (setq TeX-view-program-selection '((output-pdf "Okular")))
  ;; ---------------------------- ORG calendar --------------------------------------
  (setq org-gcal-client-id "1046223883337-g5m0oj48ri3g0blvpiker752kd39qv43.apps.googleusercontent.com"
        org-gcal-client-secret "zLRzWSYHzuQ4GG8qAJPFLjZY")
  (setq org-gcal-file-alist '(("igshov@gmail.com" . "/home/ishovkun/Dropbox/enotes/gmail_cal.org")))
  (setq org-agenda-files
        (quote ("/home/ishovkun/Dropbox/enotes/gmail_cal.org")))
  ;; ---------------------- Darkroom --------------------------------
  (require 'darkroom)
  ;; ---------------------- YCMD --------------------------------
  ;; build ycmd with ./build.py --clang-completer --system-libclang
  ;; (require 'ycmd)
  ;; (add-hook 'c++-mode-hook 'ycmd-mode)
  ;; (setq ycmd-server-command (list "python" (file-truename "~/build/ycmd/ycmd")))
  ;; (setq ycmd-server-command (list "python" (file-truename "/usr/share/ycmd/ycmd")))
  ;; (setq ycmd-force-semantic-completion t)
  ;; ----------------------------- imenu-list --------------------------
  (setq imenu-list-auto-resize nil)
  (setq imenu-list-size 0.2)
  ;; ----------------------------- doc-view ----------------------------
  (setq doc-view-continuous t)
  ;; ------------------------------ W3M --------------------------------
  ;; disable annoying confirmation about leaving secure page
  (setq w3m-confirm-leaving-secure-page nil)
  ;; W3M Home Page
  (setq w3m-home-page "https://www.google.com")
  ;; W3M default display images
  (setq w3m-default-display-inline-images t)
  (setq w3m-default-toggle-inline-images t)
  ;; W3M use cookies
  (setq w3m-command-arguments '("-cookie" "-F"))
  (setq w3m-use-cookies t)
  ;; Browse url function use w3m
  (setq browse-url-browser-function 'w3m-browse-url)
  ;; W3M view url new session in background
  (setq w3m-view-this-url-new-session-in-background t)
  ;; keys
  (with-eval-after-load 'w3m
    (define-key w3m-mode-map (kbd "f") 'ace-link-eww)
    (define-key w3m-mode-map (kbd "e") 'evil-scroll-up)
    (define-key w3m-mode-map (kbd "C-e") 'evil-scroll-up)
    (define-key w3m-mode-map (kbd "d") 'evil-scroll-down)
    (define-key w3m-mode-map (kbd "M-k") 'windmove-up)
    (define-key w3m-mode-map (kbd "M-n") 'w3m-next-buffer)
    (define-key w3m-mode-map (kbd "M-p") 'w3m-previous-buffer)
    (define-key w3m-mode-map (kbd "x") 'w3m-delete-buffer)
    (define-key w3m-mode-map (kbd "w") 'w3m-select-buffer)
    (evilified-state-evilify w3m-mode w3m-mode-map
      "f" 'ace-link-eww
      "C-e" 'evil-scroll-up
      "ww" 'w3m-select-buffer
      "H" 'w3m-view-previous-page
      "L" 'w3m-view-next-page
      )
    )
  ;; (ace-link-eww)
  ;; ----------------------------- Fixes ---------------------------------
  ;; Fix slow helm frame popup in emacs-26 helm issue #1976
  (when (= emacs-major-version 26)
    (setq x-wait-for-event-timeout nil))
  ;; workaround replace string bug
  ;; https://github.com/syl20bnr/spacemacs/issues/9700
  (setq frame-title-format nil)
  ;; scrolling
   ;;; scroll one line at a time (less "jumpy" than defaults)
  (setq mouse-wheel-scroll-amount '(2 ((shift) . 1))) ;; two lines at a time
  (setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
  (setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
  ;; Fix paste in vim visual
  (fset 'evil-visual-update-x-selection 'ignore)
  ;; use spaces instead of tabs
  (setq-default indent-tabs-mode nil)
  ;; cause I fucking hate it
  (turn-off-smartparens-strict-mode)
  ;; (add-hook 'darkroom-tentative-mode-hook 'spacemacs/toggle-line-numbers-off)
  ;; :q should kill the current buffer rather than quitting emacs entirely
  (evil-ex-define-cmd "q" 'kill-this-buffer)
  ;; Need to type out :quit to close emacs
  (evil-ex-define-cmd "quit" 'evil-quit)
  ;; line numbers in cmake-mode
  (add-hook 'cmake-mode-hook  'display-line-numbers-mode)
  ;; fix compilation mode position
 (add-hook 'c-mode-hook      (lambda () (purpose-mode -1)))
 (add-hook 'c++-mode-hook    (lambda () (purpose-mode -1)))
 (add-hook 'ranger-mode-hook (lambda () (purpose-mode -1)))
  ;; no asking for compilation directory
  (put 'helm-make-build-dir 'safe-local-variable 'stringp)
  ;; make compilation buffer stick to the frame
  (push '("\\*compilation\\*" . (nil (reusable-frames . t))) display-buffer-alist)
  ;; fix semantic auto complete bullshit
  (defun semantic-completion-advice (adviced-f &rest r)
    "Check if POINT it's inside a string or comment before calling semantic-*"
    (if (or (inside-string-q) (inside-comment-q))
        (not (message "Oleeee! do not call function, we're inside a string or comment!"))
      (apply adviced-f r)))
  (advice-add 'semantic-analyze-completion-at-point-function :around #'semantic-completion-advice)
  ;; work around rename bug
  (setq frame-title-format nil)
  ;; fix evil paste
  ;; (define-key evil-visual-state-map "p" 'evil-paste-after-from-0)
  ;; follow symlinks
  (setq vc-follow-symlinks t)
  ;; auto-exit comint mode when leaving insert mode
  (require 'company)
  (add-hook 'evil-normal-state-entry-hook '(lambda () (company-abort)))
  ;; ----------------------------- Ranger ------------------------------------
  (ranger-override-dired-mode t)
  (setq ranger-cleanup-eagerly t)
  ;; (setq ranger-cleanup-on-disable t)
  (setq ranger-parent-depth 0)

  (setq ranger-enter-with-minus nil)
  (setq ranger-show-hidden nil)
  (setq ranger-deer-show-details nil)
  (add-hook 'ranger-mode-hook (lambda () (purpose-mode -1)))
  (define-key dired-mode-map (kbd "<C-return>") 'spacemacs/open-file-or-directory-in-external-app)
  (define-key ranger-mode-map (kbd "<C-return>") 'spacemacs/open-file-or-directory-in-external-app)
  (define-key ranger-mode-map (kbd "C-t") 'ranger-new-tab)
  (define-key ranger-mode-map (kbd "C-w") 'ranger-close-tab)
  (define-key ranger-mode-map (kbd "J") 'ranger-next-tab)
  (define-key ranger-mode-map (kbd "K") 'ranger-prev-tab)
  (define-key ranger-mode-map (kbd "q") 'kill-all-dired-buffers)
  ;; (put 'dired-find-file-other-buffer 'disabled t)
  ;; zp - toggle details
  ;; zz show history
  (setq ranger-omit-regexp "^\.DS_Store$"
        ranger-excluded-extensions '("mkv" "iso" "mp4")
        ranger-deer-show-details nil
        ranger-max-preview-size 10)
  (add-hook 'ranger-mode-hook 'all-the-icons-dired-mode)
  (setq all-the-icons-color-icons t)
  ;; ----------------------------- Dired -------------------------------------
  ;; (require 'dired+)  ; Enable dired+
  ;; (setq dired-dwim-target t)            ; copy to another dired window
  ;; (diredp-toggle-find-file-reuse-dir 1)
  ;; (setq-default dired-omit-files-p 'nil)  ; Don't show hidden files by default
  ;; (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$\\|\\.pyc$"))
  ;; (add-hook 'dired-mode-hook 'ao/dired-omit-caller)
  ;; (define-key evil-normal-state-map (kbd "_") 'projectile-dired)
  ;; (define-key evil-normal-state-map (kbd "-") 'dired-jump)
  ;; (setq diredp-hide-details-initially-flag nil)
  ;; (eval-after-load "dired-mode"
  ;;   (evilified-state-evilify dired-mode dired-mode-map
  ;;            "f" 'helm-find-files
  ;;            "h" 'diredp-up-directory-reuse-dir-buffer
  ;;            "l" 'diredp-find-file-reuse-dir-buffer
  ;;            "I" 'ao/dired-omit-switch
  ;;            "zh" 'ao/dired-omit-switch
  ;;            "gg" 'ao/dired-back-to-top
  ;;            "G" 'ao/dired-jump-to-bottom
  ;;            )
  ;;   )
  ;; (define-key dired-mode-map (kbd "<C-return>") 'ergoemacs-open-in-external-app)
  ;; ----------------------- spell and syntax checking -----------------------
  (add-hook 'latex-mode-hook (lambda () (flyspell-mode t)))
  (add-hook 'org-mode-hook (lambda () (flyspell-mode t)))
  (add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++11")))
  ;; ----------------------------- Shell --------------------------------
  ;; spacemacs/helm-shell-history
  (evil-define-key 'normal comint-mode-map (kbd "<return>") 'term-send-return)
  (evil-define-key 'normal comint-mode-map (kbd "C-l") 'comint-clear-buffer)
  (evil-define-key 'normal comint-mode-map (kbd "C-e") 'evil-scroll-up)
  (evil-define-key 'hybrid comint-mode-map (kbd "C-w") 'clean-aindent--bsunindent)
  (evil-define-key 'normal comint-mode-map (kbd ", ,") 'spacemacs/helm-shell-history)
  (global-unset-key (kbd "C-r"))
  (evil-define-key 'normal comint-mode-map (kbd "C-r") 'spacemacs/helm-shell-history)
  (evil-define-key 'hybrid comint-mode-map (kbd "C-r") 'spacemacs/helm-shell-history)
  (evil-define-key 'normal eshell-mode-map (kbd "C-r") 'spacemacs/helm-eshell-history)
  (evil-define-key 'hybrid eshell-mode-map (kbd "C-r") 'spacemacs/helm-eshell-history)
  (evil-define-key 'normal eshell-mode-map (kbd "<return>") 'eshell-send-input)
  (eval-after-load "comint-mode"
    (evilified-state-evilify comint-mode comint-mode-map
      "," 'spacemacs/helm-shell-history
      )
    )
  (define-key comint-mode-map (kbd "<tab>") 'completion-at-point)
  ;; ----------------------------- Keybindings --------------------------------
  ;; show compilation window
  (define-key evil-normal-state-map (kbd "SPC b c") 'switch-to-compilation-buffer)
  (define-key evil-normal-state-map (kbd "SPC b t") 'switch-to-shell-buffer)
  (define-key evil-normal-state-map (kbd "SPC b e") 'switch-to-eshell-buffer)
  (global-set-key (kbd "<f7>") 'shell)
  (define-key evil-normal-state-map (kbd "SPC b w") 'switch-to-w3m-buffer)
  (savehist-mode 1)
  ;; add shortcuts to resize windows
  (global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
  (global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
  (global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
  (global-set-key (kbd "S-C-<down>") 'shrink-window)
  (global-set-key (kbd "S-C-<up>") 'enlarge-window)
  ;; scale font
  (global-set-key (kbd "C-=") 'spacemacs/scale-up-font)
  (global-set-key (kbd "C--") 'spacemacs/scale-down-font)

  ;; text editing
  (setq evil-escape-key-sequence "jk")
  (define-key evil-hybrid-state-map "\C-c" 'evil-normal-state)
  ;; (define-key company-mode-map "\C-f" ')
  (define-key evil-normal-state-map (kbd "SPC g g") 'goto-line)
  ;; helm
  (define-key evil-normal-state-map (kbd "SPC SPC") 'helm-mini)
  ;; (define-key evil-normal-state-map (kbd "SPC SPC") 'ivy-switch-buffer)
  ;; (define-key ivy-map (kbd "C-w") 'backward-kill-word)
  ;; (define-key ivy-map (kbd "C-j") 'helm-next-line)
  ;; (define-key ivy-map (kbd "C-k") 'helm-previous-line)
  ;; (define-key ivy-minibuffer-map (kbd "C-j") 'ivy-next-line)
  ;; (define-key ivy-minibuffer-map (kbd "C-k") 'ivy-previous-line)
  ;; (define-key ivy-minibuffer-map (kbd "<escape>") 'minibuffer-keyboard-quit)
  ;; (define-key helm-mode-map (kbd "C-w") 'backward-kill-word)
  (require 'helm)
  (define-key helm-map (kbd "C-w") 'backward-kill-word)
  (define-key helm-map (kbd "C-q") 'backward-delete-char-untabify)
  (define-key helm-map (kbd "C-j") 'helm-next-line)
  (define-key helm-map (kbd "C-k") 'helm-previous-line)

  (with-eval-after-load 'helm-swoop
    (define-key helm-swoop-map (kbd "C-w") 'backward-kill-word)
  )

  (define-key evil-hybrid-state-map (kbd "\C-o") 'insert-new-line-below)
  (define-key evil-hybrid-state-map (kbd "M-o") 'insert-new-line-above)
  ;; Set Alt-k to kill the line to the left
  ;; set shortcut to interrupt FreeFem running
  (with-eval-after-load 'freefem++-mode
    '(define-key ffpp-mode-map "\C-c\C-k" 'freefempp-interrupt-process))
  ;; Evil mode keys
  (define-key evil-normal-state-map (kbd "C-e") 'evil-scroll-up)
  (eval-after-load 'pdf-view
    '(define-key pdf-view-mode-map (kbd "e") 'pdf-view-scroll-down-or-previous-page)
    )
  (define-key evil-visual-state-map (kbd "C-e") 'evil-scroll-up)
  (define-key compilation-mode-map (kbd "C-e") 'scroll-up-half-page)
  (define-key evil-insert-state-map (kbd "C-q") 'backward-delete-char-untabify)
  ; j for gj and k for gk
  (define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
  (define-key evil-normal-state-map (kbd "SPC t d") 'darkroom-tentative-mode)
  (define-key evil-normal-state-map (kbd "$") 'evil-end-of-visual-line)
  (define-key evil-visual-state-map (kbd "$") 'evil-last-non-blank)
  (define-key evil-normal-state-map (kbd "0") 'evil-beginning-of-visual-line)
  (define-key evil-normal-state-map (kbd "SPC ;") 'evilnc-comment-or-uncomment-lines)
  (define-key evil-visual-state-map (kbd "SPC ;") 'evilnc-comment-or-uncomment-lines)
  (define-key evil-normal-state-map (kbd "C-s") 'save-buffer)
  (define-key evil-hybrid-state-map (kbd "C-s") 'save-buffer)
  (define-key evil-normal-state-map (kbd ">") 'evil-shift-right-line)
  (define-key evil-normal-state-map (kbd "<") 'evil-shift-left-line)
  (evil-define-key 'hybrid c++-mode-map (kbd "]") 'evil-forward-section-begin)
  (evil-define-key 'hybrid c++mode-map (kbd "[") 'evil-backward-section-begin)
  (evil-define-key 'hybrid c-mode-map (kbd "<f5>") 'recompile)
  (define-key evil-normal-state-map (kbd "M-n") 'next-buffer)
  (define-key evil-normal-state-map (kbd "M-p") 'previous-buffer)

  ;; evil keys in company mode
  (eval-after-load 'company
    '(define-key company-active-map (kbd "C-c h") #'company-quickhelp-manual-begin))

  (add-hook 'company-mode-hook ;; guessing
            '(lambda ()
               (define-key company-mode-map (kbd "C-j") 'company-select-next)
               (define-key company-mode-map (kbd "C-k") 'company-select-previous)
               (define-key company-active-map (kbd "C-w") 'backward-kill-word)
               ))
  ;; align
  (define-key evil-normal-state-map (kbd "SPC x a ;") 'align-before-last-item)
  ;; switch between buffers
  ;; (if (window-system)
  (setq evil-move-cursor-back nil)
  (global-set-key (kbd "M-k") 'windmove-up)
  (global-set-key (kbd "M-j") 'windmove-down)
  (global-set-key (kbd "M-l") 'windmove-right)
  (global-set-key (kbd "M-h") 'windmove-left)

  (define-key evil-normal-state-map (kbd "M-j") 'windmove-down)
  (define-key evil-normal-state-map (kbd "M-k") 'windmove-up)
  (define-key evil-normal-state-map (kbd "M-h") 'windmove-left)
  (define-key evil-normal-state-map (kbd "M-l") 'windmove-right)

  ;; replace surrounding symbols
  (define-key evil-normal-state-map (kbd "SPC (") 'evil-surround-change)
  ;; to work in term
  ;; (define-key evil-hybrid-state-map (kbd "M-h") 'windmove-left)
  ;; (define-key evil-hybrid-state-map (kbd "M-j") 'windmove-down)
  ;; (define-key evil-hybrid-state-map (kbd "M-k") 'windmove-up)
  ;; (define-key evil-hybrid-state-map (kbd "M-l") 'windmove-right)

  (add-hook 'org-mode-hook
            (lambda()
              (define-key evil-normal-state-local-map (kbd "M-j") 'windmove-down)
              (define-key evil-normal-state-local-map (kbd "M-k") 'windmove-up)
              (define-key evil-normal-state-local-map (kbd "M-h") 'windmove-left)
              (define-key evil-normal-state-local-map (kbd "M-l") 'windmove-right)
              ))

  ;; (define-key evil-normal-state-map (kbd "C-j") 'evil-scroll-line-down)
  (define-key evil-normal-state-map (kbd "C-j") 'scroll-up-line)
  (define-key evil-normal-state-map (kbd "C-k") 'scroll-down-line)
  ;; other window
  (define-key evil-normal-state-map (kbd "C-S-k") (lambda() (interactive)
                                                    (scroll-other-window-down 1)))
  (define-key evil-normal-state-map (kbd "C-S-j") (lambda() (interactive)
                                                    (scroll-other-window 1)))
  (define-key evil-normal-state-map (kbd "C-S-e") (lambda() (interactive)
                                                    (scroll-other-window-down 25)))
  (define-key evil-normal-state-map (kbd "C-S-d") (lambda() (interactive)
                                                    (scroll-other-window 25)))
  ;; dired doesn't listen to this key
  (define-key dired-mode-map (kbd "M-l") 'windmove-right)

  ;; toggle imenu-list
  (define-key evil-normal-state-map (kbd "C-\\") 'imenu-list-minor-mode)
  (global-set-key (kbd "C-\\") 'imenu-list-minor-mode)
  (define-key evil-normal-state-map (kbd "SPC (") 'evil-surround-change)

  ;; ----------------------------- GUI ----------------------------------------
  ;; add face for function call
  (defface font-lock-method-call-face
    '((t . (:foreground "orangered" :bold t)))

    "Face to display method calls in.")
  (font-lock-add-keywords 'c++-mode
                          `((,(concat
                               "\\<[_a-zA-Z][_a-zA-Z0-9]*\\>"       ; Object identifier
                               "\\s *"                              ; Optional white space
                               "\\(?:\\.\\|->\\)"                   ; Member access
                               "\\s *"                              ; Optional white space
                               "\\<\\([_a-zA-Z][_a-zA-Z0-9]*\\)\\>" ; Member identifier
                               "\\s *"                              ; Optional white space
                               "(")                                 ; Paren for method invocation
                             1 'font-lock-method-call-face t)))
  (global-set-key (kbd "C-=") 'spacemacs/scale-up-font)
  (global-set-key (kbd "C--") 'spacemacs/scale-down-font)
  ;; line spacing
  (add-text-properties (point-min) (point-max)
                       '(line-spacing 0.10 line-height 0.8))
  ;; padding in linum
  ;; (setq linum-format "%d ")
  (setq linum-relative-format "%3s ")
  ;; Style for c++ indentation
  ;; (push '(other . "google") c-default-style)
  (use-package google-c-style
    ;; provides the Google C/C++ coding style
    :ensure t
    :config
    (add-hook 'c-mode-common-hook 'google-set-c-style))

  ;; Fix terminal background
  ;; (custom-set-faces (if (not window-system) '(default ((t (:background "nil"))))))
  ;; (custom-set-faces (if (not window-system) '(linum  ((t (:background "nil"))))))
  ;; (custom-set-faces (if (not window-system) '(hl-line  ((t (:background "nil"))))))

  ;; spaceline
  (setq doom-modeline-buffer-file-name-style 'buffer-name)
  (setq doom-modeline-height 2)
  ;; (spaceline-toggle-minor-modes-off)
  ;; (spaceline-toggle-major-mode-on)
  ;; (spaceline-toggle-buffer-size-off)
  ;; (spaceline-toggle-buffer-id-on)
  ;; (spaceline-toggle-buffer-position-off)
  ;; (spaceline-toggle-anzu-on)
  ;;  maximum 68 lines (2-pane view on my laptop)
  (setq-default fill-column 78)
  ;; (setq fci-rule-color "#5682a3")
  (fci-make-overlay-strings)
  (fci-update-all-windows t)

  ;; (setq evil-normal-state-cursor '("#51afef" (box)))
  ;; (setq evil-normal-state-cursor '(box "#3F5E9D"))
  (setq evil-normal-state-cursor '("#51afef" box))
  (setq evil-hybrid-state-cursor '("#98be65" bar))
  (setq evil-visual-state-cursor '("#51afef" box))
  ;; (setq pdf-view-midnight-colors '("#abb2bf" . "#282c34"))
  ;; (setq evil-hybrid-state-cursor '("#98be65" (bar . 2)))
  ;; `(spacemacs-hybrid-face ((t (:foreground "#98be65" :background "#92f442" :inherit 'mode-line))))

  )

;; do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(defun dotspacemacs/emacs-custom-settings ()
  "Emacs custom settings.
This is an auto-generated function, do not modify its content directly, use
Emacs customize menu instead.
This function is called at the very end of Spacemacs initialization."
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#0a0814" "#f2241f" "#67b11d" "#b1951d" "#4f97d7" "#a31db1" "#28def0" "#b2b2b2"])
 '(evil-want-Y-yank-to-eol nil)
 '(hl-todo-keyword-faces
   (quote
    (("TODO" . "#dc752f")
     ("NEXT" . "#dc752f")
     ("THEM" . "#2d9574")
     ("PROG" . "#4f97d7")
     ("OKAY" . "#4f97d7")
     ("DONT" . "#f2241f")
     ("FAIL" . "#f2241f")
     ("DONE" . "#86dc2f")
     ("NOTE" . "#b1951d")
     ("KLUDGE" . "#b1951d")
     ("HACK" . "#b1951d")
     ("TEMP" . "#b1951d")
     ("FIXME" . "#dc752f")
     ("XXX" . "#dc752f")
     ("XXXX" . "#dc752f"))))
 '(package-selected-packages
   (quote
    (term-cursor zenburn-theme yasnippet-snippets writeroom-mode visual-fill-column web-mode solarized-theme pdf-tools tablist org-projectile org-download json-navigator google-translate evil-magit dumb-jump doom-modeline diff-hl define-word counsel-projectile counsel swiper ivy company-lsp cmake-ide centered-cursor-mode ace-link auctex smartparens flycheck company window-purpose helm helm-core lsp-mode magit powerline treemacs pfuture ace-window avy projectile dash org-plus-contrib hydra yapfify yaml-mode xterm-color ws-butler winum which-key web-beautify volatile-highlights vi-tilde-fringe uuidgen use-package treemacs-projectile treemacs-evil toc-org tagedit symon string-inflection stickyfunc-enhance srefactor spaceline-all-the-icons smeargle slim-mode shrink-path shell-pop scss-mode sass-mode restart-emacs ranger rainbow-delimiters pyvenv pytest pyenv-mode py-isort pug-mode prettier-js popwin pippel pipenv pip-requirements persp-mode pcre2el password-generator paradox overseer orgit org-present org-pomodoro org-mime org-category-capture org-bullets org-brain open-junk-file nameless multi-term move-text monokai-theme mmm-mode markdown-toc magit-svn magit-gitflow macrostep lsp-ui lorem-ipsum livid-mode live-py-mode link-hint levenshtein json-mode js2-refactor js-doc indent-guide importmagic impatient-mode imenu-list hungry-delete ht hl-todo highlight-parentheses highlight-numbers highlight-indentation hierarchy helm-xref helm-themes helm-swoop helm-rtags helm-pydoc helm-purpose helm-projectile helm-org-rifle helm-mode-manager helm-make helm-gitignore helm-git-grep helm-flx helm-descbinds helm-ctest helm-css-scss helm-company helm-c-yasnippet helm-ag google-c-style golden-ratio gnuplot gitignore-templates gitconfig-mode gitattributes-mode git-timemachine git-messenger git-link git-gutter-fringe git-gutter-fringe+ gh-md fuzzy font-lock+ flyspell-correct-helm flycheck-rtags flycheck-pos-tip flx-ido fill-column-indicator fancy-battery eyebrowse expand-region evil-visualstar evil-visual-mark-mode evil-unimpaired evil-tutor evil-surround evil-org evil-numbers evil-nerd-commenter evil-matchit evil-lisp-state evil-lion evil-indent-plus evil-iedit-state evil-goggles evil-exchange evil-escape evil-ediff evil-cleverparens evil-args evil-anzu eval-sexp-fu eshell-z eshell-prompt-extras esh-help emmet-mode elisp-slime-nav eldoc-eval editorconfig dotenv-mode doom-themes disaster diminish deft darkroom cython-mode cquery company-web company-tern company-statistics company-rtags company-quickhelp company-c-headers company-auctex company-anaconda column-enforce-mode cmake-mode clean-aindent-mode clang-format ccls browse-at-remote auto-yasnippet auto-highlight-symbol auto-dictionary auto-compile auctex-latexmk all-the-icons-dired aggressive-indent ag ace-jump-helm-line ac-ispell)))
 '(pdf-view-midnight-colors (quote ("#b2b2b2" . "#292b2e")) t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
)
