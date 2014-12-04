;;? <?
    # Determine the installed version of Emacs.
    `emacs --version` =~ m/^GNU Emacs (\d+)\.(\d+)\.(\d+)/;
    $EMACS_VERSION = int($3)+(int($2)<< 8)+(int($1)<<16);
    $EMACS_VERSION or warn "Can't identify version of Emacs";
    if ( $EMACS_VERSION < (22<<16) ) { ?>
;;?install ~/.emacs
;;
;; dotemacs.el - A ~/.emacs file that loads ~/.emacs.d/init.el (for Emacs 21)
;;

(load "~/.emacs.d/init")
<? } ?>
;; Generated for GNU Emacs version <? printf("0x%06x", $EMACS_VERSION) ?>.
;; Do not install this file for Emacs 22 and newer.
