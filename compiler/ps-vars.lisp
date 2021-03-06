
;;;  This file contains defvars for the postscript interpreter.
(in-package #:plisp)

(defvar main-program nil "Main postscript program")
(defvar ps-file nil "Name of root file")
(defvar ps-output nil "Output stream")
(defvar code-stream nil "Code stream")
(defvar ps-globals nil "List of all global variables")
(defvar error-count nil)
(defvar current-col 0 "Output column")
(defvar pre-code-stream nil "Initialization code")
(defvar lexical-vars nil "Current lexical environment")
(defvar lexicals-here nil "All lexicals in current frame")
(defvar old-lexical-vars nil "Saves previous lexical env")
(defvar current-table nil "Currently active hash table")
(defvar env-list nil "List of all environments (hash tables)")
(defvar main-table nil "Main program environment")
(defvar current-env nil "Currently active environment")
(defvar frame-table nil "Hash table of all frames")
(defvar next-frame nil "Current frame number")
(defvar current-frame nil "Active frame")
(defvar to-compile nil "Functions yet to be compiled")
(defvar fn-code nil "Code for all function bodies")
(defvar to-init nil "Globals to be initialized")
(defvar init-code nil "Code which initializes globals")
(defvar dict-code nil "Code to create dictionariesfor locals")
(defvar non-recursives nil "List of a ll non-recursive functions")
(defvar current-fn nil "Currently active function")
(defvar unknown-frames nil "Frames being scanned for recursion")
(defvar main-env nil "Environment for mail program")
(defvar main-code nil "Holds main program for output routine")
(defvar *assume-0-res* 'warn "Use T, nil, or warn")
