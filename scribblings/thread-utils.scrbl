#lang scribble/manual
@require[@for-label[thread-utils
                    racket/base]]

@title{thread-utils}
@author+email["Roman Klochkov" "kalimehtar@mail.ru"]

@defmodule[thread-utils]

This package provides some utilities to do common patterns of async programming.

@defproc[(until-timeout [func (-> any/c)]
                        [timeout (or/c #f (and/c real? (not/c negative?)) (-> any)) 30]
                        [on-error any/c #f]) any/c]{
Calls @racket[func] and wait for answer not more then @racket[timeout].
If @racket[func] fails to complete until that moment and @racket[on-error] is a procedure, then returns @racket[(on-error #f)]. If func raise an exception,
 applies @racket[on-error] to the exception and returns it's result. If @racket[on-error] any other value, then it will be returned in
 case of error or timeout.}

@defproc[(thread-loop [func (-> any/c)] [on-error any/c #f]) thread?]{
Returns thread, which runs @racket[func] in infinite loop. When @racket[func] raises an exception, applies
@racket[on-error] to the exception and run @racket[func] again. If @racket[on-error] is not a procedure, then errors are supressed.}
