## Hey Emacs, this is -*- coding: utf-8 -*-
<%
  project_name = utils.kebab_case(config["project_name"])
%>\
;; Hey Emacs, this is -*- coding: utf-8 -*-

(require 'cl)
(require 'hydra)
(require 'vterm)
(require 'flycheck)
(require 'lsp-mode)
(require 'lsp-javascript)
(require 'clang-format)

;;; ${project_name} common command
;;; /b/{

(defvar ${project_name}/build-buffer-name
  "*${project_name}-build*")

(defun ${project_name}/build ()
  (interactive)
  (rh-project-compile
   "build.sh"
   ${project_name}/build-buffer-name))

(defun ${project_name}/run ()
  (interactive)
  (rh-project-compile
   "run.sh"
   ${project_name}/build-buffer-name))

(defun ${project_name}/clang-check ()
  (interactive)
  (rh-project-compile
   "clang-check.sh"
   ${project_name}/build-buffer-name))

(defun ${project_name}/clang-tidy ()
  (interactive)
  (rh-project-compile
   "clang-tidy.sh"
   ${project_name}/build-buffer-name))

(defun ${project_name}/clean ()
  (interactive)
  (rh-project-compile
   "clean.sh"
   ${project_name}/build-buffer-name))

(defun ${project_name}/conan-install ()
  (interactive)
  (rh-project-compile
   "conan-install.sh"
   ${project_name}/build-buffer-name))

(defun ${project_name}/cmake ()
  (interactive)
  (rh-project-compile
   "cmake.sh"
   ${project_name}/build-buffer-name))

;;; /b/}

;;; ${project_name}
;;; /b/{

(defun ${project_name}/hydra-define ()
  (defhydra ${project_name}-hydra (:color blue :columns 4)
    "@${project_name} workspace commands"
    ;; ("l" ${project_name}/lint "lint")
    ("b" ${project_name}/build "build")
    ("r" ${project_name}/run "run")
    ("k" ${project_name}/clang-check "clang-check")
    ("t" ${project_name}/clang-tidy "clang-tidy")
    ("c" ${project_name}/clean "clean")
    ("i" ${project_name}/conan-install "conan-install")
    ("m" ${project_name}/cmake "cmake")))

(${project_name}/hydra-define)

(define-minor-mode ${project_name}-mode
  "${project_name} project-specific minor mode."
  :lighter " ${project_name}"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "<f9>") #'${project_name}-hydra/body)
            map))

(add-to-list 'rm-blacklist " ${project_name}")

(defvar lsp-clients-clangd-library-directories
  '("~/.conan2"
    "/usr/include"
    "/usr/lib"
    "/usr/local/include"
    "/usr/local/lib"))

(defvar ${project_name}/lsp-clients-clangd-args '())

(defun ${project_name}/lsp-clangd-init ()
  (setq ${project_name}/lsp-clients-clangd-args
        (copy-sequence lsp-clients-clangd-args))

  (let ((clang-version ""))
    (save-match-data
      (and (string-match
            ".*-\\([[:digit:]]+\\)"
            lsp-clients-clangd-executable)
           (setq clang-version
                 (match-string 1 lsp-clients-clangd-executable))))

    (add-to-list
     '${project_name}/lsp-clients-clangd-args
     (concat
      "--query-driver="
      (mapconcat
       'identity
       `("/usr/bin/g*-11"
         "/usr/bin/g*-10"
         ,(concat "/usr/bin/clang*-" clang-version))
       ","))
     t))

  ;; (add-hook
  ;;  'lsp-after-open-hook
  ;;  #'${project_name}/company-capf-c++-local-disable)

  ;; (add-hook
  ;;  'lsp-after-initialize-hook
  ;;  #'${project_name}/company-capf-c++-local-disable)
  )

(eval-after-load 'lsp-mode #'${project_name}/lsp-clangd-init)

(defun ${project_name}-setup ()
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
               (copy-sequence ${project_name}/lsp-clients-clangd-args))

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
          (clang-format-mode 1)
          (company-mode 1)
          (lsp-deferred))

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
