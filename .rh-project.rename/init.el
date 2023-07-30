;; Hey Emacs, this is -*- coding: utf-8 -*-

(require 'cl)
(require 'hydra)
(require 'vterm)
(require 'flycheck)
(require 'lsp-mode)
(require 'lsp-javascript)
(require 'clang-format)

;;; my-project common command
;;; /b/{

(defvar my-project/build-buffer-name
  "*my-project-build*")

;; (defun my-project/lint ()
;;   (interactive)
;;   (rh-project-compile
;;    "yarn-run app:lint"
;;    my-project/build-buffer-name))

(defun my-project/conan-install ()
  (interactive)
  (rh-project-compile
   "conan-install.sh"
   my-project/build-buffer-name))

(defun my-project/cmake ()
  (interactive)
  (rh-project-compile
   "cmake.sh"
   my-project/build-buffer-name))

(defun my-project/build ()
  (interactive)
  (rh-project-compile
   "build.sh"
   my-project/build-buffer-name))

(defun my-project/clean-conan ()
  (interactive)
  (rh-project-compile
   "clean-conan.sh"
   my-project/build-buffer-name))

;;; /b/}

;;; my-project
;;; /b/{

(defun my-project/hydra-define ()
  (defhydra my-project-hydra (:color blue :columns 5)
    "@my-project workspace commands"
    ;; ("l" my-project/lint "lint")
    ("b" my-project/build "build")
    ("i" my-project/conan-install "conan-install")
    ("c" my-project/clean-conan "clean-conan")
    ("m" my-project/cmake "cmake")))

(my-project/hydra-define)

(define-minor-mode my-project-mode
  "my-project project-specific minor mode."
  :lighter " my-project"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "<f9>") #'my-project-hydra/body)
            map))

(add-to-list 'rm-blacklist " my-project")

(defun my-project/lsp-deps-providers-path (path)
  (concat (expand-file-name (rh-project-get-root))
          "node_modules/.bin/"
          path))

(defvar my-project/lsp-clients-clangd-args '())

(setq lsp-clients-clangd-library-directories
      '("~/.conan2" "/usr/include" "/usr/local/include"))

(defun my-project/lsp-clangd-init ()
  (setq my-project/lsp-clients-clangd-args
        (copy-sequence lsp-clients-clangd-args))
  (add-to-list
   'my-project/lsp-clients-clangd-args
   "--query-driver=/usr/bin/g*-11,/usr/bin/clang*-16"
   t)

  ;; (add-hook
  ;;  'lsp-after-open-hook
  ;;  #'my-project/company-capf-c++-local-disable)

  ;; (add-hook
  ;;  'lsp-after-initialize-hook
  ;;  #'my-project/company-capf-c++-local-disable)
  )

;; (defun my-project/company-capf-c++-local-disable ()
;;   (when (eq major-mode 'c++-mode)
;;     (setq-local company-backends
;;                 (remq 'company-capf company-backends))))

(defun my-project/lsp-javascript-init ()
  (plist-put
   lsp-deps-providers
   :local (list :path #'my-project/lsp-deps-providers-path))

  (lsp-dependency 'typescript-language-server
                  '(:local "typescript-language-server"))

  (lsp--require-packages)

  (lsp-dependency 'typescript '(:local "tsserver"))

  (add-hook
   'lsp-after-initialize-hook
   #'my-project/flycheck-add-eslint-next-to-lsp))

(defun my-project/flycheck-add-eslint-next-to-lsp ()
  (when (seq-contains-p '(js2-mode typescript-mode web-mode) major-mode)
    (flycheck-add-next-checker 'lsp 'javascript-eslint)))

(defun my-project/flycheck-after-syntax-check-hook-once ()
  (remove-hook
   'flycheck-after-syntax-check-hook
   #'my-project/flycheck-after-syntax-check-hook-once
   t)
  (flycheck-buffer))

;; (eval-after-load 'lsp-javascript #'my-project/lsp-javascript-init)
(eval-after-load 'lsp-mode #'my-project/lsp-javascript-init)
(eval-after-load 'lsp-mode #'my-project/lsp-clangd-init)

(defun my-project-setup ()
  (when buffer-file-name
    (let ((project-root (rh-project-get-root))
          file-rpath ext-js)
      (when project-root
        (setq file-rpath (expand-file-name buffer-file-name project-root))
        (cond
         ;; This is required as tsserver does not work with files in archives
         ((bound-and-true-p archive-subfile-mode)
          (company-mode 1))

         ;; C/C++
         ((seq-contains '(c++-mode c-mode) major-mode)
          (when (rh-clangd-executable-find)
            (when (featurep 'lsp-mode)
              (setq-local
               lsp-clients-clangd-args
               (copy-sequence my-project/lsp-clients-clangd-args))

              (add-to-list
               'lsp-clients-clangd-args
               (concat "--compile-commands-dir="
                       (expand-file-name (rh-project-get-root)))
               t)

              (setq-local lsp-modeline-diagnostics-enable nil)
              ;; (lsp-headerline-breadcrumb-mode 1)

              (setq-local flycheck-checker-error-threshold 2000)

              (setq-local flycheck-idle-change-delay 3)
              (setq-local flycheck-check-syntax-automatically
                          ;; '(save mode-enabled)
                          '(idle-change save mode-enabled))))

          ;; (add-hook 'before-save-hook #'clang-format-buffer nil t)
          ;; (clang-format-mode 1)
          (company-mode 1)
          (lsp-deferred))

         ;; JavaScript/TypeScript
         ((or (setq
               ext-js
               (string-match-p
                (concat "\\.ts\\'\\|\\.tsx\\'\\|\\.js\\'\\|\\.jsx\\'"
                        "\\|\\.cjs\\'\\|\\.mjs\\'")
                file-rpath))
              (string-match-p "^#!.*node"
                              (or (save-excursion
                                    (goto-char (point-min))
                                    (thing-at-point 'line t))
                                  "")))

          (when (boundp 'rh-js2-additional-externs)
            (setq-local rh-js2-additional-externs
                        (append rh-js2-additional-externs
                                '("require" "exports" "module" "process"
                                  "__dirname"))))

          (setq-local flycheck-idle-change-delay 3)
          (setq-local flycheck-check-syntax-automatically
                      ;; '(save mode-enabled)
                      '(save idle-change mode-enabled))
          (setq-local flycheck-javascript-eslint-executable
                      (concat (expand-file-name project-root)
                              "node_modules/.bin/eslint"))

          (setq-local lsp-enabled-clients '(ts-ls))
          ;; (setq-local lsp-headerline-breadcrumb-enable nil)
          (setq-local lsp-before-save-edits nil)
          (setq-local lsp-modeline-diagnostics-enable nil)
          (add-hook
           'flycheck-after-syntax-check-hook
           #'my-project/flycheck-after-syntax-check-hook-once
           nil t)
          (lsp 1)
          ;; (lsp-headerline-breadcrumb-mode -1)
          (prettier-mode 1))

         ;; Python
         ((or (setq ext-js (string-match-p
                            (concat "\\.py\\'\\|\\.pyi\\'") file-rpath))
              (string-match-p "^#!.*python"
                              (or (save-excursion
                                    (goto-char (point-min))
                                    (thing-at-point 'line t))
                                  "")))

          ;;; /b/; pyright-lsp config
          ;;; /b/{

          (setq-local lsp-pyright-prefer-remote-env nil)
          (setq-local lsp-pyright-python-executable-cmd
                      (file-name-concat project-root ".venv/bin/python"))
          (setq-local lsp-pyright-venv-path
                      (file-name-concat project-root ".venv"))
          ;; (setq-local lsp-pyright-python-executable-cmd "poetry run python")
          ;; (setq-local lsp-pyright-langserver-command-args
          ;;             `(,(file-name-concat project-root ".venv/bin/pyright")
          ;;               "--stdio"))

          ;;; /b/}

          ;;; /b/; ruff-lsp config
          ;;; /b/{

          (setq-local lsp-ruff-lsp-server-command
                      `(,(file-name-concat project-root ".venv/bin/ruff-lsp")))
          (setq-local lsp-ruff-lsp-python-path
                      (file-name-concat project-root ".venv/bin/python"))
          (setq-local lsp-ruff-lsp-ruff-path
                      `[,(file-name-concat project-root ".venv/bin/ruff")])

          ;;; /b/}

          ;;; /b/; Python black
          ;;; /b/{

          (setq-local blacken-executable
                      (file-name-concat project-root ".venv/bin/black"))

          ;;; /b/}

          (setq-local lsp-enabled-clients '(pyright ruff-lsp))
          (setq-local lsp-before-save-edits nil)
          (setq-local lsp-modeline-diagnostics-enable nil)

          (blacken-mode 1)
          ;; (run-with-idle-timer 0 nil #'lsp)
          (lsp-deferred)))))))

;;; /b/}
