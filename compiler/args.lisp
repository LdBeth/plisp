;;; Copyright (c) 1987 John Peterson
;;;   Permission is given to freely modify and distribute this code
;;;   so long as this copyright notice is retained.

;;;   Support for strange common lisp parameter passing.

(in-package #:plisp)

(defun ps-compile-call (hash name fm)
  (import-name hash name 'f)
  (push-att frame-table current-frame 'uses name)
  (let* ((args (att main-table name 'processed-args))
	 (norms (car args))
	 (opts (cadr args))
	 (rest (caddr args))
	 (keys (cadddr args))
	 (do-init (car (cddddr args)))
	 (all fm)
         (lexical-vars lexical-vars) 
	 (old-lexical-vars lexical-vars))
    (setf fm (cdr fm))
    (while (and fm (not (keywordp (car fm))) (or norms opts))
      (let ((arg (car fm)))
	(cond (norms
	       (get-arg arg (car norms) do-init)
	       (setf norms (cdr norms)))
	      (opts
	       (get-arg arg (caar opts) do-init)
	       (if (caddr (car opts))
		   (get-arg T (caddr (car opts)) do-init))
	       (setf opts (cdr opts)))))
      (setf fm (cdr fm)))
    (when norms
	  (ps-error "Too few arguments" all))
    (when opts
	  (for (:in opt opts)
	       (:do
		(get-arg (cadr opt) (car opt) 'init)
		(when (caddr opt)
		      (get-arg nil (caddr opt) do-init)))))
    (when rest
	(let ((init (list 'vector)))
	  (while (and fm (not (keywordp (car fm))))
	    (push (car fm) init)
	    (setf fm (cdr fm)))
	  (get-arg (nreverse init) (car rest) do-init)))
    (when (and fm (null keys))
	  (ps-error "Excess arguments" all))
    (let ((checker fm)
	  (keyvals nil))
      (while checker
	(cond ((not (keywordp (car checker)))
	       (ps-error "Excess arguments" (car checker) all)
	       (setf checker nil))
	      ((null (cdr checker))
	       (ps-error "No argument for keyword" (car checker) all)
	       (setf checker nil))
	      ((unknown-key (car checker) keys)
	       (ps-error "Keyword not valid here" (car checker) all)
	       (setf checker nil))
	      (T
	       (push (cons (car checker) (cadr checker)) keyvals)
	       (setf checker (cddr checker)))))
      (for (:in key keys)
	   (:do
	    (let* ((kvar (car key))
		   (kname (cadr key))
		   (kinit (caddr key))
		   (ksu (cadddr key))
		   (param (assoc kname keyvals)))
	      (if param
		  (progn
		    (get-arg (cdr param) kvar do-init)
		    (if ksu
			(get-arg t ksu do-init)))
		  (progn
		    (get-arg kinit kvar 'init)
		    (if ksu
			(get-arg nil ksu do-init)))))))
      )
    (while (not (eq lexical-vars old-lexical-vars))
      (if (cadddr (car lexical-vars))
	  (push (cadddr (car lexical-vars)) lexicals-here))
      (setf lexical-vars (cdr lexical-vars))))
  (emit name)
  (att main-table name 'results))
	       
(defun get-arg (code var save-init)
   (if (eq save-init 'init)
       (compile-1 code)
       (let ((lexical-vars old-lexical-vars))
	 (compile-1 code)))
   (when save-init
	 (let ((instr (list 'save-temp var nil)))
	   (emit instr)
	   (push (cons var instr) lexical-vars))))

(defun unknown-key (key all)
  (or (null all)
      (and (not (eq key (cadr (car all)))) (unknown-key key (cdr all)))))
      
(defun process-args (hash name)
  (let ((args (att hash name 'args))
	(param 1)
	(mode 'normal)
	(normals nil)
	(optionals nil)
	(rest nil)
	(keys nil)
	(do-init nil)
	(vars nil)) 
    (while args
      (let ((arg (car args)))
	(cond ((eq arg '&optional)
	       (cond ((eq mode 'normal)
		      (setf mode 'optionals))
		     (T (ps-error "Misplaced &optional" name args)))
	       )
	      ((eq arg '&rest)
	       (cond ((member mode '(normal optionals))
		      (setf mode 'rest))
		     (t (ps-error "Misplaced &rest" name args)))
	       )
	      ((eq arg '&key)
	       (cond ((member mode '(normal optionals rest end-rest))
		      (setf mode 'key))
		     (t (ps-error "Misplaced &key" name args)))
	       )
	      ((symbolp arg)
	       (cond ((eq mode 'normal)
		      (push arg normals)
		      (push arg vars))
		     ((eq mode 'optionals)
		      (push (list arg nil nil) optionals)
		      (push arg vars))
		     ((eq mode 'rest)
		      (push arg rest)
		      (push arg vars)
		      (setf mode 'end-rest))
		     ((eq mode 'key)
		      (push (list arg (make-keyword arg) nil nil) keys)
		      (push arg vars))
		     (T (ps-error "too many &rest vars " name args)))
		      )
	      ((consp arg)
	       (let ((var (car arg))
		     (init (cadr arg))
		     (su (caddr arg)))
		 (if init (setf do-init T))
		 (cond ((eq mode 'optionals)
			(when (not (symbolp var))
			      (ps-error "Variable missing" arg args))
			(push (list var init su) optionals)
			(push var vars)
			(if su (push su vars)))
		       ((eq mode 'key)
			(let ((var (if (consp var) (car var) var))
			      (keywd (if (consp var)
					 (cadr var)
				         (make-keyword var))))
			  (push (list var keywd init su) keys)
			  (push var vars)
			  (if su (push su vars))))
		       (t (ps-error "Identifier required" arg args))))
	       )
	      (T (ps-error "Error in argument list" name args))))
      (setf args (cdr args)))
    (put-att hash name 'vars (nreverse vars))
    (put-att hash name 'processed-args (list
					(nreverse normals)
					(nreverse optionals)
					rest
					(nreverse keys)
					do-init))
    (put-att hash name 'processed T)
    ))

(defun make-keyword (x)
  (intern (symbol-name x) (find-package 'keyword)))

