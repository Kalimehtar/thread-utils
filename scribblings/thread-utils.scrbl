#lang scribble/manual
@require[@for-label[thread-utils
                    racket/base]]

@title{thread-utils}
@author+email["Roman Klochkov" "kalimehtar@mail.ru"]

@defmodule[thread-utils]

This package provides some utilities to do common patterns of async programming.

@defproc[(until-timeout [func (-> any/c)]
                        [timeout (or/c #f (and/c real? (not/c negative?)) (-> any)) 30]
                        [on-error (any/c . -> . any/c)]) any/c]{
Calls @racket[func] and wait for answer not more then @racket[timeout].
If @racket[func] fails to complete until that moment, returns @racket[(in-error #f)]. If func raise an exception,
 applies @racket[on-error] to the exception and returns it's result.}

@defproc[(thread-loop [func (-> any/c)] [on-error (any/c . -> . any)]) thread?]{
Returns thread, which runs @racket[func] in infinite loop. When @racket[func] raises an exception, applies
@racket[on-error] to the exception and run @racket[func] again.}

