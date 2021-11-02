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

(require 'json)
(require 'url)
(require 'url-parse)

(defgroup starbuck nil
  "Perform GPT-powered code completion"
  :group 'editing)

(defcustom starbuck-url "http://localhost:9900/"
  "URL the Python server is running at."
  :type 'string
  :group 'starbuck)

(defun starbuck--url (context)
  (let ((url (url-generic-parse-url starbuck-url))
        (params (url-build-query-string `(("text" ,context)))))
    (setf (url-filename url) (format "/?%s" params))
    url))

(defun starbuck ()
  (interactive)
  ;; TODO: what is best way to do it -- backward-paragraph or
  ;; previous-line?
  (let* ((context-beg (save-excursion
                        (previous-line (min 3 (- (line-number-at-pos) 1)))
                        (beginning-of-line)
                        (point)))
         (context-end (point))
         (context (buffer-substring-no-properties context-beg context-end))
         (url (starbuck--url context))
         (url-buf (url-retrieve-synchronously url))
         (old-buf (current-buffer)))
    (unwind-protect
      (with-current-buffer url-buf
        (goto-char url-http-end-of-headers)
        (let ((generation (cdr (assoc 'generation (json-read)))))
          (with-current-buffer old-buf
            (insert generation))))
      (kill-buffer url-buf)))
  (message "Inserted completion."))

(defun starbuck-redo ()
  (interactive)
  (undo)
  (starbuck))

(global-set-key (kbd "C-c c") 'starbuck)
(global-set-key (kbd "C-c v") 'starbuck-redo)
