#lang racket
(require "readsentence.rkt")
(require "stats.rkt")
(require "ratios.rkt")
(require "clean.rkt")
(require racket/vector)
(require "db.rkt")

(define (add-to-db file [source #f])
  (let loop ([sen (read-sentence file)])
    (when sen
      (let* ([clean-sen (clean sen)]
             [sen-stats (stats clean-sen)])
        (db-add (simplify-ratio (ratio (ss-over sen-stats)
                                       (ss-under sen-stats)))
                (ss-lit sen-stats)
                sen
                source)
        (loop (read-sentence file))))))

(define (read-file-in filename)
  (call-with-input-file filename
    (λ (file)
      (add-to-db file filename)))
  (close-connection))