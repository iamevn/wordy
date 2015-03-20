#lang racket/gui
(require "analysis.rkt")
(require "db.rkt")
(require "ratios.rkt")

(define args (current-command-line-arguments))

;; root window
(define frame 
  (new frame%
       [label "maybe one day this will grow into an ide..."]
       [min-width 160]
       [min-height 400]))
(send frame create-status-line)
;; menu bar
(define menu-bar
  (new menu-bar%
       [parent frame]))
;; menu items
(define file-menu
  (new menu%
       [label "&File"]
       [parent menu-bar]))
(define chache-refresh-item
  (new menu-item%
       [label "&refresh cache"]
       [parent file-menu]
       [callback (λ (m e) (send frame set-status-text "refreshing cache")
                   (refresh-cache))]))
(define exit-item
  (new menu-item%
       [label "&exit"]
       [parent file-menu]
       [callback (λ (m e) (send frame set-status-text "exit clicked")
                   (exit))]))

(define lines-menu
  (new menu%
       [label "&Lines"]
       [parent menu-bar]))
(define add-line-item
  (new menu-item%
       [label "&add line"]
       [parent lines-menu]
       [callback (λ (m e) (send frame set-status-text "adding a line")
                   (add-row num-rows))]))
(define del-line-item
  (new menu-item%
       [label "&delete line"]
       [parent lines-menu]
       [callback (λ (m e) (send frame set-status-text "deleting a line")
                   (delete-row (sub1 num-rows)))]))
(define add-line-before-num-item
  (new menu-item%
       [label "add a line before line number..."]
       [parent lines-menu]
       [callback (λ (m e) (send frame set-status-text "adding a line before...")
                   )]))
(define del-line-num-item
  (new menu-item%
       [label "delete line number..."]
       [parent lines-menu]
       [callback (λ (m e) (send frame set-status-text "deleting line number..."))]))
;; panel containing rows of lines
(define panel
  (new vertical-panel%
       [parent frame]
       [style '(vscroll)]))
;; a row
(define row%
  (class horizontal-panel%
    (init-field n)
    (super-new)
    (public increment-row decrement-row get-row)
    (define (increment-row)
      (set! n (add1 n))
      (refresh-line-num))
    (define (decrement-row)
      (set! n (sub1 n))
      (refresh-line-num))
    (define (get-row)
      n)
    (define (generate-sentence)
      (let* ([cmd (string->symbol (send choice get-string-selection))]
             [sen (sentence-for-cmd cmd)])
        (send text set-value sen)))
    (define (refresh-line-num)
      (send line-num set-label (~a n": ")))
    (define line-num
      (new message%
           [label (~a n": ")]
           [parent this]))
    (define text
      (new text-field%
           [label #f]
           [parent this]))
    (define generate-button
      (new button%
           [label "generate"]
           [parent this]
           [callback
            (λ (B e)
              (generate-sentence))]))
    (define choice
      (new choice%
           [label #f]
           [choices '("NOP" "ASSIGN" "VALUE" "LITERAL"
                            "LABEL" "GOTO"
                            "ADD" "SUBTRACT" "MULTIPLY" "DIVIDE" "MODULO" "ABS"
                            "EQUAL?" "LESS?" "GREATER?"
                            "OR" "AND" "NOT"
                            "INNUM" "INCHAR" "OUTNUM" "OUTCHAR"
                            "RAND" "EXIT"
                            )]
           [parent this]))))
;; list of rows
(define num-rows 10)
(define rows (map (λ (n) (new row% [parent panel] [n n])) (build-list num-rows values)))
(send frame show #t)

;add a row with line number n
(define (add-row n)
  ;every row with a line number greater-than or equal to n gets its line number incremented
  (map (λ (row) (send row increment-row) )
       (filter (λ (row) (>= (send row get-row) n))
               rows))
  ;add the row
  (set! num-rows (add1 num-rows))
  (set! rows (sort (cons (new row% [parent panel] [n n]) rows)
                   < #:key (λ (row) (send row get-row))))
  ;tell the panel to resort its children
  (send panel change-children (λ (c) rows)))
;delete row with line number n
(define (delete-row n)
  ;remove the row
  (set! rows (remove n rows (λ (n row) (equal? n (send row get-row)))))
  ;every row with line number greater-than n gets its line number decremented
  (map (λ (row) (send row decrement-row))
       (filter (λ (row) (> (send row get-row) n))
               rows))
  (send panel change-children (λ (c) rows))
  (set! num-rows (sub1 num-rows)))