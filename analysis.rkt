#lang racket
(require "readsentence.rkt")
(require "stats.rkt")
(require "ratios.rkt")
(require "clean.rkt")
(require racket/vector)
(require "db.rkt")

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
  (call-with-input-file filename
    (λ (file)
      (add-to-db file filename))))

(define (sentence-for-cmd cmd)
  (set! lastcmd cmd)
  (string-join
   (let ([ls (if (equal? cmd 'NOP) (sentences-matching-no-ratio)
                 (sentences-with-ratio (cmd->ratio cmd)))])
     (list-ref ls (random (length ls))))
   " "))
(define (sentence-for-lit lit)
  (set! lastcmd lit)
  (string-join
   (let ([ls (sentences-with-literal lit)])
     (list-ref ls (random (length ls))))
   " "))

(define (again)
  (when lastcmd (if (number? lastcmd) (sentence-for-lit lastcmd)
                    (sentence-for-cmd lastcmd))))

(define (s cmd)
  (sentence-for-cmd cmd))
(define (l lit)
  (sentence-for-lit lit))
(define (a)
  (again))

#;(define thethreads (map (λ (fn) (thread (λ () (read-file-in fn))))
                        '(;"sentences/alice.txt"
                          "sentences/kampf.txt"
                          "sentences/grimm.txt"
                          "sentences/peterpan.txt"
                          "sentences/mobydick.txt"
                          "sentences/marktwain.txt"
                          "sentences/raven.txt"
                          "sentences/originofspecies.txt"
                          "sentences/bible.txt"
                          "sentences/illiad.txt"
                          "sentences/warandpeace.txt"
                          )))
#;(define counterthread
  (thread (λ ()
            (let loop ([counter 0])
              (if (andmap thread-dead? thethreads)
                  (display (~a "\n!!!FINISHED READING IN "counter" SECONDS!!!\n"))
                  (begin (sleep 1)
                         (loop (+ 1 counter))))))))