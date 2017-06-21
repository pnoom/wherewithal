;;;; wherewithal.lisp - a with-all-slots macro for CLOS objects

(in-package #:wherewithal)

(defun all-distinct-p (seq)
  "Returns true only if seq contains no duplicates."
  (alexandria:length= seq (remove-duplicates seq)))

;; Adapted from github.com/Shinmera/qtools/blob/master/toolkit.lisp

(defun ensure-is-class (thing)
  (etypecase thing
    (symbol (find-class thing))
    (class thing)
    (standard-object (class-of thing))))

;; A class is only required to be finalized "no later than creation of an
;; instance of it" (think forward-referencing of superclasses), so if you
;; wish to invoke MOP functionality that requires a finalized class, precede
;; it with a call to c2mop:finalize-inheritance.

(defun list-slots (class-spec &key (direct-slots-only nil))
  (let ((fn (if direct-slots-only
                #'c2mop:class-direct-slots
		#'c2mop:class-slots)))
    (mapcar #'c2mop:slot-definition-name
	    (funcall fn (let ((class (ensure-is-class class-spec)))
			  (c2mop:finalize-inheritance class)
			  class)))))

(defun build-slot-identifier (slot object)
  "Concatenate symbols to differentiate the symbol macros generated by with-slots
  for each object."
  (intern (format nil "~a-~a" (symbol-name object) (symbol-name slot))))

(defun build-slot-identifiers (slots object)
  (mapcar (lambda (slot)
	    (build-slot-identifier slot object))
	  slots))

(defun build-slot-id-pairs (slots object)
  "Build the symbol macro bindings list required by with-slots."
  (mapcar 'list (build-slot-identifiers slots object) slots))

;; See "On Lisp" p142 for recursive expansions.

(defun with-all-slots-expand (class-names objects gbody)
  (if (or (null class-names) (null objects))
      gbody
      `(with-slots ,(build-slot-id-pairs (list-slots (car class-names))
					 (car objects))
	   ,(car objects)
	 (declare (ignorable ,@(build-slot-identifiers (list-slots (car class-names))
						       (car objects))))
	 ,(with-all-slots-expand (cdr class-names) (cdr objects) gbody))))

;; If the class names provided do not refer to classes that actually exist,
;; a condition will be raised at macroexpansion time. However if they do refer
;; to existing classes, but NOT the actual classes of the instances, the
;; condition will not be raised until after macroexpansion time.

(defmacro with-all-slots ((&rest class-names) (&rest objects)
			  &body body)
  (assert (alexandria:length= class-names objects))
  (assert (and (every 'symbolp class-names) (every 'symbolp objects)))
  (assert (all-distinct-p objects))
  (let ((gbody (gensym)))
    (subst (car body) gbody
	   (with-all-slots-expand class-names objects gbody))))

