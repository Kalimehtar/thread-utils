#lang racket/base
(require racket/contract)
(define timeout/c (or/c #f (and/c real? (not/c negative?)) (-> any)))
(provide/contract [until-timeout (((-> any/c)) (timeout/c (any/c . -> . any/c))  . ->* . any/c)]
                  [thread-loop ((-> any) (any/c . -> . any) . -> . thread?)]
                  [timeout/c contract?])

(module+ test
  (require rackunit))

(require racket/function)

(define ((do-on-error on-error) e)
  (if (procedure? on-error)
      (with-handlers ([(const #t) (const #f)])
        (on-error e))
      on-error))

(define (until-timeout func [timeout 30] [on-error #f])
  (call-in-nested-thread
   (λ ()
     (define master (current-thread))
     (define slave
       (thread (λ ()
                 (thread-send master
                              (with-handlers ([(const #t) (do-on-error on-error)])
                                (func))))))
     (cond
       [(sync/timeout timeout slave)
        (thread-receive)]
       [else
        (kill-thread slave)
        ((do-on-error on-error) #f)]))))

(define (thread-loop func [on-error #f])
  (thread
   (λ ()
     (with-handlers ([(const #t) (do-on-error on-error)])
       (let loop ()
         (func)
         (loop))))))

(module+ test
  (check-eq? (until-timeout (thunk 'a) 0.1) 'a)
  (check-eq? (until-timeout (thunk (sleep 0.2)) 0.1) #f)
  (check-eq? (until-timeout (thunk (error 'ok)) 0.1) #f)
  (check-eq? (until-timeout (thunk eof) 0.1) eof)
  (check-eq? (until-timeout (thunk (error 'ok)) 0.1 eof) eof)
  (check-eq? (let ([err 'no])
               (define (on-error x) (set! err 'yes))
               (until-timeout (thunk (error 'ok)) 0.1 on-error)
               err)
             'yes)
  (check-eq? (let ([x 0])
               (define t (thread-loop (thunk (set! x (add1 x)) (sleep 0.15))))
               (sleep 0.2)
               (kill-thread t)
               x) 2)
  )

(module+ main
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  )
