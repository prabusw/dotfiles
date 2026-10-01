;;; init.el -*- lexical-binding: t; -*-

;; This file is maintained as a literate file in
;; 20260510115218-emacs_config_file.org

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "better-defaults" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "beancount-mode" user-emacs-directory))

(use-package better-defaults
  :ensure nil
  :demand t
  :config
  ;; Overrides: these run after the package's own settings.
  (ido-mode -1)                                   ; vertico replaces ido
  (setq visible-bell nil)
  (setq ring-bell-function #'ignore)
  (global-set-key (kbd "C-x C-b") #'consult-buffer))

(setq backup-directory-alist `(("." . ,(concat user-emacs-directory
                                               "backups")))
      version-control t
      delete-old-versions t
      kept-new-versions 5
      backup-by-copying t
      create-lockfiles nil) ;; Prevents .# creation

;; define package-user-dir
(setq package-user-dir
      (expand-file-name (format "elpa-%s" (system-name)) user-emacs-directory))
;;Define the package archives
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

;; Set priorities to prefer GNU over MELPA
(setq package-archive-priorities '(("gnu" . 10)
                                   ("melpa" . 5)))

;; Initialize the package system
(package-initialize)

(require 'use-package)
(setq use-package-always-ensure t)

(defmacro use-feature (name &rest args)
  "Like `use-package' but for built-in features (sets :ensure nil).
NAME and ARGS as in `use-package'."
  (declare (indent defun))
  `(use-package ,name
     :ensure nil
     ,@args))

(pixel-scroll-precision-mode)

(set-face-attribute 'default nil :font "Hack-13" )

;; (advice-add 'ispell-completion-at-point :override #'ignore)
(with-eval-after-load 'ispell
  (setq ispell-program-name "hunspell")
  (setenv "DICPATH" "/usr/share/hunspell")
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

(use-package auto-dark
  :ensure t
  :after nord-theme
  :custom
  (auto-dark-themes '((nord) (modus-operandi)))
  :init (auto-dark-mode))

(setq-default indent-tabs-mode nil)

(defun my/untabify-buffer ()
  "Untabify the whole buffer, unless this buffer is meant to use tabs."
  (unless (or indent-tabs-mode buffer-read-only)
    (untabify (point-min) (point-max))))

(defun my-programming-setup ()
  "General settings for ALL programming modes"
  (column-number-mode 1)
  (setq-local display-line-numbers-type 'relative)
  (display-line-numbers-mode 1)
  (add-hook 'before-save-hook #'delete-trailing-whitespace nil t)
  (add-hook 'before-save-hook #'my/untabify-buffer nil t))

;; Apply this to every programming language automatically
(add-hook 'prog-mode-hook #'my-programming-setup)

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

(use-package helpful
  :ensure t
  :init
  (require 'bind-key)
  :bind
  (("C-h f" . helpful-callable)  ; Replace describe-function
   ("C-h v" . helpful-variable)  ; Replace describe-variable
   ("C-h k" . helpful-key)       ; Replace describe-key
   ("C-h x" . helpful-command))) ; Replace describe-command

(use-feature tramp
  :defer t
  :config
  (setq tramp-auto-save-directory (expand-file-name "tramp-autosave" user-emacs-directory)
        password-cache-expiry 3600))

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

(use-package magit
  :ensure t
  :bind (
         ("C-x g" .	magit-status)
         ("C-x M-g"	. magit-dispatch)
         ("C-c M-g"	. magit-file-dispatch)))

(defvar my/auto-tangle-files
  '("20260510115218-emacs_config_file.org"
    "20240317205837-swaywm.org"
    "20260616190442-sway_configuration_file.org"
    "20260617160421-sway_theme_toggle_script.org"
    "20240317210436-btrbk.org"
    "20260926215135-source_for_css.org"
    "20260529152048-graph_js.org"
    "20260529114550-gen_graph.org"
    "20260531212337-neighbour-loader_js.org"
    "20260601134637-neighbour_utils_js.org"
    "20260601135932-mobile_menu_js.org"
    "20260601144841-search_js.org"))
(defun my-org-mode-setup ()
  (electric-indent-local-mode -1)
  (when (and buffer-file-name
             (member (file-name-nondirectory buffer-file-name)
                     my/auto-tangle-files))
    (add-hook 'after-save-hook #'org-babel-tangle nil t)))

(use-feature org
  :custom
  (org-return-follows-link t) ;;Allows links to be opened without C-c C-o in emacs
  (org-id-link-to-org-use-id t) ;; Adds properties to record org ID's to non-roam files too
  (org-agenda-files '("/data/myhome/prabu/org/agenda"
                      ))
  (org-log-done t)
  (org-todo-keywords '((sequence "TODO(t)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELED(c@)")))
  (org-tag-alist '((:startgroup . nil)
                   ("@kpm" . ?k) ("@home" . ?h)
                   ("@errands" . ?e)
                   (:endgroup . nil)
                   ("@computer" . ?c) ("@phone" . ?p) ("@reading" . ?r)))
  (org-structure-template-alist '(("el" . "src emacs-lisp")
                                  ("py" . "src python")
                                  ("js" . "src javascript")
                                  ("s" . "src")
                                  ("e" . "example")
                                  ("q" . "quote")))
  :bind (
         ("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         )
  :config
  (keymap-set org-mode-map "C-c [" nil)
  (keymap-set org-mode-map "C-c ]" nil)
  ;; (setq time-stamp-active t)
  ;; (setq time-stamp-line-limit 10)               ; Plenty of room for line 4
  ;; (setq time-stamp-start "^#\\+date:[ \t]*")    ; Just find the header
  ;; (setq time-stamp-end "$")                     ; Replace everything until end of line
  ;; (setq time-stamp-format "[%Y-%m-%d %a %H:%M:%S]")
  :hook (org-mode . my-org-mode-setup))

(use-feature org-tempo
  :after org)

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
  ;; (org-roam-dailies-capture-templates
  ;;  '(("d" "default" entry
  ;;     "* %^{Title}\n%?"
  ;;     ;; "* %^{Title}\n:PROPERTIES:\n:EXPORT_FILE_NAME: %(format-time-string \"%Y-%m-%d\" (org-capture-get :default-time))\n:END:\n%?"
  ;;     :target (file+datetree "daily_journal.org" day)
  ;;     :empty-lines 1
  ;;     :no-id t)));;either day|week|month is allowed
  (org-roam-dailies-capture-templates
   '(("d" "default" entry
      "* %^{Title}\n%?"
      :target (file+head "%<%Y-%m-%d>.journal.org"
                         "#+title: %<%Y-%m-%d>\n#+date: %<%Y-%m-%dT%H:%M:%S%:z>\n#+filetags: :journal:\n")
      :empty-lines 1)))
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
  ;; (add-hook 'org-capture-before-finalize-hook #'my/set-daily-export-file-name)
  (advice-add 'org-roam-node-read :around #'case-insensitive-org-roam-node-read)
  (message "org-roam loaded"))
;; #for ox-hugo# https://hugocisneros.com/org-config/#org-roam

(use-package org-roam-ui
  :ensure t)

(defvar my/org-gemini-directory (file-truename "/data/myhome/prabu/org/gemini")
    "Directory where exported Gemini files should be stored.")

(defvar my/org-html-directory (file-truename "/data/myhome/prabu/org/html_site")
  "Directory where exported html files should be stored.")

(defvar my/sitemap-exclude-files '("20260517153259-index.org" "20260513193407-about.org")
  "Files published normally, but omitted from auto-generated sitemaps.")

(defvar my/publish-site-script "publish_site")

(defvar my/site-scss-file (expand-file-name "css/simple.scss" org-roam-directory))

(defvar my/site-css-output (expand-file-name "style.css" my/org-html-directory))

(defun my/compile-site-css ()
  "Compile simple.scss to style.css via dart-sass."
  (call-process "sass" nil "*sass-compile*" nil my/site-scss-file my/site-css-output))

(defun my/org-html-preamble (_info)
  "Top nav bar, matching simple.scss's structure."
  (concat
   "<nav class=\"topnav\">\n"
   "  <div class=\"topnav-links\">\n"
   "    <a href=\"/index.html\" class=\"topnav-title\">Knowledge Garden</a>\n"
   "    <a href=\"/notes.html\">Notes</a>\n"
   "    <a href=\"/journal.html\">Journal</a>\n"
   "    <a href=\"/about.html\">About</a>\n"
   "  </div>\n"
   "</nav>\n"))

(defun my/gemini-nav-block ()
  "Site nav block, gemtext link-line format."
  (concat
   "=> notes.gmi\tNotes\n"
   "=> journal.gmi\tJournal\n"
   "=> about.gmi\tAbout\n"
   "\n"))

(defun my/org-gemini-add-nav (orig-fun contents info)
  "Prepend the site nav block to every exported gemini page."
  (concat (my/gemini-nav-block) (funcall orig-fun contents info)))

(defun my/sitemap-excluded-p (file)
  (member (file-name-nondirectory file) my/sitemap-exclude-files))

(defun my/sitemap-sorted-files (project-name)
  "Return (PROJECT . FILES) for PROJECT-NAME, filtered and sorted newest-first.
Excludes the project's own :sitemap-filename, since org-publish-get-base-files
can include it as an expected file even when it doesn't yet exist on disk --
which crashes org-publish-find-date."
  (let* ((project (assoc project-name org-publish-project-alist))
         (sitemap-name (plist-get (cdr project) :sitemap-filename))
         (files (seq-remove
                 (lambda (f)
                   (or (my/sitemap-excluded-p f)
                       (and sitemap-name
                            (string= (file-name-nondirectory f) sitemap-name))))
                 (org-publish-get-base-files project))))
    (cons project
          (sort files
                (if (string-prefix-p "journal" project-name)
                    (lambda (a b)
                      (string> (file-name-nondirectory a) (file-name-nondirectory b)))
                  (lambda (a b)
                    (time-less-p
                     ;; (org-publish-find-date b project)
                     ;;             (org-publish-find-date a project)
                     (file-attribute-modification-time (file-attributes b))
                     (file-attribute-modification-time (file-attributes a))
                     )))))))

(defun my/html-sitemap-function-for (project-name)
  "Return an html-syntax sitemap function bound to PROJECT-NAME."
  (lambda (title _list)
    (pcase-let ((`(,project . ,files) (my/sitemap-sorted-files project-name)))
      (concat
       "#+title: " title "\n\n"
       (mapconcat
        (lambda (file)
          (format "- [[file:%s][%s]]\n"
                  (file-name-nondirectory file)
                  (org-publish-find-title file project)))
        files "")))))

(defun my/gemini-sitemap-function-for (project-name)
  "Return a gemtext-syntax sitemap function bound to PROJECT-NAME."
  (lambda (title _list)
    (pcase-let ((`(,project . ,files) (my/sitemap-sorted-files project-name)))
      (concat
       "#+title: " title "\n\n"
       "#+begin_export gemini\n"
       (mapconcat
        (lambda (file)
          (format "=> %s\t%s\n"
                  (concat (file-name-sans-extension (file-name-nondirectory file)) ".gmi")
                  (org-publish-find-title file project)))
        files "")
       "#+end_export\n"))))


(defun my/rewrite-id-links-for-gemini (tree backend info)
  "Rewrite or drop id: links in TREE, for backends that don't already
resolve them correctly.

This filter runs on parsed tree before the gemini backend transcodes
it, rewriting every id: link into a file:

Since gemtext has no anchor syntax, if the link is to same file, drop
it, keep the description as plain text.

If the link is to a different file, it is rewritten to a file: link,
keeping the .org extension deliberately -- org-gemini--describe-links
performs the equivalent .org -> .gmi swap after this filter has
already run.

Using this for html degrades html experience as ox-html resolves
cross-file id: links natively"
  (when (org-export-derived-backend-p backend 'gemini)
    (require 'org-id)
    (let ((current-file (plist-get info :input-file)))
      (org-element-map tree 'link
        (lambda (link)
          (when (string= (org-element-property :type link) "id")
            (let ((file (org-id-find-id-file (org-element-property :path link))))
              (when file
                (if (and current-file (file-equal-p file current-file))
                    (let* ((desc (org-element-contents link))
                           (post-blank (or (org-element-property :post-blank link) 0))
                           (text (concat
                                  (if desc
                                      (org-element-interpret-data desc)
                                    (org-element-property :raw-link link))
                                  (make-string post-blank ?\s))))
                      (org-element-set link (org-element-create 'plain-text nil text)))
                  (let ((filename (file-name-nondirectory file)))
                    (org-element-put-property link :type "file")
                    (org-element-put-property link :path filename)
                    (org-element-put-property link :raw-link (concat "file:" filename)))))))))))
  tree)

(use-feature ox
  :config
  (add-to-list 'org-export-filter-parse-tree-functions
               #'my/rewrite-id-links-for-gemini))

(use-package htmlize
  :ensure t)

(use-feature ox-html
  :custom
  (org-html-validation-link nil)
  (org-html-htmlize-output-type 'css))

(use-package ox-gemini
  :ensure t
  :pin melpa
  :after ox
  :config
  (defun org-gemini-code-inline (input _contents _info)
    "Generate inline code in Gemtext without the trailing space bug."
    (format "`%s`" (org-element-property :value input)))
  (advice-add 'org-gemini-template :around #'my/org-gemini-add-nav))


(use-feature ox-publish
  :after ox
  :config
  (setq org-publish-project-alist
        `(("notes-html"
           :base-directory ,org-roam-directory
           :base-extension "org"
           :exclude "\\.journal\\.org\\'\\|\\.blog\\.org\\'"
           :publishing-directory ,my/org-html-directory
           :publishing-function org-html-publish-to-html
           :with-broken-links mark
           :with-toc 3
           :section-numbers nil
           :html-preamble my/org-html-preamble
           :html-head-include-default-style nil
           :html-head-extra "<link rel=\"stylesheet\" href=\"/style.css\">"
           :auto-sitemap t
           :sitemap-filename "notes.html"
           :sitemap-title "Notes"
           :sitemap-function ,(my/html-sitemap-function-for "notes-html"))
          ("notes-gemini"
           :base-directory ,org-roam-directory
           :base-extension "org"
           :exclude "\\.journal\\.org\\'\\|\\.blog\\.org\\'"
           :publishing-directory ,my/org-gemini-directory
           :publishing-function org-gemini-publish-to-gemini
           :with-broken-links t
           :auto-sitemap t
           :sitemap-filename "notes.gmi"
           :sitemap-title "Notes"
           :sitemap-function ,(my/gemini-sitemap-function-for "notes-gemini"))
          ("journal-html"
           :base-directory ,org-roam-directory
           :base-extension "journal\\.org"
           :publishing-directory ,my/org-html-directory
           :publishing-function org-html-publish-to-html
           :with-broken-links mark
           :with-toc nil
           :section-numbers nil
           :html-preamble my/org-html-preamble
           :html-head-include-default-style nil
           :html-head-extra "<link rel=\"stylesheet\" href=\"/style.css\">"
           :auto-sitemap t
           :sitemap-filename "journal.html"
           :sitemap-title "Journal"
           :sitemap-function ,(my/html-sitemap-function-for "journal-html"))
          ("journal-gemini"
           :base-directory ,org-roam-directory
           :base-extension "journal\\.org"
           :publishing-directory ,my/org-gemini-directory
           :publishing-function org-gemini-publish-to-gemini
           :with-broken-links t
           :auto-sitemap t
           :sitemap-filename "journal.gmi"
           :sitemap-title "Journal"
           :sitemap-function ,(my/gemini-sitemap-function-for "journal-gemini"))
          ("all-sites"
           :components ("notes-html" "notes-gemini" "journal-html" "journal-gemini")))))


(defun my/trigger-syncthing-scan ()
  "Asynchronously run publish_site.sh to trigger a Syncthing rescan."
  (let ((script (executable-find my/publish-site-script)))
    (if script
        (start-process "publish-site-scan" "*publish-site-scan*" script)
      (message "my/trigger-syncthing-scan: %s not found on exec-path"
               my/publish-site-script))))

(defun my/publish-complete-html-site ()
  "Force-export every org-roam note, Journal to HTML site."
  (interactive)
  (require 'org-id)
  (org-id-update-id-locations (org-roam--list-files org-roam-directory))
  (org-publish "notes-html" t)
  (org-publish "journal-html" t)
  (my/compile-site-css)
  (my/trigger-syncthing-scan)
  (message "Published complete HTML + compiled CSS to %s" my/site-css-output))

(defun my/publish-complete-gemini-site ()
  "Force-export every org-roam note, Journal to gemini."
  (interactive)
  (require 'org-id)
  (require 'ox-gemini)
  (org-id-update-id-locations (org-roam--list-files org-roam-directory))
  (org-publish "notes-gemini" t)
  (org-publish "journal-gemini" t)
  (my/trigger-syncthing-scan)
  (message "Published complete gemini site"))

(defun my/publish-all-sites ()
  "Publish only changes to both the HTML site and Gemini."
  (interactive)
  (require 'org-id)
  (org-id-update-id-locations (org-roam--list-files org-roam-directory))
  (org-publish "all-sites")
  (my/compile-site-css)
  (my/trigger-syncthing-scan)
  (message "Publishing to both html and gemini completed."))

(defvar my/publish-log-buffer "*org-publish-log*")
(defvar my/publish-running-process nil
  "Tracks the background publish process, to avoid overlapping runs.")

(defun my/publish-all-sites-async ()
  "Run my/publish-all-sites in a background Emacs batch process,
so this Emacs session doesn't block while publishing."
  (interactive)
  (if (process-live-p my/publish-running-process)
      (message "A publish is already running -- see %s" my/publish-log-buffer)
    (let ((init-file (expand-file-name "init.el" user-emacs-directory)))
      (setq my/publish-running-process
            (start-process "org-publish" my/publish-log-buffer
                            "emacs" "--batch" "-l" init-file
                            "--eval" "(my/publish-all-sites)"))
      (set-process-sentinel
       my/publish-running-process
       (lambda (_proc event)
         (cond
          ((string-match-p "finished" event)
           (message "Publish finished. See %s for details." my/publish-log-buffer))
          ((string-match-p "\\(exited abnormally\\|failed\\)" event)
           (message "Publish FAILED -- check %s" my/publish-log-buffer)))))
      (message "Publishing started in background..."))))

(use-package org-transclusion
  :ensure t   ;;Auto-install the package from Melpa
  :hook (org-mode . org-transclusion-mode)
  )

(use-package org-noter
  :ensure t
  )

(use-package markdown-mode
  :ensure t
  )

(use-feature flymake
  ;; https://www.gnu.org/software/emacs/manual/html_node/flymake/Finding-diagnostics.html
  :bind(
        :map flymake-mode-map
             ("M-n" . flymake-goto-next-error)
             ("M-p" . flymake-goto-prev-error)
             ("<f2>" . flymake-show-buffer-diagnostics)))

(use-feature eglot
  :defer t
  :hook ((html-mode . eglot-ensure)
         (mhtml-mode . eglot-ensure))
  :bind(
        :map eglot-mode-map
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

;; From etc/emacsrc. Bind a key to reformat the entire file using
;; bean-format. Fixed error in the original function
(defun my/beancount-format-file ()
  "Reformat the whole buffer with bean-format"
  (interactive)
  (let ((line-no (line-number-at-pos)))
    (call-process-region (point-min) (point-max) "bean-format" t (current-buffer) nil "-")
    (goto-char (point-min))
    (forward-line (1- line-no))
    (recenter)
      ))

(use-package beancount
  :ensure nil
  :commands beancount-mode
  :mode ("\\.beancount\\'" . beancount-mode)
  :hook
  (beancount-mode . (lambda ()
                      (setq-local electric-indent-chars nil)
                      (setq-local beancount-outline-regexp "\\(\\*+\\)")
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
              ("C-c F" . my/beancount-format-file)
              ([backtab] . beancount-outline-cycle)))

(use-package flymake-bean-check
  :ensure nil
  :after (flymake beancount))

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
  (add-hook 'python-base-mode-hook 'pet-mode)
  (add-hook 'beancount-mode-hook 'pet-mode)
  (add-hook 'python-base-mode-hook
            (lambda ()
              (when-let* ((python (pet-executable-find "python")))
                (setq-local python-shell-interpreter python
                            python-shell-virtualenv-root (pet-virtualenv-root)))
              (pet-eglot-setup)
              (eglot-ensure)))
  (add-hook 'beancount-mode-hook
            (lambda ()
              (setq-local beancount-accounts-files
                          (directory-files default-directory t "\\.beancount$"))
              (when-let* ((root (pet-virtualenv-root))
                          (venv-bin (expand-file-name "bin" root))
                          (_ (file-directory-p venv-bin)))
                (setq-local exec-path (append (list venv-bin) exec-path))))))

(use-package hide-mode-line
  :ensure t
  :hook (inferior-python-mode . hide-mode-line-mode)
  )

(use-package live-py-mode
  :ensure t
  )

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

(defvar my/nord-rainbow-colors
  '("#88c0d0"   ; 1 cyan
    "#e07882"   ; 2 soft red
    "#ebcb8b"   ; 3 yellow
    "#a3be8c"   ; 4 green
    "#b48ead"   ; 5 purple
    "#8fbcbb"   ; 6 teal
    "#d08770"   ; 7 orange
    "#81a1c1"   ; 8 blue
    "#a692cc")  ; 9 lavender
  "Custom Rainbow-delimiters with depth colors for nord")

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  (defun my/nord-rainbow-faces (&rest _)
    "Give rainbow-delimiters distinct hues while nord is enabled."
    (when (memq 'nord custom-enabled-themes)
      (cl-loop for color in my/nord-rainbow-colors
               for depth from 1
               do (set-face-attribute
                   (intern (format "rainbow-delimiters-depth-%d-face" depth))
                   nil :foreground color))))
  ;; Re-apply whenever auto-dark (or you) enables a theme
  (add-hook 'enable-theme-functions #'my/nord-rainbow-faces))

(defun my-c-common-setup ()
  "Standardized settings for C-family languages."
  ;; Standards: PEP 8 (Python) and modern C++ (LLVM/Google) prefer spaces.
  ;; Install clangd or clang-extra-tools package for LSP features with eglot
  (setq-local indent-tabs-mode nil)
  (setq-local c-basic-offset 4) ; 4 is the modern industry standard
  (when (executable-find "clangd")
    (eglot-ensure)))
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
