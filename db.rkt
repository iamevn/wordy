#lang racket
(require db)
(require racket/string)
(require "ratios.rkt")
(provide db-add sentences-with-literal sentences-with-ratio sentences-matching-no-ratio close-connection refresh-cache)

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
    (add-ratio ratio str source)
    #;(disconnect connection)))

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
  (unless (connected? connection) (set! connection (connect)))
  (let* ([ht-sen (hash-ref literal-ht literal #f)]
         [db-sen (if ht-sen #f
                     (map (λ (v) (string-split (vector-ref v 0)))
                          (query-rows connection
                                      "SELECT sentence FROM literals WHERE literal = ?;"
                                      literal)))])
    (cond [ht-sen ht-sen]
          [db-sen (hash-set! literal-ht literal db-sen)
                  db-sen]
          [else #f])))

(define (sentences-with-ratio ratio)
  (unless (connected? connection) (set! connection (connect)))
  (let* ([ht-sen (hash-ref ratio-ht ratio #f)]
         [db-sen (if ht-sen #f
                     (map (λ (v) (string-split (vector-ref v 0)))
                          (query-rows connection
                                      "SELECT sentence FROM ratios WHERE top = ? AND bot = ?;"
                                      (ratio-top ratio)
                                      (ratio-bot ratio))))])
    (cond [ht-sen ht-sen]
          [db-sen (hash-set! ratio-ht ratio db-sen)
                  db-sen]
          [else #f])))

(define (sentences-matching-no-ratio)
  (unless (connected? connection) (set! connection (connect)))
  (let* ([ht-sen (hash-ref ratio-ht -1 #f)]
         [db-sen (if ht-sen #f
                     (map (λ (v) (string-split (vector-ref v 0)))
                          (query-rows connection
                                      "SELECT sentence FROM ratios WHERE NOT ((top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?) OR (top = ? AND bot = ?));"
                                      13 7 
                                      2 3 
                                      0 1 
                                      2 1 
                                      1 1 
                                      1 2 
                                      5 9 
                                      3 4 
                                      4 1 
                                      1 4 
                                      2 9 
                                      1 5 
                                      7 3 
                                      9 5 
                                      11 17 
                                      13 3 
                                      5 13 
                                      4 7 
                                      5 2 
                                      15 14 
                                      3 7 
                                      1 0 
                                      5 3)))])
    (cond [ht-sen ht-sen]
          [db-sen (hash-set! ratio-ht -1 db-sen)
                  db-sen]
          [else #f])))

(define (close-connection)
  (disconnect connection))

(define ratio-ht (make-hash))
(define literal-ht (make-hash))
(define (refresh-cache)
  (set! ratio-ht (make-hash))
  (set! literal-ht (make-hash)))