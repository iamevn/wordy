#lang racket
(define (translate fn)
  (define x 0)
  (define unmatched '())
  (define inst-ht (hash
                   #\> (λ () "AND VALUE LITERAL 0 ASSIGN LITERAL 0 ADD VALUE LITERAL 0 LITERAL 1\n")
                   #\< (λ () "AND VALUE LITERAL 0 ASSIGN LITERAL 0 SUBTRACT VALUE LITERAL 0 LITERAL 1\n")
                   #\+ (λ () "AND VALUE LITERAL 0 ASSIGN VALUE LITERAL 0 ADD VALUE VALUE LITERAL 0 LITERAL 1\n")
                   #\- (λ () "AND VALUE LITERAL 0 ASSIGN VALUE LITERAL 0 SUBTRACT VALUE VALUE LITERAL 0 LITERAL 1\n")
                   #\. (λ () "AND VALUE LITERAL 0 OUTCHAR VALUE VALUE LITERAL 0\n")
                   #\, (λ () "AND VALUE LITERAL 0 ASSIGN VALUE LITERAL 0 INCHAR\n")
                   #\[ (λ () (set! x (add1 x))
                         (set! unmatched (cons x unmatched))
                         (~a "AND VALUE LITERAL 0 OR VALUE VALUE LITERAL 0 GOTO LITERAL "
                             x
                             "\nOR VALUE LITERAL 0 LABEL SUBTRACT LITERAL 0 LITERAL "
                             x
                             "\n"))
                   #\] (λ () (let ([x (car unmatched)])
                               (set! unmatched (cdr unmatched))
                               (~a "AND VALUE LITERAL 0 AND VALUE VALUE LITERAL 0 GOTO SUBTRACT LITERAL 0 LITERAL "
                                   x"\nOR VALUE LITERAL 0 LABEL LITERAL "
                                   x
                                   "\n")))))
  (display "LABEL LITERAL 0\n")
  (call-with-input-file fn
    (λ (file)
      (let loop ([next (read-char file)])
        (unless (eof-object? next)
          (let ([fn (hash-ref inst-ht next #f)])
            (when fn (display (apply fn '()))
              (loop (read-char file))))))))
  (display "AND VALUE LITERAL 0 EXIT\n")
  (display "ASSIGN LITERAL 0 LITERAL 1\n")
  (display "GOTO LITERAL 0\n"))

(define args (current-command-line-arguments))
(cond [(and (equal? (vector-length args) 1)
            (file-exists? (vector-ref args 0)))
       (translate (vector-ref args 0))]
      [else (display (~a "Usage ./brainfuck->wordy filename\n"))])
