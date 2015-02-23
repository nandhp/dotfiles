;;
;; misc.init.el - Miscellaneous Emacs settings
;;

;; Default to unified diffs
(setq diff-switches "-u")

;;; Always end a file with a newline
;;(setq require-final-newline 'query)

;; Never use double-spaces between sentences.
(setq sentence-end-double-space nil)

;; Automatic (de)compression of files
(auto-compression-mode t)


;; Start emacsclient server
(server-start)

;;; Save minibuffer history between sessions.
;;(setq savehist-additional-variables     ; Also save searches
;;      '(search-ring regexp-search-ring))
;;(savehist-mode t)

;; Set the current working directory to HOME if running on a window system.
;; Needed in Emacs.app, which always defaults to /.
(if (and (window-system) (getenv "HOME"))
    (setq default-directory (concat (getenv "HOME") "/")))
