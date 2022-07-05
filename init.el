;; el-get init
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")
(setq el-get-dir "~/.emacs.d/elisp")
(el-get 'sync)

;; installed packages
;; autoconf and markdown must be installed additional
;; >> sudo apt install autoconf markdown
(el-get-bundle auctex)
(el-get-bundle auctex-latexmk)
(el-get-bundle markdown-preview-mode)
(el-get-bundle markdown-mode)
(el-get-bundle uuidgen)
(el-get-bundle websocket)
(el-get-bundle web-server)
(el-get-bundle uuidgen)
(el-get-bundle yasnippet)
(el-get-bundle uuidgen)
(el-get-bundle company-mode)
(el-get-bundle company-quickhelp)
(el-get-bundle company-mode)


;; line numbrs
(global-display-line-numbers-mode t)
(custom-set-variables '(display-line-numbers-width-start t))

;; no tab
(setq-default indent-tabs-mode nil)

;; indent using 2 spaces
(setq-default tab-width 2)

;; visualisation of tab and space
(defface my-face-b-1 '((t (:background "medium aquamarine"))) nil)
(defface my-face-b-2 '((t (:background "gray26"))) nil)
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(
     ("　" 0 my-face-b-1 append)
     ("\t" 0 my-face-b-2 append)
     ("[ ]+$" 0 my-face-u-1 append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(add-hook 'find-file-hooks '(lambda ()
(if font-lock-mode
nil
(font-lock-mode t))) t)

;; no backup files *.~
(setq make-backup-files nil)
;; no backup files .#* 
(setq auto-save-default nil)

;; yasnippet init
(setq yas-snippet-dirs
      '("~/.emacs.d/mySnippets"))
(yas-global-mode 1)



;; settings for markdown preview mode
(setq auto-mode-alist
   (cons '("\.md" . markdown-mode) auto-mode-alist))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(setq markdown-preview-stylesheets nil)



;; LaTeX auto compile
(autoload 'smart-compile "smart-compile.el" t)
(eval-when-compile (require 'smart-compile))
(declare-function smart-compile-string "smart-compile")
(defun run-latexmk ()
  (when (string-match ".tex$" (buffer-file-name))
    (let ((buf (get-buffer "*Background TeX proccess*")))
      (if (bufferp buf) (kill-buffer buf)) ) ;; flush previous log
    (require 'smart-compile) ;; for smart-compile-string
    (start-process-shell-command
     "Background TeX" "*Background TeX proccess*"
     (smart-compile-string "latexmk %f"))))
(define-minor-mode AutoTeX-mode
  "Mode for compiling latex sources and creating PDFs after saving."
  :global nil
  :lighter " Auto"
  (if AutoTeX-mode
      (add-hook 'after-save-hook 'run-latexmk t t)
    (remove-hook 'after-save-hook 'run-latexmk t)))

(add-hook 'TeX-mode-hook #'(lambda () (AutoTeX-mode 1)))



;; company
(require 'company)
(global-company-mode) 
(setq company-transformers '(company-sort-by-backend-importance))
(setq company-idle-delay 0)
(setq company-minimum-prefix-length 3)
(setq company-selection-wrap-around t)
(setq completion-ignore-case t)
(setq company-dabbrev-downcase nil)
(global-set-key (kbd "C-M-i") 'company-complete)
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
(define-key company-search-map (kbd "C-n") 'company-select-next)
(define-key company-search-map (kbd "C-p") 'company-select-previous)
(define-key company-active-map (kbd "C-s") 'company-filter-candidates)
(define-key company-active-map (kbd "C-i") 'company-complete-selection)
(define-key company-active-map [tab] 'company-complete-selection)
(define-key company-active-map (kbd "C-f") 'company-complete-selection)
(define-key emacs-lisp-mode-map (kbd "C-M-i") 'company-complete)

;; company works with yasnippet
(defvar company-mode/enable-yas t
  "Enable yasnippet for all backends.")
(defun company-mode/backend-with-yas (backend)
  (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
      backend
    (append (if (consp backend) backend (list backend))
            '(:with company-yasnippet))))
(setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))