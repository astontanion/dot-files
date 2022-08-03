;; general config
(global-linum-mode 1)
(global-visual-line-mode 1)
(global-auto-revert-mode t)
(setq inhibit-startup-message t)

(global-hl-line-mode +1)
(delete-selection-mode 1)
;; START TABS CONFIG
;; Create a variable for our preferred tab width
(setq custom-tab-width 4)

;; Two callable functions for enabling/disabling tabs in Emacs
(defun disable-tabs () (setq indent-tabs-mode nil))
(defun enable-tabs  ()
  (local-set-key (kbd "TAB") 'tab-to-tab-stop)
  (setq indent-tabs-mode t)
  (setq tab-width custom-tab-width)
  (setq c-basic-offset custom-tab-width))

;; Hooks to Enable Tabs
(add-hook 'prog-mode-hook 'enable-tabs)
(add-hook 'typescript-mode 'enable-tabs)
;; Hooks to Disable Tabs
;;(add-hook 'lisp-mode-hook 'disable-tabs)
;;(add-hook 'emacs-lisp-mode-hook 'disable-tabs)

;; Language-Specific Tweaks
(setq-default python-indent-offset custom-tab-width) ;; Python
(setq-default js-indent-level custom-tab-width)      ;; Javascript

;; Making electric-indent behave sanely
(setq-default electric-indent-inhibit nil)

;; Make the backspace properly erase the tab instead of
;; removing 1 space at a time.
(setq backward-delete-char-untabify-method nil)

(setq debug-on-error t)

(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
      backup-by-copying t    ; Don't delink hardlinks
      version-control t      ; Use version numbers on backups
      delete-old-versions t  ; Automatically delete excess backups
      kept-new-versions 20   ; how many of the newest versions to keep
      kept-old-versions 5    ; and how many of the old
      )

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))



(require 'use-package)

(setq use-package-always-ensure t)

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;;(use-package nord-theme
;;    :config
;;    (setq nord-uniform-mode-lines t)
;;    (load-theme 'nord t))

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t)                
  (setq doom-themes-enable-italic t)
  (setq doom-themes-treemacs-theme "doom-colors")
  (load-theme 'doom-one t)
  (doom-themes-neotree-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config)
  )

(use-package dashboard
  :ensure t
  :init 
  (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))
  ;; Set the title
  (setq dashboard-banner-logo-title "Welcome to Emacs Dashboard")
  ;; Set the banner
  (setq dashboard-startup-banner `logo)
  ;; Value can be
  ;; 'official which displays the official emacs logo
  ;; 'logo which displays an alternative emacs logo
  ;; 1, 2 or 3 which displays one of the text banners
  ;; "path/to/your/image.png" which displays whatever image you would prefer

  ;; Content is not centered by default. To center, set
  (setq dashboard-center-content t)

  ;; To disable shortcut "jump" indicators for each section, set
  (setq dashboard-show-shortcuts nil)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-set-navigator t)
  :config
  (dashboard-setup-startup-hook)
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))
  )

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-buffer-file-name-style 'truncate-with-project)
  (setq doom-modeline-buffer-encoding nil)
  )

(use-package all-the-icons)

(use-package adaptive-wrap
  :ensure t
  :config
  (setq adaptive-wrap-extra-indent custom-tab-width)
  (add-hook 'visual-line-mode-hook #'adaptive-wrap-prefix-mode))

(use-package perspective
  :ensure t
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :config
  (persp-mode)
  (setq persp-state-default-file "~/.emacs.d/perspective/persp-state")
  )

(add-hook 'kill-emacs-hook #'persp-state-save)

(use-package projectile
  :config
  (projectile-mode 1)
  )

(defvar custom--projectile-target-project nil
  "Hold the target projectile name.")

(defun custom/projectile-switch-project-by-name (projectile-switch-project-by-name &rest args)
  (setq custom--projectile-target-project (->> (split-string (car args) "/")
                                               (-drop-last 1)
                                               (-last-item)))
  (apply projectile-switch-project-by-name args))

(advice-add #'projectile-switch-project-by-name :around #'custom/projectile-switch-project-by-name)

(defun custom/new-persp-for-project-switch ()
  (persp-switch custom--projectile-target-project))

(add-hook 'projectile-before-switch-project-hook #'custom/new-persp-for-project-switch)

;;(use-package treemacs
;;  :ensure t
;;  :defer t)

;;(use-package treemacs-projectile
;;  :after (treemacs projectile)
;;  :ensure t)

(use-package treemacs-perspective ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs perspective) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives)
  )

(use-package eyebrowse
  :config
  (eyebrowse-mode t)
  )

(use-package evil
  :demand t
  :init 
  (setq evil-respect-visual-line-mode t)
  :config
  (evil-mode 1)
  (setq evil-auto-indent nil)
  (setq evil-auto-indent nil)
  (setq evil-shift-width custom-tab-width)
  )

(define-key evil-motion-state-map (kbd "<tab>") nil)
(define-key evil-motion-state-map (kbd "TAB") nil)

(use-package which-key
  :init
  (setq which-key-show-early-on-C-h t)
  (setq which-key-idle-delay 1)
  (setq which-key-idle-secondary-delay 1)
  :config (which-key-mode 1))

(defun custom/org-mode-setup()
  (org-indent-mode))

(defun my-org-agenda-skip-all-siblings-but-first ()
  "Skip all but the first non-done entry."
  (let (should-skip-entry) (unless (org-current-is-todo) (setq should-skip-entry t))
       (save-excursion
         (while (and (not should-skip-entry) (org-goto-sibling t))
           (when (org-current-is-todo) (setq should-skip-entry t))))
       (when should-skip-entry (or (outline-next-heading) (goto-char (point-max))))))

(defun org-current-is-todo ()
  (string= "TODO" (org-get-todo-state)))

(use-package org
  :hook (org-mode . custom/org-mode-setup)
  :config
  (org-indent-mode 1)
  (setq org-log-done 'time)
  (setq org-enforce-todo-dependencies t)
  (setq org-enforce-todo-checkbox-dependencies t)
  (setq org-refile-use-outline-path 'file)
  (setq org-outline-path-complete-in-steps nil)
  (setq org-agenda-window-setup 'current-window)
  (setq org-agenda-files '("~/doc/org/inbox.org" "~/doc/org/main.org" "~/doc/org/tickler.org"))

  (setq org-refile-targets
        '(("~/doc/org/main.org" :maxlevel . 3)
          ("~/doc/org/someday.org" :level . 1)
          ("~/doc/org/tickler.org" :maxlevel . 2)))

  (setq org-log-into-drawer t)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)" "CANCELED(x@/!)")
          (sequence "BUCKET(b)" "IN PROGRESS(p)" "TESTING(f)" "WAITING(w@/!)" "|" "COMPLETED(c)")))

  (setq org-tag-alist '((:startgroup . nil)
                        ("@home" . ?h) ("@office" . ?o)
                        ("@errands" . ?e) ("@travelling" . ?t)
                        ("@phone" . ?p) ("@email" . ?m)
                        (:endgroup . nil)
                        ("emacs" . ?x) ("writing" . ?w) ("reading" . ?r) ("studing" . ?l) ("chore" . ?c)))

  (setq org-agenda-custom-commands 
        '(("o" "At the office" tags-todo "@office"
           ((org-agenda-overriding-header "Office")
            (org-agenda-skip-function #'my-org-agenda-skip-all-siblings-but-first)))))

  (setq org-ellipsis " ▼" org-hide-emphasis-markers t)
  ;; set up org capture
  (setq org-default-notes-file "~/doc/org/inbox.org")
  ;; capture templates
  (setq org-capture-templates
        '(("t" "Task" entry (file+headline "~/doc/org/inbox.org" "Tasks") "* TODO %i%?")
          ("j" "Journal" entry (file+datetree "~/doc/org/journal.org") "* %?\nEntered on %U\n %i\n %a")
          ("d" "Thoughts" entry (file+headline "~/doc/org/inbox.org" "Thoughts") "* %?\n%U")
          ("T" "Tickler" entry (file+headline "~/doc/org/tickler.org" "Tickler") "* %i%?\n %U"))))

(use-package org-bullets
  :config 
  (org-indent-mode 1)
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(defun org-summary-todo()
  "Switch entry to DONE when all subentries are done, to TODO otherwise."
  (let (org-log-done org-log-states)   ; turn off logging
    (org-todo (if (= n-not-done 0) "DONE" "TODO"))))

;;(add-hook 'org-after-todo-statistics-hook #'org-summary-todo)

(use-package counsel)

(use-package ivy
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "%d/%d "))

(global-set-key (kbd "C-s") 'swiper-isearch)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "M-y") 'counsel-yank-pop)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "<f2> j") 'counsel-set-variable)
(global-set-key (kbd "C-c v") 'ivy-push-view)
(global-set-key (kbd "C-c V") 'ivy-pop-view)

(use-package flycheck)
(use-package yasnippet :config (yas-global-mode))

(use-package lsp-mode 
  :hook (
         (lsp-mode . lsp-enable-which-key-integration)
         (web-mode . lsp-deferred))
  :config
  (setq lsp-completion-enable-additional-text-edit nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-log-io nil)
  (setq lsp-restart 'auto-restart))

(use-package hydra)
(use-package company)
(use-package lsp-ui
  :config (setq lsp-ui-doc-show-with-cursor t))
(use-package which-key :config (which-key-mode))

(use-package dap-mode 
  :after lsp-mode 
  :config (dap-auto-configure-mode))

(use-package lsp-treemacs
  :config 
  (lsp-treemacs-sync-mode 1)
  (setq treemacs-width 28)
  (setq treemacs-wrap-around nil)
  )

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode)
  )

(use-package lsp-java
  :config
  (add-hook 'java-mode-hook 'lsp)
  (setq lsp-enable-on-type-formatting nil))
(use-package dap-java :ensure nil)

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level custom-tab-width))

(use-package web-mode
  :ensure t
  :mode (("\\.js\\'" . web-mode)
         ("\\.jsx\\'" . web-mode)
         ("\\.ts\\'" . web-mode)
         ("\\.tsx\\'" . web-mode)
         ("\\.html\\'" . web-mode)
         ("\\.vue\\'" . web-mode)
         ("\\.json\\'" . web-mode))
  :commands web-mode
  :config
  (setq company-tooltip-align-annotations t)
  (setq web-mode-markup-indent-offset custom-tab-width)
  (setq web-mode-css-indent-offset custom-tab-width)
  (setq web-mode-code-indent-offset custom-tab-width)
  (setq web-mode-enable-part-face t)
  (setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'"))))

(use-package yaml-mode)

(use-package json-mode)

(define-key evil-motion-state-map (kbd "'") nil)

(defconst custom-leader-key "'")

(use-package general
  :config
  (general-create-definer custom-leader-def
    :states '(normal motion emacs)
    :prefix custom-leader-key
    :keymaps 'override)
  (general-define-key
   :states '(insert)
   :keymaps 'org-mode-map
   "<tab>" 'tab-to-tab-stop)
  )

(custom-leader-def
  "b" '(:ignore t :which-key "Buffer")
  "bs" '(persp-ivy-switch-buffer :which-key "Switch buffer")
  "bk" '(persp-remove-buffer :which-key "Kill buffer")
  "bc" '(kill-buffer :which-key "Kill buffer")
  )

(custom-leader-def
  "." '(counsel-find-file :which-key "Open file")
  "f" '(:ignore t :which-key "File")
  "fd" '(dired :which-key "Current director")
  )

(custom-leader-def
  "h" '(:ignore t :which-key "Help")
  "w" '(:ignore t :which-key "Window")
  "wv" '(split-window-right :which-key "Split vertically")
  "ws" '(split-window-below :which-key "Split horizontally")
  "wc" '(delete-window :which-key "Close window")
  "wb" '(balance-windows :which-key "Balance")
  "wk" '(windmove-up :which-key "Switch up")
  "wj" '(windmove-down :which-key "Switch down")
  "wl" '(windmove-right :which-key "Switch right")
  "wh" '(windmove-left :which-key "Switch left")
  "wK" '(evil-window-move-very-up :which-key "Move up")
  "wJ" '(evil-window-move-very-down :which-key "Move down")
  "wL" '(evil-window-move-far-right :which-key "Move right")
  "wH" '(evil-window-move-far-left :which-key "Move left")
  "wn" '(evil-window-new :which-key "New")
  "wg" '(treemacs-visit-node-ace :which-key "Go to window")
  "wos" '(treemacs-visit-node-ace-vertical-split :which-key "Go to window")
  "wov" '(treemacs-visit-node-ace-horizontal-split :which-key "Go to window")
  )

(custom-leader-def
  "p" '(:ignore t :which-key "Project")
  "pa" '(projectile-add-known-project :which-key "Add project")
  "pf" '(projectile-find-file :which-key "Find file")
  "ps" '(projectile-switch-project :which-key "Switch project")
  )

(custom-leader-def
  "d" '(:ignore t :which-key "Desktop")
  "dc" '(persp-switch :which-key "Create a desktop")
  "dm" '(persp-switch-by-number :which-key "Switch desktop")
  "dn" '(persp-next :which-key "Next desktop")
  "dp" '(persp-prev :which-key "Previous desktop")
  "dr" '(persp-rename :which-key "Rename desktop")
  "ds" '(persp-state-save :which-key "Save desktop")
  "dl" '(persp-state-load :which-key "Load desktop")
  )

(custom-leader-def
  "c" '(:ignore t :which-key "Code")
  "cd" '(lsp-find-declaration :which-key "Find declaration")
  "cg" '(lsp-find-definition :which-key "Find definition")
  "cr" '(lsp-find-references :which-key "Find references")
  "ci" '(lsp-find-implementation :which-key "Find implementation")
  "co" '(lsp-organize-imports :which-key "Organize imports")
  "clr" '(lsp-treemacs-errors-list :which-key "List error")
  )

(custom-leader-def
  "o" '(:ignore t :which-key "Org mode")
  "oa" '(org-agenda :which-key "Show agenda")
  "os" '(org-schedule :which-key "Schedule task")

  "ot" '(:ignore t :which-key "Org todo")
  "ots" '(org-todo :which-key "Show todo state")
  "ott" '(org-show-todo-tree :which-key "Show todo tree")
  "oth" '(org-insert-todo-heading :which-key "Insert todo heading")
  "otc" '(org-toggle-checkbox :which-key "Toggle checkbox")

  "o#a" '(org-set-tags-command :which-key "Add a tag")

  "occ" '(org-capture :which-key "Capture templates")
  "ocf" '(org-capture-finalize :which-key "Finish capturing")
  "oca" '(org-capture-kill :which-key "Abort capturing")

  "or" '(org-refile :which-key "Refile")
  )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(yasnippet yaml-mode which-key web-mode use-package treemacs-projectile treemacs-perspective treemacs-persp tide rainbow-delimiters page-break-lines org-bullets nord-theme lsp-ui lsp-java json-mode general eyebrowse evil doom-themes doom-modeline desktop+ dashboard counsel company all-the-icons adaptive-wrap 0x0 0blayout)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
