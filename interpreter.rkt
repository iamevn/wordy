#lang racket
(require "readsentence.rkt") ; read-sentence
(require "stats.rkt") ; statstruct stats ss-over ss-under ss-list
(require "ratios.rkt") ; ratio ratio->cmd cmd->ratio
(require "run.rkt") ; run
(require racket/vector)

(define file (open-input-file "cat.txt"))

(define (clean sen)
  (define (clean-word word)
    (list->string (filter (λ (ch) (or (char-alphabetic? ch)
                                      (char-numeric? ch)
                                      (equal? #\. ch)))
                          (string->list word))))
  ;remove non alphanumeric characters from each word
  (define (phase1 sen)
    (let loop ([sen sen])
      (cond [(null? sen) '()]
            [else (cons (clean-word (car sen))
                        (loop (cdr sen)))])))
  ;remove words of length 0
  (define (phase2 sen)
    (filter (λ (word) (not (zero? (string-length word))))
            sen))

  (phase2 (phase1 sen)))

(define (read file)
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

;(run (read file))
