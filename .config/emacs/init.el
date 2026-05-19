;;; init.el -*- lexical-binding: t; -*-

;; https://stackoverflow.com/questions/2079095/how-to-modularize-an-emacs-configuration/2079146
(defconst user-init-dir
  (cond ((boundp 'user-emacs-directory)
         user-emacs-directory)
        ((boundp 'user-init-directory)
         user-init-directory)
        (t "~/.emacs.d/")))

(defun load-user-file (file)
  "Load a file in current user's configuration directory"
  (interactive "f")
  (load-file (expand-file-name file user-init-dir)))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "better-defaults" user-emacs-directory))

(use-package better-defaults
  :ensure nil
  :init
  (require 'better-defaults)
  )

;; Based on https://git.sr.ht/~technomancy/better-defaults
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory
                                               "backups"))))
(setq version-control t)
(setq delete-old-versions t)
(setq kept-new-versions 5)
(setq backup-by-copying t)
(setq create-lockfiles nil)         ;; Prevents .# creation

; Define the package archives
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

;; Set priorities to prefer GNU over MELPA
(setq package-archive-priorities '(("gnu" . 10)
                                   ("melpa" . 5)))

;; Initialize the package system
(package-initialize)

(unless (require 'use-package nil t)
  (when (not package-archive-contents)
    (package-refresh-contents))
  (package-install 'use-package)
  (use-package use-package-ensure
    :config  (setq use-package-always-ensure t)))

(defmacro use-feature (name &rest args)
  "Like `use-package' but for built-in features (sets :ensure nil).
NAME and ARGS as in `use-package'."
  (declare (indent defun))
  `(use-package ,name
     :ensure nil
     ,@args))

;; Remove trailing whitespace before saving
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;https://batsov.com/articles/2021/12/19/building-emacs-from-source-with-pgtk/
(pixel-scroll-precision-mode)

(column-number-mode 1)

;; To change default font or size in Emacs https://stackoverflow.com/questions/294664/how-to-set-the-font-size-in-emacs
;; (set-face-attribute 'default nil :height 130)
;; (set-face-attribute 'default nil :font "Monaco-16" )
;; (set-face-attribute 'default nil :font "Hack-13:embolden=true" )
;; (set-face-attribute 'default nil :font "Roboto Mono-13" )
(set-face-attribute 'default nil :font "Hack-13" )

;; (advice-add 'ispell-completion-at-point :override #'ignore)
(with-eval-after-load 'ispell
  (setq ispell-program-name "hunspell")
  (setenv "DICPATH" "/usr/share/hunspell")
  (setq corfu-popupinfo-mode nil)
  (remove-hook 'completion-at-point-functions #'ispell-completion-at-point))

(setq window-divider-default-places t)
(set-face-background 'internal-border (face-background 'default))
;; For PGTK, use alpha-background instead of alpha
(add-to-list 'default-frame-alist '(alpha-background . 85))
(defun toggle-transparency ()
  "Toggle between transparent and opaque background."
  (interactive)
  (let ((current-alpha (frame-parameter nil 'alpha-background)))
    (set-frame-parameter
     nil 'alpha-background
     (if (< (or current-alpha 100) 100) 100 85))))

(global-set-key (kbd "C-c t") 'toggle-transparency)

;; Turn off the startup screen, splash screen and puts straight into
;; the scratch buffer to quickly type or paste in emacs instead of
;; standard emacs startpage
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq initial-scratch-message "")
(setq initial-major-mode 'fundamental-mode)

(use-package nord-theme
  :ensure t
  :init
  (setq nord-region-highlight "frost")
  :config
  (load-theme 'nord t))

(defun now ()
  "Insert string for the current time formatted like '2:34 PM'."
  (interactive)                 ; permit invocation in minibuffer
  ;; (insert (format-time-string "%-I:%M %p"))
  (insert (format-time-string "%R")))

(defun today ()
  "Insert string for today's date nicely formatted in American style,
e.g. Sunday, September 17, 2000."
  (interactive)                 ; permit invocation in minibuffer
  ;; (insert (format-time-string "%A, %B %e, %Y"))
  (insert (format-time-string "%F")))

(defun my/doasedit ()
  "Re-open current file with doas (elevated) privileges."
  (interactive)
  (if (buffer-file-name)
      (let ((cursor-pos (point))
            (truename (file-truename (buffer-file-name))))
        (find-alternate-file (concat "/doas::" truename))
        (goto-char cursor-pos))
    (message "This buffer is not visiting a file!")))

;; https://emacs.stackexchange.com/questions/77295/org-roam-case-insensitive-search
(defun case-insensitive-org-roam-node-read (orig-fn &rest args)
  "Make org-roam node search case-insensitive."
  (let ((completion-ignore-case t))
    (apply orig-fn args)))

;; (defun build/export-all ()
;;   (dolist (org-file (directory-files-recursively org-roam-directory "\.org$"))
;;      (with-current-buffer (find-file org-file)
;; 			   (message (format "[build] Exporting %s" org-file))
;; 			   (org-hugo-export-wim-to-md :all-subtrees nil nil nil))))


;; Define a reusable function for general programming mode setup

(defun my-programming-setup ()
  "General settings for ALL programming modes"
  (display-line-numbers-mode 1)
  (setq-local display-line-numbers-type 'relative)
  ;; The below two disabled as they break PEP
  ;; (setq-local tab-width 4)
  ;; (setq-local indent-tabs-mode t)
  )
;; Apply this to every programming language automatically
(add-hook 'prog-mode-hook #'my-programming-setup)

(use-package helpful
  :ensure t
  :init
  (require 'bind-key)
  :bind
  (("C-h f" . helpful-callable)  ; Replace describe-function
   ("C-h v" . helpful-variable)  ; Replace describe-variable
   ("C-h k" . helpful-key)       ; Replace describe-key
   ("C-h x" . helpful-command))) ; Replace describe-command

;; Define a function to quit ediff with a single 'q' press
;; Enhanced settings for ediff in Emacs
(use-feature ediff
  :config
  (setq ediff-split-window-function 'split-window-horizontally
        ediff-window-setup-function 'ediff-setup-windows-plain
        ediff-diff-options "-w")
  (defun my-ediff-quit-session ()
    (interactive)
    (ediff-quit 'no-confirm))
  (add-hook 'ediff-keymap-setup-hook
            (lambda ()
              (define-key ediff-mode-map (kbd "q") 'my-ediff-quit-session))))

(use-package outshine
  :ensure t
  :diminish outline-minor-mode
  :commands outshine-hook-function
  :hook (emacs-lisp-mode . outshine-mode)
  :init
  (setq outshine-imenu-show-headlines-p nil))

(use-package diminish
  :ensure t
  )

(use-package vertico
  :ensure t
  :init
  (vertico-mode)
  ;; Settings for a minimal UI.
  (setq vertico-cycle t)
  (setq vertico-count 10)
  :config
  (vertico-mouse-mode 1))
(use-package consult
  :ensure t
  :bind (
         ("C-x b" . consult-buffer)
         ("C-s" . consult-line)
         ("C-c r" . consult-ripgrep)
         :map isearch-mode-map
         ("M-s s" . consult-line))
  )

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles . (partial-completion)))))
  :init
  ;; Orderless provides powerful fuzzy-matching
  (setq completion-ignore-case t)
  (setq completion-flex-enable t))

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         ("C-S-y" . embark-consult-kill-ring))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  )
(use-package embark-consult
  :ensure t
  :after (embark consult))

(use-package corfu
  :ensure t
  :if (display-graphic-p)
  :custom
  (corfu-auto t)                 ; Enable auto-completion
  (corfu-auto-prefix 3)          ; Wait for 3 characters
  (corfu-auto-delay 0.2)         ; Wait 0.2s
  :bind (:map corfu-map
              ("M-p" . corfu-popupinfo-scroll-down)
              ("M-n" . corfu-popupinfo-scroll-up)
              ("M-d" . corfu-popupinfo-toggle))
  :init
  (global-corfu-mode)
  :config
  ;; Enable the documentation popup
  (corfu-popupinfo-mode 1)
  ;; Visual tweaks for the documentation child-frame
  (setq corfu-popupinfo-parameters
      '((vertical-scroll-bars . nil)
        (horizontal-scroll-bars . nil)
        (inner-border-width . 1)
        (left-fringe . 8)
        (right-fringe . 8))))

(defun my-cape-keyword-setup ()
  "Add keyword completion to the current buffer."
  (add-to-list 'completion-at-point-functions #'cape-keyword t))

(use-package cape
  :ensure t
  :bind ("C-c p f" . cape-file)
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  :hook (prog-mode . my-cape-keyword-setup)
  )

(use-feature org
  :custom
  (org-return-follows-link t) ;;Allows links to be opened without C-c C-o in emacs
  (org-id-link-to-org-use-id t) ;; Adds properties to record org ID's to non-roam files too
  (org-agenda-files '("/data/myhome/prabu/org/agenda"
                      "/data/myhome/prabu/org/Resources/daily_journal.org"))
  (org-log-done t)
  (org-todo-keywords '((sequence "TODO(t)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELED(c@)")))
  (org-tag-alist '((:startgroup . nil)
                   ("@kpm" . ?k) ("@home" . ?h)
                   ("@errands" . ?e)
                   (:endgroup . nil)
                   ("@computer" . ?c) ("@phone" . ?p) ("@reading" . ?r)))
  (org-structure-template-alist '(("el" . "src emacs-lisp")
                                   ("s" . "src")
                                   ("e" . "example")
                                   ("q" . "quote")))
 :bind (
         ("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         )
  :config
  ;; (setq time-stamp-active t)
  ;; (setq time-stamp-line-limit 10)               ; Plenty of room for line 4
  ;; (setq time-stamp-start "^#\\+date:[ \t]*")    ; Just find the header
  ;; (setq time-stamp-end "$")                     ; Replace everything until end of line
  ;; (setq time-stamp-format "[%Y-%m-%d %a %H:%M:%S]")
  (add-hook 'org-mode-hook
            (lambda ()
              ;; (add-hook 'before-save-hook 'time-stamp nil t)
              (org-defkey org-mode-map "\C-c[" 'undefined)
              (org-defkey org-mode-map "\C-c]" 'undefined)
              (electric-indent-local-mode -1)
              (when (string-equal buffer-file-name
                                (expand-file-name "20260510115218-emacs_config_file.org"
                                                  org-roam-directory))
              (add-hook 'after-save-hook #'org-babel-tangle nil t)))))

(use-feature org-tempo
  :after org)

;; --- Custom Helper Functions ---
(defun my/org-roam-publish-site ()
  "Runs the graph gen, hugo build, and syncthing scan."
  (interactive)
  (message "Publishing site...")
  (shell-command "/data/myhome/prabu/org/my_hugo_site/scripts/publish_hugo_site.sh &"))
(defun my/set-daily-export-file-name ()
  (let* ((target-buf (org-capture-get :buffer))
         (target-file (when target-buf (buffer-file-name target-buf))))
    (when (and target-file
               (string-match-p "daily_journal\\.org$" target-file))
      (save-excursion
        (org-up-heading-safe)
        ;; (message "Hook fired at: %s" (org-entry-get nil "EXPORT_FILE_NAME"))
        (org-entry-get nil "EXPORT_FILE_NAME")
        (unless (org-entry-get nil "EXPORT_FILE_NAME")
          (org-entry-put nil "EXPORT_FILE_NAME"
                         (format-time-string "%Y-%m-%d" (org-capture-get :default-time))))
        (unless (org-entry-get nil "EXPORT_DATE")
          ;; (message "Setting EXPORT_DATE")
          (org-entry-put nil "EXPORT_DATE"
                         (or (org-entry-get nil "EXPORT_FILE_NAME")
                             (format-time-string "%Y-%m-%d" (org-capture-get :default-time)))))))))
(use-package org-roam
  :ensure t
  :init
  (setq org-roam-database-connector 'sqlite-builtin)
  :custom
  (org-roam-v2-ack t)
  (org-roam-completion-everywhere t)
  (org-roam-directory (file-truename "/data/myhome/prabu/org/Resources"))
  (org-roam-dailies-directory ".")
  ;; (org-roam-dailies-directory "daily/")
  ;; ;; Daily Template
  ;; (org-roam-dailies-capture-templates
  ;;  '(("d" "default" entry
  ;;     "* %^{Title}\n%?"
  ;;     :target (file+head "%<%Y-%m-%d>.org"
  ;;                        "#+title: %<%Y-%m-%d %A>\n"))))
  (org-roam-dailies-capture-templates
   '(("d" "default" entry
      "* %^{Title}\n%?"
      ;; "* %^{Title}\n:PROPERTIES:\n:EXPORT_FILE_NAME: %(format-time-string \"%Y-%m-%d\" (org-capture-get :default-time))\n:END:\n%?"
      :target (file+datetree "daily_journal.org" day)
      :empty-lines 1
      :no-id t)));;either day|week|month is allowed
  :bind
  (("C-c n f" . org-roam-node-find)
   ("C-c n r" . org-roam-node-random)
   ("C-c n j" . org-roam-dailies-capture-today)
   ("C-c n g" . org-roam-dailies-goto-today)
   :map org-mode-map
   ;; org-mode-specific keybindings
   ("C-c n i" . org-roam-node-insert)
   ("C-c n o" . org-id-get-create)
   ("C-c n t" . org-roam-tag-add)
   ("C-c n a" . org-roam-alias-add)
   ("C-c n l" . org-roam-buffer-toggle)
   ("C-M-i" . completion-at-point))
  :config
  (require 'org-roam-dailies)
  (global-set-key (kbd "C-c n d") org-roam-dailies-map)
  ;; Dailies Keymap definitions
  (define-key org-roam-dailies-map (kbd "Y") #'org-roam-dailies-capture-yesterday)
  (define-key org-roam-dailies-map (kbd "T") #'org-roam-dailies-capture-tomorrow)
  ;; Notes Template
  (setq org-roam-capture-templates
        '(("d" "default" plain
           "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %<%Y-%m-%dT%H:%M:%S%:z>\n#+filetags: :draft:\n")
           :unnarrowed t)))
  ;; org-Roam Database and Sync
  (org-roam-db-autosync-mode)
  (setq org-id-extra-files (org-roam--list-files org-roam-directory))
  (setq org-roam-db-node-include-function
        (lambda () (= (org-outline-level) 0)))
  ;; Refresh the list automatically whenever node is changed or saved
  (add-hook 'org-roam-db-sync-hook
            (lambda ()
              (setq org-id-extra-files (org-roam--list-files org-roam-directory))))
  (add-hook 'org-capture-before-finalize-hook #'my/set-daily-export-file-name)
  (advice-add 'org-roam-node-read :around #'case-insensitive-org-roam-node-read)
  (message "org-roam loaded"))
;; #for ox-hugo# https://hugocisneros.com/org-config/#org-roam

(use-package org-roam-ui
  :ensure t)

(defun my/ox-hugo-export-all-org-to-md ()
  "Force export all Org-roam notes to Hugo Markdown."
  (interactive)
  (let ((org-export-with-broken-links t))
    (dolist (org-file (directory-files-recursively org-roam-directory "\\.org$"))
      (with-current-buffer (find-file-noselect org-file)
        (message (format "[build] Exporting %s" org-file))
        (org-hugo-export-wim-to-md :all-subtrees nil nil nil)))))

(use-package ox-hugo
  ;; uses /data/myhome/prabu/org/Resources/.dir-locals.el
  :ensure t   ;;Auto-install the package from Melpa
  :pin melpa  ;;`package-archives' should already have ("melpa" . "https://melpa.org/packages/")
  :after ox
  :config
  (setq org-hugo-auto-set-lastmod t)
  (setq org-hugo-export-with-section-modified-time t)
  (setq org-hugo-allow-all-export-keywords t)
  ;; (setq org-hugo-link-desc-insert-type 'id)
  ;; (setq org-id-extra-files
  ;;       (directory-files-recursively org-roam-directory "\\.org$"))
  ;; (citeproc-org-org-bib-header "* Bibliography\n<ol class=\"biblio-list\">")
  ;; (citeproc-org-org-bib-footer "</ol>")
)

(use-package org-transclusion
  :ensure t   ;;Auto-install the package from Melpa
  ;; :config
  ;; (setq org-tranclusion-modes '(org-mode))
  :hook (org-mode . org-transclusion-mode)
  ;; (map
  ;;  :map global-map "<f12>" #'org-transclusion-add
  ;;  :leader
  ;;  :prefix "n"
  ;;  :desc "Org Transclusion Mode" "t" #'org-transclusion-mode)
  )

(use-package org-noter
  :ensure t
  )

(use-package markdown-mode
  :ensure t
  )

(use-feature python
  :config
  (setq python-indent-guess-indent-offset-verbose nil)   ;; Remove guess indent python message
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))   ;; Remap python-mode to python-ts-mode
  (add-hook 'python-ts-mode-hook
            (lambda ()
              (setq python-indent-offset 4)  ;; Use 4 spaces for indentation (PEP 8)
              (setq-local eglot-workspace-configuration
                        '((:pylsp :plugins
                                  (:autopep8 (:enabled :json-false)
                                   :yapf (:enabled :json-false)
                                   :pycodestyle (:enabled :json-false)
                                   :mccabe (:enabled :json-false)
                                   :flake8 (:enabled :json-false)
                                   :pylint (:enabled :json-false)))))))) ;; do not use pylsp for linting

(use-package ruff-format
  :ensure t
  :hook (python-base-mode . ruff-format-on-save-mode))

(use-package pet
  :ensure t
  :config
  ;; (add-hook 'python-base-mode-hook 'pet-mode -10)
  (add-hook 'python-base-mode-hook 'pet-mode +1)
  (add-hook 'beancount-mode-hook 'pet-mode +1)
  (add-hook 'python-base-mode-hook
            (lambda ()
              (setq-local python-shell-interpreter (pet-executable-find "python")
                          python-shell-virtualenv-root (pet-virtualenv-root))
              (pet-eglot-setup)
              (eglot-ensure)
              )
            )
  (add-hook 'beancount-mode-hook
            (lambda ()
              ;; Use the current directory to find ledger files
              (setq-local beancount-accounts-files
                          (directory-files default-directory t "\\.beancount$"))
              ;; Ensure flymake-bean-check uses the 'bean-check' inside your venv
              (let ((venv-bin (expand-file-name "bin" (pet-virtualenv-root))))
                (when (file-directory-p venv-bin)
                  (setq-local exec-path (append (list venv-bin) exec-path))))
              )
            )
  )

(use-package hide-mode-line
  :ensure t
  :hook (inferior-python-mode . hide-mode-line-mode)
  )

(use-package live-py-mode
  :ensure t
  )

(use-feature flymake
  ;; https://www.gnu.org/software/emacs/manual/html_node/flymake/Finding-diagnostics.html
  :bind(
        :map flymake-mode-map
             ("M-n" . flymake-goto-next-error)
             ("M-p" . flymake-goto-prev-error)
             ("<f2>" . flymake-show-buffer-diagnostics)))

(defun my-sh-mode-setup ()
  "Specific settings for shell scripts."
  ;; sh-mode-hook inherits prog-mode-hook!
  (setq-local sh-basic-offset 4)
  (setq-local indent-tabs-mode t)
  (setq-local tab-width 4)
  )
;; Use custom function if sh-mode is activated anywhere
(add-hook 'sh-mode-hook #'my-sh-mode-setup)
;; Ensure APKBUILD files open in sh-mode so the hook above triggers
(add-to-list 'auto-mode-alist '("APKBUILD\\'" . sh-mode))

(use-feature eglot
  :defer t
  :hook ((html-mode . eglot-ensure)
         (mhtml-mode . eglot-ensure))
  :bind(
        :map eglot-mode-map
             ("C-c r" . eglot-rename)
             ("C-c o" . eglot-code-action-organize-imports)
             ("C-c h" . eldoc))
  :config
  (add-to-list 'eglot-server-programs
               '((html-mode mhtml-mode) . ("superhtml" "lsp")))
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              ;; Show flymake diagnostics first.
              (setq eldoc-documentation-functions
                    (cons #'flymake-eldoc-function
                          (remove #'flymake-eldoc-function eldoc-documentation-functions)))
              ;; Show all eldoc feedback.
              (setq eldoc-documentation-strategy #'eldoc-documentation-compose)))
  )

(use-package flymake-bean-check
  :after flymake)

(use-package beancount
  :commands beancount-mode
  :mode ("\\.beancount\\'" . beancount-mode)
  :hook
  (beancount-mode . (lambda ()
                      (setq-local electric-indent-chars nil)
                      (outline-minor-mode)
                      (flymake-mode) ; Enable flymake-mode here
                      (flymake-bean-check-enable)))
  :bind (:map beancount-mode-map
              ("C-c C-n" . outline-next-visible-heading)
              ("C-c C-p" . outline-previous-visible-heading)
              ("C-c C-u" . outline-up-heading)
              ("C-c C-b" . outline-backward-same-level)
              ("C-c C-f" . outline-forward-same-level)
              ("C-c C-a" . outline-show-all)
              ([backtab] . beancount-outline-cycle)))

(use-package magit
  :ensure t
  :bind (
         ("C-x g" .	magit-status)
         ("C-x M-g"	. magit-dispatch)
         ("C-c M-g"	. magit-file-dispatch)))

(defun my-c-common-setup ()
  "Standardized settings for C-family languages."
  ;; Standards: PEP 8 (Python) and modern C++ (LLVM/Google) prefer spaces.
  ;; Install clangd or clang-extra-tools package for LSP features with eglot
  (setq-local indent-tabs-mode nil)
  (setq-local c-basic-offset 4) ; 4 is the modern industry standard
  (eglot-ensure))
(add-hook 'c-mode-common-hook #'my-c-common-setup)

;; (use-package arduino-mode
;;   :ensure t
;;   :mode ("\\.ino$" . arduino-mode)
;;   )

;; (use-package platformio-mode
;;   :ensure t
;;   :hook ((c-mode . platformio-conditionally-enable)
;;          (c++-mode . platformio-conditionally-enable))
;;   )

;; (use-package projectile
;;   :ensure t
;;   :init
;;   (projectile-mode +1)
;;   :bind (:map projectile-mode-map
;;               ("s-p" . projectile-command-map)
;;               ("C-c p" . projectile-command-map)))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-feature tramp
  :defer t
  :config
  (setq tramp-auto-save-directory (expand-file-name "tramp-autosave" user-emacs-directory)
        password-cache-expiry 3600))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))
