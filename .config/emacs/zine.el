(defun my/get-org-keyword (key)
  "Safely extract the value of an Org keyword like #+TITLE."
  (let ((kv (assoc key (org-collect-keywords (list key)))))
    (if kv (cadr kv) nil)))

(defun my/zine-publish ()
  "Export Org-roam file to Zine .smd with correct link syntax and location."
  (interactive)
  (let* ((zine-content-dir "/data/myhome/prabu/org/zine_site/content/") ;; Ensure this ends in /
         (current-file (buffer-file-name))
         (base-name (file-name-base current-file))
         (outfile (expand-file-name (concat base-name ".smd") zine-content-dir))
         ;; Extract metadata before switching buffers
         (title (or (my/get-org-keyword "TITLE") base-name))
         (date  (or (my/get-org-keyword "DATE") (format-time-string "%Y-%m-%dT%H:%M:%S"))))

    ;; Ensure the output directory exists
    (unless (file-directory-p zine-content-dir)
      (make-directory zine-content-dir t))

    (let ((org-export-with-toc nil)
          (org-md-toplevel-hlevel 1))

      ;; Override the link generator
      (cl-letf (((symbol-function 'org-md-link)
                 (lambda (link contents info)
                   (let* ((type (org-element-property :type link))
                          (path (org-element-property :path link))
                          (desc (or contents "")))
                     (if (string= type "id")
                         (let* ((node (org-roam-node-from-id path))
                                (target-slug (if node (file-name-base (org-roam-node-file node)) path)))
                           ;; Zine standard: leading slash resolves to $link.page
                           (format "[%s](/%s)" desc target-slug))
                       ;; Standard external/web links
                       (format "[%s](%s)" desc path))))))

        ;; Generate the Markdown content
        (let ((exported-content (org-export-as 'md)))
          (with-temp-file outfile
            (insert "---\n{\n")
            (insert (format "    .title = \"%s\",\n" title))
            (insert (format "    .date = @date(\"%s\"),\n" date))
            (insert "    .layout = \"post.shtml\",\n")
            (insert "}\n---\n\n")
            (insert exported-content)))))

    (message "Published to Zine: %s" outfile)))
