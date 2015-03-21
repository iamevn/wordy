#lang racket/gui
(require "analysis.rkt")
(require "db.rkt")
(require "ratios.rkt")

(define args (current-command-line-arguments))
;; dialog to enter a line number
(define (valid-line-num-in-field field)
  ;if field is anumber
  (string->number (send field get-value)))
(define dialog-submitted #f)
(define line-num-dialog
  (new dialog%
       [label "line number..."]))
(define line-num-entry-field
  (new text-field%
       [label "Line number: "]
       [parent line-num-dialog]))
(define line-num-buttons
  (new horizontal-panel%
       [parent line-num-dialog]
       [alignment '(center center)]))
(define line-num-dialog-ok
  (new button%
       [label "okay"]
       [parent line-num-buttons]
       [callback (λ (b e) (when (valid-line-num-in-field line-num-entry-field) 
                            (send line-num-dialog show #f) 
                            (set! dialog-submitted #t)))]))
(define line-num-dialog-cancel
  (new button%
       [label "cancel"]
       [parent line-num-buttons]
       [callback (λ (b e) (send line-num-dialog show #f))]))

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
(define save-item
  (new menu-item%
       [label "&save text"]
       [parent file-menu]
       [callback (λ (m e) (send frame set-status-text "saving...")
                   (save-text)
                   (send frame set-status-text "saved!"))]))
#;(define open-item
    (new menu-item%
         [label "&open text"]
         [parent file-menu]
         [callback (λ (m e) (send frame set-status-text "not implemented!"))]))
#;(define save-wimp-item
    (new menu-item%
         [label "save pseudocode"]
         [parent file-menu]
         [callback (λ (m e) (send frame set-status-text "not implemented!"))]))
(define open-wimp-item
  (new menu-item%
       [label "open pseudocode"]
       [parent file-menu]
       [callback (λ (m e) (send frame set-status-text "opening...")
                   (open-wimpmode)
                   (send frame set-status-text "opened!"))]))
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
(define generate-all-item
  (new menu-item%
       [label "&generate sentences"]
       [parent lines-menu]
       [callback (λ (m e) (send frame set-status-text "generating...")
                   (map (λ (r) (send r generate-sentence)) rows)
                   (send frame set-status-text "generated!"))]))
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
                   (send line-num-entry-field set-value "")
                   (set! dialog-submitted #f)
                   (send line-num-entry-field focus)
                   (send line-num-dialog show #t)
                   (when dialog-submitted (add-row (string->number (send line-num-entry-field get-value))))
                   )]))
(define del-line-num-item
  (new menu-item%
       [label "delete line number..."]
       [parent lines-menu]
       [callback (λ (m e) (send frame set-status-text "deleting line number...")
                   (send line-num-entry-field set-value "")
                   (set! dialog-submitted #f)
                   (send line-num-entry-field focus)
                   (send line-num-dialog show #t)
                   (when dialog-submitted (delete-row (string->number (send line-num-entry-field get-value))))
                   )]))
;; panel containing rows of lines
(define panel
  (new vertical-panel%
       [parent frame]
       [style '(auto-vscroll)]))
;; a row
(define row%
  (class horizontal-panel%
    (init-field n)
    (super-new)
    (public increment-row decrement-row get-row generate-sentence set-to-instruction set-to-literal get-text)
    (define (increment-row)
      (set! n (add1 n))
      (refresh-line-num))
    (define (decrement-row)
      (set! n (sub1 n))
      (refresh-line-num))
    (define (get-row)
      n)
    (define (generate-sentence)
      (let* ([cmd (string->symbol (send instruction-choice get-string-selection))]
             [lit (string->number (send literal-input get-value))]
             [sen (if (zero? (send radio-choice get-selection)) 
                      (sentence-for-cmd cmd)
                      (sentence-for-lit lit))])
        (send text set-value sen)
        (send text focus)))
    (define (refresh-line-num)
      (send line-num set-label (~a n": ")))
    (define (get-text)
      (send text get-value))
    
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
            (λ (b e)
              (generate-sentence))]))
    (define radio-choice
      (new radio-box%
           [label #f]
           [parent this]
           [choices '("instruction" "literal")]))
    (define instruction-choice
      (new choice%
           [label #f]
           [choices '("NOP" "ASSIGN" "VALUE" "LITERAL"
                            "LABEL" "GOTO"
                            "ADD" "SUBTRACT" "MULTIPLY" "DIVIDE" "MODULO" "ABS"
                            "EQUAL?" "LESS?" "GREATER?"
                            "OR" "AND" "NOT"
                            "INNUM" "INCHAR" "OUTNUM" "OUTCHAR"
                            "RAND" "EXIT")]
           [parent this]))
    (define literal-input
      (new text-field%
           [label #f]
           [parent this]
           [min-width 60]
           [stretchable-width #f]))
    
    (define (set-to-instruction inst)
      (send radio-choice set-selection 0)
      (send instruction-choice set-string-selection (symbol->string inst)))
    (define (set-to-literal lit)
      (send radio-choice set-selection 1)
      (send literal-input set-value (~a lit)))))
;; list of rows
(define num-rows 10)
(define rows (map (λ (n) (new row% [parent panel] [n n])) (build-list num-rows values)))
(send frame show #t)

;add a row with line number n
(define (add-row n)
  (if (or (< n 0) (> n num-rows)) (send frame set-status-text (~a "Can't add row "n))
      (begin
        ;every row with a line number greater-than or equal to n gets its line number incremented
        (map (λ (row) (send row increment-row) )
             (filter (λ (row) (>= (send row get-row) n))
                     rows))
        ;add the row
        (set! num-rows (add1 num-rows))
        (set! rows (sort (cons (new row% [parent panel] [n n]) rows)
                         < #:key (λ (row) (send row get-row))))
        ;tell the panel to resort its children
        (send panel change-children (λ (c) rows)))))
;delete row with line number n
(define (delete-row n)
  (if (or (< n 0) (>= n num-rows)) (send frame set-status-text (~a "Can't delete row "n))
      (begin
        ;remove the row
        (set! rows (remove n rows (λ (n row) (equal? n (send row get-row)))))
        ;every row with line number greater-than n gets its line number decremented
        (map (λ (row) (send row decrement-row))
             (filter (λ (row) (> (send row get-row) n))
                     rows))
        (send panel change-children (λ (c) rows))
        (set! num-rows (sub1 num-rows)))))

(define (save-text)
  (let ([fn (put-file)])
    (when fn 
      (call-with-output-file fn
        (λ (f) (let loop ([rows rows])
                 (unless (null? rows)
                   (display (send (car rows) get-text) f)
                   (display "\n" f)
                   (loop (cdr rows)))))))))

(define (open-wimpmode)
  (let ([fn (get-file)])
    (when fn (call-with-input-file fn
               (λ (f)
                 (set-rows-to (let loop ([symbol (read f)])
                                (if (eof-object? symbol) '()
                                    (cons symbol (loop (read f)))))))))))
(define (set-rows-to ls)
  (let ([len (length ls)])
    (set! rows (map (λ (n) (new row% [parent panel] [n n])) (build-list len values)))
    (send panel change-children (λ (c) rows))
    (let loop ([i 0] [rows rows] [ls ls])
      (unless (null? ls) (if (number? (car ls)) (send (car rows) set-to-literal (car ls))
                             (send (car rows) set-to-instruction (car ls)))
        (loop (add1 i) (cdr rows) (cdr ls))))))