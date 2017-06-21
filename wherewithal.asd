;;;; wherewithal.asd

(asdf:defsystem #:wherewithal
  :description "Portable with-all-slots macro."
  :author "Andy Page"
  :license "MIT"
  :depends-on (#:closer-mop #:alexandria)
  :serial t
  :components ((:file "package")
               (:file "wherewithal")))

