;;; init.el -*- lexical-binding: t; -*-

;; Copy this file to ~/.doom.d/init.el or ~/.config/doom/init.el ('doom
;; quickstart' will do this for you). The `doom!' block below controls what
;; modules are enabled and in what order they will be loaded. Remember to run
;; 'doom refresh' after modifying it.
;;
;; More information about these modules (and what flags they support) can be
;; found in modules/README.org.

(doom! :input
       ;;chinese
       ;;japanese
       ;;layout                ; auie,ctsrnm is the superior home row

       :completion
       company                 ; the ultimate code completion backend
       ;;helm                  ; the *other* search engine for love and life
       ;;ido                   ; the other *other* search engine...
       ;; vertico              ; the search engine of the future
       (ivy +icons)            ; a search engine for love and life

       :ui
       deft                    ; notational velocity for Emacs
       doom                    ; what makes DOOM look the way it does
       doom-dashboard          ; a nifty splash screen for Emacs
       ;; doom-quit            ; DOOM quit-message prompts when you quit Emacs
       ;; (emoji +unicode)     ; 🙂
       ;; fill-column          ; a `fill-column' indicator
       hl-todo                 ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW tags
       ;;hydra
       (:if IS-MAC ligatures   ; ligatures and symbols to make your code pretty again
        +iosevka)
       indent-guides           ; highlighted indent columns
       modeline                ; snazzy, Atom-inspired modeline, plus API
       nav-flash               ; blink the current line after jumping
       ;; neotree              ; a project drawer, like NERDTree for vim
       ophints                 ; highlight the region an operation acts on
       (popup                  ; tame sudden yet inevitable temporary windows
                               ; +all             ; catch all popups that start with an asterix
        +defaults)             ; default popup rules
       tabs                 ; an tab bar for Emacs
       (treemacs               ; a project drawer, like neotree but cooler
        +lsp)                  ; this should add breadcrumb icons
       ;;unicode               ; extended unicode support for various languages
       vc-gutter               ; vcs diff in the fringe
       vi-tilde-fringe         ; fringe tildes to mark beyond EOB
       window-select           ; visually switch windows
       workspaces              ; tab emulation, persistence & separate workspaces
       ;;zen                   ; distraction-free coding or writing

       :editor
       (evil +everywhere)      ; come to the dark side, we have cookies
       file-templates          ; auto-snippets for empty files
       ;; fold                 ; (nigh) universal code folding
       (format                 ; automated prettiness
       ;;+onsave               ; even prettier
       )
       ;;god                   ; run Emacs commands without modifier keys
       ;;lispy                 ; vim for lisp, for people who dont like vim
       ;; multiple-cursors     ; editing in many places at once
       ;;objed                 ; text object editing for the innocent
       ;;parinfer              ; turn lisp into python, sort of
       ;; rotate-text          ; cycle region at point between text candidates
       snippets                ; my elves. They type so I don't have to
       ;;word-wrap             ; soft wrapping with language-aware indent

       :emacs
       (dired                  ; making dired pretty [functional]
       +ranger                 ; bringing the goodness of ranger to dired
       +icons                  ; colorful icons for dired-mode
        )
       electric                ; smarter, keyword-based electric-indent
       undo                    ; persistent, smarter undo for your inevitable mistakes
       vc                      ; version-control and Emacs, sitting in a tree
       undo                    ; emacs-fu

       :term
       ;;eshell                ; a consistent, cross-platform shell (WIP)
       ;;shell                 ; a terminal REPL for Emacs
       ;;term                  ; terminals in Emacs
       vterm                   ; another terminals in Emacs

       :tools
       ;;ansible
       (debugger +lsp)         ; stepping through code, to help you add bugs
       ;;direnv
       docker
       editorconfig            ; let someone else argue about tabs vs spaces
       ein                     ; tame Jupyter notebooks with emacs
       (eval                   ; run code, run (also, repls)
        ;; +overlay
        )
       ;;gist                  ; interacting with github gists
       (lookup                 ; helps you navigate your code and documentation
        +docsets)              ; ...or in Dash docsets locally
       lsp
       lookup                  ; navigate your code and its documentation
       ;;macos                 ; MacOS-specific commands
       (magit +forge)          ; a git porcelain for Emacs
       make                    ; run make tasks from Emacs
       tty                     ; improve the terminal Emacs experience
       ;;pass                  ; password manager for nerds
       pdf                     ; pdf enhancements
       ;;prodigy               ; FIXME managing external services & code builders
       rgb                     ; creating color strings
       terraform             ; infrastructure as code
       tmux                    ; an API for interacting with tmux
       ;;upload                ; map local to remote projects via ssh/ftp
       ;;wakatime
       :checkers
       syntax                  ; tasing you for every semicolon you forget
       spell                   ; tasing you for misspelling mispelling
       grammar                 ; tasing grammar mistake every you make

       :os
       ;; (:if IS-MAC macos)   ; improve compatibility with macOS
       tty                     ; improve the terminal Emacs experience

       :lang
       ;;agda                  ; types of types of types of types...
       ;;assembly              ; assembly for fun or debugging
       (cc +lsp)               ; C > C++ == 1
       ;;clojure               ; java with a lisp
       ;;common-lisp           ; if you've seen one lisp, you've seen them all
       ;;coq                   ; proofs-as-programs
       ;;crystal               ; ruby at the speed of c
       ;;csharp                ; unity, .NET, and mono shenanigans
       data                    ; config/data formats
       ;;erlang                ; an elegant language for a more civilized age
       ;;elixir                ; erlang done right
       ;;elm                   ; care for a cup of TEA?
       emacs-lisp              ; drown in parentheses
       ;;ess                   ; emacs speaks statistics
       ;;fsharp                ; ML stands for Microsoft's Language
       ;;go                    ; the hipster dialect
       ;;(haskell +intero)     ; a language that's lazier than I am
       ;;hy                    ; readability of scheme w/ speed of python
       ;;idris             ;
       (java +meghanada +lsp)  ; the poster child for carpal tunnel syndrome
       ;;javascript            ; all(hope(abandon(ye(who(enter(here))))))
       ;;julia                 ; a better, faster MATLAB
       ;;kotlin                ; a better, slicker Java(Script)
       (latex +latexmk)
       ;;ledger                ; an accounting system in Emacs
       ;;lua                   ; one-based indices? one-based indices
       markdown                ; writing docs for people to ignore
       yaml                    ; tabulate my config
       ;;nim                   ; python + lisp at the speed of c
       ;;nix                   ; I hereby declare "nix geht mehr!"
       ;;ocaml                 ; an objective camel
       (org                    ; organize your plain life in plain text
        +dragndrop             ; drag & drop files/images into org buffers
        ;; +roam               ; dip inside my mind palace
        ;; +brain              ; Enables integration [[https://github.com/Kungsgeten/org-brain][org-brain]].
        ;; + jupyter           ; Enables Jupyter integration for babel.
        ;;
        +attach                ; custom attachment system
        +babel                 ; running code in org
        +capture               ; org-capture in and outside of Emacs
        +export                ; Exporting org to whatever you want
        +habit                 ; Keep track of your habits
        +present               ; Emacs for presentations
        +pretty                ; Enables pretty unicode symbols for bullets and priorities
        +protocol)             ; Support for org-protocol:// links
       ;;perl                  ; write code no one else can comprehend
       ;;php                   ; perl's insecure younger brother
       ;;plantuml              ; diagrams for confusing people more
       ;;purescript            ; javascript, but functional
       (python +lsp
               ;; +conda
               )    ; beautiful is better than ugly
       ;;qt                    ; the 'cutest' gui framework ever
       ;;racket                ; a DSL for DSLs
       ;;rest                  ; Emacs as a REST client
       ;;ruby                  ; 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}
       ;; (rust +lsp)             ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       ;;scala                 ; java, but good
       sh                      ; she sells {ba,z,fi}sh shells on the C xor
       ;;solidity              ; do you need a blockchain? No.
       ;;swift                 ; who asked for emoji variables?
       ;;terra                 ; Earth and Moon in alignment for performance.
       ;;web                   ; the tubes
       ;;vala                  ; GObjective-C

       :email
       ;;(mu4e +gmail)         ; WIP
       ;;notmuch               ; WIP
       ;;(wanderlust +gmail)   ; WIP

       ;; Applications are complex and opinionated modules that transform Emacs
       ;; toward a specific purpose. They may have additional dependencies and
       ;; should be loaded late.
       :app
       calendar
       ;; emms
       ;; everywhere           ; *leave* Emacs!? You must be joking (works only on X)
       ;;irc                   ; how neckbeards socialize
       ;;(rss +org)            ; emacs as an RSS reader
       ;;twitter               ; twitter client https://twitter.com/vnought
       ;;(write                ; emacs as a word processor (latex + org + markdown)
       ;; +wordnut             ; wordnet (wn) search
       ;; +langtool)           ; a proofreader (grammar/style check) for Emacs

       :collab
       ;;floobits              ; peer programming for a price
       ;;impatient-mode        ; show off code over HTTP

       :config
       ;; For literate config users. This will tangle+compile a config.org
       ;; literate config in your `doom-private-dir' whenever it changes.
       ;;literate

       ;; The default module sets reasonable defaults for Emacs. It also
       ;; provides a Spacemacs-inspired keybinding scheme and a smartparens
       ;; config. Use it as a reference for your own modules.
       (default +bindings +smartparens))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("c95043bcca81b664f7b394e88f888065aa80ba48b4f3a02ede30590399035a49" "2d1fe7c9007a5b76cea4395b0fc664d0c1cfd34bb4f1860300347cdad67fb2f9" "332e009a832c4d18d92b3a9440671873187ca5b73c2a42fbd4fc67ecf0379b8c" "70ed3a0f434c63206a23012d9cdfbe6c6d4bb4685ad64154f37f3c15c10f3b90" "2a3ffb7775b2fe3643b179f2046493891b0d1153e57ec74bbe69580b951699ca" "f951343d4bbe5a90dba0f058de8317ca58a6822faa65d8463b0e751a07ec887c" "071f5702a5445970105be9456a48423a87b8b9cfa4b1f76d15699b29123fb7d8" "b462d00de785490a0b6861807a360f5c1e05b48a159a99786145de7e3cce3afe" "f2b83b9388b1a57f6286153130ee704243870d40ae9ec931d0a1798a5a916e76" "1728dfd9560bff76a7dc6c3f61e9f4d3e6ef9d017a83a841c117bd9bebe18613" "f589e634c9ff738341823a5a58fc200341b440611aaa8e0189df85b44533692b" "f30aded97e67a487d30f38a1ac48eddb49fdb06ac01ebeaff39439997cbdd869" default)))
 '(safe-local-variable-values (quote ((helm-make-build-dir . "build/")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
