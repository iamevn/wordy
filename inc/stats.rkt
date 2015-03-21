#lang racket
(provide stats ss-over ss-under ss-avg ss-lit ss-len)
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
(define (ss-over ss)
  (statstruct-over ss))
(define (ss-under ss)
  (statstruct-under ss))
(define (ss-avg ss)
  (statstruct-avg ss))
(define (ss-lit ss)
  (statstruct-lit ss))
(define (ss-len ss)
  (statstruct-len ss))