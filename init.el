;;; init.el --- Modern minimal Emacs -*- lexical-binding: t; -*-

;; ============================================================
;; Elpaca bootstrap (公式README準拠)
;; ============================================================
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; use-package を elpaca 経由でインストール、以降 :ensure t は elpaca に流れる
(elpaca elpaca-use-package
  (elpaca-use-package-mode))
(elpaca-wait)

;; ============================================================
;; GUI Emacs はログインシェルの PATH を継承しないので、
;; mise の shim (~/.local/share/mise/shims) を含む PATH を取り込む
;; ============================================================
(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns x pgtk))
  :init
  (setq exec-path-from-shell-arguments '("-l"))
  (dolist (v '("MYSQL_USER" "MYSQL_PASSWORD" "MYSQL_PWD"
               "MYSQL_HOST" "MYSQL_PORT" "MYSQL_DATABASE"))
    (add-to-list 'exec-path-from-shell-variables v))
  :config
  (exec-path-from-shell-initialize))

;; ============================================================
;; Sane defaults
;; ============================================================
(setq-default indent-tabs-mode nil
              tab-width 2
              fill-column 100)

(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      custom-file (expand-file-name "custom.el" user-emacs-directory)
      use-short-answers t
      require-final-newline t
      sentence-end-double-space nil
      read-process-output-max (* 1024 1024))

(when (file-exists-p custom-file) (load custom-file))

;; 外部からのファイル変更をリアルタイム反映 (inotify/kqueue で即時、
;; フォールバック時のポーリングも 1 秒に短縮)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t   ; dired 等も自動更新
      auto-revert-use-notify t                ; inotify/kqueue を使う
      auto-revert-avoid-polling t             ; 通知が使えるなら polling しない
      auto-revert-interval 1
      auto-revert-verbose nil)
(delete-selection-mode 1)
(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; 分割を避ける: 新規バッファは同ウィンドウで開く
(setq display-buffer-base-action
      '((display-buffer-reuse-window display-buffer-same-window))
      even-window-sizes nil)

;; ============================================================
;; UI
;; ============================================================
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(global-tab-line-mode 1)

;; ============================================================
;; Whitespace 可視化: tab / space / trailing を別 face で色分け
;;   indent-tabs-mode nil なので、混入した TAB を目立たせる意味も兼ねる
;; ============================================================
(use-package whitespace
  :ensure nil
  :hook (prog-mode . whitespace-mode)
  :custom
  (whitespace-style '(face tabs spaces tab-mark space-mark trailing))
  (whitespace-display-mappings
   '((space-mark ?\  [?·])
     (tab-mark   ?\t [?» ?\t]))))

;; ============================================================
;; Minibuffer completion
;; ============================================================
(use-package vertico
  :ensure t
  :init (vertico-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :ensure t
  :init (marginalia-mode))

(use-package consult
  :ensure t
  :bind (("C-x b"   . consult-buffer)
         ("C-x C-r" . consult-recent-file)
         ("M-g g"   . consult-goto-line)
         ("M-g i"   . consult-imenu)
         ("M-s r"   . consult-ripgrep)
         ("M-s f"   . consult-fd)
         ("M-y"     . consult-yank-pop)))

;; ============================================================
;; In-buffer completion
;; ============================================================
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  :init (global-corfu-mode))

(use-package cape
  :ensure t
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

;; ============================================================
;; Tree-sitter (Emacs 29+ built-in、モード自動セットアップだけ elpaca 経由)
;; ============================================================
(use-package treesit-auto
  :ensure t
  :custom (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; ============================================================
;; Web (Svelte)
;;   .svelte を編集するための major-mode。LSP は下の eglot 側で紐付け
;; ============================================================
(use-package svelte-mode
  :ensure t
  :mode ("\\.svelte\\'" . svelte-mode))

;; ============================================================
;; LSP (eglot は built-in)
;;   必要な language server (mise/npm でグローバルに入れておく):
;;     npm i -g typescript typescript-language-server   ; React (ts/tsx/js/jsx)
;;     npm i -g svelte-language-server                  ; Svelte
;; ============================================================
(use-package eglot
  :ensure nil
  :hook ((go-ts-mode ruby-ts-mode python-ts-mode
          typescript-ts-mode tsx-ts-mode
          svelte-mode) . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  (eglot-sync-connect nil)
  :bind (:map eglot-mode-map
              ("M-." . xref-find-definitions)
              ("M-?" . xref-find-references)
              ("C-c r" . eglot-rename)
              ("C-c a" . eglot-code-actions))
  :config
  (add-to-list 'eglot-server-programs
               '(svelte-mode . ("svelteserver" "--stdio"))))

;; ============================================================
;; Git / diff
;; ============================================================
;; 組み込み transient は古く magit が要求する 0.13+ を満たさないので
;; 先に ELPA 版をインストール&ロードして built-in を上書きする
(use-package transient :ensure t :demand t)
(elpaca-wait)

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

(use-package diff-hl
  :ensure t
  :init (global-diff-hl-mode)
  :hook ((magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)))

(use-package difftastic
  :ensure t
  :after magit
  :config
  (with-eval-after-load 'magit-diff
    (transient-append-suffix 'magit-diff '(-1 -1)
      [("D" "Difftastic diff (dwim)" difftastic-magit-diff)
       ("S" "Difftastic show"        difftastic-magit-show)])))

;; ============================================================
;; SQL
;;   - sql.el / sqlite-mode は built-in
;;   - 環境変数 MYSQL_USER / MYSQL_PASSWORD (or MYSQL_PWD) /
;;     MYSQL_HOST / MYSQL_PORT / MYSQL_DATABASE から local-mysql 接続を作る
;;   - M-x sql-mysql-local で即時接続
;; ============================================================
(use-package sql
  :ensure nil
  :custom
  (sql-mysql-login-params '(user password server database port))
  (sql-connection-alist
   '((local-mysql
      (sql-product 'mysql)
      (sql-user     (getenv "MYSQL_USER"))
      (sql-password (or (getenv "MYSQL_PASSWORD") (getenv "MYSQL_PWD")))
      (sql-server   (or (getenv "MYSQL_HOST") "127.0.0.1"))
      (sql-port     (string-to-number (or (getenv "MYSQL_PORT") "3306")))
      (sql-database (or (getenv "MYSQL_DATABASE") "")))))
  :config
  (defun sql-mysql-local ()
    "MYSQL_USER / MYSQL_PASSWORD (or MYSQL_PWD) / MYSQL_HOST /
MYSQL_PORT / MYSQL_DATABASE を読んで local MySQL に接続する。"
    (interactive)
    (unless (getenv "MYSQL_USER")
      (user-error "MYSQL_USER が未設定です"))
    (sql-connect 'local-mysql)))

(provide 'init)
;;; init.el ends here
