;; -*- mode: emacs-lisp -*-
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
   '(html
     javascript
     cmake
     ;; ----------------------------------------------------------------
     ;; Example of useful layers you may want to use right away.
     ;; Uncomment some layer names and press `SPC f e R' (Vim style) or
     ;; `M-m f e R' (Emacs style) to install them.
     ;; ----------------------------------------------------------------
     helm
     markdown
     semantic
     auto-completion
     better-defaults
     emacs-lisp
     git
     (latex :variables latex-enable-auto-fill nil)
     python
     (c-c++ :variables c-c++-enable-clang-support t
            c-c++-default-mode-for-headers 'c++-mode)
     imenu-list
     ycmd
     ;; neotree
     spell-checking
     (auto-completion :variables
                      auto-completion-enable-snippets-in-popup t
                      auto-completion-enable-sort-by-usage t)
     ;; markdown
     ranger
     org
     shell
     ;; (shell :variables
     ;;        shell-default-position 'bottom
     ;;        shell-default-height 30)     ;; syntax-checking
     version-control
     ;; w3m
     )

   ;; List of additional packages that will be installed without being
   ;; wrapped in a layer. If you need some configuration for these
   ;; packages, then consider creating a layer. You can also put the
   ;; configuration in `dotspacemacs/user-config'.
   ;; To use a local version of a package, use the `:location' property:
   ;; '(your-package :location "~/path/to/your-package/")
   ;; Also include the dependencies as they will not be resolved automatically.
   dotspacemacs-additional-packages '(darkroom
                                      ;; (dired+ :location "~/.emacs.d/elpa/26.1/dired+-20170818.1411")
                                      dracula-theme
                                      ag
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
     leuven
     monokai
     zenburn)
   ;; Set the theme for the Spaceline. Supported themes are `spacemacs',
   ;; `all-the-icons', `custom', `vim-powerline' and `vanilla'. The first three
   ;; are spaceline themes. `vanilla' is default Emacs mode-line. `custom' is a
   ;; user defined themes, refer to the DOCUMENTATION.org for more info on how
   ;; to create your own spaceline theme. Value can be a symbol or list with\
   ;; additional properties.
   ;; (default '(spacemacs :separator wave :separator-scale 1.5))
   ;; other separators at
   ;; https://github.com/syl20bnr/spacemacs/blob/develop/doc/DOCUMENTATION.org#powerline-separators
   dotspacemacs-mode-line-theme '(spacemacs :separator arrow :separator-scale 1.0)

   ;; If non-nil the cursor color matches the state color in GUI Emacs.
   ;; (default t)
   dotspacemacs-colorize-cursor-according-to-state t

   ;; Default font. `powerline-scale' allows to quickly tweak the mode-line
   ;; size to make separators look not too crappy.
   dotspacemacs-default-font '(
                     ;; "Meslo LG L DZ for Powerline" :size 19 :height 0
                     ;; "Inconsolata for Powerline"
                     "Inconsolata"
                     :size 32  ;; Inconsolata Laptop
                     ;; :size 16  ;; Inconsolata Desktop
                     :weight bold
                     ;; :width condensed
                     ;; :width extra-condensed
                     :powerline-scale 2)
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
   dotspacemacs-helm-position 'bottom

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

  (defun select-current-line ()
    "Select current line."
    (interactive)
    (back-to-indentation)
    (set-mark (line-end-position))
    (exchange-point-and-mark)
    )

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

  ;; (defvar ao/v-dired-omit t
  ;;   "If dired-omit-mode enabled by default. Don't setq me.")

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

  ;; (defun align-before-last-item (start end)
  ;;   (interactive "r")
  ;;   (align-regexp start end (concat "\\(\\s-*\\)" "[a-zA-Z_]+[;,]$")))

  (defun term-send-return()
    "send execute"
    (interactive)
    (evil-goto-line)
    (comint-send-input))
  ;;----------------------------------------
  ;;Open file by C-return in external application
  (defun ergoemacs-open-in-external-app ()
    "Open the current file or dired marked files in external app."
    (interactive)
    (let ( doIt
          (myFileList
            (cond
            ((string-equal major-mode "dired-mode") (dired-get-marked-files))
            (t (list (buffer-file-name))) ) ) )

      (setq doIt (if (<= (length myFileList) 5)
                    t
                  (y-or-n-p "Open more than 5 files?") ) )

      (when doIt
        (cond
        ((string-equal system-type "windows-nt")
          (mapc (lambda (fPath) (w32-shell-execute "open" (replace-regexp-in-string "/" "\\" fPath t t)) ) myFileList)
          )
        ((string-equal system-type "darwin")
          (mapc (lambda (fPath) (shell-command (format "open \"%s\"" fPath)) )  myFileList) )
        ((string-equal system-type "gnu/linux")
          (mapc (lambda (fPath) (let ((process-connection-type nil)) (start-process "" nil "xdg-open" fPath)) ) myFileList) ) ) ) ) )

  (defun switch-to-compilation-buffer (&optional arg)
    "Switch to the `*Compilation*' buffer.
if prefix argument ARG is given, switch to it in an other, possibly new window."
    (interactive "P")
    (with-current-buffer (get-buffer "*compilation*")
      (goto-char (point-max))
      (if arg
          (switch-to-buffer-other-window (current-buffer))
        (switch-to-buffer (current-buffer)))))

  (defun switch-to-shell-buffer (&optional arg)
    "Switch to the `*Compilation*' buffer.
if prefix argument ARG is given, switch to it in an other, possibly new window."
    (interactive "P")
    (with-current-buffer (get-buffer "*shell*")
      (goto-char (point-max))
      (if arg
          (switch-to-buffer-other-window (current-buffer))
        (switch-to-buffer (current-buffer)))))
  ;; ------------------- dealii prm ------------------------------------------
  ;; (load-file "~/.emacs.d/private/local/prm-mode/prm-mode.el")
  ;; (require 'prm-mode)
  ;; (add-to-list 'auto-mode-alist '("\\.prm$" . prm-mode))
  ;; ------------------- silver searcher -------------------------------------
  (require 'ag)
  (define-key evil-normal-state-map (kbd "SPC p s") 'projectile-ag)
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
  ;; ---------------------------- LaTeX --------------------------------------
  (auctex-latexmk-setup)
  (set-default 'preview-scale-function 2.0)
  (spacemacs/toggle-auto-fill-mode-off)
  ;; (setq latex-enable-auto-fill -1)
  ;; (word-wrap) ;; as opposed to characer wrap
  (add-hook 'text-mode-hook #'toggle-word-wrap)
  (add-hook 'text-mode-hook (lambda () (auto-fill-mode -1)))
  ;; bigger latex fragment
  (add-hook 'org-mode-hook (lambda ()
                             (plist-put org-format-latex-options :scale 2.0)
                             ))
  ;; ---------------------- Darkroom --------------------------------
  (require 'darkroom)
  ;; ---------------------- YCMD --------------------------------
  ;; build ycmd with ./build.py --clang-completer --system-libclang
  (require 'ycmd)
  (add-hook 'c++-mode-hook 'ycmd-mode)
  ;; (setq ycmd-server-command '("python" "-u" "/home/ishovkun/build/ycmd/ycmd"))
  (setq ycmd-server-command (list "python" (file-truename "~/build/ycmd/ycmd")))
  (setq ycmd-force-semantic-completion t)
  ;; ----------------------------- imenu-list --------------------------
  (setq imenu-list-auto-resize nil)
  (setq imenu-list-size 0.2)
  ;; ----------------------------- doc-view ----------------------------
  (setq doc-view-continuous t)
  ;; ------------------------------ W3M --------------------------------
  ;; (setq w3m-home-page "https://www.google.com")
  ;; ;; W3M Home Page
  ;; (setq w3m-default-display-inline-images t)
  ;; (setq w3m-default-toggle-inline-images t)
  ;; ;; W3M default display images
  ;; (setq w3m-command-arguments '("-cookie" "-F"))
  ;; (setq w3m-use-cookies t)
  ;; ;; W3M use cookies
  ;; (setq browse-url-browser-function 'w3m-browse-url)
  ;; ;; Browse url function use w3m
  ;; (setq w3m-view-this-url-new-session-in-background t)
  ;; ;; W3M view url new session in background

  ;; ----------------------------- Fixes ---------------------------------
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
  (add-hook 'c++-mode-hook (lambda () (purpose-mode nil)))
  ;; no asking for compilation directory
  (put 'helm-make-build-dir 'safe-local-variable 'stringp)
  ;; ----------------------------- Ranger ------------------------------------
  (ranger-override-dired-mode t)
  (setq ranger-cleanup-eagerly t)
  (setq ranger-cleanup-on-disable t)
  (setq ranger-enter-with-minus t)
  (setq ranger-show-hidden nil)
  (setq ranger-deer-show-details nil)
  (define-key dired-mode-map (kbd "<C-return>") 'ergoemacs-open-in-external-app)
  ;; (define-key dired-mode-map (kbd "J") 'ranger-next-tab)
  ;; (define-key dired-mode-map (kbd "K") 'ranger-prev-rab)
  ;; zp - toggle details
  ;; zz show history
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
  ;;            "za" 'ao/dired-omit-switch
  ;;            "gg" 'ao/dired-back-to-top
  ;;            "G" 'ao/dired-jump-to-bottom
  ;;            )
  ;;   )
  ;; ----------------------------- Keybindings --------------------------------
  ;; show compilation window
  (define-key evil-normal-state-map (kbd "SPC b c") 'switch-to-compilation-buffer)
  (define-key evil-normal-state-map (kbd "SPC b t") 'switch-to-shell-buffer)
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
  (require 'helm)
  (require 'helm-swoop)
  (define-key evil-normal-state-map (kbd "SPC SPC") 'helm-mini)
  (define-key helm-map (kbd "C-w") 'backward-kill-word)
  (define-key helm-map (kbd "C-q") 'backward-delete-char-untabify)
  (define-key helm-map (kbd "C-j") 'helm-next-line)
  (define-key helm-map (kbd "C-k") 'helm-previous-line)
  (define-key helm-swoop-map (kbd "C-w") 'backward-kill-word)
  (define-key helm-swoop-map (kbd "C-q") 'backward-delete-char-untabify)
  (define-key evil-hybrid-state-map (kbd "\C-o") 'insert-new-line-below)
  (define-key evil-hybrid-state-map (kbd "M-o") 'insert-new-line-above)
  ; Set Alt-k to kill the line to the left
  ;; set shortcut to interrupt FreeFem running
  (eval-after-load 'freefem++-mode
    '(define-key ffpp-mode-map "\C-c\C-k" 'freefempp-interrupt-process))
  ;; Evil mode keys
  (define-key evil-normal-state-map (kbd "C-e") 'scroll-up-half-page)
  (define-key evil-visual-state-map (kbd "C-e") 'scroll-up-half-page)
  (define-key compilation-mode-map (kbd "C-e") 'scroll-up-half-page)
  (define-key evil-insert-state-map (kbd "C-q") 'backward-delete-char-untabify)
  ; j for gj and k for gk
  (define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
  (define-key evil-normal-state-map (kbd "SPC t d") 'darkroom-tentative-mode)
  (define-key evil-normal-state-map (kbd "$") 'evil-end-of-visual-line)
  (define-key evil-normal-state-map (kbd "0") 'evil-beginning-of-visual-line)
  (define-key evil-normal-state-map (kbd "SPC ;") 'evilnc-comment-or-uncomment-lines)
  (define-key evil-visual-state-map (kbd "SPC ;") 'evilnc-comment-or-uncomment-lines)
  (define-key evil-normal-state-map (kbd "C-s") 'save-buffer)
  (define-key evil-normal-state-map (kbd ">") 'evil-shift-right-line)
  (define-key evil-normal-state-map (kbd "<") 'evil-shift-left-line)
  ;; evil keys in company mode

  (add-hook 'company-mode-hook ;; guessing
            '(lambda ()
               (define-key company-mode-map (kbd "C-j") 'company-select-next)
               (define-key company-mode-map (kbd "C-k") 'company-select-previous)
               ))
  ;; (eval-after-load "company-mode"
  ;;     '(progn
  ;;       (define-key company-mode-map (kbd "C-j") 'company-select-next)
  ;;       (define-key company-mode-map (kbd "C-k") 'company-select-previous)
  ;;       ))
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

  ;; to work in term
(evil-define-key 'normal comint-mode-map (kbd "<return>") 'term-send-return)
  ;; (define-key evil-hybrid-state-map (kbd "M-h") 'windmove-left)
  ;; (define-key evil-hybrid-state-map (kbd "M-j") 'windmove-down)
  ;; (define-key evil-hybrid-state-map (kbd "M-k") 'windmove-up)
  ;; (define-key evil-hybrid-state-map (kbd "M-l") 'windmove-right)


  (add-hook 'org-mode-hook (lambda()
                             (define-key evil-normal-state-local-map (kbd "M-j") 'windmove-down)
                             (define-key evil-normal-state-local-map (kbd "M-k") 'windmove-up)
                             (define-key evil-normal-state-local-map (kbd "M-h") 'windmove-left)
                             (define-key evil-normal-state-local-map (kbd "M-l") 'windmove-right)
                             ))

  ;; (define-key evil-normal-state-map (kbd "C-j") 'evil-scroll-line-down)
  (define-key evil-normal-state-map (kbd "C-j") 'scroll-up-line)
  (define-key evil-normal-state-map (kbd "C-k") 'scroll-down-line)
  ;; dired doesn't listen to this key
  (define-key dired-mode-map (kbd "M-l") 'windmove-right)

  ;; toggle imenu-list
  (define-key evil-normal-state-map (kbd "C-\\") 'imenu-list-minor-mode)
  (global-set-key (kbd "C-\\") 'imenu-list-minor-mode)
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
  (custom-set-faces (if (not window-system) '(default ((t (:background "nil"))))))
  (custom-set-faces (if (not window-system) '(linum  ((t (:background "nil"))))))
  (custom-set-faces (if (not window-system) '(hl-line  ((t (:background "nil"))))))
  ;; spaceline
  ;; (setq spaceline-major)
  ;; (spaceline-toggle-major-mode-off)
  (spaceline-toggle-minor-modes-off)
  (spaceline-toggle-major-mode-on)
  (spaceline-toggle-buffer-size-off)
  (spaceline-toggle-buffer-id-on)
  (spaceline-toggle-buffer-position-off)
  (spaceline-toggle-anzu-on)
  ;;  maximum 68 lines (2-pane view on my laptop)
  (setq-default fill-column 78)
  ;; (setq fci-rule-color "#5682a3")
  (fci-make-overlay-strings)
  (fci-update-all-windows t)

  ;; (setq evil-normal-state-cursor '("#51afef" (box)))
  ;; (setq evil-normal-state-cursor '(box "#3F5E9D"))
  ;; (setq evil-hybrid-state-cursor '("chartreuse3" (bar . 2)))
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
 '(package-selected-packages
   (quote
    (ranger ag yapfify xterm-color ws-butler winum which-key web-mode web-beautify volatile-highlights vi-tilde-fringe uuidgen use-package unfill toc-org tagedit stickyfunc-enhance srefactor spaceline powerline smeargle slim-mode shell-pop scss-mode sass-mode restart-emacs rainbow-delimiters pyvenv pytest pyenv-mode py-isort pug-mode popwin pip-requirements persp-mode pcre2el paradox spinner orgit org-projectile org-category-capture org-present org-pomodoro alert log4e gntp org-plus-contrib org-mime org-download org-bullets open-junk-file neotree mwim multi-term move-text mmm-mode markdown-toc markdown-mode magit-gitflow macrostep lorem-ipsum livid-mode skewer-mode simple-httpd live-py-mode linum-relative link-hint json-mode json-snatcher json-reformat js2-refactor multiple-cursors js2-mode js-doc indent-guide imenu-list hydra hy-mode hungry-delete htmlize hl-todo highlight-parentheses highlight-numbers parent-mode highlight-indentation helm-themes helm-swoop helm-pydoc helm-projectile helm-mode-manager helm-make projectile helm-gitignore helm-flx helm-descbinds helm-css-scss helm-company helm-c-yasnippet helm-ag haml-mode google-translate golden-ratio gnuplot gitignore-mode gitconfig-mode gitattributes-mode git-timemachine git-messenger git-link git-gutter-fringe+ git-gutter-fringe fringe-helper git-gutter+ git-gutter gh-md fuzzy flyspell-correct-helm flyspell-correct flx-ido flx fill-column-indicator fancy-battery eyebrowse expand-region exec-path-from-shell evil-visualstar evil-visual-mark-mode evil-unimpaired evil-tutor evil-surround evil-search-highlight-persist evil-numbers evil-nerd-commenter evil-mc evil-matchit evil-magit magit magit-popup git-commit ghub with-editor evil-lisp-state smartparens evil-indent-plus evil-iedit-state iedit evil-exchange evil-escape evil-args evil-anzu anzu evil goto-chg undo-tree eval-sexp-fu highlight eshell-z eshell-prompt-extras esh-help emmet-mode elisp-slime-nav dumb-jump dracula-theme doom-themes all-the-icons memoize disaster diminish diff-hl define-word darkroom cython-mode company-ycmd ycmd pkg-info request-deferred request deferred epl company-web web-completion-data company-tern dash-functional tern company-statistics company-c-headers company-auctex company-anaconda company column-enforce-mode coffee-mode cmake-mode clean-aindent-mode clang-format bind-map bind-key auto-yasnippet yasnippet auto-highlight-symbol auto-dictionary auto-compile packed auctex anaconda-mode pythonic f dash s aggressive-indent adaptive-wrap ace-window ace-link ace-jump-helm-line helm avy helm-core async ac-ispell auto-complete popup))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (ag yapfify xterm-color ws-butler winum which-key web-mode web-beautify volatile-highlights vi-tilde-fringe uuidgen use-package unfill toc-org tagedit stickyfunc-enhance srefactor spaceline powerline smeargle slim-mode shell-pop scss-mode sass-mode restart-emacs rainbow-delimiters pyvenv pytest pyenv-mode py-isort pug-mode popwin pip-requirements persp-mode pcre2el paradox spinner orgit org-projectile org-category-capture org-present org-pomodoro alert log4e gntp org-plus-contrib org-mime org-download org-bullets open-junk-file neotree mwim multi-term move-text mmm-mode markdown-toc markdown-mode magit-gitflow macrostep lorem-ipsum livid-mode skewer-mode simple-httpd live-py-mode linum-relative link-hint json-mode json-snatcher json-reformat js2-refactor multiple-cursors js2-mode js-doc indent-guide imenu-list hydra hy-mode hungry-delete htmlize hl-todo highlight-parentheses highlight-numbers parent-mode highlight-indentation helm-themes helm-swoop helm-pydoc helm-projectile helm-mode-manager helm-make projectile helm-gitignore helm-flx helm-descbinds helm-css-scss helm-company helm-c-yasnippet helm-ag haml-mode google-translate golden-ratio gnuplot gitignore-mode gitconfig-mode gitattributes-mode git-timemachine git-messenger git-link git-gutter-fringe+ git-gutter-fringe fringe-helper git-gutter+ git-gutter gh-md fuzzy flyspell-correct-helm flyspell-correct flx-ido flx fill-column-indicator fancy-battery eyebrowse expand-region exec-path-from-shell evil-visualstar evil-visual-mark-mode evil-unimpaired evil-tutor evil-surround evil-search-highlight-persist evil-numbers evil-nerd-commenter evil-mc evil-matchit evil-magit magit magit-popup git-commit ghub with-editor evil-lisp-state smartparens evil-indent-plus evil-iedit-state iedit evil-exchange evil-escape evil-args evil-anzu anzu evil goto-chg undo-tree eval-sexp-fu highlight eshell-z eshell-prompt-extras esh-help emmet-mode elisp-slime-nav dumb-jump dracula-theme doom-themes all-the-icons memoize disaster diminish diff-hl define-word darkroom cython-mode company-ycmd ycmd pkg-info request-deferred request deferred epl company-web web-completion-data company-tern dash-functional tern company-statistics company-c-headers company-auctex company-anaconda company column-enforce-mode coffee-mode cmake-mode clean-aindent-mode clang-format bind-map bind-key auto-yasnippet yasnippet auto-highlight-symbol auto-dictionary auto-compile packed auctex anaconda-mode pythonic f dash s aggressive-indent adaptive-wrap ace-window ace-link ace-jump-helm-line helm avy helm-core async ac-ispell auto-complete popup \(one-dark\ :location\ local\)-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
