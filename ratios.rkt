#lang racket
;translate ratios to symbols and symbols to ratios
(provide (struct-out ratio) ratio->cmd cmd->ratio simplify-ratio)

(struct ratio (top bot) #:transparent)
(define cmd-ht 
  (hash
   (/ 13 7) 'ASSIGN
   (/ 2 3) 'VALUE
   (/ 0 1) 'LITERAL
   (/ 2 1) 'LABEL
   (/ 1 1) 'GOTO
   (/ 1 2) 'ADD
   (/ 5 9) 'SUBTRACT
   (/ 3 4) 'MULTIPLY
   (/ 4 1) 'DIVIDE
   (/ 1 4) 'MODULO
   (/ 2 9) 'ABS
   (/ 1 5) 'EQUAL?
   (/ 7 3) 'LESS?
   (/ 9 5) 'GREATER?
   (/ 11 17) 'OR
   (/ 13 3) 'AND
   (/ 5 13) 'NOT
   (/ 4 7) 'INNUM
   (/ 5 2) 'INCHAR
   (/ 15 14) 'OUTNUM
   (/ 3 7) 'OUTCHAR
   ;(/ 1 0) 'RAND
   (/ 5 3) 'EXIT))
(define ratio-ht
  (hash
   'ASSIGN (ratio 13 7) 
   'VALUE (ratio 2 3) 
   'LITERAL (ratio 0 1) 
   'LABEL (ratio 2 1) 
   'GOTO (ratio 1 1) 
   'ADD (ratio 1 2) 
   'SUBTRACT (ratio 5 9) 
   'MULTIPLY (ratio 3 4) 
   'DIVIDE (ratio 4 1) 
   'MODULO (ratio 1 4) 
   'ABS (ratio 2 9) 
   'EQUAL? (ratio 1 5) 
   'LESS? (ratio 7 3) 
   'GREATER? (ratio 9 5) 
   'OR (ratio 11 17) 
   'AND (ratio 13 3) 
   'NOT (ratio 5 13) 
   'INNUM (ratio 4 7) 
   'INCHAR (ratio 5 2) 
   'OUTNUM (ratio 15 14) 
   'OUTCHAR (ratio 3 7) 
   'RAND (ratio 1 0) 
   'EXIT (ratio 5 3)))

(define (ratio->cmd rat)
  (if (zero? (ratio-bot rat))
      'RAND
      (hash-ref cmd-ht (/ (ratio-top rat) (ratio-bot rat)) 'NOP)))

(define (cmd->ratio cmd)
  (hash-ref ratio-ht cmd))

(define (simplify-ratio rat)
  (if (zero? (ratio-bot rat))
    (ratio 1 0)
    (let ([n (/ (ratio-top rat) (ratio-bot rat))])
      (ratio (numerator n) (denominator n)))))