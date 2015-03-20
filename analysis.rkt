#lang racket
(require "readsentence.rkt")
(require "stats.rkt")
(require "ratios.rkt")
(require "clean.rkt")
(require racket/vector)
(require "db.rkt")

(provide sentence-for-cmd sentence-for-lit)

(define lastcmd #f)

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
  (call-with-input-file (~a "sentences/"filename)
    (λ (file)
      (add-to-db file filename))))

(define (sentence-for-cmd cmd)
  (set! lastcmd cmd)
  (if (equal? cmd 'NOP) (sentences-matching-no-ratio)
      (sentences-with-ratio (cmd->ratio cmd))))
(define (sentence-for-lit lit)
  (set! lastcmd lit)
  (sentences-with-literal lit))

(define (again)
  (when lastcmd (if (number? lastcmd) (sentence-for-lit lastcmd)
                    (sentence-for-cmd lastcmd))))

(define (s cmd)
  (sentence-for-cmd cmd))
(define (l lit)
  (sentence-for-lit lit))
(define (a)
  (again))

(define (do-some-database-stuff)
  (define thethreads (map (λ (fn) (thread (λ () (read-file-in fn))))
                          '("alice.txt"
                            "kampf.txt"
                            "grimm.txt"
                            "peterpan.txt"
                            "mobydick.txt"
                            "marktwain.txt"
                            "raven.txt"
                            "originofspecies.txt"
                            "bible.txt"
                            "illiad.txt"
                            "warandpeace.txt")))
  (define counterthread
    (thread (λ ()
              (let loop ([counter 0])
                (if (andmap thread-dead? thethreads)
                    (display (~a "\n!!!FINISHED READING IN "counter" SECONDS!!!\n"))
                    (begin (sleep 1)
                           (loop (+ 1 counter))))))))
  (thread-wait counterthread))