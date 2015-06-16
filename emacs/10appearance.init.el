;;
;; appearance.init.el - Set up frames, faces, and font-lock
;;

;; Disable extra window dressing. Use frame-alists due to a bug
;; unsetting menu/toolbar in Emacs 23.
(setq default-frame-alist '((width . 80) (height . 40)
			    (menu-bar-lines . 0) (tool-bar-lines . 0)))
;; Use reverse video (white-on-black) on graphical displays.
(setq window-system-default-frame-alist '((x (reverse . t))
                                          (ns (reverse . t))))
;; Alternate reverse-video method that doesn't work with emacs --daemon.
;;(if (window-system) (invert-face 'default))
;; Update initial frame from default-frame-alist
(setq initial-frame-alist
      (append default-frame-alist
              (cdr (assq (window-system) window-system-default-frame-alist))))

;; Insert buffer name into frame titles
(setq frame-title-format
      (concat  "%b - emacs@" (system-name)))

;; Turn on font-lock mode
(when (fboundp 'global-font-lock-mode)
  (global-font-lock-mode t))

;;; Enable visual feedback on selections
;;(setq transient-mark-mode t)

;; Disable the startup screen
(setq inhibit-startup-screen t)

;; Scrollbar on the right
(set-scroll-bar-mode 'right)

;; Show (mis)matching parens
(show-paren-mode t)
(set-face-attribute 'show-paren-match nil)

;; Display column number in mode line
(column-number-mode t)

;;; Highlight the current line (buggy)
;;(global-hl-line-mode t)

;;; Display line numbers in left margin (buggy)
;;(setq linum-format "%4d")
;;(global-linum-mode t)

;; Set faces
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((((type ns)) (:family "Menlo"))
	    (t (:height 97 :family "DejaVu Sans Mono"))))
 '(hl-line ((((background light)) (:background "gray95"))
            (((background dark)) (:background "gray10"))))
 '(show-paren-match ((((background light)) (:background "palegreen"))
                     (((background dark)) (:background "darkgreen"))))
 '(show-paren-mismatch ((((class color))
                         (:background "#C00" :foreground "white"))))
 '(tex-verbatim ((((type ns)) (:family "Menlo"))
		 (t (:family "DejaVu Sans Mono")))))
