(defun my/get-org-keyword (key)
  "Extract the value of a specific global metadata KEY from the current Org buffer."
  (org-element-map (org-element-parse-buffer) 'keyword
    (lambda (kw)
      (when (string= (org-element-property :key kw) (upcase key))
        (org-element-property :value kw)))
    nil t))
(defun my/zine-publish ()
  "Export Org-roam file to Zine .smd with absolute link verification and strict markdown fallback."
  (interactive)
  (let* ((zine-site-root "/data/myhome/prabu/org/zine_site/content/")
         (zine-section "blog")
         (zine-content-dir (expand-file-name zine-section zine-site-root))
         (current-file (buffer-file-name))
         (base-name (file-name-base current-file))
         (outfile (expand-file-name (concat base-name ".smd") zine-content-dir))

         ;; Extract metadata safely
         (title (or (my/get-org-keyword "TITLE") base-name))
         (author (or (my/get-org-keyword "AUTHOR") "Prabu Anand Kalivaradhan"))
         (raw-date (my/get-org-keyword "DATE"))
         (date (if raw-date
                   (replace-regexp-in-string "\\[\\|\\]\\| Mon\\| Tue\\| Wed\\| Thu\\| Fri\\| Sat\\| Sun" "" raw-date)
                 (format-time-string "%Y-%m-%dT%H:%M:%S"))))

    (unless (file-directory-p zine-content-dir)
      (make-directory zine-content-dir t))

    ;; Global export options configured to force Markdown and bypass HTML Generation
    (let ((org-export-with-toc nil)
          (org-md-toplevel-hlevel 1)
          (org-md-extension "smd")
          (org-export-with-tables t)            ;; Forces plain text Markdown tables
          (org-export-with-drawers nil))

      (cl-letf (((symbol-function 'org-md-link)
                 (lambda (link contents info)
                   (let* ((type (org-element-property :type link))
                          (path (org-element-property :path link))
                          (desc (or contents "")))
                     (cond
                      ;; 1. Handle Internal Org-Roam IDs
                      ((string= type "id")
                       (let* ((node (org-roam-node-from-id path))
                              (target-slug (if node (file-name-base (org-roam-node-file node)) nil)))
                         (if target-slug
                             (format "[%s](/%s/%s)" desc zine-section target-slug)
                           ;; If Org-roam cache resolution fails completely, output text instead of a broken link
                           (format "**%s**" (if (string= desc "") "Internal Link" desc)))))

                      ;; 2. Handle Mail Links lacking implicit protocol
                      ((and (string= type "mailto") (not (string-prefix-p "mailto:" path)))
                       (format "[%s](mailto:%s)" desc path))
                      ((and (string= type "http") (string-match-p "@" path) (not (string-prefix-p "http" path)))
                       (format "[%s](mailto:%s)" desc path))

                      ;; 3. Handle External Web Protocols
                      ((member type '("http" "https" "ftp"))
                       (when (string-prefix-p "//" path)
                         (setq path (concat "https:" path)))
                       (when (string= desc "")
                         (setq desc (if (string-match "//\\(www\\.\\)?\\([^/]+\\)" path)
                                        (match-string 2 path)
                                      "Link")))
                       (format "[%s](%s)" desc path))

                      ;; 4. Local media asset routing (Pictures directory maps to assets layout)
                      ((string= type "file")
                       (if (string-match-p "\\.\\(png\\|jpg\\|jpeg\\|gif\\|svg\\)$" path)
                           (format "![%s](/assets/%s)" desc path)
                         (format "[%s](/%s)" desc path)))

                      ;; Default Safe Fallback
                      (t
                       ;; Strip potential angle bracket syntax if evaluated as raw routing string
                       (setq path (replace-regexp-in-string "<\\|>" "" path))
                       (format "[%s](%s)" (if (string= desc "") "Link" desc) path)))))))

        (let ((exported-content (org-export-as 'md)))
          (with-temp-file outfile
            (insert "---\n")
            (insert (format ".title = \"%s\",\n" title))
            (insert (format ".author = \"%s\",\n" author))
            (insert (format ".date = \"%s\",\n" date))
            (insert ".layout = \"post.shtml\",\n")
            (insert "---\n\n")
            ;; Thoroughly purge all remnants of HTML tables, structural elements, and text subscripts
            (let ((clean-body (replace-regexp-in-string
                               (concat "</?table[^>]*>\\|</?colgroup>\\|</?col[^>]*>"
                                       "\\|</?tr>\\|</?td[^>]*>\\|</?th[^>]*>\\|</?tbody[^>]*>"
                                       "\\|</?sub>\\|</?sup>")
                               "" exported-content)))
              (insert clean-body))))))

    (message "Published to Zine: %s" outfile)))

(defun my/zine-publish-all ()
  "Mass export all Org files from the Org-roam directory to Zine."
  (interactive)
  (let* (;; 1. Define the source directory where your Org-roam notes live
         (org-roam-dir "/data/myhome/prabu/org/Resources/") ;; ADJUST THIS TO YOUR NOTES DIR
         ;; Find all .org files in that directory (excluding hidden files)
         (org-files (directory-files org-roam-dir t "\\.org$")))

    (if (not org-files)
        (message "No Org files found in %s" org-roam-dir)

      (let ((published-count 0))
        ;; Loop through each file
        (dolist (file org-files)
          ;; Prevent Emacs from opening UI windows for every single file
          (with-current-buffer (find-file-noselect file)
            (condition-case err
                (progn
                  ;; Run your existing single-file publish function
                  (my/zine-publish)
                  (setq published-count (1+ published-count)))
              ;; If a specific file fails (e.g., missing metadata), log it and move on
              (error (message "Failed to publish %s: %s" (file-name-nondirectory file) err)))))

        (message "Mass export complete! Successfully published %d files to Zine." published-count)))))
