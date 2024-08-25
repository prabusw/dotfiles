;;; lambda-nord-theme.el --- Lambda-theme nord variant   -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Colin McLear

;; Author: Colin McLear <mclear@unl.edu>
;; Keywords: faces,


;;; Code:

(require 'lambda-themes)

(deftheme lambda-nord "Lambda theme, the nord version")

(lambda-themes-create 'nord 'lambda-nord)

(run-hooks 'lambda-themes-after-load-theme-hook)

(provide-theme 'lambda-nord)

(provide 'lambda-nord-theme)

;; Local Variables:
;; eval: (when (fboundp 'rainbow-mode) (rainbow-mode +1))
;; End:

;;; lambda-nord-theme.el ends here
