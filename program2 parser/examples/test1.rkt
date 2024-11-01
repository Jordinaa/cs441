#lang racket

(require parser-tools/lex
         racket/string)

;; Define token and AST node structures
(struct token (type value) #:transparent)
(struct ast-node (type children) #:transparent)

;; Step 1: Scanner
(define-lex-abbrevs
  [whitespace (:or #\space #\tab #\newline #\return)]
  [digit (:+ #\0 #\9)]
  [alpha (:or #\a #\z #\A #\Z)]
  [id (:seq alpha (:* (:or alpha digit)))]
  [integer (:seq digit)]
  [assign ":="]
  [lparen "("]
  [rparen ")"]
  [colon ":"]
  [semicolon ";"]
  [string-lit (:seq "\"" (:* (:or alpha digit #\space)) "\"")]
  [keyword (:or "def" "enddef" "end" "if" "then" "endif" "while" "do" "endwhile" "print" "return" "rem")])

(define empty-token (token 'EOF "EOF"))

(define scan-lexer
  (lexer
   [id (token 'ID lexeme)]
   [integer (token 'INT lexeme)]
   [string-lit (token 'STRING lexeme)]
   [assign (token 'ASSIGN lexeme)]
   [lparen (token 'LPAREN lexeme)]
   [rparen (token 'RPAREN lexeme)]
   [colon (token 'COLON lexeme)]
   [semicolon (token 'SEMICOLON lexeme)]
   [keyword (token 'KEYWORD (string-upcase lexeme))]
   [whitespace (scan-lexer input-port)] ; ignore whitespace
   [any-char (error "Unrecognized character")]))

;; Tokenize input string
(define (tokenize input)
  (define tokens '())
  (define input-port (open-input-string input))
  (let loop ()
    (let ([token (scan-lexer input-port)])
      (if (eq? (token-type token) 'EOF)
          (reverse tokens)
          (loop (cons token tokens))))))

;; Step 2: Basic Parser
(define (parse tokens)
  (define current 0)

  (define (peek [offset 0])
    (if (< (+ current offset) (length tokens))
        (list-ref tokens (+ current offset))
        empty-token))

  (define (advance)
    (when (< current (length tokens))
      (set! current (add1 current))
      (list-ref tokens (sub1 current))))

  ;; Parse Functions
  (define (parse-program)
    (let loop ([statements '()])
      (if (eq? (token-type (peek)) 'EOF)
          (ast-node 'PROGRAM (reverse statements))
          (loop (cons (parse-statement) statements)))))

  (define (parse-statement)
    (let ([tok (peek)])
      (case (token-type tok)
        [(KEYWORD)
         (case (string-upcase (token-value tok))
           [("DEF") (parse-def)]
           [("ENDDEF") (advance) (ast-node 'ENDDEF '())]
           [("END") (advance) (ast-node 'END '())]
           [("IF") (parse-if)]
           [("WHILE") (parse-while)]
           [("PRINT") (parse-print)]
           [("RETURN") (parse-return)]
           [("REM") (advance) (ast-node 'REM '())])]
        [(ID) (parse-assignment-or-call)]
        [else (error "Unexpected token in statement" tok)])))

  ;; Statement parsers
  (define (parse-def)
    (advance) ; consume DEF
    (let ([name (token-value (advance))]) ; consume function name
      (expect 'LPAREN "Expected '(' after DEF")
      (let ([params (parse-id-list)])
        (expect 'RPAREN "Expected ')' after parameters")
        (ast-node 'DEF (cons name params)))))

  (define (parse-if)
    (advance) ; consume IF
    (let ([condition (parse-expression)])
      (expect 'KEYWORD "Expected THEN")
      (ast-node 'IF (list condition (parse-statements)))))

  (define (parse-while)
    (advance) ; consume WHILE
    (let ([condition (parse-expression)])
      (expect 'KEYWORD "Expected DO")
      (ast-node 'WHILE (list condition (parse-statements)))))

  (define (parse-print)
    (advance) ; consume PRINT
    (ast-node 'PRINT (list (parse-expression))))

  (define (parse-return)
    (advance) ; consume RETURN
    (ast-node 'RETURN (list (parse-expression))))

  (define (parse-assignment-or-call)
    (let ([name (token-value (advance))])
      (cond
        [(eq? (token-type (peek)) 'ASSIGN)
         (advance) ; consume :=
         (ast-node 'ASSIGN (list name (parse-expression)))]
        [(eq? (token-type (peek)) 'LPAREN)
         (advance) ; consume (
         (let ([args (parse-expression-list)])
           (expect 'RPAREN "Expected ')' after arguments")
           (ast-node 'CALL (cons name args)))]
        [else (error "Expected := or ( after identifier")])))

  ;; Expression Parsers (simplified for basic AST structure)
  (define (parse-expression) (parse-add-exp))
  (define (parse-add-exp)
    (let ([left (parse-mult-exp)])
      (if (eq? (token-type (peek)) 'PLUS)
          (begin
            (advance) ; consume +
            (ast-node 'ADD (list left (parse-add-exp))))
          left)))

  (define (parse-mult-exp)
    (let ([left (parse-value)])
      (if (eq? (token-type (peek)) 'TIMES)
          (begin
            (advance) ; consume *
            (ast-node 'MULT (list left (parse-mult-exp))))
          left)))

  (define (parse-value)
    (let ([tok (peek)])
      (case (token-type tok)
        [(LPAREN)
         (advance) ; consume (
         (let ([expr (parse-expression)])
           (expect 'RPAREN "Expected ')' after expression")
           expr)]
        [(ID) (advance) (ast-node 'ID (list (token-value tok)))]
        [(INT) (advance) (ast-node 'INT (list (token-value tok)))]
        [(STRING) (advance) (ast-node 'STRING (list (token-value tok)))]
        [else (error "Unexpected token in value" tok)])))

  ;; Helper Functions
  (define (expect type msg)
    (let ([tok (peek)])
      (if (eq? (token-type tok) type)
          (advance)
          (error msg tok))))

  ;; Start parsing
  (parse-program))

;; Main function to read file and print basic AST
(define (process-file filename)
  (let* ([content (with-input-from-file filename read-string)]
         [tokens (tokenize content)]
         [ast (parse tokens)])
    (print-basic-ast ast)))

;; Basic AST printer
(define (print-basic-ast node [depth 0])
  (printf "~a~a\n" (make-string (* 2 depth) #\space) (ast-node-type node))
  (for-each (lambda (child)
              (if (ast-node? child)
                  (print-basic-ast child (add1 depth))
                  (printf "~a~a\n" (make-string (* 2 (add1 depth)) #\space) child)))
            (ast-node-children node)))

;; Run parser on the provided .txt file
(module+ main
  (process-file "Fall24SampleCode.txt"))


