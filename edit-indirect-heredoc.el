(require 'edit-indirect)

(defcustom edit-indirect-here-doc-begin-regex
  "<<\\([A-Z_]+\\)$"
  "Regular expression to search for the first part of there HEREDOC"
  :group 'edit-indirect-heredoc
  :type 'string)

(defcustom edit-indirect-here-doc-end-regex
  "^%s$"
  "Regular expression format string for the last part of the HEREDOC"
  :group 'edit-indirect-heredoc
  :type 'string)

(defun edit-indirect-heredoc ()
  (interactive)
  (let* ((region (save-excursion
                    (re-search-backward edit-indirect-here-doc-begin-regex)
                    (let* ((keyword (match-string 1))
                          (beg (search-forward "\n"))
                          (end (progn
                                  (re-search-forward (format "^%s$" keyword))
                                  (search-backward "\n"))))
                      (list :beg beg :end end :keyword keyword))))
          (mode-symbol (intern
                        (downcase
                        (replace-regexp-in-string "_"
                                                  "-"
                                                  (getf region :keyword)))))
          (maybe-mode (symbol-function mode-symbol)))
    (switch-to-buffer
      (edit-indirect-region (getf region :beg)
                            (getf region :end)))
    (when maybe-mode
      (funcall maybe-mode))))

(define-minor-mode edit-indirect-heredoc-mode
  "Minor mode for editing HEREDOCs with edit-indirect."
  :keymap
  (list (cons (kbd "C-c '") #'edit-indirect-heredoc))
  :require 'edit-indirect
  :init-value nil
  :group 'edit-indirect-heredoc
  :lighter nil)

(provide 'edit-indirect-heredoc)
