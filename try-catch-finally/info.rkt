#lang info

;; Package Info

(define collection "try-catch-finally")

(define deps '("base" "try-catch-finally-lib"))
(define implies '("try-catch-finally-lib"))
(define update-implies '("try-catch-finally-lib"))

(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))

(define pkg-desc "Tests and Docs for try-catch-finally-lib")

(define version "0.0")

;; Collection Info

(define scribblings '(("scribblings/try-catch-finally.scrbl" ())))
