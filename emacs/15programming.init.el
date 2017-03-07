;;
;; programming.init.el - Support for programming in Emacs. Important.
;;

;; Show trailing whitespace so that it can be eliminated.
(setq-default show-trailing-whitespace t)

;; Tabs violate the Principle of Least Astonishment. Never use them.
(setq-default indent-tabs-mode nil)

;; Indent comments properly.
(setq-default c-comment-only-line-offset 'set-from-style)
(setq-default sh-indent-comment t)
;; FIXME: Comment indentation is still insane in python-mode

;; prog-mode is new in Emacs 24, so we have to enumerate the modes for now.
(setq prog-hook-list '(python-mode-hook perl-mode-hook
                       c-mode-common-hook js-mode-hook
                       sh-mode-hook emacs-lisp-mode-hook
                       octave-mode-hook))
(defun add-prog-hook (hook)
  (mapc (lambda (mode-hook) (add-hook mode-hook hook)) prog-hook-list))
;; FIXME: If running Emacs 24, just use prog-mode-hook instead

;; The tab support in Python mode is stupid
(defun my-python-mode ()
  (local-set-key (kbd "<backtab>") (if (fboundp 'python-indent-shift-left)
                                       'python-indent-shift-left
                                       'python-shift-left))
  ;(setq indent-line-function 'python-indent-line-1)
)
(add-hook 'python-mode-hook 'my-python-mode)

;; Fix comment syntax in CSS mode
(defun patch-css-mode-comment-syntax ()
  (when (and (not (string-suffix-p " " comment-start))
             (not (string-prefix-p " " comment-end)))
    (setq comment-start (concat comment-start " "))
    (setq comment-end (concat " " comment-end))))
(add-hook 'css-mode-hook 'patch-css-mode-comment-syntax)

;; Octave mode
;; See also http://ubuntuforums.org/showthread.php?t=1566508&page=3
(setq octave-block-offset 4)
(setq octave-continuation-string "...")
(setq octave-block-comment-start "% ")  ; Use %, not #, for comments
(setq octave-comment-start "% ")
(setq octave-comment-char 37)

;; Set comment-add to 0 to avoid Elisp-style distinguishing between %
;; and %%.
(defun my-octave-mode ()
  (setq-local comment-add 0))
(add-hook 'octave-mode-hook 'my-octave-mode)

;; Sometimes that is not enough, so advise octave-indent-comment to
;; always return nil.
(defadvice octave-indent-comment (around octave-dont-indent-commment ())
  "Don't indent comments."
  nil) ; (if (> ad-return-value 0) (setq ad-return-value 0)))
(ad-activate 'octave-indent-comment)

;; Use octave-mode for .m files, not MATLAB mode (if installed) or
;; Objective-C mode
(if (fboundp 'octave-mode)
    (add-to-list 'auto-mode-alist '("\\.m$" . octave-mode)))

;; Also make MATLAB mode less annoying, just in case
(setq matlab-auto-fill nil)

;; Use Markdown mode for Markdown files
(if (fboundp 'markdown-mode)
    (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode)))
