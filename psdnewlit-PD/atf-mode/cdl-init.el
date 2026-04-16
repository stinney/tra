;; CDL version 1.0

(defun turn-on-cuneitex ()
  (set-input-method "Cuneiform"))

(load-file "~/xml-rpc.el")
(load-file "~/atf-mode.el")
(load-file "~/cuneitex.el")

(when (boundp 'aquamacs-version)
  (setq my-font 
	"-apple-lynn sans mono-medium-r-normal--14-*-*-*-m-*-iso10646-1")
  (if mac-input-method-mode
      (mac-input-method-mode))
  (if aquamacs-styles-mode
      (aquamacs-styles-mode)))

;(when (eq window-system 'w32)
;  (setq my-font
;	"-outline-Lynn Sans Mono-normal-r-normal-normal-12-*-*-*-c-*-iso10646-1"))

(set-language-environment "utf-8")
(set-default-font my-font)
