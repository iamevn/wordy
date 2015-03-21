#lang racket
(require "interpreter.rkt")
(require "run.rkt")

(define (display-usage)
  (display "Usage: ./wordy filename [--to-pseudocode][--wimpmode]\nthe --to-pseudocode flag doesn't run the program, just ouputs the pseudocode translated from filename.\nthe --wimpmode flag marks that filename consists of pseudocode and not actual interpretable sentences"))

(define (read-wimpmode fn)
  (call-with-input-file fn
    (λ (f)
      (list->vector (let loop ([symbol (read f)])
                      (if (eof-object? symbol) '()
                          (cons symbol (loop (read f)))))))))

(define args (current-command-line-arguments))
(define wimpmode #f)
(define to-pseudocode #f)

(let ([wimpmode (vector-member "--wimpmode" args)]
      [to-pseudocode (vector-member "--to-pseudocode" args)])
  (cond [(not (equal? 1 
                      (vector-length (vector-filter-not (λ (elem) (or (equal? elem "--to-pseudocode")
                                                                      (equal? elem "--wimpmode")))
                                                        args))))
         (display-usage)]
        [(and wimpmode to-pseudocode)
         (display (read-wimpmode (vector-ref args 0)))]
        [wimpmode
         (run (read-wimpmode (vector-ref args 0)))]
        [to-pseudocode
         (display (call-with-input-file (vector-ref args 0) 
                    (λ (file) (read-to-instructions file))))]
        [else (interpret (vector-ref args 0))]))