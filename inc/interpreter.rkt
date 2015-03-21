#lang racket
(require "readsentence.rkt") ; read-sentence
(require "stats.rkt") ; statstruct stats ss-over ss-under ss-list
(require "ratios.rkt") ; ratio ratio->cmd cmd->ratio
(require "run.rkt") ; run
(require "clean.rkt") ;clean
(require racket/vector)
(provide interpret read-to-instructions)
(define (read-to-instructions file)
  (let loop ([sen (read-sentence file)]
             [prog (make-vector 0)]
             [read-literal #f])
    (if (not sen) prog
        (let* ([clean-sen (clean sen)]
               [sen-stats (stats clean-sen)]
               [val (if read-literal
                        (ss-lit sen-stats)
                        (ratio (ss-over sen-stats)
                               (ss-under sen-stats)))]
               [symbol (if read-literal val (ratio->cmd val))])
          (loop (read-sentence file)
                (vector-append prog (vector symbol))
                (equal? symbol 'LITERAL))))))

(define (interpret filename)
  (run (call-with-input-file filename
         (λ (file) (read-to-instructions file)))))

;(interpret "hello.txt")
;(interpret "cat.txt")
