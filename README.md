try-catch-finally
=================
A macro for catching exceptions and running teardown operations.

Documentation: https://docs.racket-lang.org/try-catch-finally/index.html

```scheme
(try
  body ...+
  catch-clause ...
  maybe-finally-clause)

        catch-clause = (catch pred => handler)
                     | (catch (pred id) handler-body ...+)
                     | (catch (id) handler-body ...+)
                     | (catch _ handler-body ...+)

maybe-finally-clause =
                     | (finally post-body ...+)
```

Examples:
```scheme
> (try
    (raise-syntax-error #f "a syntax error")
    (catch (exn:fail:syntax? e)
      (displayln "got a syntax error")))
got a syntax error
> (try
    (raise-syntax-error #f "a syntax error")
    (catch (exn:fail:syntax? e)
      (displayln "got a syntax error"))
    (catch (exn:fail? e)
      (displayln "fallback clause")))
got a syntax error
> (try
    (displayln "at")
    (finally (displayln "out")))
at
out
> (let/cc up
    (try
      (displayln "at before")
      (up (void))
      (displayln "at after")
      (finally (displayln "out"))))
at before
out
```
