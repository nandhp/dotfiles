;;
;; tramp.init.el - Emacs settings relating to tramp-mode
;;

;; Allow tramp to sudo on remote machines. Note that this will cause
;; local sudo access to be done over SSH to localhost.
(setq tramp-default-proxies-alist '((".*" "\\`root\\'" "/ssh:%h:")))

;; When run in daemon mode at boot, Emacs won't have access to a
;; running SSH agent. run-emacs can do "agent forwarding" by using
;; emacsclient to pass the current value of SSH_AUTH_SOCK to the
;; ssh-agent-maybe-change-socket function.
;;
;; FIXME: Keep a ring of saved ssh-agents and hook into tramp-mode to
;; switch to the most recent working one.
(defun ssh-agent-check-socket (&optional SOCK)
    "Return t if SOCK is set and points to an existing maybe-socket.

If SOCK is not given or nil, use the SSH_AUTH_SOCK environment variable."
    (let ((sock (or SOCK (getenv "SSH_AUTH_SOCK"))))
      (and sock
           (file-exists-p sock)
           (file-readable-p sock)
           ;; FIXME: Is there really no file-socket-p?
           (not (file-regular-p sock))
           (not (file-directory-p sock)))))
(defun ssh-agent-maybe-change-socket (SOCK)
    "Update the value of SSH_AUTH_SOCK to SOCK if it is a better choice."
    (when (and (not (ssh-agent-check-socket))
               (ssh-agent-check-socket SOCK))
      (setenv "SSH_AUTH_SOCK" SOCK)
      (message (concat "Updated ssh-agent socket to " SOCK))
      (assert (ssh-agent-check-socket))
      t))
