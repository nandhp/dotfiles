;;
;; flyspell.init.el - Enable Flyspell spell-checking
;;

;; Don't write a message when Flyspell is enabled
(setq flyspell-issue-message-flag nil)

;; Enable Flyspell in text-based buffers
(defun my-turn-on-flyspell ()
  (flyspell-mode 1)
  (flyspell-buffer))
(add-hook 'text-mode-hook 'my-turn-on-flyspell)
(add-hook 'LaTeX-mode-hook 'my-turn-on-flyspell)

;; Enable Flyspell for programming modes (comments and strings only)
(add-prog-hook 'flyspell-prog-mode)
