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
If @racket[func] fails to complete until that moment, returns @racket[eof]. If func raise an exception, applies @racket[on-error] to
the exception}
