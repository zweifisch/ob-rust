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
(require 'ob)

(defun org-babel-execute:rust (body params)
  (ob-rust-eval (ob-rust-prep body)))

(defun ob-rust-eval (body)
  (let ((src-tmp (org-babel-temp-file "rust-"))
        (output-tmp (org-babel-temp-file "rustc-")))
    (with-temp-file src-tmp (insert body))
    (shell-command-to-string
     (format "rustc -A dead_code -o %s %s && %s"
             output-tmp src-tmp output-tmp))))

(defun ob-rust-prep (body)
  (with-current-buffer (get-buffer-create "*ob-rust-src*")
    (erase-buffer)
    (insert "fn main() {\n")
    (insert body)
    (goto-char (point-max))
    (beginning-of-line)
    (while (looking-at "\\(^[\t ]*//\\|^[\t ]*$\\)")
      (forward-line -1))
    (if (looking-at "[\t ]*\\(println\\|}\\)")
        (end-of-line)
      (insert "println!(\"{:?}\", ")
      (when (search-forward-regexp ";[\t ]*$" nil t)
        (replace-match "" t t))
      (end-of-line)
      (insert ");"))
    (insert "\n}")
    (buffer-string)))

(provide 'ob-rust)
;;; ob-rust.el ends here
