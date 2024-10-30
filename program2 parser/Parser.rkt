#lang racket

(require parser-tools/lex
         (prefix-in : parser-tools/lex-sre)
         racket/string)

;; Structures for tokens and AST nodes
(struct token (type value) #:transparent)
(struct ast-node (type children) #:transparent)

;; Scanner function
(define (tokenize input-text)
  (let ([port (open-input-string input-text)])
    (port-count-lines! port)
    (let loop ([tokens '()])
      (let ([next-token (scan-token port)])
        (if (token? next-token)
            (if (eq? (token-type next-token) 'EOF)
                (reverse tokens)
                (loop (cons next-token tokens)))
            (reverse tokens))))))

;; Scanner for individual tokens
(define (scan-token port)
  (let loop ()
    (let ([c (read-char port)])
      (cond
        [(eof-object? c) (token 'EOF "EOF")]
        [(char-whitespace? c) 
         (if (char=? c #\newline)
             (token 'newline "\n")
             (loop))]
        [(char=? c #\:) 
         (let ([next (peek-char port)])
           (if (char=? next #\=)
               (begin (read-char port)
                      (token 'assign ":="))
               (token 'colon ":")))]
        [(char=? c #\<) 
         (let ([next (peek-char port)])
           (cond
             [(char=? next #\=) 
              (read-char port)
              (token 'op "<=")]
             [(char=? next #\>) 
              (read-char port)
              (token 'op "<>")]
             [else (token 'op "<")]))]
        [(char=? c #\>) 
         (let ([next (peek-char port)])
           (cond
             [(char=? next #\=) 
              (read-char port)
              (token 'op ">=")]
             [(char=? next #\<) 
              (read-char port)
              (token 'op "><")]
             [else (token 'op ">")]))]
        [(char=? c #\=) (token 'op "=")]
        [(char=? c #\+) (token 'plus "+")]
        [(char=? c #\-) (token 'minus "-")]
        [(char=? c #\*) (token 'times "*")]
        [(char=? c #\/) (token 'div "/")]
        [(char=? c #\() (token 'lparen "(")]
        [(char=? c #\)) (token 'rparen ")")]
        [(char=? c #\;) (token 'semicolon ";")]
        [(char=? c #\,) (token 'comma ",")]
        [(char=? c #\") (scan-string port)]
        [(char-numeric? c) (scan-number port c)]
        [(char=? c #\R) 
         (let ([next (peek-char port)])
           (if (and (char=? next #\E)
                   (begin 
                     (read-char port)
                     (char=? (peek-char port) #\M))
                   (begin
                     (read-char port)
                     (or (eof-object? (peek-char port))
                         (char-whitespace? (peek-char port)))))
               (scan-rem port)
               (scan-identifier port c)))]
        [(char-alphabetic? c) (scan-identifier port c)]
        [else (error (format "Invalid character: ~a" c))]))))

;; Scanner helper functions
(define (scan-rem port)
  (let loop ([comment-chars '()])
    (let ([c (read-char port)])
      (cond
        [(or (eof-object? c) (char=? c #\newline))
         (token 'keyword 
                (string-append "REM " (list->string (reverse comment-chars))))]
        [else (loop (cons c comment-chars))]))))

(define (scan-string port)
  (let loop ([chars '()])
    (let ([c (read-char port)])
      (cond
        [(eof-object? c) (error "Unterminated string")]
        [(char=? c #\") (token 'string (list->string (reverse chars)))]
        [else (loop (cons c chars))]))))

(define (scan-number port first-char)
  (let loop ([chars (list first-char)] [saw-dot #f])
    (let ([c (peek-char port)])
      (cond
        [(and (char=? c #\.) (not saw-dot))
         (read-char port)
         (loop (cons c chars) #t)]
        [(and (char? c) (char-numeric? c))
         (read-char port)
         (loop (cons c chars) saw-dot)]
        [else
         (token (if saw-dot 'real 'num) 
                (list->string (reverse chars)))]))))

(define (scan-identifier port first-char)
  (let loop ([chars (list first-char)])
    (let ([c (peek-char port)])
      (if (and (char? c) (or (char-alphabetic? c) (char-numeric? c)))
          (begin
            (read-char port)
            (loop (cons c chars)))
          (let ([id (string-upcase (list->string (reverse chars)))])
            (cond
              [(member id '("REM" "END" "DEF" "ENDDEF" "IF" "THEN" "ENDIF" 
                          "WHILE" "DO" "ENDWHILE" "PRINT" "RETURN"
                          "OR" "AND" "NOT"))
               (token 'keyword id)]
              [else (token 'id id)]))))))

;; Parser implementation
(define (parse tokens)
  (let ([current 0])
    
    ;; Parser helper functions
    (define (peek [offset 0])
      (if (< (+ current offset) (length tokens))
          (list-ref tokens (+ current offset))
          (token 'EOF "EOF")))
    
    (define (advance)
      (when (< current (length tokens))
        (set! current (add1 current))
        (list-ref tokens (sub1 current))))
    
    (define (expect type msg)
      (let ([tok (peek)])
        (if (eq? (token-type tok) type)
            (advance)
            (error (format "~a: expected ~a, got ~a" 
                         msg type (token-type tok))))))
    
    ;; Main parsing functions
    (define (parse-program)
      (let loop ([statements '()])
        (if (eq? (token-type (peek)) 'EOF)
            (ast-node 'PROGRAM (reverse statements))
            (let ([stmt (parse-line)])
              (loop (cons stmt statements))))))
    
    (define (parse-line)
      (let ([stmts (parse-statements)])
        (expect 'newline "Expected newline")
        stmts))
    
    (define (parse-statements)
      (let ([stmt (parse-statement)])
        (if (eq? (token-type (peek)) 'colon)
            (begin
              (advance) ; consume colon
              (ast-node 'STMTS (cons stmt (parse-statements))))
            (ast-node 'STMTS (list stmt)))))

    ;; Statement parsing functions
    (define (parse-statement)
      (let ([tok (peek)])
        (case (token-type tok)
          [(keyword)
           (case (token-value tok)
             [("DEF") (parse-def)]
             [("ENDDEF") (begin (advance) (ast-node 'ENDDEF '()))]
             [("END") (begin (advance) (ast-node 'END '()))]
             [("IF") (parse-if)]
             [("WHILE") (parse-while)]
             [("PRINT") (parse-print)]
             [("RETURN") (parse-return)]
             [("REM") (begin (advance) 
                            (ast-node 'REM (list (token-value tok))))]
             [else (error (format "Unexpected keyword: ~a" 
                                (token-value tok)))])]
          [(id) (parse-id-statement)]
          [else (error (format "Unexpected token type: ~a" 
                             (token-type tok)))])))
    
    (define (parse-def)
      (advance) ; consume DEF
      (let* ([name (token-value (expect 'id "Expected function name"))]
             [_ (expect 'lparen "Expected '(' after function name")]
             [params (parse-id-list)]
             [_ (expect 'rparen "Expected ')' after parameters")])
        (ast-node 'DEF (list name params))))
    
    (define (parse-if)
      (advance) ; consume IF
      (let* ([condition (parse-expression)]
             [_ (expect 'keyword "Expected THEN")]
             [body (parse-statements)]
             [_ (expect 'keyword "Expected ENDIF")])
        (ast-node 'IF (list condition body))))
    
    (define (parse-while)
      (advance) ; consume WHILE
      (let* ([condition (parse-expression)]
             [_ (expect 'keyword "Expected DO")]
             [body (parse-statements)]
             [_ (expect 'keyword "Expected ENDWHILE")])
        (ast-node 'WHILE (list condition body))))
    
    ;; List parsing functions
    (define (parse-id-list)
      (let ([first-id (token-value (expect 'id "Expected identifier"))])
        (if (eq? (token-type (peek)) 'comma)
            (begin
              (advance)
              (cons first-id (parse-id-list)))
            (list first-id))))
    
    (define (parse-expression-list)
      (let ([expr (parse-expression)])
        (if (eq? (token-type (peek)) 'comma)
            (begin
              (advance)
              (cons expr (parse-expression-list)))
            (list expr))))
    
    (define (parse-print-list)
      (let ([expr (parse-expression)])
        (if (eq? (token-type (peek)) 'semicolon)
            (begin
              (advance)
              (cons expr (parse-print-list)))
            (list expr))))

    ;; Expression parsing functions
    (define (parse-expression)
      (let ([left (parse-and-exp)])
        (if (and (eq? (token-type (peek)) 'keyword)
                 (equal? (token-value (peek)) "OR"))
            (begin
              (advance)
              (ast-node 'OR (list left (parse-expression))))
            left)))
    
    (define (parse-and-exp)
      (let ([left (parse-not-exp)])
        (if (and (eq? (token-type (peek)) 'keyword)
                 (equal? (token-value (peek)) "AND"))
            (begin
              (advance)
              (ast-node 'AND (list left (parse-and-exp))))
            left)))
    
    (define (parse-not-exp)
      (if (and (eq? (token-type (peek)) 'keyword)
               (equal? (token-value (peek)) "NOT"))
          (begin
            (advance)
            (ast-node 'NOT (list (parse-compare-exp))))
          (parse-compare-exp)))
    
    (define (parse-compare-exp)
      (let ([left (parse-add-exp)])
        (let ([tok (peek)])
          (if (and (eq? (token-type tok) 'op)
                   (member (token-value tok) 
                          '("=" "<>" "><" ">" ">=" "<" "<=")))
              (begin
                (advance)
                (ast-node 'COMPARE 
                         (list left 
                               (token-value tok)
                               (parse-compare-exp))))
              left))))
    
    (define (parse-add-exp)
      (let ([left (parse-mult-exp)])
        (let ([tok (peek)])
          (if (member (token-type tok) '(plus minus))
              (begin
                (advance)
                (ast-node 'ADD
                         (list left
                               (token-value tok)
                               (parse-add-exp))))
              left))))
    
    (define (parse-mult-exp)
      (let ([left (parse-negate-exp)])
        (let ([tok (peek)])
          (if (member (token-type tok) '(times div))
              (begin
                (advance)
                (ast-node 'MULT
                         (list left
                               (token-value tok)
                               (parse-mult-exp))))
              left))))
    
    (define (parse-negate-exp)
      (if (eq? (token-type (peek)) 'minus)
          (begin
            (advance)
            (ast-node 'NEGATE (list (parse-value))))
          (parse-value)))
    
    (define (parse-value)
      (let ([tok (peek)])
        (case (token-type tok)
          [(lparen)
           (advance) ; consume (
           (let ([expr (parse-expression)])
             (expect 'rparen "Expected ')'")
             expr)]
          [(id)
           (advance)
           (if (eq? (token-type (peek)) 'lparen)
               (begin
                 (advance)
                 (let ([args (parse-expression-list)])
                   (expect 'rparen "Expected ')'")
                   (ast-node 'CALL (cons (token-value tok) args))))
               (ast-node 'ID (list (token-value tok))))]
          [(num real string)
           (advance)
           (ast-node 'CONSTANT (list (token-value tok)))]
          [else (error (format "Unexpected token in value: ~a" tok))])))
    
    (define (parse-print)
      (advance) ; consume PRINT
      (ast-node 'PRINT (parse-print-list)))
    
    (define (parse-return)
      (advance) ; consume RETURN
      (ast-node 'RETURN (list (parse-expression))))
    
    (define (parse-id-statement)
      (let ([id (token-value (advance))])
        (cond
          [(eq? (token-type (peek)) 'assign)
           (advance) ; consume :=
           (ast-node 'ASSIGN 
                    (list (ast-node 'ID (list id))
                          (parse-expression)))]
          [(eq? (token-type (peek)) 'lparen)
           (advance) ; consume (
           (let ([args (parse-expression-list)])
             (expect 'rparen "Expected ')'")
             (ast-node 'CALL (cons id args)))]
          [else (error "Expected := or ( after identifier")])))
    
    ;; Start parsing
    (parse-program)))

;; Helper function to format tokens for output
(define (format-token tok)
  (case (token-type tok)
    [(id) `(id ,(token-value tok))]
    [(string) `(string ,(token-value tok))]
    [(num) `(num ,(token-value tok))]
    [(real) `(real ,(token-value tok))]  ; Added real number formatting
    [(plus) `(plus ,(token-value tok))]
    [(minus) `(minus ,(token-value tok))]
    [(times) `(times ,(token-value tok))]
    [(div) `(div ,(token-value tok))]
    [(lparen) `(lparen ,(token-value tok))]
    [(rparen) `(rparen ,(token-value tok))]
    [(assign) `(assign ,(token-value tok))]
    [(colon) `(colon ,(token-value tok))]
    [(semicolon) `(semicolon ,(token-value tok))]
    [(comma) `(comma ,(token-value tok))]
    [(keyword) `(keyword ,(token-value tok))]
    [(op) `(op ,(token-value tok))]
    [(newline) `(newline "\n")]
    [else `(,(token-type tok) ,(token-value tok))]))

;; File reading and main processing functions remain the same
(define (read-file filename)
  (with-input-from-file filename
    (lambda ()
      (let loop ([lines '()]
                 [line (read-line)])
        (if (eof-object? line)
            (string-join (reverse lines) "\n")
            (loop (cons line lines)
                  (read-line)))))))

(define (process-file filename)
  (let* ([content (read-file filename)]
         [tokens (tokenize content)])
    (printf "Processing file: ~a\n" filename)
    (printf "Tokens:\n")
    (for-each (λ (tok) 
                (printf "~a\n" (format-token tok)))
              tokens)))

;; Export main functions
(provide tokenize format-token process-file read-file)

;; Test the scanner
(module+ main
  (define test-file "Fall24SampleCode.txt")
  (when (file-exists? test-file)
    (process-file test-file)))