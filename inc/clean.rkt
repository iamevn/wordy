#lang racket

(provide clean)

(define (clean sen)
  (define (clean-word word)
    (list->string (filter (λ (ch) (or (char-alphabetic? ch)
                                      (char-numeric? ch)))
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
