#lang racket
;; interpreter for Wordy language.
;prog is a vector containing the program
(provide run)

(define (run prog)
  ;index of instruction pointer
  (define idx 0)
  ;hashtable of labels encountered
  (define labels-ht (make-hash))
  ;hashtable of vars
  (define vars-ht (make-hash))
  ;an instruction
  (struct instruction (argc code))
  (define instruction-ht
    (hash
     'ASSIGN (instruction 2 (λ (a b) (hash-set! vars-ht a b) b))
     'VALUE (instruction 1 (λ (a) (hash-ref vars-ht a 0)))
     'LITERAL (instruction 1 (λ (a) a))
     'LABEL (instruction 1 (λ (a) (hash-set! labels-ht a idx)))
     'GOTO (instruction 1 (λ (a) (let ([jmp (hash-ref labels-ht a #f)])
                                   (if jmp (set! idx jmp) 0)))) 
     'ADD (instruction 2 (λ (a b) (+ a b))) 
     'SUBTRACT (instruction 2 (λ (a b) (- a b))) 
     'MULTIPLY (instruction 2 (λ (a b) (* a b))) 
     'DIVIDE (instruction 2 (λ (a b) (quotient a b)))
     'MODULO (instruction 2 (λ (a b) (modulo a b)))
     'ABS (instruction 1 (λ (a) (abs a)))
     'EQUAL? (instruction 2 (λ (a b) (if (equal? a b) 1 0)))
     'LESS? (instruction 2 (λ (a b) (if (< a b) 1 0)))
     'GREATER? (instruction 2 (λ (a b) (if (> a b) 1 0)))
     'OR (instruction 2 (λ (a b) (if (zero? a) b a))) ;these aren't quite right, need to make b not even run if a is true
     'AND (instruction 2 (λ (a b) (if (zero? a) a b))) ; need to make b not even run if a is false
     'NOT (instruction 1 (λ (a) (if (zero? a) 1 0))) 
     'INNUM (instruction 0 (λ () (let loop ([in (read)])
                                   (if (number? in) in (loop (read))))))
     'INCHAR (instruction 0 (λ () (char->integer (read-char))))
     'OUTNUM (instruction 1 (λ (a) (display a) a)) 
     'OUTCHAR (instruction 1 (λ (a) (display (integer->char a)) a))
     'RAND (instruction 1 (λ (a) (* (random (add1 (abs a)))
                                    (if (negative? a) -1 1))))
     'EXIT (instruction 0 (λ () (kill-thread theprocess)))
     'NOP (instruction 0 (λ () 0))
     ))
  (define (inst-ref symbol)
    (if (number? symbol)
        (instruction 0 (λ () symbol))
        (hash-ref instruction-ht symbol)))
  
  (define (get-result prog)
    (let* ([inst (inst-ref (vector-ref prog idx))]
           [argc (instruction-argc inst)]
           [code (instruction-code inst)])
      (set! idx (add1 idx))
      (cond [(zero? argc)
             (code)]
            [(equal? argc 1)
             (apply code (list (get-result prog)))]
            [(equal? argc 2)
             (apply code (list (get-result prog) (get-result prog)))])))
  
  (define theprocess (thread (λ () (let loop ()
                                     (unless (equal? idx (vector-length prog))
                                       (get-result prog)
                                       (loop))
                                     (kill-thread theprocess)))))
  
  (thread-wait theprocess))



(define test-prog '#(OUTNUM ADD LITERAL 4 LITERAL 5
                            OUTCHAR LITERAL 10
                            OUTCHAR ADD OUTNUM LITERAL 6 MULTIPLY LITERAL 25 LITERAL 389
                            EXIT))

(define hello 
  '#(ASSIGN GOTO NOP ADD MULTIPLY MULTIPLY LITERAL 2 LITERAL 2 LITERAL 2 MULTIPLY LITERAL 10 LITERAL 10
     ASSIGN LITERAL 1 ADD VALUE GOTO NOP LITERAL 3
     OUTCHAR SUBTRACT ADD MULTIPLY LITERAL 2 MULTIPLY LITERAL 5 LITERAL 2 DIVIDE VALUE LITERAL 0 LITERAL 2 LITERAL 2
     OUTCHAR SUBTRACT VALUE LITERAL 1 MULTIPLY LITERAL 2 LITERAL 5
     OUTCHAR OUTCHAR VALUE LITERAL 0
     ASSIGN LITERAL 1 SUBTRACT OUTCHAR VALUE 1 ADD LITERAL 1 MULTIPLY SUBTRACT VALUE LITERAL 1 VALUE NOP LITERAL 4
     OUTCHAR ADD ASSIGN VALUE GOTO NOP MULTIPLY MULTIPLY LITERAL 2 LITERAL 2 ADD DIVIDE VALUE LITERAL 1 LITERAL 10 LITERAL 1 LITERAL 4
     ASSIGN VALUE LITERAL 0 ADD OUTCHAR SUBTRACT VALUE VALUE LITERAL 0 LITERAL 8 MULTIPLY LITERAL 3 LITERAL 4
     OUTCHAR ADD VALUE LITERAL 0 ADD LITERAL 5 LITERAL 6
     OUTCHAR ADD VALUE NOP LITERAL 3
     OUTCHAR ADD MULTIPLY LITERAL 2 LITERAL 3 VALUE NOP
     OUTCHAR VALUE NOP
     OUTCHAR MULTIPLY LITERAL 10 LITERAL 10
     OUTCHAR SUBTRACT VALUE VALUE NOP ADD ADD LITERAL 3 LITERAL 4 LITERAL 4))

(define cat '#(LABEL NOP OUTCHAR INCHAR GOTO NOP))
