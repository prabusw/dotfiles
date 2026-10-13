;;; ox-gemini.el --- Output gemini formatted documents from org-mode  -*- lexical-binding: t; -*-

;; Author: Justin Abrahms <justin@abrah.ms>
;; URL: https://git.sr.ht/~abrahms/ox-gemini
;; Keywords: lisp gemini
;; Package-Requires: ((emacs "28.1") (org "9.7"))
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; There's a web-alternative that's similar to the gopher protocol
;; named 'gemini'.  You can find more about it at
;; https://gemini.circumlunar.space/ This package serves as an
;; org-mode export backend in order to build those types of
;; document-oriented sites.

(require 'ox)
(require 'ox-publish)
(require 'ox-ascii)
(require 'cl-lib)
(require 'url-util)
(require 'subr-x)

;; This is a fork of ox-gemini (20240221.2127, revision 50818de823b7).

;; Changes in this fork:
;; - id: links resolve to the target file (.gmi).  An unresolvable id
;;   follows `org-export-with-broken-links' (stop, ignore or mark; per
;;   file with "#+OPTIONS: broken-links:mark").
;; - file: links to files inside the base directory are made relative
;;   to the exported file; the file: prefix is dropped for non-Org
;;   files, and search options (::) are ignored.
;; - A list item that is only a link becomes a Gemtext link line.
;; - No trailing space after inline code.
;; - Preformatted blocks (source, example, fixed-width and table) get
;;   the caption or name as alt text; source blocks also the language.
;;
;; The following artifacts are due to Gemtext format limitations:
;; - No nested lists, so sublists are flattened.
;; - No anchors, so links to headings, targets, code lines and ids in
;;   the same document are exported as plain text.
;; - Links in titles and footnote definitions are not clickable, so
;;   the target is printed after the text, as "[text] (target)".
;; - No escape for fences, so a line starting with ``` inside a source,
;;   example or fixed-width block ends the preformatted block early.

;;; Code:

(org-export-define-derived-backend 'gemini 'ascii
  :menu-entry
  '(?g "Export to Gemini"
       ((?b "To buffer"
            (lambda (a s v b)
              (org-gemini-export-to-buffer a s v b nil)))
        (?f "To file"
            (lambda (a s v b)
              (org-gemini-export-to-file a s v b nil)))))
  :translate-alist '((code . org-gemini-code-inline)
                     (example-block . org-gemini-pre-formatted-block)
                     (export-block . org-gemini-export-block)
                     (fixed-width . org-gemini-pre-formatted-block)
                     (headline . org-gemini-headline)
                     (item . org-gemini-item)
                     (link . org-gemini-link)
                     (paragraph . org-gemini-paragraph)
                     (quote-block . org-gemini-quote-block)
                     (section . org-gemini-section)
                     (src-block . org-gemini-pre-formatted-block)
                     (table . org-gemini-table)
                     (template . org-gemini-template)))

(defun org-gemini-paragraph (_paragraph contents _info)
  "CONTENTS is the text of the paragraph."
  (concat (string-replace "\n" " " contents) "\n"))

(defun org-gemini-quote-block (_input contents _info)
  "CONTENTS is the text of the quote."
  (replace-regexp-in-string
   "^" "> "
   (replace-regexp-in-string "\n\\'" "" contents)))

(defun org-gemini-code-inline (input _contents _info)
  "Generate an inline code in Gemtext from the parsed INPUT.
INPUT is a `code' object.  A line break in it becomes a space, since
Gemtext reads each line on its own."
  (format "`%s`" (string-replace "\n" " " (org-element-property :value input))))

(defun org-gemini--alt-text (element info)
  "Return the alt text for ELEMENT's preformatted block.
It is the language, if any, followed by the caption or name.
INFO is a plist."
  (let* ((caption (org-export-get-caption element))
         (name (if caption
                   (org-export-data caption info)
                 (org-element-property :name element))))
    (string-join (delq nil (list (org-element-property :language element)
                                 name))
                 " ")))

(defun org-gemini-pre-formatted-block (element _contents info)
  "Transcode ELEMENT to a Gemtext preformatted block.
ELEMENT is a `src-block', `example-block' or `fixed-width'.  The alt
text is the language, if any, followed by the caption or name.  INFO
is a plist."
  (format "```%s\n%s```"
          (org-gemini--alt-text element info)
          (if (org-element-type-p element 'fixed-width)
              (org-element-normalize-string
               (org-remove-indentation (org-element-property :value element)))
            (org-export-format-code-default element info))))

(defun org-gemini-export-block (export-block _contents _info)
  "Transcode a EXPORT-BLOCK element from Org to gemtext.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (when (member (org-element-property :type export-block)
                '("GEMINI" "GMI" "GEMTEXT"))
    (org-remove-indentation (org-element-property :value export-block))))

(defun org-gemini-table (table contents info)
  "Generate a Gemtext table from the parsed Org.
Use the `org-ascii-table' but surrounded by backticks.
Parameters: TABLE is the parsed org-element table.  CONTENTS is the text with
properties.  INFO is a plist with export options."
  (format "```%s\n%s\n```\n"
          (org-gemini--alt-text table info)
          (org-ascii-table table contents info)))

;; Links: Gemtext has no inline links, so each link is exported as its
;; description in brackets, and the targets are listed as `=>' lines
;; after the section.  A list item that is only a link is exported as
;; that `=>' line directly and left out of the section's list.

(defun org-gemini--id-destination (link info)
  "Return the absolute file name an id LINK points to, or nil.
Nil means the id is in the exported document itself (Gemtext has no
anchors) or cannot be resolved.  INFO is a plist."
  (let ((dest (condition-case nil
                  (org-export-resolve-id-link link info)
                (org-link-broken nil)))
        (input (plist-get info :input-file)))
    (and (stringp dest)
         (not (and input (file-equal-p dest input)))
         (expand-file-name dest))))

(defun org-gemini--link-target (link info)
  "Return the Gemtext target of LINK.  INFO is a plist.
File and id links are made relative to the exported file.  Absolute
file names outside the project's base directory are left alone."
  (let* ((type (org-element-property :type link))
         (id-file (and (equal type "id") (org-gemini--id-destination link info)))
         (file (or id-file (and (equal type "file")
                                (org-element-property :path link))))
         (input (plist-get info :input-file))
         (base (plist-get info :base-directory)))
    (if (not file)
        (org-element-property :raw-link link)
      (when (and input (file-name-absolute-p file)
                 (or id-file (and base (file-in-directory-p file base))))
        (setq file (file-relative-name (file-truename file)
                                       (file-name-directory (file-truename input)))))
      (if (string-suffix-p ".org" file t)
          (concat (file-name-sans-extension file) ".gmi")
        file))))

(defun org-gemini--linkable-p (link info)
  "Non-nil if LINK has a target that can be listed.  INFO is a plist."
  (let ((type (org-element-property :type link)))
    (not (or ;; Gemtext has no anchors: see "Limitations" above.
             (member type '("fuzzy" "custom-id" "radio" "coderef"))
             (and (equal type "id")
                  (not (org-gemini--id-destination link info)))))))

(defun org-gemini--sole-link (item info)
  "Return the link in ITEM if its text consists of nothing but that link.
A sublist under the item does not count.  Items with a checkbox or a
tag are left alone, so that the marker is not lost.  INFO is a plist."
  (when (and (org-element-type-p item 'item)
             (not (org-element-property :checkbox item))
             (not (org-element-property :tag item)))
    (pcase (org-element-contents item)
      ((or `(,para) `(,para ,(pred (lambda (e) (org-element-type-p e 'plain-list)))))
       (when (org-element-type-p para 'paragraph)
         (let ((parts (seq-remove (lambda (e) (and (stringp e) (string-blank-p e)))
                                  (org-element-contents para))))
           (when (and (null (cdr parts))
                      (org-element-type-p (car parts) 'link)
                      (org-gemini--linkable-p (car parts) info))
             (car parts))))))))

(defun org-gemini--unique-links (element info)
  "Return the unique links of ELEMENT that belong in its link list.
ELEMENT is a headline or a section.  This hands off to
`org-ascii--unique-links', then leaves out links already exported as
a link line (see `org-gemini-item') and links without a usable
target.  INFO is a plist."
  (seq-remove
   (lambda (link)
     (let ((item (org-element-parent (org-element-parent link))))
       (or (and item (eq (org-gemini--sole-link item info) link))
           (not (org-gemini--linkable-p link info)))))
   (org-ascii--unique-links element info)))

(defun org-gemini--describe-links (links info)
  "Describe LINKS as Gemtext link lines, followed by a blank line.
They go at the end of the text of the section or headline holding the
links, and a link-only list item uses one directly.  LINKS is a list
of links.  INFO is a plist."
  (concat
   (mapconcat
    (lambda (link)
      (format "=> %s\^I%s\n"
              (url-encode-url (org-gemini--link-target link info))
              (string-replace
               "\n" " "
               (org-export-data
                (or (org-element-contents link) (org-element-property :raw-link link))
                info))))
    links "")
   (when (car links)
     "\n")))

(defun org-gemini-link (link desc info)
  "Transcode a LINK object from Org to Gemtext.
DESC is its description, if any.  INFO is a plist.

A link with a target is exported as its text in brackets; its `=>'
line is added after the section (see `org-gemini--describe-links').
Without a target (see `org-gemini--linkable-p') it is exported as
plain text.  An id that cannot be resolved is handled as
`org-export-with-broken-links' says."
  ;; Resolve only to signal `org-link-broken' for an unknown id.
  (when (equal (org-element-property :type link) "id")
    (org-export-resolve-id-link link info))
  (let ((text (if (org-string-nw-p desc) desc (org-element-property :raw-link link))))
    (cond
     ((not (org-gemini--linkable-p link info)) text)
     ((plist-get info :ascii-links-to-notes) (format "[%s]" text))
     ;; No link line will follow (footnote definitions, document title),
     ;; where `ox-ascii' turns `:ascii-links-to-notes' off: keep the target.
     (t (let ((target (org-gemini--link-target link info)))
          (if (equal text target)
              (format "[%s]" text)
            (format "[%s] (%s)" text (url-encode-url target))))))))

(defun org-gemini-item (item contents info)
  "Generate a Gemtext item from the org CONTENTS.
CONTENTS is the text of the individual item.
ITEM is the parsed-org element with all properties.
An item that is nothing but a link becomes a Gemtext link line,
followed by its sublist, if any."
  (if-let* ((link (org-gemini--sole-link item info)))
      (concat (string-trim-right (org-gemini--describe-links (list link) info))
              ;; the sublist, if any, follows the link line
              (when-let* ((sublist (nth 1 (org-element-contents item))))
                (concat "\n" (string-trim-right (org-export-data sublist info)))))
    (concat "* "
            ;; vv Code from ox-md! vv
            (pcase (org-element-property :checkbox item)
              (`on "[X] ")
              (`trans "[-] ")
              (`off "[ ] "))
            (let ((tag (org-element-property :tag item)))
              (and tag (format "%s :: " (org-export-data tag info))))
            ;; ^^ ^^
            contents)))

(defun org-gemini-section (section contents info)
  "Transcode a SECTION element from Org to GEMINI.
CONTENTS is the contents of the section.  INFO is a plist holding
contextual information."
  ;; CONTENTS is nil when the section has no text but it has properties set.
  (let ((contents-str (or contents "")) ;; ensure that contents is a string.
        (links
         (and (plist-get info :ascii-links-to-notes)
              ;; Take care of links in first section of the document.
              (not (org-element-lineage section '(headline)))
              (org-gemini--describe-links
               (org-gemini--unique-links section info)
               info))))
    (org-remove-indentation
      (if (not (org-string-nw-p links)) contents-str
        (concat (org-element-normalize-string contents-str) "\n\n" links))
      ;; Remove indentation: N is the inner margin, or 0 when the parent
      ;; headline is low level or there is none.
      (let ((headline (org-export-get-parent-headline section)))
        (if (or (not headline) (org-export-low-level-p headline info)) 0
          (plist-get info :ascii-inner-margin))))))

(defun org-gemini--build-title (element info)
  "Build a Gemtext heading line for ELEMENT.  INFO is a plist."
  (format "%s %s"
          (make-string (org-element-property :level element) ?#)
          (org-trim (org-export-data (org-element-property :title element) info))))

(defun org-gemini-headline (headline contents info)
  "Transcode a HEADLINE element from Org to GEMINI.
CONTENTS holds the contents of the headline.  INFO is a plist
holding contextual information."
  ;; Don't export footnote section: `org-ascii-inner-template'
  ;; appends the footnote definitions.
  (unless (org-element-property :footnote-section-p headline)
    (let* ((low-level (org-export-low-level-p headline info))
           ;; Export title early so that any link in it can be
           ;; exported and seen in `org-gemini--unique-links'.
           (title (org-gemini--build-title headline info))
           ;; Blank lines between headline and its contents.
           ;; `org-ascii-headline-spacing', when set, overwrites
           ;; original buffer's spacing.
           (pre-blanks
            (make-string (or (car (plist-get info :ascii-headline-spacing))
                             (org-element-property :pre-blank headline)
                             0)
                         ?\n))
           (links (and (plist-get info :ascii-links-to-notes)
                       (org-gemini--describe-links
                        (org-gemini--unique-links headline info) info)))
           ;; Re-build contents, inserting section links at the right
           ;; place.  The cost is low since build results are cached.
           (body
            (if (not (org-string-nw-p links)) contents
              (let* ((contents (org-element-contents headline))
                     (section (let ((first (car contents)))
                                (and (org-element-type-p first 'section)
                                     first))))
                (concat (and section
                             (concat (org-element-normalize-string
                                      (org-export-data section info))
                                     "\n\n"))
                        links
                        (mapconcat (lambda (e) (org-export-data e info))
                                   (if section (cdr contents) contents)
                                   ""))))))
      ;; Deep subtree: export it as a list item.
      (if low-level
          (let* ((bullets (cdr (assq (plist-get info :ascii-charset)
                                     (plist-get info :ascii-bullets))))
                 (bullet
                  (format "%c "
                          (nth (mod (1- low-level) (length bullets)) bullets))))
            (concat bullet title "\n" pre-blanks
                    ;; In Gemtext, text should not be indented. Otherwise,
                    ;; source code blocks, links, and other line types would not
                    ;; be interpreted by clients because of the initial spacing.
                    body))
        ;; Else: Standard headline.
        (concat title "\n" pre-blanks body)))))

(defun org-gemini-template (contents info)
  "Return complete document string after GEMINI conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (let ((title (org-export-data (when (plist-get info :with-title)
                                  (plist-get info :title))
                                ;; No link footer can follow the title.
                                (org-combine-plists
                                 info '(:ascii-links-to-notes nil)))))
    (concat
     (unless (string= title "")
       (format "# %s\n\n" title))
     contents)))

(defun org-gemini-export-to-buffer (&optional async subtreep visible-only body-only ext-plist)
  "Export an org file to a new buffer.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

When optional argument BODY-ONLY is non-nil, strip title and
table of contents from output.

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings."
  (interactive)
  (org-export-to-buffer 'gemini "*Org Gemini Export*" async subtreep visible-only body-only ext-plist (lambda () (text-mode))))

(defun org-gemini-export-to-file (&optional async subtreep visible-only body-only ext-plist)
  "Export an org file to a gemini file.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

When optional argument BODY-ONLY is non-nil, strip title and
table of contents from output.

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings."
  (interactive)
  (let ((file (org-export-output-file-name ".gmi" subtreep)))
    (org-export-to-file 'gemini file
      async subtreep visible-only body-only ext-plist)))

(defun org-gemini-publish-to-gemini (plist filename pub-dir)
  "Publish an org file to a gemini file.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (org-publish-org-to
   'gemini filename ".gmi" plist pub-dir))

(provide 'ox-gemini)
;;; ox-gemini.el ends here
