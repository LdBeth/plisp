(asdf:defsystem plisp
  :description "A PostScript Generator."
  :author "John Peterson"
  :licence "Public Domain"
  :serial t
  :components ((:file "package")
               (:file "vars")
               (:file "macros")
               (:file "top")
               (:file "compile")
               (:file "output")
               (:file "defps")
               (:file "args")
               (:file "names")
               (:file "flow")
               (:file "util")
               (:module "common-lisp"
                :components ((:file "bind")
                             (:file "control")
                             (:file "functional")
                             (:file "lisp-util")
                             (:file "loop")
                             (:file "mvalues")
                             (:file "numeric")
                             (:file "for")))))
