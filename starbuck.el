(require 'cl-lib)

(defun company-starbuck-backend (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-starbuck-backend))
    (prefix (when (looking-back "foo\\>")
              (match-string 0)))
    (candidates (when (equal arg "foo")
                  (list "foobar" "foobaz" "foobarbaz")))
    (meta (format "This value is named %s" arg))))

(add-to-list 'company-backends 'company-starbuck-backend)
