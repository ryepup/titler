;;;; titler.asd

(asdf:defsystem #:titler
  :serial t
  :depends-on (#:vecto)
  :components ((:file "package")
               (:file "titler")))

