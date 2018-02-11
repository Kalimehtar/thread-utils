#lang racket/base
(require racket/contract)
(provide/contract [until-timeout (((-> any/c)) ((or/c #f (and/c real? (not/c negative?)) (-> any)) (any/c . -> . any))  . ->* . any/c)])
(provide thread-loop)

(module+ test
  (require rackunit))

(require racket/function)

(define (until-timeout func [timeout 30] [on-error (const #t)])
  (call-in-nested-thread
   (λ ()
     (define master (current-thread))
     (define slave (thread (λ () (thread-send master
                                              (with-handlers ([(const #t) (λ (e) (on-error e) eof)])
                                                (func))))))
     (cond
       [(sync/timeout timeout slave)
        (thread-receive)]
       [else
        (kill-thread slave)
        eof]))))

(define-syntax-rule (thread-loop on-error BODY ...)
  (thread
   (λ ()
     (with-handlers ([(const #t) on-error])
       (let loop ()
         BODY ...
         (loop))))))

(module+ test
  (check-eq? (until-timeout (thunk 'a) 1) 'a)
  (check-eq? (until-timeout (thunk (sleep 2)) 1) eof)
  (check-eq? (until-timeout (thunk (error 'ok)) 1) eof)
  (check-eq? (until-timeout (thunk eof) 1) eof)
  (check-eq? (let ([err 'no])
               (define (on-error x) (set! err 'yes))
               (until-timeout (thunk (error 'ok)) 1 on-error)
               err)
             'yes)
  )

(module+ main
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  )
