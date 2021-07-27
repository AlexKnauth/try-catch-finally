#lang scribble/manual

@(require scribble/example
          (for-label try-catch-finally
                     racket/base))

@title{try-catch-finally}
@author{Alex Knauth}

@(define ev (make-base-eval '(require try-catch-finally)))

@defmodule[try-catch-finally]{
A macro for catching exceptions and running teardown operations.
}

@defform[#:literals [catch finally => _]
         (try body ...+ catch-clause ... maybe-finally-clause)
         #:grammar ([catch-clause (catch pred-expr => handler-expr)
                                  (catch (pred-expr id) handler-body ...+)
                                  (catch (id) handler-body ...+)
                                  (catch _ handler-body ...+)]
                    [maybe-finally-clause (code:line)
                                          (finally post-body ...+)])]{
After evaluating the @racket[pred-expr]s and @racket[handler-expr]s,
@racket[try] evaluates the @racket[body]s with the new exception handlers,
and then evaluates the @racket[post-body]s even if execution exits the
@racket[body]s through an exception or continuation.

@examples[#:eval ev
  (try
    (raise-syntax-error #f "a syntax error")
    (catch (exn:fail:syntax? e)
      (displayln "got a syntax error")))
  (try
    (raise-syntax-error #f "a syntax error")
    (catch (exn:fail:syntax? e)
      (displayln "got a syntax error"))
    (catch (exn:fail? e)
      (displayln "fallback clause")))
  (try
    (displayln "at")
    (finally (displayln "out")))
  (let/cc up
    (try
      (displayln "at before")
      (up (void))
      (displayln "at after")
      (finally (displayln "out"))))
]

@defsubform*[#:literals [=> _]
             [(catch pred-expr => handler-expr)
              (catch (pred-expr id) handler-body ...+)
              (catch (id) handler-body ...+)
              (catch _ handler-body ...+)]]

@defsubform[(finally post-body ...+)]
}
