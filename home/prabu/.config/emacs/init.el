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

(defvar beancount-mode-dir (file-name-as-directory (expand-file-name "beancount-mode" user-emacs-directory))
  "Directory containing beancount package.")
(defvar flymake-bean-check-dir (file-name-as-directory (expand-file-name "beancount-mode" user-emacs-directory))
  "Directory containing beancount package with flymake-bean-check.el.")

(defun load-user-file (file)
  (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file user-init-dir)))
;; https://www.reddit.com/r/emacs/comments/o6do4k/enabling_a_minor_mode_only_in_files_that_are_in_a/
;; (setq enable-local-variables :all)

;; https://www.emacswiki.org/emacs/LoadPath
;; (add-to-list 'load-path "~/.emacs.d/lisp/")

;;;; package sources

;; Initialize the emacs packaging system
(package-initialize)
;; By default melpa stable alone is enabled.
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/")) ;;Enable this if required
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
;; Use tabs for indentation in APKBUILD files
(add-hook 'sh-mode-hook
          (lambda ()
            (when (and buffer-file-name
                       (string-match-p "APKBUILD\\'" buffer-file-name))
              (setq indent-tabs-mode t))))

;; Remove trailing whitespace before saving
(add-hook 'before-save-hook 'delete-trailing-whitespace)
;;;; smooth scrolling

(pixel-scroll-precision-mode)

;; https://batsov.com/articles/2021/12/19/building-emacs-from-source-with-pgtk/

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
;;;; transparency
;; Not working. Disabled for now by commenting the below code

;; https://www.emacswiki.org/emacs/TransparentEmacs
;;(set-frame-parameter (selected-frame) 'alpha '(<active> . <inactive>))
 ;;(set-frame-parameter (selected-frame) 'alpha <both>)
;; (set-frame-parameter (selected-frame) 'alpha '(85 . 50))
;; (add-to-list 'default-frame-alist '(alpha . (85 . 50)))

;; (defun toggle-transparency ()
;;   (interactive)
;;   (let ((alpha (frame-parameter nil 'alpha)))
;;     (set-frame-parameter
;;      nil 'alpha
;;      (if (eql (cond ((numberp alpha) alpha)
;;                     ((numberp (cdr alpha)) (cdr alpha))
;;                     ;; Also handle undocumented (<active> <inactive>) form.
;;                     ((numberp (cadr alpha)) (cadr alpha)))
;;               100)
;;          '(85 . 50) '(100 . 100)))))
;; (global-set-key (kbd "C-c t") 'toggle-transparency)

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
;; (add-to-list 'load-path "better-defaults")
;; (add-to-list 'load-path "/home/prabu/.emacs.d/better-defaults")
;; (require 'better-defaults)

;;;; theme
;; (use-package nord-theme
;;   :ensure t
;;   :config
;;   (load-theme 'nord t)
;;   )
(use-package lambda-themes
  ;; :straight (:type git :host github :repo "lambda-emacs/lambda-themes")
  :load-path "lambda-themes"
  :custom
  (lambda-themes-set-italic-comments t)
  (lambda-themes-set-italic-keywords t)
  (lambda-themes-set-variable-pitch t)
  :config
  ;; load preferred theme
  (load-theme 'lambda-dark-faded t)
  )
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


;; https://emacs.stackexchange.com/questions/77295/org-roam-case-insensitive-search
(defun case-insensitive-org-roam-node-read (orig-fn &rest args)
  (let ((completion-ignore-case t))
    (apply orig-fn args)))

(defun build/export-all ()
  (dolist (org-file (directory-files-recursively org-roam-directory "\.org$"))
     (with-current-buffer (find-file org-file)
			   (message (format "[build] Exporting %s" org-file))
			   (org-hugo-export-wim-to-md :all-subtrees nil nil nil))))

;; (defhydra hydra-flycheck (:color blue)
;;   ;; https://www.reddit.com/r/emacs/comments/931la6/tip_how_to_adopt_flycheck_as_your_new_best_friend/
;;   "
;;   ^
;;   ^Flycheck^          ^Errors^            ^Checker^
;;   ^────────^──────────^──────^────────────^───────^─────
;;   _q_ quit            _<_ previous        _?_ describe
;;   _M_ manual          _>_ next            _d_ disable
;;   _v_ verify setup    _f_ check           _m_ mode
;;   ^^                  _l_ list            _s_ select
;;   ^^                  ^^                  ^^
;;   "
;;   ("q" nil)
;;   ("<" flycheck-previous-error :color pink)
;;   (">" flycheck-next-error :color pink)
;;   ("?" flycheck-describe-checker)
;;   ("M" flycheck-manual)
;;   ("d" flycheck-disable-checker)
;;   ("f" flycheck-buffer)
;;   ("l" flycheck-list-errors)
;;   ("m" flycheck-mode)
;;   ("s" flycheck-select-checker)
;;   ("v" flycheck-verify-setup))

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
;;;; bind-key
;; https://framagit.org/steckerhalter/steckemacs.el/-/blob/master/steckemacs.el#L148
(use-package bind-key
  :ensure t
  ;; A simple way to manage personal keybindings, provided by `use-package'
  :init
  ;; If non-nil, extract docstrings from lambdas, closures and keymaps if possible.
  (setq bind-key-describe-special-forms t)
  (defun my-keyboard-translations (&optional frame)
    (with-selected-frame (or frame (selected-frame))
      (define-key input-decode-map (kbd "C-h") (kbd "<backspace>"))
      (define-key input-decode-map (kbd "M-h") (kbd "<M-backspace>"))))
  (add-to-list 'after-make-frame-functions 'my-keyboard-translations)
  :bind
  ;; ("<f10>" . save-buffer)
  ;; ("<f6>" . my-kill-buffer)
  ;; ("<f7>" . my-toggle-window-split)
  ;; ("C-8" . my-split-window)
  ;; ("<f2>" . split-window-vertically)
  ;; ("S-<f2>" . make-frame-command)
  ;; ("<f3>" . split-window-horizontally)
  ;; ("<f4>" . delete-window)
  ;; ("S-<f4>" . delete-frame)
  ;; ("<f5>" . delete-other-windows)
  ;; ("S-<f5>" . delete-other-frames)
  ;; ("C-c c" . my-capture)
  ;; ("C-c m" . menu-bar-mode)
  ;; ("C-c n" . my-org-agenda)
  ;; ("C-c a" . org-agenda)
  ("C-c g" . magit-status)
  ("C-c d" . ispell-change-dictionary)
  ("C-c n f" . org-roam-node-find)
  ("C-c n r" . org-roam-node-random)
  ;; ("C-z" . undo)
  ;; ("C-c s" . web-search)
  ;; ("C-c w" . wdired-mode)
  ;; ("<f9>" . helm-org-roam)
  )


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

;;;; hydra
;; Make bindings that stick around. https://framagit.org/steckerhalter/steckemacs.el/-/blob/master/steckemacs.el#L375
(use-package hydra
  ;; :quelpa
  :ensure t
  :defer 2
  ;; :bind ("C-c f" . hydra-flycheck/body)
  )
  ;; :bind
;;   ("S-SPC" . hydra-navigate/body) ;;here hydra-! is the name of hydra function
;;   ;; ("<menu>" . !/body) ;;more than hydra can be defined or same hydra can have multiple shortcuts.
;;   :config
;;   (defun kbds (keys)
;;     "Simulate keyboard input.
;; KEYS should be provided as with `kbd'."
;;     (execute-kbd-macro (kbd keys)))
;;   (defmacro hydra-resume (fn &rest args)
;;     "Execute FN and resume the current hydra."
;;     `(progn (if (commandp ',fn)
;;                 (call-interactively ',fn)
;;               (,fn ,@args))
;;             (funcall hydra-curr-body-fn)))
;;   (defmacro hydra-arg (fn &rest plist)
;;     "Execute FN or with arg the function given in the PLIST.
;; PLIST are pairs of the numerical argument and function, for example to call `find-file' with C-u, use: 4 find-file"
;;     ;; Example:
;;     ;; ("SPC f" (hydra-arg ff-helm-places 4 hydra-ff) :exit t)
;;     ;; (defhydra hydra-ff (:color blue :pre (setq hydra-is-helpful t) :post (!/body))
;;     ;;   "Firefox"
;;     ;;   ("f" ff-helm-places "History")
;;     ;;   ("b" ff-helm-bookmarks "Bookmarks")
;;     ;;   ("u" ff-paste-current-url "Yank current url")
;;     ;;   ("q" nil "quit"))
;;     `(let* ((prefix (prefix-numeric-value current-prefix-arg))
;;             (fnp (plist-get ',plist prefix)))
;;        (call-interactively (or fnp ',fn))))
;;   (defun !/state (&optional exit)
;;     ;; TODO: add state to mode-line
;;     (setq hydra-is-helpful exit)
;;     (if exit
;;         (progn
;;           (setq which-key-show-docstrings 'docstring-only)
;;           (custom-theme-recalc-face 'cursor))
;;       ;; (set-face-background 'cursor "#ff5f87")
;;       (set-face-background 'cursor "#40e0d0") ;;changed the hydra color
;;       (setq which-key-show-docstrings nil))))

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

;;;; helm
;; Below code to load helm and bind keys taken from
;; https://github.com/jwiegley/use-package without melpa-stable helm
;; could not install.
;; https://emacs.stackexchange.com/questions/44529/use-package-wont-load-helm-for-projectile
;; sample helm settings from helm author
;; https://github.com/thierryvolpiatto/emacs-config/blob/main/init-helm.el

(use-package helm
  ;; :quelpa
  :ensure t
  :pin melpa-stable
  :bind (
         ("C-x b" . helm-mini)
         ("C-S-y" . helm-show-kill-ring)
         ("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ;; ([f9] . helm-buffers-list)
         ;; ([S-f10] . helm-recentf)
         )
  :custom
  (helm-split-window-default-side 'right)
  )
;; Helm can resize its buffer automatically to fit the number of candidates
;; (setq ;;helm-autoresize-mode t
;;       helm-autoresize-max-height                80   ; it is %.
;;       helm-autoresize-min-height                20   ; it is %.
;;       )

;;;; org Mode
;; https://orgmode.org/worg/org-tutorials/orgtutorial_dto.html
;; https://www.reddit.com/r/emacs/comments/dv02lk/how_to_force_emacs_to_prefer_manually_installed/

(use-package org
  ;; :quelpa
  :pin gnu
  :mode (("\\.org$" . org-mode))
  :ensure t
  :requires oc
  :requires org-id
  :requires org-tempo
  :custom
  ;; (org-directory (file-truename "/data/docs/prabu/Dropbox/org"))
  (org-cite-global-bibliography '("~/org/Resources/my_library.bib"))
  (org-cite-csl-styles-dir '("~/Zotero/styles"))
  :bind (
         ("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         )
  )

(setq org-log-done t)
(setq org-todo-keywords
      '((sequence "TODO(t)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELED(c@)")))

;; https://orgmode.org/manual/Setting-Tags.html#Setting-Tags
(setq org-tag-alist '((:startgroup . nil)
                      ("@kpm" . ?k) ("@home" . ?h)
                      ("@errands" . ?e)
                      (:endgroup . nil)
                      ("@computer" . ?c) ("@phone" . ?p) ("@reading" . ?r)))

;;http://doc.norang.ca/org-mode.html#AgendaSetup
(setq org-agenda-files (quote ("/data/docs/prabu/Dropbox/org") ;; ("~/org1") folders can be added
                              )
      )
;; Undefine keys "C-c [" and "C-c ]" which expands the agenda list files
(add-hook 'org-mode-hook
	      '(lambda ()
	         (org-defkey org-mode-map "\C-c[" 'undefined)
	         (org-defkey org-mode-map "\C-c]" 'undefined))
	      'append)

;;;; org-roam
;;;;; comments
;; Install and configure org-roam as per following sources
;; https://www.orgroam.com/manual.html and for dailies
;; https://www.orgroam.com/manual.html#org_002droam_002ddailies
;; https://lucidmanager.org/productivity/taking-notes-with-emacs-org-mode-and-org-roam/
;; https://systemcrafters.net/build-a-second-brain-in-emacs/keep-a-journal/
;; https://org-roam.discourse.group/t/how-to-put-all-the-org-roam-dailies-in-one-file-with-a-date-tree-structure/1561/2
;;;;; code
(use-package org-roam
  :ensure t
  :after org
  :init
  (setq org-roam-v2-ack t) ;; Acknowledge V2 upgrade
  ;; (org-roam-completion-everywhere t)
  (setq org-roam-completion-system 'helm)
  :custom
  (org-roam-directory (file-truename "/data/docs/prabu/Dropbox/org/Resources"))
  ;; (setq org-roam-directory (file-truename "~/org/Resources"))
  (org-roam-dailies-directory "daily")
  (org-roam-dailies-capture-templates
   '(("d" "default" entry
      "* %?"
      :target (file+datetree "daily_journal.org" day);;either day|week|month is allowed
      :Context: %a\n%?)))
  :config
  (org-roam-db-autosync-mode)
  (setq org-id-extra-files (org-roam--list-files org-roam-directory))
  (advice-add 'org-roam-node-read :around #'case-insensitive-org-roam-node-read)
  (message "org-roam loaded")
  ;; (require 'org-roam-dailies)
  :bind (
         ;; below two global commands moved to bind-key package
         ;; ("C-c n f" . org-roam-node-find)
         ;; ("C-c n r" . org-roam-node-random)
         :map org-mode-map
         ("C-c n i" . org-roam-node-insert)
         ("C-c n o" . org-id-get-create)
         ("C-c n t" . org-roam-tag-add)
         ("C-c n a" . org-roam-alias-add)
         ("C-c n l" . org-roam-buffer-toggle)
         ("C-M-i" . completion-at-point)))

;; Below code not working. To be fixed at a later date
;; :map org-roam-dailies-map
;; ("Y" . org-roam-dailies-capture-yesterday)
;; ("T" . org-roam-dailies-capture-tomorrow)
;; :bind-keymap
;; ("C-c n d" . org-roam-dailies-map)

;; Below options are not used for now. Need to see if they are useful

;; (setq org-id-link-to-org-use-id 'use-existing)

;; #for ox-hugo# https://hugocisneros.com/org-config/#org-roam
(setq org-id-link-to-org-use-id t)
;; (setq org-id-extra-files (org-roam--list-files org-roam-directory)) moved to :config section
(setq org-return-follows-link t)

;;;; ox-hugo

(use-package ox-hugo
  :ensure t   ;;Auto-install the package from Melpa
  :pin melpa  ;;`package-archives' should already have ("melpa" . "https://melpa.org/packages/")
  :after ox
  :custom
  ;; (org-id-link-to-org-use-id t)
  (org-hugo-base-dir "/data/docs/prabu/Dropbox/org/quickstart/")
  (org-hugo-section "note")
  (citeproc-org-org-bib-header "* Bibliography\n<ol class=\"biblio-list\">")
  (citeproc-org-org-bib-footer "</ol>")
  )
;; (org-id-extra-files (directory-files-recursively org-roam-directory "\.org$"))
;; (setf org-id-extra-files (directory-files-recursively org-hugo-base-dir "org"))

;; Exporting Org-Mode Documents With Many Org-Id Links Is Slow https://notes.alexkehayias.com/exporting-org-mode-documents-with-many-org-id-links-is-slow/

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
;; (use-package markdown-mode
;;   )
;;;; python IDE
;; Current IDE uses emacs packages Python,hide-mode-line,live-py-mode,flymake,Company, Eglot
;; Eglot connects to python-lsp and ruff
;; https://gitlab.com/nathanfurnal/dotemacs/-/snippets/2060535
;; https://robbmann.io/emacsd/#language-specific-major-modes
;; python-mode is the builtin major-mode for the Python language.
;; https://www.adventuresinwhy.com/post/eglot/

;;;;; Python
;; Using inbuilt python.el. Other alternates are python-mode, elpy etc..

(use-package python
  :config
  ;; Remove guess indent python message
  (setq python-indent-guess-indent-offset-verbose nil)
  ;; https://robbmann.io/emacsd/#language-specific-major-modes
  ;; (setq python-check-command "ruff")
  ;; https://www.reddit.com/r/emacs/comments/10yzhmn/flymake_just_works_with_ruff/
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
  :mode  ("\\.py\\'" . python-ts-mode)
  ;; https://www.adventuresinwhy.com/post/eglot/
  ;;check flymake-ruff below
;; (add-hook 'python-base-mode-hook 'flymake-mode)
  ;; (setq python-flymake-command '("ruff" "--quiet" "--stdin-filename=stdin" "-"))
  ;; https://stackoverflow.com/questions/1259873/how-can-i-use-emacs-flymake-mode-for-python-with-pyflakes-and-pylint-checking-co
  ;; (add-hook 'python-mode-hook
  ;;     (lambda ()
  ;;       (unless (eq buffer-file-name nil) (flymake-mode 1)) ;dont invoke flymake on temporary buffers for the interpreter
  ;;       (local-set-key [f2] 'flymake-goto-prev-error)
  ;;       (local-set-key [f3] 'flymake-goto-next-error)
  ;;       ))
)
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
  :defer t
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


;; (add-to-list 'load-path "/home/prabu/.emacs.d/flymake-diagnostic-at-point-master")
;; (use-package flymake-diagnostic-at-point
;;   :after flymake
;;   :config
;;   (add-hook 'flymake-mode-hook #'flymake-diagnostic-at-point-mode)
;;   )

;;;; Company
;; Provide drop-down completion.
(use-package company
  :ensure t
  :defer t
  :custom
  ;; Search other buffers with the same modes for completion instead of
  ;; searching all other buffers.
  (company-dabbrev-other-buffers t)
  (company-dabbrev-code-other-buffers t)
  ;; M-<num> to select an option according to its number.
  (company-show-numbers t)
  ;; Only 2 letters required for completion to activate.
  (company-minimum-prefix-length 3)
  ;; Do not downcase completions by default.
  (company-dabbrev-downcase nil)
  ;; Even if I write something with the wrong case,
  ;; provide the correct casing.
  (company-dabbrev-ignore-case t)
  ;; company completion wait
  (company-idle-delay 0.2)
  ;; No company-mode in shell & eshell
  (company-global-modes '(not eshell-mode shell-mode))
  ;; Use company with text and programming modes.
    :hook ((text-mode . company-mode)
           (prog-mode . company-mode)))

;;;; Eglot
;; See: https://github.com/joaotavora/eglot.
;; https://www.adventuresinwhy.com/post/eglot/
;; sudo pacman -S python-lsp-server
(use-package eglot
  :ensure t
  :defer t
  :hook (
         (python-mode . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         )
  :config
  ;; https://www.reddit.com/r/emacs/comments/16fvmow/disable_eglotinlayhintsmode_in_every_buffer/
  ;; (setq eglot-ignored-server-capabilities '(:inlayHintProvider))
;; https://www.reddit.com/r/emacs/comments/106oq11/eglot_flymake_eldoc/
  (with-eval-after-load 'eglot
    (add-hook 'eglot-managed-mode-hook
              (lambda ()
                ;; Show flymake diagnostics first.
                (setq eldoc-documentation-functions
                      (cons #'flymake-eldoc-function
                            (remove #'flymake-eldoc-function eldoc-documentation-functions)))
                ;; Show all eldoc feedback.
                (setq eldoc-documentation-strategy #'eldoc-documentation-compose))))
;; To enable pyvenv in eglot
;; https://github.com/wyuenho/emacs-pet/issues/29#issuecomment-1812952799
  ;; (setq-default eglot-workspace-configuration
  ;;                 '(:pylsp (:plugins
  ;;                           (:pylsp_mypy (;;:enabled t
  ;;                                         :overrides ["--python-executable"
  ;;                                                   "home/prabu/.venv/bin/python"
  ;;                                                    t])
  ;;                                  ))))

  :bind(
        :map eglot-mode-map
             ("C-c r" . eglot-rename)
             ("C-c o" . eglot-code-action-organize-imports)
             ("C-c h" . eldoc)
             )
  )
;;;; beancount
(use-package beancount
  :load-path beancount-mode-dir
  :commands beancount-mode
  :hook
  (beancount-mode . outline-minor-mode)
  :config
  (setq-local electric-indent-chars nil)
  :bind (:map beancount-mode-map
              ("C-c C-n" . outline-next-visible-heading)
              ("C-c C-p" . outline-previous-visible-heading)
              ("C-c C-u" . outline-up-heading)
              ("C-c C-b" . outline-backward-same-level)
              ("C-c C-f" . outline-forward-same-level)
              ("C-c C-a" . outline-show-all)
              ("C-c TAB" . beancount-outline-cycle)
              ))
(use-package flymake-bean-check
  :load-path flymake-bean-check-dir
  :hook
  (beancount-mode . flymake-bean-check-enable)
  )

;; ;; https://github.com/beancount/beancount-mode
;; ;; (setq beancount-mode-old-style-keybindings t)
;; (add-to-list 'load-path "/home/prabu/.emacs.d/beancount-mode/")
;; (require 'beancount)
;; (add-to-list 'auto-mode-alist '("\\.beancount\\'" . beancount-mode))
;; (add-hook 'beancount-mode-hook
;;           (lambda () (setq-local electric-indent-chars nil)))
;; (setq beancount-outline-regexp "\\(\\*+\\)")
;; (add-hook 'beancount-mode-hook #'outline-minor-mode)
;; (define-key beancount-mode-map (kbd "C-c C-n") #'outline-next-visible-heading)
;; (define-key beancount-mode-map (kbd "C-c C-p") #'outline-previous-visible-heading)
;; (define-key beancount-mode-map (kbd "C-c C-u") #'outline-up-heading)
;; (define-key beancount-mode-map (kbd "C-c C-b") #'outline-backward-same-level)
;; (define-key beancount-mode-map (kbd "C-c C-f") #'outline-forward-same-level)
;; (define-key beancount-mode-map (kbd "C-c C-a") #'outline-show-all)
;; ;; (define-key beancount-mode-map (kbd "C-c C-t") #'outline-hide-body)
;; ;; (define-key beancount-mode-map (kbd "C-c C-q") #'outline-hide-sublevels)
;; (define-key beancount-mode-map (kbd "C-c TAB") #'beancount-outline-cycle)
;; (require 'flymake-bean-check)
;; (add-hook 'beancount-mode-hook #'flymake-bean-check-enable)

;;;; helm-org-rifle

(use-package helm-org-rifle
  ;; :quelpa
  :ensure t
  :pin melpa-stable
  :bind (
         ("C-c r" . helm-org-rifle-org-directory)
         )
  )
;;;; helm-swoop

(use-package helm-swoop
  ;; :quelpa (helm-swoop :fetcher github :repo "emacsorphanage/helm-swoop")
  :ensure t
  :after helm
  )

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


;;;; nov - epub reader
(use-package nov
  :ensure t
  :mode ("\\.epub\\'" . nov-mode)
  :custom
  (nov-text-width 80)  ;; Adjust text width for readability
  (nov-variable-pitch t)  ;; Use variable pitch font for a more book-like appearance
  ;; (nov-custom-css-file (expand-file-name "nov-custom.css" user-emacs-directory))
  :config
  ;; Any additional configurations can go here
  ;; set Bookerly as the variable-pitch font only inside the mode
  (defun my-nov-font-setup ()
    (face-remap-add-relative 'variable-pitch nil
                             :family "Bookerly"
                             :height 1.1))
  (add-hook 'nov-mode-hook 'my-nov-font-setup)

  (defun my-nov-window-configuration-change-hook ()
    (my-nov-post-html-render-hook)
    (remove-hook 'window-configuration-change-hook
                 'my-nov-window-configuration-change-hook
                 t))
  (require 'justify-kp)
  (setq nov-text-width t)
  (defun my-nov-post-html-render-hook ()
    (if (get-buffer-window)
        (let ((max-width (pj-line-width))
              buffer-read-only)
          (save-excursion
            (goto-char (point-min))
            (while (not (eobp))
              (when (not (looking-at "^[[:space:]]*$"))
                (goto-char (line-end-position))
                (when (> (shr-pixel-column) max-width)
                  (goto-char (line-beginning-position))
                  (pj-justify)))
              (forward-line 1))))
      (add-hook 'window-configuration-change-hook
                'my-nov-window-configuration-change-hook
                nil t)))

  (add-hook 'nov-post-html-render-hook 'my-nov-post-html-render-hook)

  ;; ;; Force reload of the custom CSS
  ;; (defun my-nov-reload-custom-css ()
  ;;   (interactive)
  ;;   (setq nov-css-url nil)
  ;;   (nov-render-document))

  ;; (add-hook 'nov-mode-hook 'my-nov-reload-custom-css)
  )


;;;; justify-kp
(use-package justify-kp
  :load-path "~/.config/emacs/"
  :config
  ;; Your configuration here
  ;; (setq justify-kp-option t))  ;; Example configuration
)
;;;; eww
;; https://emacs.stackexchange.com/questions/7328/how-to-make-eww-default-browser-in-emacs
;; https://howardism.org/Technical/Emacs/browsing-in-emacs.html
;; (setq browse-url-browser-function 'eww-browse-url)
;; https://www.reddit.com/r/orgmode/comments/n5tlv4/opening_links_in_eww/

;; (setq browse-url-browser-function 'eww-browse-url
;;       shr-use-colors nil
;;       shr-bullet "• "
;;       shr-folding-mode t
;;       eww-search-prefix "https://html.duckduckgo.com/html?q="
;;       url-privacy-level '(email agent cookies lastloc)
;;       browse-url-secondary-browser-function 'browse-url-firefox)

;; (setq browse-url-browser-function 'browse-url-generic
;; browse-url-generic-program "firefox")

;;;; elfeed

(use-package elfeed
  :ensure t
  :config
  (setq browse-url-browser-function 'eww-browse-url)
  (setq elfeed-db-directory "~/.config/emacs/.elfeed")
  :bind(
        ("C-x w" . elfeed)
       )
  :init
  (setq elfeed-feeds
      '("https://abnormalreturns.com/feed"
        "https://archlinux.org/feeds/news/"
        ;; ...
        ))
)
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

(use-package arduino-mode
  :ensure t
  :mode ("\\.ino$" . arduino-mode)
  )

(use-package platformio-mode
  :ensure t
  :hook (c++-mode . platformio-conditionally-enable)
  )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("5ec088e25ddfcfe37b6ae7712c9cb37fd283ea5df7ac609d007cafa27dab6c64" default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
