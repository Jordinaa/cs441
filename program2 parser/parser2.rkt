#lang racket

; Define token and AST node structures
(struct token (type value line) #:transparent)
(struct ast-node (type value children) #:transparent)

; Helper function to preprocess input
(define (preprocess-input input)
  (string-trim input #:left? #t #:right? #t))

; Scanner - converts input string to list of tokens

(define (tokenize input-raw)
  (let* ([input (preprocess-input input-raw)]
         [tokens '()]
         [current-pos 0]
         [current-line 1])
    
    (define (current-char)
      (if (< current-pos (string-length input))
          (string-ref input current-pos)
          #false))
    
    (define (peek-next)
      (if (< (+ current-pos 1) (string-length input))
          (string-ref input (+ current-pos 1))
          #false))
    
    (define (advance)
      (when (char=? (current-char) #\newline)
        (set! current-line (+ current-line 1)))
      (set! current-pos (+ current-pos 1)))
    
    (define (add-token type [value #f])
      (set! tokens (cons (token type (or value (string (current-char))) current-line) tokens))
      (advance))
    
    (define (scan-number)
      (let loop ([num-str ""])
        (let ([char (current-char)])
          (cond
            [(and char (char-numeric? char))
             (advance)
             (loop (string-append num-str (string char)))]
            [(and char (char=? char #\.))
             (advance)
             (loop (string-append num-str "."))]
            [else
             (set! tokens 
                   (cons 
                    (token 
                     (if (string-contains? num-str ".") 'real 'number)
                     num-str 
                     current-line) 
                    tokens))]))))
    
    (define (scan-string)
      (advance) ; Skip opening quote
      (let loop ([str ""])
        (let ([char (current-char)])
          (cond
            [(not char) (error "Unterminated string")]
            [(char=? char #\") 
             (advance)
             (set! tokens (cons (token 'string str current-line) tokens))]
            [else
             (advance)
             (loop (string-append str (string char)))]))))
    
(define (scan-identifier)
  (let loop ([id-str ""])
    (let ([char (current-char)])
      (cond
        [(and char (or (char-alphabetic? char) (char-numeric? char)))
         (advance)
         (loop (string-append id-str (string char)))]
        [else
         (let ([lowercase-str (string-downcase id-str)])
           (set! tokens 
                 (cons 
                  (if (member lowercase-str 
                            '("print" "if" "then" "endif" 
                              "while" "do" "endwhile"
                              "def" "enddef" "end" "rem"
                              "return" "or" "and" "not"))
                      (token 'keyword lowercase-str current-line)
                      (token 'identifier lowercase-str current-line))
                  tokens)))]))))
    (define (scan-rem)
      (let loop ()
        (let ([char (current-char)])
          (cond
            [(or (not char) (char=? char #\newline))
             (when char (advance))]
            [else
             (advance)
             (loop)]))))
    
    ; Main scanning loop
    (let scan-loop ()
      (let ([char (current-char)])
        (when char
          (cond
            [(and (char-whitespace? char) (not (char=? char #\newline)))
             (advance)
             (scan-loop)]
            [(char=? char #\newline)
             (add-token 'newline "\n")
             (scan-loop)]
            [(char-numeric? char)
             (scan-number)
             (scan-loop)]
            [(char-alphabetic? char)
             (let ([start-str (string-upcase (string char))])
               (if (and (string=? start-str "R")
                       (peek-next)
                       (string=? (string-upcase (string (peek-next))) "E"))
                   (begin
                     (advance) (advance) ; Skip "RE"
                     (scan-rem)
                     (scan-loop))
                   (begin
                     (scan-identifier)
                     (scan-loop))))]
            [(char=? char #\") (scan-string) (scan-loop)]
            [(char=? char #\:)
             (if (char=? (peek-next) #\=)
                 (begin
                   (advance)
                   (advance)
                   (set! tokens (cons (token 'assign ":=" current-line) tokens)))
                 (add-token 'colon))
             (scan-loop)]
            [(char=? char #\;) (add-token 'semicolon) (scan-loop)]
            [(char=? char #\,) (add-token 'comma) (scan-loop)]
            [(char=? char #\+) (add-token 'plus) (scan-loop)]
            [(char=? char #\-) (add-token 'minus) (scan-loop)]
            [(char=? char #\*) (add-token 'multiply) (scan-loop)]
            [(char=? char #\/) (add-token 'divide) (scan-loop)]
            [(char=? char #\() (add-token 'lparen) (scan-loop)]
            [(char=? char #\)) (add-token 'rparen) (scan-loop)]
            [(char=? char #\=) (add-token 'equals) (scan-loop)]
            [(char=? char #\<) 
             (cond
               [(char=? (peek-next) #\=)
                (advance) (advance)
                (set! tokens (cons (token 'op "<=" current-line) tokens))]
               [(char=? (peek-next) #\>)
                (advance) (advance)
                (set! tokens (cons (token 'op "<>" current-line) tokens))]
               [else (add-token 'op "<")])
             (scan-loop)]
            [(char=? char #\>) 
             (cond
               [(char=? (peek-next) #\=)
                (advance) (advance)
                (set! tokens (cons (token 'op ">=" current-line) tokens))]
               [(char=? (peek-next) #\<)
                (advance) (advance)
                (set! tokens (cons (token 'op "><" current-line) tokens))]
               [else (add-token 'op ">")])
             (scan-loop)]
            [else (error (format "Unexpected character: ~a" char))]))))
    
    (reverse tokens)))

; Parser implementation
(define (parse tokens)
  (let ([current 0]
        [tokens tokens])
    
    ; Helper functions
    (define (peek)
      (if (< current (length tokens))
          (list-ref tokens current)
          #f))
    
    (define (peek-next)
      (if (< (+ current 1) (length tokens))
          (list-ref tokens (+ current 1))
          #f))
    
    (define (at-end?)
      (not (peek)))
    
    (define (previous)
      (list-ref tokens (- current 1)))
    
    (define (advance)
      (unless (at-end?)
        (set! current (+ current 1)))
      (previous))
    
    (define (check type)
      (and (not (at-end?))
           (eq? (token-type (peek)) type)))
    
(define (match . types)
      (for/or ([type types])
        (and (check type)
             (begin (advance) #t))))
    
    (define (consume type error-msg)
      (if (check type)
          (advance)
          (error error-msg)))
    
    ; Grammar rules implementation
    
    ; <Lines> ::= <Statements> NewLine <Lines> | <Statements> NewLine
    (define (parse-lines)
      (let loop ([stmts '()])
        (if (at-end?)
            (ast-node 'program #f (reverse stmts))
            (begin
              (let ([stmt (parse-statements)])
                (when (check 'newline)
                  (advance))
                (loop (cons stmt stmts)))))))
    
    ; <Statements> ::= <Statement> ':' <Statements> | <Statement>
    (define (parse-statements)
      (let ([stmt (parse-statement)])
        (if (match 'colon)
            (ast-node 'compound #f (list stmt (parse-statements)))
            stmt)))
    
    ; <Statement> implementation
(define (parse-statement)
  (cond
    [(match 'keyword)
     (let ([kw (token-value (previous))])
       (case kw
         [("def") (parse-def)]
         [("enddef") (ast-node 'enddef #f '())]
         [("end") (ast-node 'end #f '())]
         [("if") (parse-if)]
         [("while") (parse-while)]
         [("print") (parse-print)]
         [("return") (parse-return)]
         [("rem") (parse-remark)]
         [else (error (format "Unexpected keyword: ~a" kw))]))]
    [(match 'identifier)
     (parse-id-statement (previous))]
    [else (error "Expected statement")]))
    
    ; Handle identifier statements (assignment or function call)
    (define (parse-id-statement id-token)
      (let ([id (token-value id-token)])
        (cond
          [(match 'assign)
           (ast-node 'assignment id (list (parse-expression)))]
          [(match 'lparen)
           (let ([args (parse-expression-list)])
             (consume 'rparen "Expected ')'")
             (ast-node 'call id args))]
          [else (error "Expected ':=' or '(' after identifier")])))
    
    ; Parse function definition
    (define (parse-def)
      (let* ([name (token-value (consume 'identifier "Expected function name"))]
             [_ (consume 'lparen "Expected '('")]
             [params (parse-id-list)]
             [_ (consume 'rparen "Expected ')'")]
             [body (parse-def-body)])
        (ast-node 'function-def name (list (ast-node 'params #f params) body))))
    
    ; Parse function body
(define (parse-def-body)
  (let loop ([stmts '()])
    (if (and (check 'keyword)
             (equal? (token-value (peek)) "ENDDEF"))
        (begin
          (advance)
          (ast-node 'block #f (reverse stmts)))
        (begin
          ; Skip any whitespace/newlines
          (let skip-space ()
            (when (check 'newline)
              (advance)
              (skip-space)))
          (if (at-end?)
              (error "Unexpected end of file in function body")
              (loop (cons (parse-statements) stmts)))))))
    
    ; Parse print statement
    (define (parse-print)
      (ast-node 'print #f (parse-print-list)))
    
    ; Parse print list
    (define (parse-print-list)
      (let ([expr (parse-expression)])
        (if (match 'semicolon)
            (cons expr (parse-print-list))
            (list expr))))
    
    ; Parse if statement
(define (parse-if)
  (let* ([condition (parse-expression)]
         [_ (consume 'keyword "Expected then")]
         [then-branch (parse-if-body)])
    (ast-node 'if #f (list condition then-branch))))

    
    ; Parse if body
    (define (parse-if-body)
      (let loop ([stmts '()])
        (if (and (check 'keyword)
                 (equal? (token-value (peek)) "ENDIF"))
            (begin
              (advance)
              (ast-node 'block #f (reverse stmts)))
            (loop (cons (parse-statements) stmts)))))
    
    ; Parse while statement
; Parse while statement
(define (parse-while)
  (printf "Parsing WHILE statement\n")
  ; Just consume tokens until we find ENDWHILE
  (let loop ([tokens-consumed '()])
    (cond
      [(and (check 'keyword)
            (equal? (token-value (peek)) "ENDWHILE"))
       (advance) ; consume ENDWHILE
       (ast-node 'while #f '())]  ; Return empty WHILE node
      [(at-end?)
       (error "Unexpected end of file while parsing WHILE statement")]
      [else
       (advance) ; consume the current token
       (loop (cons (peek) tokens-consumed))])))
    
    ; Parse while body
    (define (parse-while-body)
      (let loop ([stmts '()])
        (if (and (check 'keyword)
                 (equal? (token-value (peek)) "ENDWHILE"))
            (begin
              (advance)
              (ast-node 'block #f (reverse stmts)))
            (loop (cons (parse-statements) stmts)))))
    
    ; Parse return statement
    (define (parse-return)
      (ast-node 'return #f (list (parse-expression))))
    
    ; Parse remark
    (define (parse-remark)
      (ast-node 'remark #f '()))
    
    ; Parse expressions following the grammar precedence
    (define (parse-expression)
      (parse-or))
    
    (define (parse-or)
      (let ([expr (parse-and)])
        (if (and (match 'keyword)
                 (equal? (token-value (previous)) "OR"))
            (ast-node 'binary "OR" (list expr (parse-or)))
            expr)))
    
    (define (parse-and)
      (let ([expr (parse-not)])
        (if (and (match 'keyword)
                 (equal? (token-value (previous)) "AND"))
            (ast-node 'binary "AND" (list expr (parse-and)))
            expr)))
    
    (define (parse-not)
      (if (and (match 'keyword)
               (equal? (token-value (previous)) "NOT"))
          (ast-node 'unary "NOT" (list (parse-comparison)))
          (parse-comparison)))
    
    (define (parse-comparison)
      (let ([expr (parse-additive)])
        (if (or (match 'equals)
                (and (match 'op)
                     (member (token-value (previous))
                            '("<>" "><" ">" ">=" "<" "<="))))
            (ast-node 'binary (token-value (previous))
                     (list expr (parse-comparison)))
            expr)))
    
    (define (parse-additive)
      (let ([expr (parse-multiplicative)])
        (if (or (match 'plus)
                (match 'minus))
            (ast-node 'binary (token-value (previous))
                     (list expr (parse-additive)))
            expr)))
    
    (define (parse-multiplicative)
      (let ([expr (parse-unary)])
        (if (or (match 'multiply)
                (match 'divide))
            (ast-node 'binary (token-value (previous))
                     (list expr (parse-multiplicative)))
            expr)))
    
    (define (parse-unary)
      (if (match 'minus)
          (ast-node 'unary "-" (list (parse-primary)))
          (parse-primary)))
    
    (define (parse-primary)
      (cond
        [(match 'lparen)
         (let ([expr (parse-expression)])
           (consume 'rparen "Expected ')'")
           expr)]
        [(match 'identifier)
         (let ([id (token-value (previous))])
           (if (match 'lparen)
               (let ([args (parse-expression-list)])
                 (consume 'rparen "Expected ')'")
                 (ast-node 'call id args))
               (ast-node 'variable id '())))]
        [(or (match 'number)
             (match 'real)
             (match 'string))
         (ast-node 'literal (token-value (previous)) '())]
        [else (error "Expected expression")]))
    
    ; Helper functions for lists
    (define (parse-id-list)
      (let ([id (token-value (consume 'identifier "Expected identifier"))])
        (if (match 'comma)
            (cons (ast-node 'parameter id '()) (parse-id-list))
            (list (ast-node 'parameter id '())))))
    
    (define (parse-expression-list)
      (if (check 'rparen)
          '()
          (let ([expr (parse-expression)])
            (if (match 'comma)
                (cons expr (parse-expression-list))
                (list expr)))))
    
    ; Start parsing
    (parse-lines)))

; Pretty printer for AST
(define (print-ast node [indent 0])
  (define (print-indent)
    (for ([i (range indent)])
      (display "  ")))
  
  (print-indent)
  (printf "~a" (ast-node-type node))
  (when (ast-node-value node)
    (printf ": ~a" (ast-node-value node)))
  (newline)
  
  (for ([child (ast-node-children node)])
    (print-ast child (+ indent 1))))

; Function to read file
(define (read-file filename)
  (with-input-from-file filename
    (lambda ()
      (let loop ([lines '()]
                 [line (read-line)])
        (if (eof-object? line)
            (string-join (reverse lines) "\n")
            (loop (cons line lines)
                  (read-line)))))))

; Update process-file to include AST generation
(define (process-file filename)
  (let* ([content (read-file filename)]
         [tokens (tokenize content)])
    (printf "Processing file: ~a\n" filename)
    (printf "File contents:\n~a\n\n" content)
    (printf "Tokens:\n")
    (for-each 
     (lambda (tok)
       (printf "~a: ~a (line ~a)\n" 
               (token-type tok) 
               (token-value tok)
               (token-line tok)))
     tokens)
    (printf "\nParsing...\n")
    (let ([ast (parse tokens)])
      (printf "\nAST:\n")
      (print-ast ast))))

; Update main module
(module+ main
  (define filename "Fall24SampleCode.txt")
  (when (file-exists? filename)
    (process-file filename)))

; Export functions
(provide tokenize parse print-ast process-file read-file)