;;;; titler.asd

(asdf:defsystem #:titler
  :serial t
  :depends-on (#:vecto #:iterate)
  :components ((:file "package")
               (:file "titler")))

