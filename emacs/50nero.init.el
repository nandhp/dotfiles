;;
;; nero.init.el - Load Nero, an Emacs wrapper for Lynx
;;

;; nero-el uses lynx to display webpages. See also emacs-w3m.
(when (load "nero" 'noerror)
  (setq nero-default-flags "-display_charset=US-ASCII"))
