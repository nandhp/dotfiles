;;?install ~/.emacs.d/init.el
;;
;; init.el - Emacs initialization file
;;

(let ((default-directory "~/.emacs.d/lisp/"))
      (normal-top-level-add-subdirs-to-load-path))

;;; uncomment this line to disable loading of "default.el" at startup
;; (setq inhibit-default-init t)

<? run_parts("*.init.el", ";;") ?>

;; Custom will store its customizations here.
;; They should be merged, when appropriate.

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
)
