#lang racket

(provide read-sentence read-word)

(define (read-sentence file)
  (if (eof-object? (peek-char file)) #f
    (let loop ([ls '()] [word (read-word file)])
      (cond [(not word) #f]
            [(eos? word) (reverse
                           (cons (substring word 0
                                            (sub1 (string-length word)))
                                 ls))]
            [else (loop (cons word ls) (read-word file))]))))

(define (eos? word)
  (equal? #\. (string-ref word (sub1 (string-length word)))))

(define (read-word file)
  (let loop ([next-char (read-char file)]
             [word '()])
    (cond
      ;reached eof
      [(eof-object? next-char) #f]
      ;have yet to hit the start of a word
      [(and (null? word)
            (not (char-alphabetic? next-char))
            (not (char-numeric? next-char)))
       (loop (read-char file) word)]
      ;at the end of a word
      [(and (not (or (char-alphabetic? next-char)
                     (char-numeric? next-char)))
            (char-whitespace? next-char))
       (list->string (reverse word))]
      ;at the end of the sentence
      [(equal? #\. next-char)
       (list->string (reverse (cons next-char word)))]
      ;skip over symbols
      [(not (or (char-alphabetic? next-char)
                (char-numeric? next-char)))
       (loop (read-char file) word)]
      ;char to add to the word
      [else
        (loop (read-char file) (cons next-char word))])))
