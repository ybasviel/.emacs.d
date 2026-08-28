;;; early-init.el --- Pre-init tuning -*- lexical-binding: t; -*-

;; elpaca が package.el を置き換えるので無効化
(setq package-enable-at-startup nil)

;; フレーム描画前にUIを削っておく（後から消すよりチラつかない）
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function 'ignore
      frame-inhibit-implied-resize t)

(setq native-comp-async-report-warnings-errors 'silent)

;; 起動高速化: GC閾値を吊り上げ、init後に戻す
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 32 1024 1024)
                  gc-cons-percentage 0.1)))

(setq default-frame-alist
      '((width . 120)
        (height . 40)
        (menu-bar-lines . 0)
        (tool-bar-lines . 0)
        (vertical-scroll-bars)))
