#Wherewithal

A trivial library to provide a portable with-all-slots macro for CLOS objects.
Relies on the MOP for portability.

## Installation

Clone the respository to a location that ASDF/Quicklisp can find, eg.
`~/common-lisp/`, then start up your CL implementation and run:

```
CL-USER> (ql:quickload :wherewithal)
```

## Usage

Assuming these definitions:

```
(defclass unit ()
  ((hp :initarg :hp :accessor hp)
   (dmg :initarg :dmg :accessor dmg)))

(defclass air-unit (unit)
  ()
  (:default-initargs
    :hp 6
    :dmg 3))
    
(defclass land-unit (unit)
  ()
  (:default-initargs
    :hp 10
    :dmg 2))

```
the following usage:
```
(let ((attacker (make-instance 'air-unit))
      (defender (make-instance 'land-unit)))
  (with-all-slots (air-unit land-unit) (attacker defender)
    (- defender-hp attacker-dmg)))
```
expands to:
```
(WITH-SLOTS ((ATTACKER-HP HP) (ATTACKER-DMG DMG))
    ATTACKER
  (DECLARE (IGNORABLE ATTACKER-HP ATTACKER-DMG))
  (WITH-SLOTS ((DEFENDER-HP HP) (DEFENDER-DMG DMG))
      DEFENDER
    (DECLARE (IGNORABLE DEFENDER-HP DEFENDER-DMG))
    (- DEFENDER-HP ATTACKER-DMG)))
```
Note that the class of each object must be provided.

Note also that the anaphor for an object's slot is the concatenation of the
symbol provided as the name of the object, and the name of the slot in
question (with a hypen inserted between the two, for readablity).
