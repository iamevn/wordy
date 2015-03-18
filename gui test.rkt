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
       [callback (λ (m e) (refresh-cache))]))
(define exit-item
  (new menu-item%
       [label "&exit"]
       [parent file-menu]
       [callback (λ (m e) (send frame set-status-text "exit clicked"))]))

(define lines-menu
  (new menu%
       [label "&Lines"]
       [parent menu-bar]))
(define add-line-item
  (new menu-item%
       [label "&add line"]
       [parent lines-menu]
       [callback (λ (m e) (send frame set-status-text "adding a line"))]))
(define del-line-item
  (new menu-item%
       [label "&delete line"]
       [parent lines-menu]
       [callback (λ (m e) (send frame set-status-text "deleting a line"))]))
(define add-line-before-num-item
  (new menu-item%
       [label "add a line before line number..."]
       [parent lines-menu]
       [callback (λ (m e) (send frame set-status-text "adding a line before..."))]))
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
  (class horizontal-pane%
    (init n)
    (super-new)
    (define (generate-sentence)
      (let* ([cmd (string->symbol (send choice get-string-selection))]
             [sen (sentence-for-cmd cmd)])
        (send text set-value sen)))
    (define text
      (new text-field%
           [label (~a n": ")]
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
(define rows (map (λ (n) (new row% [parent panel] [n n])) (build-list 10 values)))
(send frame show #t)