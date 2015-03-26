;;(setq lexical-binding t)
;; Hypatia -- emacs init.el
;; 03/26/2015 09:20:01 AM

;=======================================================
;; # Package Archives #
;=======================================================


(require 'package)

 (add-to-list 'package-archives
 	     '("gnu" . "http://elpa.gnu.org/packages/"))
;;(add-to-list 'package-archives
;; 	     '("marmalade" . "http://marmalade-repo.org/packages/"))
;; (add-to-list 'package-archives
;; 	     '("melpa-stable" . "http://melpa-stable.milkbox.net/packages/"))
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives
 	     '("org" . "http://orgmode.org/elpa/"))
(package-initialize)


;=======================================================
;; # Load Paths #
;=======================================================

(add-to-list 'load-path "~/.emacs.d/elpa/")

;=======================================================
;; # Functions #
;=======================================================

(defun find-user-init-file ()
  (interactive)
  (find-file user-init-file))
(global-set-key (kbd "<f6>") 'find-user-init-file)

(defun rename-file-and-buffer ()
  "Rename the current buffer and file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer is not visiting a file!")
      (let ((new-name (read-file-name "New name: " filename)))
       (cond
         ((vc-backend filename) (vc-rename-file filename new-name))
         (t
          (rename-file filename new-name t)
          (set-visited-file-name new-name t t)))))))

(defun delete-file-and-buffer ()
  "Kill the current buffer and deletes the file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (when filename
      (if (vc-backend filename)
          (vc-delete-file filename)
        (progn
          (delete-file filename)
          (message "Deleted file %s" filename)
          (kill-buffer))))))


(defun mp-insert-date ()
  (interactive)
  (insert (format-time-string "%x")))
(defun mp-insert-time ()
  (interactive)
  (insert (format-time-string "%X")))
(global-set-key (kbd "C-c i d") 'mp-insert-date)
(global-set-key (kbd "C-c i t") 'mp-insert-time)

;; install package if missing (for config move)
(defun require-package (package)
  (setq-default highlight-tabs t)
  "Install given PACKAGE."
  (unless (package-installed-p package)
    (unless (assoc package package-archive-contents)
      (package-refresh-contents))
    (package-install package)))

;=======================================================
;; # Tweaks #
;=======================================================

; back-up options -- will replace/augment with git vc
(setq backup-directory-alist `(("." . "~/.saves")))


(setq make-backup-files t  
      backup-by-copying t               ; don't clobber symlinks
      version-control t                 ; version numbers for backup files
      delete-old-versions t             ; delete excess backup files silently
      delete-by-moving-to-trash t
      kept-old-versions 6  
      kept-new-versions 9  
      auto-save-default t               ; auto-save every buffer that visits a file
      auto-save-timeout 60 
      auto-save-interval 500            
      )
(setq vc-make-backup-files t)
(defun force-backup-of-buffer ()
  ;; Make a special "per session" backup at the first save of each
  ;; emacs session.
  (when (not buffer-backed-up)
    ;; Override the default parameters for per-session backups.
    (let ((backup-directory-alist '(("" . "~/.saves/per-session")))
          (kept-new-versions 3))
      (backup-buffer)))
  ;; Make a "per save" backup on each save.  The first save results in
  ;; both a per-session and a per-save backup, to keep the numbering
  ;; of per-save backups consistent.
  (let ((buffer-backed-up nil))
    (backup-buffer)))

(add-hook 'before-save-hook  'force-backup-of-buffer)

; syntax in org source blocks
(setq org-src-fontify-natively t)

; start-up messages: Init to scratch buffer
(setq initial-scratch-message nil)
(setq inhibit-startup-message t)

(setq package-enable-at-startup nil)

(setq inferior-lisp-program (executable-find "sbcl"))

; drag/drop file to new buffer
(global-set-key [ns-drag-file] 'ns-find-file)

(require 'js-comint)
(setq inferior-js-program-command "/usr/bin/rhino")
(add-hook 'js2-mode-hook '(lambda () 
			    (local-set-key "\C-x\C-e" 'js-send-last-sexp)
			    (local-set-key "\C-\M-x" 'js-send-last-sexp-and-go)
			    (local-set-key "\C-cb" 'js-send-buffer)
			    (local-set-key "\C-c\C-b" 'js-send-buffer-and-go)
			    (local-set-key "\C-cl" 'js-load-file-and-go)
			    ))

;; flx-ido
(require 'flx-ido)
(require 'ido-ubiquitous)
(ido-mode 1)
(ido-ubiquitous-mode 1)
(flx-ido-mode 1)
; disable ido faces to see flx
(setq ido-enable-flex-matching t)
;(setq ido-use-faces nil)

;; smex
(require 'smex)
(smex-initialize)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
; old M-x
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;; Mouse Scrolling Fix
(setq mouse-wheel-scroll-amount '(0.05))
(setq mouse-wheel-progressive-speed nil)


(fringe-mode 4)
(setq pandoc-binary "/usr/local/bin/pandoc")

(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)

(electric-pair-mode)
(add-hook 'LaTeX-mode-hook
	  '(lambda ()
	     (define-key LaTeX-mode-map (kbd "$") 'self-insert-command)))

;; <F9> runs processing sketches without nagging prompt
(add-hook 'processing-mode-hook
	  '(lambda ()
	     (define-key processing-mode-map (kbd "<f9>") (lambda () (interactive)
					(save-buffer)
					(processing-sketch-run)))))
;(global-set-key (kbd "C-c a b c") (lambda () (interactive) (some-command) (some-other-command)))
;replace with local key-mapdef, hook unnecessary?


;(setq debug-on-error t)
;=======================================================
;; # EVIL Configurations and Keybindings #
;=======================================================


(require 'key-chord)
(require 'evil)

;(key-chord-define evil-insert-state-map "jk" 'evil-normal-state)

; some emacs keybindings recontextualized for consistency
(define-key evil-normal-state-map "\C-e" 'evil-end-of-line)
;needs more definitions, below needs changed
;(define-key evil-normal-state-map "\C-p" 'evil-scroll-line-up)
;(define-key evil-normal-state-map "\C-n" 'evil-scroll-line-down)
(define-key evil-insert-state-map "\C-d" 'paredit-forward-delete)


;; refine cursor behavior when editing code with paredit
(setq evil-move-cursor-back nil)
(setq evil-highlight-closing-paren-at-point-states nil) 
;; not sure what this is for:
;(define-key evil-insert-state-map "\C-i" "-")

; choose 'y' or 'n' for yes/no prompts
(fset 'yes-or-no-p 'y-or-n-p)

; movement keys work like they should
(define-key evil-normal-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
; horizontal movement cross lines                                    
(setq-default evil-cross-lines t)




;; nerd-commenter config
 (global-set-key (kbd "M-;") 'evilnc-comment-or-uncomment-lines)


;; leader config
(require 'evil-leader) 
(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
  "f" 'find-file
  "b" 'switch-to-buffer
  "k" 'kill-buffer
  "j" 'other-window
  "0" 'delete-window
  "K" 'kill-buffer-and-window
  "s" 'save-buffer
  "D" 'dired
  "d" 'deft 
  "n" 'org-narrow-to-subtree
  "w" 'widen
  "2" 'split-window-below
  "3" 'split-window-right
  "1" 'delete-other-windows
  "x" 'eval-buffer
  "u" 'browse-url-of-file
  "y" 'yas-new-snippet
  "]" 'enlarge-window-horizontally
  "[" 'shrink-window-horizontally
  "<SPC>" 'ace-jump-mode
  "ci" 'evilnc-comment-or-uncomment-lines
  "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
  ;;"ll" 'evilnc-quick-comment-or-uncomment-to-the-line
  "cc" 'evilnc-copy-and-comment-lines
  "cp" 'evilnc-comment-or-uncomment-paragraphs
  "cr" 'comment-or-uncomment-region
  "cv" 'evilnc-toggle-invert-comment-line-by-line
  "\\" 'evilnc-comment-operator
  "<escape>" 'shell-command)

(evil-leader/set-key-for-mode 'emacs-lisp-mode "x" 'eval-buffer)
  


;=======================================================
;; # ORG-MODE #
;=======================================================



(add-to-list 'load-path (expand-file-name "~/.emacs.d/org-20141215"))
(add-to-list 'auto-mode-alist '("\\.\\(org\\  |org_archive\\|txt\\)$" . org-mode))

(setq org-agenda-files (list "~/Notes/org/academic.org"
                             "~/Notes/org/school.org"
			     "~/Notes/org/projects.org"
			     "~/Notes/org/desk.org"
			     "~/Notes/org/journal.org"))



(setq org-log-done 'time)

;; ;; org-capture templates
;;  (setq org-capture-templates
;;       '(("t" "Todo" entry (file+headline "~/org/gtd.org" "Tasks")
;;              "* TODO %?\n  %i\n  %a")
;;         ("j" "Journal" entry (file+datetree "~/Notes/org/journal.org")
;; 	 "* %?\nEntered on %U\n  %i\n  %a")))

;;(setq-default org-journal-dir "~/Notes/journal/")


(require 'org-install)
(require 'org-habit)
(require 'evil-org)
(require 'org-journal)
(plist-put org-format-latex-options :scale 2.0)
(evil-leader/set-key-for-mode 'org-mode
  "t"  'org-show-todo-tree
  "a"  'org-agenda
  "c"  'org-archive-subtree
  "l"  'org-preview-latex-fragment;;evil-org-open-links
  "j"  'other-window
  "'"  'evil-org-recompute-clocks
  "i"  'org-clock-in
  "o"  'org-clock-out
  "g"  'org-mark-ring-goto
  "p"  'org-mark-ring-push
  )


(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
;definekey vs global set?
(define-key global-map (kbd "<f5>") 'org-agenda)



;=======================================================
;; # Other Plugins and Packages #
;=======================================================

;(require 'sr-speedbar)

(require 'geiser)
; Deft
(require 'deft)
 (setq
       deft-extension "org"
       deft-directory "~/Notes/org"
       deft-text-mode 'org-mode
       )
 (setq deft-use-filename-as-title t)
 (add-hook 'deft-mode-hook (lambda () (setq truncate-lines t)))


;;(setq default-directory (getenv "Notes"))
(setq org-startup-indented t)


(require 'evil-paredit)
(add-hook 'enable-paredit-mode 'evil-paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode )

(add-hook 'scheme-mode-hook  'paredit-mode)
(add-hook 'scheme-mode-hook  'rainbow-delimiters-mode)
(add-hook 'paredit-mode-hook 'rainbow-delimiters-mode)

;; Processing
(setq processing-location "~/Downloads/processing/processing-java")
(setq processing-application-dir "~/Downloads/processing")
(setq processing-sketchbook-dir "~/sketchbook")



;; yas-snippet
(require 'yasnippet)
(yas-global-mode 1)

(setq yas-snippet-dirs
      '("~/.emacs.d/snippets"                         ;; personal snippets
        "~/.emacs.d/yasnippet-0.8.0/snippets"         ;; the default collection
        ))
(setq yas-prompt-functions '(yas-completing-prompt))  ;; *or* yas-ido-prompt
                                      ;; *or* yas-dropdown-prompt w/ dropdownmenu.el
;;Processing2-Mode
(add-hook 'processing-mode-hook 'processing-mode-init)
(setq processing-keymap-prefix (kbd "s-p"))


;;for restoring session:
;; (desktop-save-mode 1)


;; Make ido work in snippet selection
(setq-default yas-prompt-functions '(yas-ido-prompt yas-dropdown-prompt))


					;(define-key python-mode-map (kbd "<f12>") 'python-switch-to-python)
;=======================================================
;; # Init Modes #
;=======================================================

(global-evil-leader-mode)
(key-chord-mode 1)
(global-visual-line-mode)
(evil-mode 1)
(rainbow-delimiters-mode)
(tool-bar-mode -1)
(show-paren-mode 1)
(global-linum-mode)

;; fix colors in term emacs
(color-theme-approximate-on)

;; ;;;
;; ;=======================================================
;; ;; # El-Get #
;; ;=======================================================
;; (add-to-list 'load-path "~/.emacs.d/el-get/el-get")
;; (unless (require 'el-get nil 'noerror)
;;   (with-current-buffer
;;       (url-retrieve-synchronously
;;        "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
;;     (goto-char (point-max))
;;     (eval-print-last-sexp)))
;; (add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")
;; (el-get 'sync)



(show-paren-mode t)
(setq show-paren-style 'expression)



(setq org-todo-keyword-faces
          '(("NEW"  . leuven-org-created-kwd)
            ("TODO" . org-todo)
            ("STRT" . leuven-org-inprogress-kwd)
            ("WAIT" . leuven-org-waiting-for-kwd)
            ("SDAY" . leuven-org-someday-kwd)
            ("DONE" . org-done)
            ("LSRE" . leuven-org-someday-kwd)
	    ("APPRAISE" . leuven-org-appraise-kwd)))
;; CANX . org-done

    ;; ;; Org standard faces
    ;; (set-face-attribute 'org-todo nil
    ;;                     :weight 'bold :box '(:line-width 1 :color "#D8ABA7")
    ;;                     :foreground "#D8ABA7" :background "#FFE6E4")
    ;; (set-face-attribute 'org-done nil
    ;;                     :weight 'bold :box '(:line-width 1 :color "#BBBBBB")
    ;;                     :foreground "#BBBBBB" :background "#F0F0F0")

    ;; Org non-standard faces
    (defface leuven-org-created-kwd
      '((t (:weight normal :box (:line-width 1 :color "#EEE9C3")
            :foreground "#1A1A1A" :background "#FDFCD8")))
      "Face used to display state NEW.")
    (defface leuven-org-inprogress-kwd
      '((t (:weight bold :box (:line-width 1 :color "#D9D14A")
            :foreground "#D9D14A" :background "#FCFCDC")))
      "Face used to display state STRT.")
    (defface leuven-org-waiting-for-kwd
      '((t (:weight bold :box (:line-width 1 :color "#89C58F")
            :foreground "#89C58F" :background "#E2FEDE")))
      "Face used to display state WAIT.")
    (defface leuven-org-someday-kwd
      '((t (:weight bold :box (:line-width 1 :color "#9EB6D4")
            :foreground "#9EB6D4" :background "#E0EFFF")))
      "Face used to display state SDAY.")
    (defface leuven-org-appraise-kwd
      '((t (:weight bold :box (:line-width 1 :color "#D49ECE")
            :foreground "#D49ECE" :background "#FFE0FB")))
      "Face used to display state APPRAISE.")

(set-face-attribute 'default nil :font "Meslo LG M DZ-11")
(load-theme 'leuven t)
(require 'smart-mode-line)
(sml/setup)
(sml/apply-theme 'light)
;=======================================================
;; # custom-set-variables #
;=======================================================
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Linum-format "%7i ")
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#272822" "#F92672" "#A6E22E" "#E6DB74" "#66D9EF" "#FD5FF0" "#A1EFE4" "#F8F8F2"])
 '(ansi-term-color-vector
   [unspecified "#1F1611" "#660000" "#144212" "#EFC232" "#5798AE" "#BE73FD" "#93C1BC" "#E6E1DC"])
 '(compilation-message-face (quote default))
 '(cua-global-mark-cursor-color "#2aa198")
 '(cua-normal-cursor-color "#839496")
 '(cua-overwrite-cursor-color "#b58900")
 '(cua-read-only-cursor-color "#859900")
 '(custom-safe-themes
   (quote
    ("a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "c4e6fe8f5728a5d5fd0e92538f68c3b4e8b218bcfb5e07d8afff8731cc5f3df0" "8d6fb24169d94df45422617a1dfabf15ca42a97d594d28b3584dc6db711e0e0b" "c739f435660ca9d9e77312cbb878d5d7fd31e386a7758c982fa54a49ffd47f6e" "f0a99f53cbf7b004ba0c1760aa14fd70f2eabafe4e62a2b3cf5cabae8203113b" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "08efabe5a8f3827508634a3ceed33fa06b9daeef9c70a24218b70494acdf7855" "4e262566c3d57706c70e403d440146a5440de056dfaeb3062f004da1711d83fc" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "62c9339d5cac3a49688abb34e98f87a6ee82003a11251f12e0ada1788090c40f" "4402028b09b797389c0b089c247854a1cf67f0058d0a8f66cbc60a9960c30cd3" "b69df114abdbbf223e1ad2c98ad1abee04ac2a5070aeb8b7ceefcf00aa5e43f8" "4217c670c803e8a831797ccf51c7e6f3a9e102cb9345e3662cc449f4c194ed7d" "9dae95cdbed1505d45322ef8b5aa90ccb6cb59e0ff26fef0b8f411dfc416c552" "3b819bba57a676edf6e4881bd38c777f96d1aa3b3b5bc21d8266fa5b0d0f1ebf" default)))
 '(fci-rule-character-color "#202020")
 '(fci-rule-color "#2D2D2D")
 '(fringe-mode 4 nil (fringe))
 '(geiser-default-implementation (quote guile))
 '(geiser-racket-binary "/usr/bin/racket")
 '(geiser-repl-read-only-prompt-p nil)
 '(global-linum-mode t)
 '(haskell-mode-hook (quote (turn-on-haskell-indentation)))
 '(highlight-changes-colors ("#FD5FF0" "#AE81FF"))
 '(highlight-symbol-colors
   (--map
    (solarized-color-blend it "#002b36" 0.25)
    (quote
     ("#b58900" "#2aa198" "#dc322f" "#6c71c4" "#859900" "#cb4b16" "#268bd2"))))
 '(highlight-symbol-foreground-color "#93a1a1")
 '(highlight-tail-colors
   (("#49483E" . 0)
    ("#67930F" . 20)
    ("#349B8D" . 30)
    ("#21889B" . 50)
    ("#968B26" . 60)
    ("#A45E0A" . 70)
    ("#A41F99" . 85)
    ("#49483E" . 100)))
 '(hl-bg-colors
   (quote
    ("#7B6000" "#8B2C02" "#990A1B" "#93115C" "#3F4D91" "#00629D" "#00736F" "#546E00")))
 '(hl-fg-colors
   (quote
    ("#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36")))
 '(hl-paren-background-colors (quote ("#2492db" "#95a5a6" nil)))
 '(hl-paren-colors (quote ("#ecf0f1" "#ecf0f1" "#c0392b")))
 '(linum-format "%i")
 '(magit-diff-use-overlays nil)
 '(magit-use-overlays nil)
 '(main-line-color1 "#1E1E1E")
 '(main-line-color2 "#111111")
 '(main-line-separator-style (quote chamfer))
 '(org-babel-load-languages
   (quote
    ((emacs-lisp . t)
     (scheme . t)
     (C . t)
     (python . t)
     (js . t)
     (emacs-lisp . t)
     (sass . t)
     (latex . t)
     (gnuplot . t)
     (maxima . t)
     (makefile . t)
     (sh . t)
     (haskell . t)
     (js . t)
     (lilypond . t))))
 '(org-blank-before-new-entry (quote ((heading) (plain-list-item))))
 '(org-modules
   (quote
    (org-bbdb org-bibtex org-docview org-gnus org-info org-irc org-mhe org-rmail org-w3m)))
 '(org-startup-indented t)
 '(pandoc-binary "~/.cabal/bin/" t)
 '(paradox-automatically-star nil)
 '(paradox-github-token "fd080b68b580d3eb087f51316527e8237a21bd46")
 '(powerline-color1 "#1E1E1E")
 '(powerline-color2 "#111111")
 '(processing-application-dir "/usr/share/processing" t)
 '(processing-location "/usr/share/processing/processing-java" t)
 '(processing-sketchbook-dir "~/Development/processing_sketchbook" t)
 '(python-shell-interpreter "python2.7")
 '(scss-compile-at-save nil)
 '(show-paren-mode t)
 '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#073642" 0.2))
 '(term-default-bg-color "#002b36")
 '(term-default-fg-color "#839496")
 '(tool-bar-mode nil)
 '(vc-annotate-background "#202020")
 '(vc-annotate-color-map
   (quote
    ((20 . "#C99090")
     (40 . "#D9A0A0")
     (60 . "#ECBC9C")
     (80 . "#DDCC9C")
     (100 . "#EDDCAC")
     (120 . "#FDECBC")
     (140 . "#6C8C6C")
     (160 . "#8CAC8C")
     (180 . "#9CBF9C")
     (200 . "#ACD2AC")
     (220 . "#BCE5BC")
     (240 . "#CCF8CC")
     (260 . "#A0EDF0")
     (280 . "#79ADB0")
     (300 . "#89C5C8")
     (320 . "#99DDE0")
     (340 . "#9CC7FB")
     (360 . "#E090C7"))))
 '(vc-annotate-very-old-color "#E090C7")
 '(weechat-color-list
   (unspecified "#272822" "#49483E" "#A20C41" "#F92672" "#67930F" "#A6E22E" "#968B26" "#E6DB74" "#21889B" "#66D9EF" "#A41F99" "#FD5FF0" "#349B8D" "#A1EFE4" "#F8F8F2" "#F8F8F0"))
 '(yas-snippet-dirs (quote ("~/.emacs.d/snippets")) nil (yasnippet)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 ;'(default ((t (:family "Source Code Pro" :foundry "adobe" :slant normal :weight normal :height 113 :width normal))))
 '(highlight-indentation-current-column-face ((t nil)))
 '(highlight-indentation-face ((t (:background "gray57"))))
 '(powerline-evil-emacs-face ((t (:inherit powerline-evil-base-face :background "#E090C7"))))
 '(powerline-evil-insert-face ((t (:inherit powerline-evil-base-face :background "#79ADB0"))))
 '(powerline-evil-normal-face ((t (:inherit powerline-evil-base-face :background "#6C8C6C"))))
 '(powerline-evil-operator-face ((t (:inherit powerline-evil-operator-face :background "#99DDE0"))))
 '(powerline-evil-replace-face ((t (:inherit powerline-evil-base-face :background "#996060"))))
 '(powerline-evil-visual-face ((t (:inherit powerline-evil-base-face :background "#ECBC9C")))))


(set-face-attribute 'default nil :font "Meslo LG M DZ-10")
;=======================================================
;; # Retired Code #
;=======================================================


;(add-to-list 'load-path (expand-file-name "~/.emacs.d") t)
;(add-to-list 'load-path "~/.emacs.d/plugins/evil-org-mode-master")
;(add-to-list 'load-path "~/.emacs.d/plugins/evil-leader-master")
;(add-to-list 'load-path "~/.emacs.d/plugins/geiser-master/elisp")

;(add-to-list 'load-path "~/.emacs.d/plugins/evil-paredit-master")

;; (require 'powerline)
;; (require 'moe-theme)
;; ;; Show highlighted buffer-id as decoration. (Default: nil)
;;     (setq moe-theme-highlight-buffer-id t)
;;     ;; Resize titles (optional).
;;     (setq moe-theme-resize-markdown-title '(1.5 1.4 1.3 1.2 1.0 1.0))
;;     (setq moe-theme-resize-org-title '(1.5 1.4 1.3 1.2 1.1 1.0 1.0 1.0 1.0))
;;     (setq moe-theme-resize-rst-title '(1.5 1.4 1.3 1.2 1.1 1.0))
;;     ;; Choose a color for mode-line.(Default: blue)
;;     (moe-theme-set-color 'cyan)
;; ;; (Available colors: blue, orange, green ,magenta, yellow, purple, red, cyan, w/b.)
;;     ;; Finally, apply moe-theme now.
;; ;; Choose what you like, (moe-light) or (moe-dark)
;; (setq moe-light-pure-white-background-in-terminal t)
;; (require 'moe-theme-switcher)
;; (powerline-moe-theme)

;(autoload 'processing-snippets-initialize "processing-snippets" nil nil nil)
;(eval-after-load 'yasnippet '(processing-snippets-initialize))
;
;
;(defun processing-mode-init ()
 ; (make-local-variable 'ac-sources)
  ;(setq ac-sources '(ac-source-dictionary ac-source-yasnippet))
  ;(make-local-variable 'ac-user-dictionary)
  ;(setq ac-user-dictionary (append processing-functions
   ;                                processing-builtins
    ;                               processing-constants)))

;(add-to-list 'ac-modes 'processing-mode)

;(require 'auto-complete)

;(require 'powerline) (powerline-evil-vim-theme)
;(require 'pandoc-mode)

;ibuffer
  ;"\\" 'org-export-dispatch
  ;"`" 'kill-other-buffers
  ;"l" 'bookmark-bmenu-list
  ;"b" 'bookmark-set
					;"v" 'bookmark-save
					;"r" 'sr-speedbar-open

;; ;; cursor color based on mode // pretty stuff
;; (setq evil-emacs-state-cursor '("#E090C7" box))
;; (setq evil-normal-state-cursor '("#CCF8CC" box))
;; (setq evil-visual-state-cursor '("#ECBC9C" box))
;; (setq evil-insert-state-cursor '("#A0EDF0" bar))
;; (setq evil-replace-state-cursor '("#E9B0B0" hbar))
;; (setq evil-operator-state-cursor '("#996060" hollow))


;(global-set-key (kbd "C-c l") 'evilnc-quick-comment-or-uncomment-to-the-line)
;(global-set-key (kbd "C-c c") 'evilnc-copy-and-comment-lines)
;(global-set-key (kbd "C-c p") 'evilnc-comment-or-uncomment-paragraphs)


;; (defvar --backup-directory (concat user-emacs-directory "backups"))
;; (if (not (file-exists-p --backup-directory))
;;         (make-directory --backup-directory t))
;; (setq backup-directory-alist `(("." . ,--backup-directory)))


;--------------------------------------------
;; change mode-line color by evil state
   ;(lexical-let ((default-color (cons (face-background 'mode-line)
    ;                                  (face-foreground 'mode-line))))

     ;(add-hook 'post-command-hook
      ; (lambda ()
       ;  (let ((color (cond ((minibufferp) default-color)
        ;                    ((evil-insert-state-p) '("#996060" . "#DCDCCC"))
         ;                   ((evil-emacs-state-p)  '("#444488" . "#ffffff"))
          ;                  ((buffer-modified-p)   '("#79ADB0" . "#ffffff"))
           ;                 (t default-color))))

           ;(set-face-background 'mode-line (car color))
           ;(set-face-foreground 'mode-line (cdr color))))))

;; Note: lexical-binding must be t in order for this to work correctly.
;   (defun make-conditional-key-translation (key-from key-to translate-keys-p)
;     "Make a Key Translation such that if the translate-keys-p function returns true,
;   key-from translates to key-to, else key-from translates to itself.  translate-keys-p
;   takes key-from as an argument. "
;     (define-key key-translation-map key-from
;       (lambda (prompt)
;         (if (funcall translate-keys-p key-from) key-to key-from))))
;   (defun my-translate-keys-p (key-from)
;     "Returns whether conditional key translations should be active.  See make-conditional-key-translation function. "
;     (and
;       ;; Only allow a non identity translation if we're beginning a Key Sequence.
;       (equal key-from (this-command-keys))
;       (or (evil-motion-state-p) (evil-normal-state-p) (evil-visual-state-p))))
;   (define-key evil-normal-state-map "c" nil)
 ;  (define-key evil-motion-state-map "cu" 'universal-argument)
;   (make-conditional-key-translation (kbd "ch") (kbd "C-h") 'my-translate-keys-p)
;   (make-conditional-key-translation (kbd "g") (kbd "C-x") 'my-translate-keys-p)
;--------------------------------------------

