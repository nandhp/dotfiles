;;
;; clipboard.init.el - More consistent integration with X11 clipboard
;;

;; Use the clipboard, instead of the primary selection, for copy and paste.
(setq x-select-enable-clipboard t
      x-select-enable-primary nil)

;; Update the primary selection (based on the active region).
(setq select-active-regions t)

;; Have mouse-3 yanks from the primary selection.
(global-set-key [remap mouse-yank-at-click]
                'mouse-yank-primary)
