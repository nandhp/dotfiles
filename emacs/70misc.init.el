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

;; Uniquify buffer names using directory names instead of numbers
;; (new default in Emacs 24)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)
(require 'uniquify nil 'noerror)

;; Reenable backup files for files under version control
(setq vc-make-backup-files t)

;; Start emacsclient server
(server-start)

;;; Save minibuffer history between sessions.
(setq savehist-file "~/.emacs.d/history")
(setq savehist-additional-variables
      '(search-ring regexp-search-ring)) ; Also save searches
(savehist-mode t)

;; If browse-kill-ring is available, M-y will activate the kill-ring
;; browser if the previous command was not a yank.
(when (require 'browse-kill-ring nil 'noerror)
  (browse-kill-ring-default-keybindings)
  (setq browse-kill-ring-quit-action 'save-and-restore))

;; Set the current working directory to HOME if running on a window system.
;; Needed in Emacs.app, which always defaults to /.
(if (and (window-system) (getenv "HOME"))
    (setq default-directory (concat (getenv "HOME") "/")))
