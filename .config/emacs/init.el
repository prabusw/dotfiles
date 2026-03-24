;;; init.el -*- lexical-binding: t; -*-
;;; initialization
;;;; files and folders
;; https://stackoverflow.com/questions/2079095/how-to-modularize-an-emacs-configuration/2079146
(defconst user-init-dir
  (cond ((boundp 'user-emacs-directory)
         user-emacs-directory)
        ((boundp 'user-init-directory)
         user-init-directory)
        (t "~/.emacs.d/")))

(defun load-user-file (file)
  (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file user-init-dir)))
;; https://www.reddit.com/r/emacs/comments/o6do4k/enabling_a_minor_mode_only_in_files_that_are_in_a/
;; (setq enable-local-variables :all)

;; https://www.emacswiki.org/emacs/LoadPath
(add-to-list 'load-path "~/.emacs.d/lisp/")
;; (add-to-list 'load-path user-init-dir/lisp)
;;;; Backup settings
;; Based on https://git.sr.ht/~technomancy/better-defaults
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory
                                               "backups"))))
(setq version-control t)
(setq delete-old-versions t)
(setq kept-new-versions 5)
(setq backup-by-copying t)
(setq create-lockfiles nil)         ;; Prevents .# creation

;;;; package sources
; Define the package archives
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

;; Set priorities to prefer GNU over MELPA
(setq package-archive-priorities '(("gnu" . 10)
                                   ("melpa" . 5)))

;; Initialize the package system
(package-initialize)

;;;; use-package
;; The original code snippet for use-package based
;; https://ianyepan.github.io/posts/setting-up-use-package/ Later
;; modified based on https://github.com/jwiegley/use-package ,
;; https://github.com/kingcons/dotemacs/blob/master/init.el and
;; currently based on https://framagit.org/steckerhalter/steckemacs.el

(unless (require 'use-package nil t)
  (when (not package-archive-contents)
    (package-refresh-contents))
  (package-install 'use-package)
  (use-package use-package-ensure
    :config  (setq use-package-always-ensure t)))

;; ;;;; quelpa
;; ;; Build and install your Emacs Lisp packages on-the-fly and directly
;; ;; from source either locally or from remote sources

;; ;; Install quelpa-use-package
;; (quelpa
;;  '(quelpa-use-package
;;    :fetcher git
;;    :url "https://github.com/quelpa/quelpa-use-package.git"))
;; (require 'quelpa-use-package)


;;; settings
;;;; Trailing whitespace and Tabs
;; There are few custom functions related to Tabs
;; Remove trailing whitespace before saving
(add-hook 'before-save-hook 'delete-trailing-whitespace)
;;;; smooth scrolling

(pixel-scroll-precision-mode)

;; https://batsov.com/articles/2021/12/19/building-emacs-from-source-with-pgtk/

;;;; Enable column number mode
(column-number-mode 1)

;;;; consistency

;; To change default font or size in Emacs https://stackoverflow.com/questions/294664/how-to-set-the-font-size-in-emacs
;; (set-face-attribute 'default nil :height 130)
;; (set-face-attribute 'default nil :font "Monaco-16" )
;; (set-face-attribute 'default nil :font "Hack-13:embolden=true" )
;; (set-face-attribute 'default nil :font "Roboto Mono-13" )
(set-face-attribute 'default nil :font "Hack-13" )


(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(setq display-line-numbers-type 'relative)

;; To make Tab-width consistent with all OS as per "Learning Emacs" 3rd Edition pg175
(setq-default tab-width 4)

;;;; Transparency

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

;;;; scratch buffer
;; Turn off the startup screen, splash screen and puts straight into
;; the scratch buffer to quickly type or paste in emacs instead of
;; standard emacs startpage
(setq-default inhibit-startup-screen t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq initial-scratch-message "")
;; (setq initial-buffer-choice "/home/prabu/newfile.txt")
(setq initial-major-mode 'fundamental-mode)

;;;; better-defaults
;; Found about better-defaults from
;; https://git.sr.ht/~technomancy/better-defaults
(use-package better-defaults
  :load-path "better-defaults"
  :init
  (require 'better-defaults)
  )

;;;; theme
(use-package nord-theme
  :ensure t
  :init
  (setq nord-region-highlight "frost")
  :config
  (load-theme 'nord t))
;;;; custom functions

(defun now ()
  "Insert string for the current time formatted like '2:34 PM'."
  (interactive)                 ; permit invocation in minibuffer
  ;; (insert (format-time-string "%-I:%M %p"))
  (insert (format-time-string "%R"))
)

(defun today ()
  "Insert string for today's date nicely formatted in American style,
e.g. Sunday, September 17, 2000."
  (interactive)                 ; permit invocation in minibuffer
  ;; (insert (format-time-string "%A, %B %e, %Y"))
  (insert (format-time-string "%F"))
  )
(defun my/doasedit ()
  (interactive)
  (if (buffer-file-name)
      (let ((cursor-pos (point))
            (truename (file-truename (buffer-file-name))))
        (find-alternate-file (concat "/doas::" truename))
        (goto-char cursor-pos))
    (message "This buffer is not visiting a file!")))

;; https://emacs.stackexchange.com/questions/77295/org-roam-case-insensitive-search
(defun case-insensitive-org-roam-node-read (orig-fn &rest args)
  (let ((completion-ignore-case t))
    (apply orig-fn args)))

;; (defun build/export-all ()
;;   (dolist (org-file (directory-files-recursively org-roam-directory "\.org$"))
;;      (with-current-buffer (find-file org-file)
;; 			   (message (format "[build] Exporting %s" org-file))
;; 			   (org-hugo-export-wim-to-md :all-subtrees nil nil nil))))

;; Define a reusable function for general programming mode setup
(defun my-programming-setup ()
  "Sets up common features for programming modes, including indentation and column display."
  (setq-local tab-width 4)
  (setq-local indent-tabs-mode t)
  (column-number-mode 1))

;; Define a function for sh-mode specific settings, which also calls the general setup
(defun my-sh-mode-setup ()
  "Setup for `sh-mode` that applies a specific offset after general programming setup."
  (my-programming-setup)
  (setq-local sh-basic-offset 4))
;;; packages

;;;; helpful
;; https://github.com/jeffkreeftmeijer/.emacs.d/blob/main/emacs-configuration.org
(use-package helpful
  :ensure t
  :init
  (require 'bind-key)
  :bind
  (("C-h f" . helpful-callable)  ; Replace describe-function
   ("C-h v" . helpful-variable)  ; Replace describe-variable
   ("C-h k" . helpful-key)       ; Replace describe-key
   ("C-h x" . helpful-command))) ; Replace describe-command
;;;; ediff
;; Enhanced settings for ediff in Emacs
(use-package ediff
  :config
  ;; Split window horizontally for ediff
  (setq ediff-split-window-function 'split-window-horizontally
        ;; Use a single frame for ediff
        ediff-window-setup-function 'ediff-setup-windows-plain
        ;; Keep the cursor in the same position when scrolling in ediff
        scroll-preserve-screen-position t
        ;; Do not highlight all differences
        ediff-highlight-all-diffs 'nil
        ;; Make ediff diffing algorithm more aggressive
        ediff-diff-options "-w"
        ;; Auto-refine differences
        ediff-auto-refine 'on
        ;; Automatically merge non-conflicting changes
        ediff-merge-split-window-function 'split-window-horizontally
        ;; Show help messages in the echo area
        ediff-show-clashes-only t
        ;; Ignore whitespace differences
        ediff-ignore-similar-regions t)

  ;; Define a function to quit ediff with a single 'q' press
  (defun my-ediff-quit-session ()
    (interactive)
    (ediff-quit 'no-confirm))

  ;; Hook to set custom key bindings
  (add-hook 'ediff-keymap-setup-hook
            (lambda ()
              (define-key ediff-mode-map (kbd "q") 'my-ediff-quit-session)))

  :bind (
         ;; Add any additional key bindings here if needed
         )
  )

;;;; outshine
;; Outshine brings Org Mode to the world outside of Org;; https://github.com/alphapapa/outshine

(use-package outshine
  ;; :quelpa (outshine :fetcher github :repo "alphapapa/outshine")
  :ensure t
  :diminish outline-minor-mode
  :commands outshine-hook-function
  :hook (;;(outline-minor-mode . outshine-mode) ;;this command affected beancount
         ;; (emacs-lisp-mode . outline-minor-mode))
         (emacs-lisp-mode . outshine-mode))
  :init
  (setq outshine-imenu-show-headlines-p nil))

;; To use outshine hook with a major mode, alternate way or command is
;; (add-hook 'emacs-lisp-mode-hook 'outshine-mode)

;;;; diminish
;; Diminished modes are minor modes with no modeline display
(use-package diminish
  ;; :quelpa
  :ensure t
  )
;;;; Vertico
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

;;;; org mode
;; https://orgmode.org/worg/org-tutorials/orgtutorial_dto.html
;; https://www.reddit.com/r/emacs/comments/dv02lk/how_to_force_emacs_to_prefer_manually_installed/

(use-package org
  ;; :quelpa
  ;; :pin gnu
  :ensure t
  :custom
  (org-return-follows-link t) ;;Allows links to be opened without C-c C-o in emacs
  ;; Use ONLY ONE of the below:
  (org-id-link-to-org-use-id t) ;; Adds properties to record org ID's to non-roam files too
  ;; (org-id-link-to-org-use-id 'use-existing) ;; doesn't add ID, so links break, if file renamed
  ;; (org-directory (file-truename "/data/docs/prabu/Dropbox/org"))
  ;; (org-cite-global-bibliography '("/data/myhome/prabu/Dropbox/org/Resources/my_library.bib"))
  ;; (org-cite-csl-styles-dir '("~/Zotero/styles"))
  (org-agenda-files '("/data/myhome/prabu/org/agenda"
                      "/data/myhome/prabu/org/Resources/daily_journal.org"))
  (org-log-done t)
  (org-todo-keywords '((sequence "TODO(t)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELED(c@)")))
  (org-tag-alist '((:startgroup . nil)
                   ("@kpm" . ?k) ("@home" . ?h)
                   ("@errands" . ?e)
                   (:endgroup . nil)
                   ("@computer" . ?c) ("@phone" . ?p) ("@reading" . ?r)))
  :bind (
         ("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         )
  :config
  (setq time-stamp-active t)
  (setq time-stamp-line-limit 10)               ; Plenty of room for line 4
  (setq time-stamp-start "^#\\+date:[ \t]*")    ; Just find the header
  (setq time-stamp-end "$")                     ; Replace everything until end of line
  (setq time-stamp-format "[%Y-%m-%d %a %H:%M:%S]")
  (add-hook 'org-mode-hook
            (lambda ()
              (add-hook 'before-save-hook 'time-stamp nil t)))
  ;; Undefine keys "C-c [" and "C-c ]" which expands the agenda list files
  (add-hook 'org-mode-hook
	        (lambda ()
	          (org-defkey org-mode-map "\C-c[" 'undefined)
	          (org-defkey org-mode-map "\C-c]" 'undefined))
	        'append))

;;;; org-roam
;; Install and configure org-roam as per following sources
;; https://www.orgroam.com/manual.html and for dailies
;; https://www.orgroam.com/manual.html#org_002droam_002ddailies
;; https://lucidmanager.org/productivity/taking-notes-with-emacs-org-mode-and-org-roam/
;; https://systemcrafters.net/build-a-second-brain-in-emacs/keep-a-journal/
;; https://org-roam.discourse.group/t/how-to-put-all-the-org-roam-dailies-in-one-file-with-a-date-tree-structure/1561/2
;; --- Custom Helper Functions ---
(defun my/org-roam-publish-site ()
  "Runs the graph gen, hugo build, and syncthing scan."
  (interactive)
  (message "Publishing site...")
  ;; Note: Using the actual path we verified earlier
  (shell-command "/data/myhome/prabu/org/my_hugo_site/scripts/publish_hugo_site.sh &"))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-database-connector 'sqlite-builtin)
  :custom
  (org-roam-v2-ack t)
  (org-roam-completion-everywhere t)
  (org-roam-directory (file-truename "/data/myhome/prabu/org/Resources"))
  (org-roam-dailies-directory ".")
  ;; Daily Template
  (org-roam-dailies-capture-templates
   '(("d" "default" entry
      "* %?\n:PROPERTIES:\n:CONTEXT: %a\n:END:"
      :target (file+datetree "daily_journal.org" day))));;either day|week|month is allowed
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
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map);; To use C-c n d Y or C-c n d T
  :config
  (require 'org-roam-dailies)
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
  ;; Refresh the list automatically whenever node is changed or saved
  (add-hook 'org-roam-db-sync-hook
            (lambda ()
              (setq org-id-extra-files (org-roam--list-files org-roam-directory))))
  (advice-add 'org-roam-node-read :around #'case-insensitive-org-roam-node-read)
  (message "org-roam loaded")
)
;; #for ox-hugo# https://hugocisneros.com/org-config/#org-roam

(use-package org-roam-ui
  :ensure t)
;;;; ox-hugo

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
  ;; (citeproc-org-org-bib-header "* Bibliography\n<ol class=\"biblio-list\">")
  ;; (citeproc-org-org-bib-footer "</ol>")
)
;;;; org-transclusion
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
;;;; markdown-Mode
;; Installed markdown package in the OS for preview
(use-package markdown-mode
  :ensure t
  )
;;;; python IDE
;; Current IDE uses emacs packages Python,hide-mode-line,live-py-mode,flymake,Company, Eglot
;; Eglot connects to python-lsp and ruff
;; https://gitlab.com/nathanfurnal/dotemacs/-/snippets/2060535
;; https://robbmann.io/emacsd/#language-specific-major-modes
;; python-mode is the builtin major-mode for the Python language.
;; https://www.adventuresinwhy.com/post/eglot/
;; https://stackoverflow.com/questions/1259873/how-can-i-use-emacs-flymake-mode-for-python-with-pyflakes-and-pylint-checking-co
;;;;; Python
;; Using inbuilt python.el. Other alternates are python-mode, elpy etc..

(use-package python
  :config
  (setq python-indent-guess-indent-offset-verbose nil)   ;; Remove guess indent python message
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))   ;; Remap python-mode to python-ts-mode
  (add-hook 'python-ts-mode-hook
            (lambda ()
              (setq mode-name "Python-TS")   ;; Set custom mode name for python-ts-mode
              ;; Ensure proper indentation in `python-ts-mode`
              (setq python-indent-offset 4)  ;; Use 4 spaces for indentation (PEP 8)
              (setq tab-width 4)            ;; Set tab width to 4
              (electric-indent-local-mode 1)))) ;; Enable automatic indentation

(use-package pet
  :ensure t
  :config
  (add-hook 'python-base-mode-hook 'pet-mode -10)
  (add-hook 'python-mode-hook
            (lambda ()
              (setq-local python-shell-interpreter (pet-executable-find "python")
                          python-shell-virtualenv-root (pet-virtualenv-root))
              (pet-eglot-setup)
              (eglot-ensure)
              ))
  )

;;;;; hide-mode-line

;; Hide the modeline for inferior python processes.  This is not a necessary
;; package but it's helpful to make better use of the screen real-estate at our
;; disposal. See: https://github.com/hlissner/emacs-hide-mode-line.

(use-package hide-mode-line
  :ensure t
  :hook (inferior-python-mode . hide-mode-line-mode)
  )

;;;;; live-py-mode
;; https://github.com/donkirkby/live-py-plugin
(use-package live-py-mode
  :ensure t
  )

;; The configuration related to Python has ended with the above line.

;;;; flymake
;; This package is inbuilt within emacs

(use-package flymake
  ;; https://www.gnu.org/software/emacs/manual/html_node/flymake/Finding-diagnostics.html
  :config
  :bind(
        :map flymake-mode-map
             ("M-n" . flymake-goto-next-error)
             ("M-p" . flymake-goto-prev-error)
             ("<f2>" . flymake-show-buffer-diagnostics)
  ))

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
        (right-fringe . 8)))
  )

;;;; cape
;; Provides in-buffer drop-down completion
(use-package cape
  :ensure t
  :init
  ;; Add to the global completion list
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

;;;; aports
;; Use custom function if sh-mode is activated anywhere
(add-hook 'sh-mode-hook 'my-sh-mode-setup)
;; Use a directory-local file (`.dir-locals.el`) to activate these settings
;; automatically in the aports project directory. The .dir-locals.el file should
;; be placed at the root of the aports tree with the following content:
;; ((nil . ((mode . sh))))
;; Earlier i used the following approach to use tabs for indentation in APKBUILD files
;; (add-to-list 'auto-mode-alist '("APKBUILD\\'" . sh-mode))

;;;; Eglot
;; See: https://github.com/joaotavora/eglot.
;; https://www.adventuresinwhy.com/post/eglot/
;; In alpine installed py3-lsp-server, ruff-lsp and beancount-language-server
;; https://www.reddit.com/r/emacs/comments/106oq11/eglot_flymake_eldoc/
  ;; https://www.reddit.com/r/emacs/comments/16fvmow/disable_eglotinlayhintsmode_in_every_buffer/
(use-package eglot
  :ensure t
  :defer t
  :hook
  (python-mode . eglot-ensure)
  (python-ts-mode . eglot-ensure)
  :config
  (with-eval-after-load 'eglot
    (add-hook 'eglot-managed-mode-hook
              (lambda ()
                ;; Show flymake diagnostics first.
                (setq eldoc-documentation-functions
                      (cons #'flymake-eldoc-function
                            (remove #'flymake-eldoc-function eldoc-documentation-functions)))
                ;; Show all eldoc feedback.
                (setq eldoc-documentation-strategy #'eldoc-documentation-compose))))
  :bind(
        :map eglot-mode-map
             ("C-c r" . eglot-rename)
             ("C-c o" . eglot-code-action-organize-imports)
             ("C-c h" . eldoc)
             )
  )

(use-package flymake-bean-check
  :after flymake
  )

;;;; beancount
(use-package beancount
  :commands beancount-mode
  :hook
  (beancount-mode . (lambda ()
                      (outline-minor-mode)
                      (flymake-mode) ; Enable flymake-mode here
                      (flymake-bean-check-enable)
                      ))
  :config
  (setq-local electric-indent-chars nil)
  :bind (:map beancount-mode-map
              ("C-c C-n" . outline-next-visible-heading)
              ("C-c C-p" . outline-previous-visible-heading)
              ("C-c C-u" . outline-up-heading)
              ("C-c C-b" . outline-backward-same-level)
              ("C-c C-f" . outline-forward-same-level)
              ("C-c C-a" . outline-show-all)
              ([backtab] . beancount-outline-cycle)
              ))

;;;; magit

(use-package magit
  ;; :quelpa (magit :fetcher github :repo "magit/magit")
  :ensure t
  ;; :after
  :bind (
         ("C-x g" .	magit-status)
         ("C-x M-g"	. magit-dispatch)
         ("C-c M-g"	. magit-file-dispatch)
         )
  )
;;

;;;; tree-sitter-module
;; https://www.adventuresinwhy.com/post/eglot/
;; https://github.com/casouri/tree-sitter-module

;;;; projectile
;; Needed for platformio-mode
(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))
;;;;
;; https://github.com/ZachMassia/platformio-mode
;; https://nickgeorge.net/programming/platformio-emcas/
;; Code from nickgeorge website converted by chatgpt
;; Enable irony for all c++ files, and platformio-mode only
;; when needed (platformio.ini present in project root).
(defun my/c++-mode-setup ()
  (when (derived-mode-p 'c++-mode)
    (irony-mode)
    (irony-eldoc)
    (platformio-conditionally-enable)))

;; (use-package irony-eldoc
;;   :ensure t
;;   )
;; (use-package irony
;;   :ensure t
;;   :config
;;   (add-hook 'irony-mode-hook 'irony-eldoc)
;;   (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
;;   (add-hook 'c++-mode-hook 'my/c++-mode-setup)
;;   :init
;;   (eval-after-load 'irony
;;     '(progn
;;        (define-key irony-mode-map [remap completion-at-point] 'irony-completion-at-point-async)
;;        (define-key irony-mode-map [remap complete-symbol] 'irony-completion-at-point-async)))
;;   )
;;;; Arduino
(use-package arduino-mode
  :ensure t
  :mode ("\\.ino$" . arduino-mode)
  )
;;;; platformio
(use-package platformio-mode
  :ensure t
  :hook (c++-mode . platformio-conditionally-enable)
  )

;;;; rainbow-delimiters
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))
;;;; TRAMP
(use-package tramp
  :defer t
  :config
  (setq tramp-auto-save-directory (expand-file-name "tramp-autosave" user-emacs-directory)
        password-cache-expiry 3600)
  )

;;;; custom
;; Redirect the "Custom" stuff to a separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))
