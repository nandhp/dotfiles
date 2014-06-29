;;
;; compat.init.el - Some compatibility across versions of Emacs.
;;

;; window-system is a function only in Emacs ~23.
(when (not (fboundp 'window-system))
  (defun window-system (&optional FRAME)
    "Compatibility shim for window-system function from Emacs 23.

Returns `window-system'. FRAME argument is ignored."
    window-system))

;; save-buffers-kill-terminal is new in Emacs ~23.
(when (not (fboundp 'save-buffers-kill-terminal))
  (defun save-buffers-kill-terminal (&optional ARG)
    "Compatibility shim. Runs `save-buffers-kill-emacs'."
    (interactive "P")
    (save-buffers-kill-emacs ARG)))

;; set-scroll-bar-mode is missing in the stock OS X build of Emacs 22.
(when (not (fboundp 'set-scroll-bar-mode))
  (defun set-scroll-bar-mode (VALUE)
    "Compatibility shim for missing set-scroll-bar-mode. Does nothing."))

;; Macros not available in Emacs 22, at least not in the stock OS X build.
(when (not (fboundp 'assert))
  (defmacro assert (FORM &optional SHOW-ARGS STRING &rest ARGS)
    "Compatibility shim. Does nothing."))

;; From http://stackoverflow.com/a/17080860/462117
(defmacro defun-with-optional-shift-selection (name args doc inter &rest body)
  "Like `defun' but enables shift selection, if supported.

Note that the documentation string and the `interactive' form
must be present. Requires a string literal as argument to
`interactive'.

See `this-command-keys-shift-translated' for the meaning of shift
translation.

This is implemented by adding the `^' token to the `interactive'
string, when shift selection is supported."
  `(defun ,name ,args
     ,doc
     ,(progn
        (assert (stringp doc))
        (assert (listp inter))
        (assert (eq (length inter) 2))
        (assert (eq (car inter) 'interactive))
        (let ((s (nth 1 inter)))
          (assert (stringp s))
          (if (fboundp 'handle-shift-selection)
              (setq s (concat "^" s)))
          (list 'interactive s)))
     ,@body))
