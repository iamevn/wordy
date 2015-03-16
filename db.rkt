#lang racket
(require db)
(require racket/string)
(require "ratios.rkt")
(provide db-add sentences-with-literal sentences-with-ratio close-connection)

;(struct ratio (top bot) #:transparent)
(define (connect)
  (mysql-connect #:server "localhost"	 	 	 	 
                 #:database "wordy"	 	 	 	 
                 #:user "wordy"
                 #:password "wordy"))
(define connection (connect))

(define (db-add ratio literal sentence [source #f])
  (let ([str (string-join sentence " ")])
    (unless (connected? connection) (set! connection (connect)))
    (add-literal literal str source)
    (add-ratio ratio str source)))

(define (add-literal literal str source)
  (if source
      (query-exec connection
                  "INSERT INTO literals (literal, sentence, source) VALUES (?, ?, ?);"
                  literal
                  str
                  source)
      (query-exec connection 
                  "INSERT INTO literals (literal, sentence) VALUES (?, ?);"
                  literal
                  str)))

(define (add-ratio ratio str source)
  (if source 
      (query-exec connection
                  "INSERT INTO ratios (top, bot, sentence, source) VALUES (?, ?, ?, ?);"
                  (ratio-top ratio)
                  (ratio-bot ratio)
                  str
                  source)
      (query-exec connection
                  "INSERT INTO ratios (top, bot, sentence) VALUES (?, ?, ?);"
                  (ratio-top ratio)
                  (ratio-bot ratio)
                  str)))

(define (sentences-with-literal literal)
  (map (λ (v) (string-split (vector-ref v 0)))
       (query-rows connection
                   "SELECT sentence FROM literals WHERE literal = ?;"
                   literal)))

(define (sentences-with-ratio ratio)
  (map (λ (v) (string-split (vector-ref v 0)))
       (query-rows connection
                   "SELECT sentence FROM ratios WHERE top = ? AND bot = ?;"
                   (ratio-top ratio)
                   (ratio-bot ratio))))

(define (close-connection)
  (disconnect connection))