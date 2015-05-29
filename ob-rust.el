;;; ob-rust.el --- org-babel functions for rust evaluation

;; Copyright (C) 2015 ZHOU Feng

;; Author: ZHOU Feng <zf.pascal@gmail.com>
;; URL: http://github.com/zweifisch/ob-rust
;; Keywords: org babel rust
;; Version: 0.0.1
;; Created: 29th May 2015
;; Package-Requires: ((org "8"))

;;; Commentary:
;;
;; org-babel functions for rust evaluation
;;

;;; Code:
(require 'org)
(require 'ob)

(defun org-babel-execute:rust (body params)
  (ob-rust-eval (ob-rust-prep body)))

(defun ob-rust-eval (body)
  (let* ((src-tmp (org-babel-temp-file "rust-"))
         (output-tmp (org-babel-temp-file "rustc-")))
    (with-temp-file src-tmp (insert body))
    (let ((result (shell-command-to-string
                   (format "rustc -A dead_code -o %s %s && %s"
                           output-tmp src-tmp output-tmp))))
      (message (prin1-to-string result))
      result)))

(defun ob-rust-last-char ()
    (when (not (thing-at-point 'char t))
      (forward-char -1))
    (thing-at-point 'char t))

(defun ob-rust-trim-right ()
  (while
      (let ((cur (ob-rust-last-char)))
        (or (string-equal "\n" cur)
            (string-equal "\r" cur)
            (string-equal " " cur)
            (string-equal ";" cur)))
    (delete-char 1)))

(defun ob-rust-prep (body)
  (with-current-buffer (get-buffer-create "*ob-rust-src*")
    (erase-buffer)
    (insert "fn main() {\n")
    (insert body)
    (goto-char (point-max))
    (ob-rust-trim-right)
    (beginning-of-line)
    (if (or (string= "println" (thing-at-point 'word t))
            (string= "}" (thing-at-point 'char t)))
        (end-of-line)
      (insert "println!(\"{:?}\", ")
      (end-of-line)
      (insert ");"))
    (insert "\n}")
    (buffer-string)))

(provide 'ob-rust)
;;; ob-rust.el ends here
