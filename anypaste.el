;;;; -*- lexical-binding: t -*-
;;;; Anypaste Emacs integration
;;;; Copyright 2019 Mark Polyakov
;;;; Released under the GNU Public License, Version 3

(require 'ansi-color)

(defvar anypaste-tags '("private" "direct" "permanent" "editable" "deletable")
  "The valid options for anypaste -t")

(defcustom anypaste-program "anypaste"
  "Anypaste executable")
(defcustom anypaste-default-tags ()
  "Tags which are enabled by default")
(defcustom anypaste-buffer-name "*Anypaste Output*"
  "Name of the Anypaste output buffer")
(defcustom anypaste-erase-buffer nil
  "If non-nil, will erase any old output in the anypaste buffer before each upload")

(defun anypaste--join (separator list)
  "Join list of strings by separator. Empty string if list is nil"
  (let ((result ""))
    (when list
      (setq result (car list))
      (dolist (elt (cdr list))
        (setq result (concat result separator elt))))
    result))

(defun anypaste--args (&optional plugin tags &rest more)
  "Get a list of args to past to the Anypaste cli"
  (unless tags
    (setq tags anypaste-default-tags))
  (apply #'nconc (remove nil (cons
                              more
                              (list
                               (when plugin (list "-p" plugin))
                               (when tags (list "-t" (anypaste--join "," tags))))))))

(defun anypaste--normalize-plugin-name (name)
  "Convert an external plugin name to an internal one by
  stripping punctuation and dots"
  (downcase (remove ?. name)))

(defun anypaste-plugin-list ()
  "Get the list of enabled plugin names by order of precedence."
  ;; anypaste -l is fast, so we do it synchronously for ease of searching.
  (with-temp-buffer
    (call-process "anypaste" nil t nil "-l") ; TODO: anypaste--args
    (goto-char (point-min))
    (let ((names))
      (while (search-forward "[name]" nil t)
        (next-line)
        (beginning-of-line)
        (let ((beg (point)))
          (end-of-line)
          (push (buffer-substring-no-properties
                 beg (point))
                names)))
      names)))

(defun anypaste--plugin-prompt ()
  "Prompt for a plugin name. Returns the normalized name"
  (anypaste--normalize-plugin-name (completing-read "Plugin: " (anypaste-plugin-list) nil t)))

;;; Although (completing-read-multiple) is more elegant to the programmer, a
;;; good ol' (completing-read) is better able to integrate with completion
;;; frameworks like Ivy. So, I'm leaving this here.
;; (defun anypaste--tag-prompt ()
;;   "Prompt for tags. Returns list of selected tags"
;;   (let ((result)
;;         (last-read)
;;         (tags-left (cons "DONE" anypaste-tags))) ; TODO: not this
;;     (while (not (equal "DONE" (setq last-read (completing-read "Tag: " tags-left))))
;;       (push last-read result)
;;       (setq tags-left (remove last-read tags-left)))
;;     result))

(defun anypaste-upload (beg end &optional plugin tags)
  "Upload the region between beg and end in the current
buffer. Optionally, use the given plugin (exact name required)
instead of automatic selection or choose a plugin based on the
given list of tags"
  (with-current-buffer (get-buffer-create anypaste-buffer-name)
    (font-lock-mode 1)
    (read-only-mode 0) ; TODO: how to enable/disable read-only mode properly
    (when anypaste-erase-buffer
      (erase-buffer))
    (read-only-mode 1))
  (let ((process (make-process :name "anypaste"
                               :buffer anypaste-buffer-name
                               :command (cons "anypaste" (anypaste--args plugin tags))
                               :connection-type 'pipe)))
    (add-function :around (process-filter process)
                  (lambda (oldfun process str)
                    (funcall oldfun process (ansi-color-apply str))))
    (process-send-region process beg end)
    (process-send-eof process)
    (display-buffer anypaste-buffer-name)))

(defun anypaste (arg)
  "Upload with anypaste. With a single prefix argument, manually
select plugin. With two, select tags. For interactive use only;
see (anypaste-upload) for a scriptable version"
  (interactive "p")
  (anypaste-upload (if (use-region-p) (region-beginning) (point-min))
                   (if (use-region-p) (region-end) (point-max))
                   (when (= arg 4) (anypaste--plugin-prompt))
                   (when (= arg 8)
                     (completing-read-multiple "Tags: " anypaste-tags))))
