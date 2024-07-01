 ;; Script to migrate org roam old to new

(defun generate-meta-data-fields ()
  "Generate ID and get metadata segment"
  (get-metadata-as-string (org-id-new)))


(defun get-metadata-as-string (id)
  "Get the new org roam meta data fields given a string
To be used by generated-meta-data-fields"
  (format ":PROPERTIES:
:ID:       %s
:END:
" id))

(defun append-string-to-file (string file no-replace)
  "Append or replace (if 3rd argument is nil) a string to a file"
  (if (not no-replace)
      (with-temp-buffer
	(insert "")
	(write-region (point-min) (point-max) file nil)))
  (with-temp-buffer
    (insert string)
    (write-region (point-min) (point-max) file no-replace)))

;; TODO: Some steps might be redundant clean them
(defun get-id-of-file (filename)
  "Open the file given the filename and get its org roam ID"
  (setq link-file-content (get-file-contents-as-string filename))
  (string-match ":ID:       \\(.*-.*-.*-.*-.*\\)" link-file-content)
  (match-string 1 link-file-content))


(defun get-file-contents-as-string (filepath)
  "Helper function to get the contents of file as string"
  (with-temp-buffer
    (insert-file-contents filepath)
    (buffer-string)))

(defun get-new-link (new-id link-name)
  "Generate new link format"
  (format "[[id:%s][%s]]" new-id link-name))

(defun replace-old-references (filepath)
  "Helper function to find all old style filepath and replace them with new"
  (setq file-contents (get-file-contents-as-string filepath))
  (while (string-match "\\[\\[file:\\(.+org\\)\\]\\[\\(.*\\)\\]\\]" file-contents)
    (setq link-name (match-string 2 file-contents))
    (setq new-id (get-id-of-file (match-string 1 file-contents)))
    (setq new-link (get-new-link new-id link-name))
    (string-match "\\[\\[file:\\(.+org\\)\\]\\[\\(.*\\)\\]\\]" file-contents)
    (setq file-contents (replace-match new-link nil nil file-contents)))
  (append-string-to-file file-contents filepath nil))

(defun migrate-to-roam-v2 (dirpath)
  "Interactive funtion to invoke the migrate script"
  (interactive "fDirectory Name:")
  (cd dirpath)
  (setq files (directory-files dirpath nil ".org"))
  (while files
    (append-string-to-file (generate-meta-data-fields) (car files) 0)
    (setq files (cdr files)))
  (setq files (directory-files dirpath nil ".org"))
  ;; (while files
  ;;   (replace-old-references (car files))
  ;;   (setq files (cdr files)))

  )






