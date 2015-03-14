#lang racket
#|
(define sen1 '("Honestly" "this" "is" "very" "easy" "much" "more" "simple" "than" "some"))
(define sen2 '("It" "is" "named" "after" "the" "Unix" "command" "cat" "although" "this" "command" "is" "actually" "more" "powerful"))
(define sen3 '("In" "the" "beginning" "there" "was" "no" "sense" "of" "heuristic" "algorithms" "with" "which" "they" "wrote" ))
(define sen4 '("Weirdly" "thruvian" "melodics" "are" "not" "terribly" "complex"))
(define sen5 '("This" "is" "harder" "than" "I" "thought"))
(define sen6 '("Cats" "are" "fluffy" "but" "dont" "fuck" "with" "them" "unless" "youre" "ready" "for" "the" "consequences"))
|#

(define (eos? word)
  (eq? #\. (string-ref word (sub1 (string-length word)))))

(define (get-sentence)
  (let loop ([ls '()]
             [next (symbol->string (read))])
    (if (or (eos? next) (eqv? next eof))
        (reverse (cons (substring next 0 (- (string-length next) 1))
                       ls))
        (loop (cons next ls)
              (symbol->string (read))))))

(define (avg sen)
  (round (/ (foldl + 0 (map string-length sen))
            (length sen))))

(define (over sen)
  (length (filter (λ (n) (> n (avg sen))) 
                  (map string-length sen))))

(define (under sen)
  (length (filter (λ (n) (< n (avg sen))) 
                  (map string-length sen))))

(define (lit sen)
  (length (filter (λ (n) (eq? n (avg sen))) 
                  (map string-length sen))))

(struct statstruct (over under avg lit len) #:transparent)
(define (stats sen)
  (statstruct (over sen)
              (under sen)
              (avg sen)
              (lit sen)
              (length sen)))

(define (print-stats s)
  (display (~a "avg "(statstruct-avg s)
               ", above "(statstruct-over s)
               ", below "(statstruct-under s)
               ", exact "(statstruct-lit s)"\n")))

(define (s)
  (print-stats (stats (get-sentence))))
