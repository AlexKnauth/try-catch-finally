#lang racket/base

(require (only-in racket/base [#%app rkt:#%app])
         try-catch-finally
         (for-syntax racket/base syntax/stx))
(module+ test
  (require racket/port
           rackunit)
  (define-check (check-output-string actual-thunk expected-string)
    (check-equal? (with-output-to-string actual-thunk) expected-string)))

(define-syntax #%app
  (λ (stx)
    (define (ca*r v) (if (pair? v) (ca*r (car v)) v))
    (cond [(equal? #\{ (ca*r (syntax-property stx 'paren-shape)))
           (quasisyntax/loc stx (λ () . #,(stx-cdr stx)))]
          [else
           (quasisyntax/loc stx (rkt:#%app . #,(stx-cdr stx)))])))

;; Tests for dynamic-wind and continuation-barrier

(module+ test
  (check-output-string {(dynamic-wind
                         {(displayln "in")}
                         {(displayln "at")}
                         {(displayln "out")})}
                       "in\nat\nout\n")

  (check-output-string {(let/cc up
                          (dynamic-wind
                           {(displayln "in")}
                           {(displayln "at before")
                            (up (void))
                            (displayln "at after")}
                           {(displayln "out")}))}
                       "in\nat before\nout\n")

  (check-output-string {(define down
                          (let/cc up
                            (dynamic-wind
                             {(displayln "in")}
                             {(displayln "at before")
                              (let/cc down
                                (up down))
                              (displayln "at after")
                              void}
                             {(displayln "out")})))
                        (displayln "away")
                        (down (void))}
                       "in\nat before\nout\naway\nin\nat after\nout\naway\n")

  (check-exn #rx"continuation application: attempt to cross a continuation barrier"
             {(with-output-to-string
                {(define down
                   (let/cc up
                     (call-with-continuation-barrier
                      {(dynamic-wind
                        {(displayln "in")}
                        {(displayln "at before")
                         (let/cc down
                           (up down))
                         (displayln "at after")
                         void}
                        {(displayln "out")})})))
                 (displayln "away")
                 (down (void))})}))

;; Tests for try and finally

(module+ test
  (check-output-string {(try
                         (displayln "at")
                         (finally (displayln "out")))}
                       "at\nout\n")

  (check-output-string {(let/cc up
                          (try
                           (displayln "at before")
                           (up (void))
                           (displayln "at after")
                           (finally (displayln "out"))))}
                       "at before\nout\n")

  (check-exn #rx"continuation application: attempt to cross a continuation barrier"
             {(with-output-to-string
                {(define down
                   (let/cc up
                     (try
                      (displayln "at before")
                      (let/cc down
                        (up down))
                      (displayln "at after")
                      void
                      (finally (displayln "out")))))
                 (displayln "away")
                 (down (void))})}))

;; Tests for try and catch

(module+ test
  (check-output-string {(try
                          (raise-syntax-error #f "a syntax error")
                          (catch (exn:fail:syntax? e)
                            (displayln "got a syntax error")))}
                       "got a syntax error\n")

  (check-output-string {(try
                          (raise-syntax-error #f "a syntax error")
                          (catch (exn:fail:syntax? e)
                            (displayln "got a syntax error"))
                          (catch (exn:fail? e)
                            (displayln "fallback clause")))}
                       "got a syntax error\n"))

;; Tests for try, catch, and finally together

(module+ test
  (check-output-string {(try
                          (displayln "at before")
                          (raise-syntax-error #f "a syntax error")
                          (displayln "at after")
                          (catch (exn:fail:syntax? e)
                            (displayln "out catch"))
                          (finally
                            (displayln "out finally")))}
                       "at before\nout catch\nout finally\n"))

