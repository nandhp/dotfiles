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
                       sh-mode-hook emacs-lisp-mode-hook))
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

;; Make MATLAB mode less annoying
(setq matlab-auto-fill nil)

;; Use Markdown mode for Markdown files
(if (fboundp 'markdown-mode)
    (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode)))
