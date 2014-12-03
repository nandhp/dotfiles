;;
;; keybindings.init.el - General key remappings.
;;

;; Don't use scrolling acceleration; the trackpad does enough of that.
(setq mouse-wheel-progressive-speed nil)

;; Navigate by real lines, not visual lines.
(setq line-move-visual nil)

;; Make C-a and <home> toggle between the real and logical beginning
;; of the line. (Smart Home)
;; http://emacsredux.com/blog/2013/05/22/smarter-navigation-to-the-beginning-of-a-line/
(defun-with-optional-shift-selection smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there."
  (interactive "p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; remap C-a and <home> to `smarter-move-beginning-of-line'
(global-set-key [remap move-beginning-of-line]
                'smarter-move-beginning-of-line)

;; From http://www.emacswiki.org/emacs/Scrolling#toc4 and
;; http://snarfed.org/emacs_page_up_page_down
;;
;; Note that emacs scrolling commands are named backwards. This
;; feature is built-in to Emacs 24.1.
(defun scroll-up-or-end (&optional arg)
  "Page down; if no more pages go to the end of the buffer."
  (interactive "P")
  (condition-case nil (scroll-up arg)
    (end-of-buffer (goto-char (point-max)))))
(defun scroll-down-or-home (&optional arg)
  "Page up; if no more pages go to the beginning of the buffer."
  (interactive "P")
  (condition-case nil (scroll-down arg)
    (beginning-of-buffer (goto-char (point-min)))))

;; Remap keybindings to use scroll-{up,down}-or-{home,end}
(global-set-key [remap scroll-up] 'scroll-up-or-end)
(global-set-key [remap scroll-down] 'scroll-down-or-home)

;; Emacs 24.1 version of the above
(setq scroll-error-top-bottom t)

;;; Simpler keybinding for goto-line
;;(global-set-key (kbd "M-g") 'goto-line) ; M-g n and M-g p: next/prev error

;; Use C-x _ to quit Emacs
(global-set-key (kbd "C-x _") 'save-buffers-kill-terminal)
(global-unset-key (kbd "C-x C-c"))

;;; Simpler keybindings for {find-file,switch-to-buffer}-other-window
;;(global-set-key (kbd "C-x M-f") 'find-file-other-window)
;;(global-set-key (kbd "C-x M-b") 'switch-to-buffer-other-window)

;; C-c C-o for compare-windows.
(global-set-key (kbd "C-c C-o") 'compare-windows)
(add-hook 'c-mode-common-hook ; c-mode redefines C-c C-o for c-set-offset
          (lambda () (local-set-key (kbd "C-c C-o") 'compare-windows)))

;; <f12> to make a buffer go away (without killing it)
(global-set-key (kbd "<f12>") 'bury-buffer)
