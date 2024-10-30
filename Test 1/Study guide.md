Bindings: Static and Dynamic
- Language definition time (keyword int bound to the meaning of integer)
	- involves defining the syntax and semantics of a programming language
- Language implementation (int data type bound to a storage size such as four bytes)
	- the time at which a compiler or interpreter for the language is built
	- some of the semantics of the implemented language are bound/defined as well
- Compile time (identifier x bound to an integer variable)
- Link time (printf is bound to a definition from a library of routines)
- Load time (variable x bound to memory cell at address 0x7cd7 - can happen at run-time as well; consider a variable local to a function)
- static 
	- bindings occur before run time and are fixed during run time
- dynamic 
	- bindings occur at run time and are changeable during run time
---
Give the approximate dates each language was introduced. Describe its main features, any new features or ‘firsts’ it introduced, intended use, and how successful it was: 
- FORTRAN - 1952
	- First compiled high level language
	- first implementation of arrays and subroutines 
	- translated arithmetic expressions 
- LISP - 1958 
	- John McCarthy
	- lists
	- code and data homoiconic
	- first function programming language
	- first JIT compiler 
- COBOL - 1960 
	- Grace Hopper
	- Designed for ease of use to managers could read
	- designed specifically for business
	- hierarchal data structures
	- use was mandated by DoD 
- PL/I - 1964 
	- IBM
	- Recursion could be disabled for more efficient linkage if a program had no recursion 
	- first attempt at a language suitable for multiple purposes 
	- first concurrent execution of subprograms
	- first systematic use of exceptions
	- 23 types of exception and runtime errors 
	- first use of pointers as a data type
	- first implementation of array slicing
- Smalltalk - 1972
	- Kay
	- borrow ideas from SIMULA 67 
	- syntax based on message passing between objects
	- first fully OO language GUI as fundamental part of the language
	- more sophisticated memory 
- C - 1972
	- typed but type checking not consistently enforced
	- flexible but not very secure 
	- primary design goal was compact and fast-executing object code
	- availability with UNIX made it adopted and it quickly became a widespread general development language
	- standardizes by ANSI in 1989 with updates in 1999
- Objective-C - 1980s 
	- Cox and Love
	- C+ objects using smalltalk syntax
	- licensed by Steve jobs after he left apple to write NeXT software
	- later used it for OS X 
	- standard language of iPhone development
	- strictly superset of C so all of C's insecurities are retained
- C++ - 1984
	- Stroustrup
	- virtual methods method name and operator overloading
	- references as a type
	- design goals included usability anywhere C could be used
	- few features from C were removed even those considered unsafe
- Java - 1990
	- Gosling et al 
	- designed for reliability in consumer devices
	- adopted for web programming via applets 
- Python - 1995
	- Van Rossum 
	- Strong dynamic typing 
	- including lists 
	- immutable lists (tuples)
	- associative arrays (dictionaries)
	- list comprehensions 
- BASIC - 1992
	- Popular for writing GUI interfaces became standard interface language for MS Office
	- supports OO programming
- Scheme, 
- Ada - 1979
	- history's largest design effort
	- instigated and pushed by DoD 
	- must more extensive exception handling than previous languages - reliability was major design goal 
	- delayed by difficulty writing compiler
	- FIRST
		- packages for data encapsulation 
		- generic program units - sort routine that leaves data type unspecified 
		- works for anything with < operator 
		- concurrency via rendezvous method
- Swift - 2014
	- developed by apple 
	- uses objective Cs runtime library
	- so swift and objective code can easily coexist 
- Rust - 2010
	- Hoare et al. 
	- Focus on memory safety and efficient but safe concurrency 
- Julia - 2012
	- designed for high speed technical computing and data science
	- JIT compiler type interface multiple dispatch lead to high performance
	- dynamically typed
	- syntax based on python 
	- designed for interoperability with other languages
---
What is a domain-specific language?
- A style of programming, to use a programming language not to develop a solution to a problem but rather to build a language specifically tailored to solving a family of problem for which the problem at hand is an instance. 
- **Bottom up programming** - building a library of functions followed by writing a concise program that calls those functions 
---
There may be questions about features or design goals of particular languages but you will not have to interpret source code.
- The Goals of a language 
	- speed of execution
	- ease of development
	- safety
- influence its design choices 
	- static or dynamic bindings
- in turn these have an influence on language implementation 
	- interpretation
	- compilation
- Fortran and C programs are intended to execute fast and therefore are compiled
	- the speed of the executable produced by a compiler is a direct result of the efficient decoding of machine instructions at run-time coupled with few semantic checks at run time
	- static bindings also support fast program execution 
	- it is natural to implement a language designed to support static bindings through compilation because establishing those bindings and performing semantic checks for them can occur at compile time so they do not occupy CPU cycles at run time
	- in cases where implementation can provides both an interpreter and a compiler for a language the interpreter can be used for prototyping while the compiler can be reserved for producing the final production version of software 
---
What is the difference between a compiler and an interpreter?
- Compiler - translates code from high level into machine code
- Interpreter - translates code written in a high level programming language into machine code line by line as the code runs
---
What is a hybrid language?
- example:
	- final representation being evaluated by a software interpreter is a compiler from java source code to jave bytecode where the resulting bytecode is executed by the java virtual machine in a software interpreter 
---
What is the difference between declarative and imperative languages?
- Imperative - System knows enough to figure out instructions on its own
- Declarative - You're dictating instructions 
![[Pasted image 20240924112803.png]]
---
What is the difference between statement-oriented and expression-oriented languages?
- schema and racket
	- evaluating a block is whatever evaluated last 
	- value of a function or loop 
	- side effect - when you want to change a variable later
	- whatever if another thread mucks around with my data
	- if data is immutable then 
- statement
	- python java etc
---
Describe the steps necessary to translate a C++ program into a running program.
![[Pasted image 20240924110948.png]]

---

Describe the steps necessary to translate a Java program into a running program.
![[Pasted image 20240924111004.png]]

---
Explain the difference between context-sensitive and context-free grammars. Why do we use context-free grammars for programming languages? 
- context free grammar
	- a formal grammar in which every production rule replaces a single non terminal symbol with a string of terminal and/or nonterminals 
- sufficient expressiveness 
- efficient parsing algorithms 
	- LLs
	- LRs
	- parse most in linear time relative to length of input 
- simplicity
- manageability
- compiler design practicality 

---
Why aren’t regular expressions powerful enough to describe a language?
- a regular expression defines a regular language using a sequence of characters that form a search pattern
- example
	- regex cannot enforce that ever '(' has a matching ')'
	- cannot remember an arbitrary amount of information from the first half to compare with the second half 
- NEEDS
	- complex syntax
	- hierarchical structure
	- dependencies and matching 
---
Explain the difference between leftmost and rightmost derivation.
- leftmost derivation always expanded the LEFT MOST NONTERMINAL 
- rightmost derivation always expanded the RIGHT MOST NONTERMINAL 
- both CAN produce the same parse tree but the order in which the nodes are expanded during parsing differs
- IF a string can have more than one leftmost or rightmost derivation (different parse trees) the grammar is ambiguous for that string
---
How can we demonstrate that a grammar is ambiguous?
- a context free grammar (CFG) is said to be ambiguous if there exists at least one string in the language generated by the grammar that has two o r more distinct parse trees, leftmost derivations, rightmost derivations 
---
Given a simple grammar and an expression, produce the parse tree.

---
Given a simple grammar and a parse tree, determine whether the parse tree is correct.

---
How is the precedence of operators established, and how does it manifest in the parse tree?
- Expression
	- handles the lowest precedence operators
- term
	- handles operators with high precedence than those in expression
- factor
	- handles the highest precedence operations or operands 
- PARSE TREE PRECEDENCE 
	- higher precedence operators appear lower in the parse tree
	- lower precedence operators appear higher in the parse trees

---
We have discussed two features that prevent leftmost parsing. What are they?
- **left recursion** 
- statement -> ID := expr
- statement -> ID(paramlist)
- issue is they both start with an ID how do i know which to pick
- **top down ID is the same**
- so we refactor into statements which is
- id statement-tail
- tail -> := expr (param)
- **common prefix**
- CAN FIX BY ADDING MORE TERMINAL

---
- How does table-driven parsing work? Name an advantage of table-driven methods.
	- top down predicting next set of rules and push it into stack
	- bottom up 
		- different table
	- advantage of table driven methods
		- setting up is fairly complex
		- keep track of rules at any given point
		- whats at the top what do we do
		- give me grammar it will generate table
		- advantage is i just get a new table for new language
	- scenario: parsing along
		- state that we are in at the current rate of the parse will determine where we look in the stack
		- if we ever hit an empty spot at the table
			- there is no rule we give syntax error
	- do all parsers use a table system?
		- automating tables is easy
		- so most use it
---
Terms
- scanner
	- turns input into a list of tokens
- lexer
	- forms the first phase of a compiler frontend in processing 
- parser
	- analyze and interpret the syntax of a text or program to extract relevant information
- lexical analysis
	- breaking syntaxes into a series of tokens by removing whitespace in the source code
- semantic analysis
	- task of ensuring the declarations and statements of a program are semantically correct
- parse tree
	- abstracting of the derivation process 
- syntax tree
- static semantics
	- before run time semantic checker
		- type compatible 
		- functions and methods called with correct calling and sequences
- dynamic semantics
	- what actually happens when the program is executed 
- regular expression REGEX!!!
	- sequence of characters that defines a search pattern it is used for string matching searching and manipulation 
- terminal
	- a basic symbol that represents an actual value and cannot be broken down further
	- terminals are the "leaves" of the parse tree 
	- tokens or terminals 
		- keywords like if or else
		- operators + or - 
		- literals 42 or "hello"
- nonterminal
	- a symbol used in a grammar that can be expanded into one or more terminals and nonterminals. 
	- Nonterminals **represent abstract** syntactic categories or constructs 
	- nonterminals define the hierarchical structure of a languages syntax. they are used in **production rules** to derive strings of terminals
	- **NONTERMINALS**
		- EXPRESSION 
		- TERM
		- FACTOR
- production
	- in a grammar is a rule that defines how a nonterminal can be replaced by a combination of terminals and nonterminals 
		- sentence = noun-phrase verb-phrase
		- noun-phrase = article noun
		- verb-phrase = verb noun phrase 
- BNF Backus-Naur Form 
	- BNF is notation for expressing the grammar of a language in terms of production rules
	- it uses symbols and rules to define how sentences in the language can be formed
	- digit = "1" "2" "3" "4" ... 
- EBNF Extended Backus-Naur Form 
	- An extension of BNF that includes additional notation for expressing grammar rules more concisely and expressively 
	- [] for optional elements
	- {} fir repetitions
	- | for alternatives 
- token 
	- a categorized unit of a string identified during lexical analysis 
	- tokens are the output of the tokenization process and serve as the input for parsing 
	- tokens represent the meaningful elements of the language classified into types like identifiers keywords literals operators and symbols 
	- int keyword
	- count identifier
	- = operator
	- 10 numeric literal 
	- ; separator 
- lexeme 
	- a reserved word is a word that has a special meaning in a programming language and cannot be used as an identifier 
	- count or total is an example
- reserved word
	- a word that has a special meaning in a programming language and cannot be used as an identifier
	- reserved words are part of the languages syntax and are used to define control structure data types etc
	- if, else, while, return, class, public, static, etc.
- top-down parsing
	- a parsing strategy that start from the highest level construct - start symbol - and works down to the terminals by expanding nonterminal using production rules 
	- PREDICTS what the input should be based on the grammar and try to match the input tokens to these predictions
	- recursive descent are a common type of top down parser 
- bottom-up parsing
	- a parsing strategy that starts from the input tokens and works up to the start symbol by reducing sequences of tokens to nonterminals
	- bottoms up parsers shift input tokens onto a stack and reduce them to nonterminals when they match the right-hand side of a production rule
	- shift reduce parsers, like LR parsers, are bottom up parsers
- recursive descent
	- recursive descent parsing is a top down parsing technique 
	- WHERE each nonterminal in the grammar has a corresponding function in the parsers that can recursively parse that nonterminal 
	- parser consists of a set of recursive functions that call each other according to the grammars production rules 
	- MANY have issues with left recursive grammar
- table-driven parsing
	- table driven parsing uses pre-computed parsing tables to guide the parsing process instead of hard coded logic the parser reads the tables to decide which action to take based on the current state and input token 
- shift-reduce parsing
	- is a BOTTOM-UP parsing technique that uses a stack to hold symbols and performs actions based on the input token and the top of the stack 
	- bottom up parsing
	- at any given point we have a choice we keep a stack of things we have seen so far
	- if we recognize its right to the rule we shift it over thats the end of the number 
	- how we implement bottom up parsing
	- after we have read how do we know when shift or reduce
		- shift reduce conflict 
		- term or a factor
		- if there are two rules that either one might apply - no distinction about priority 
			- do i add the sum or shift and do product first priority is shift because we use *
- epsilon production
	- Term -> factor or ID or epsilon
		- epsilon - is an empty string which means it can be satisfied 
- determining priority of factors it is in the grammar 
---
- Important people: 
- Alan Turing, 
	- invented the turing machine and turing test 
- John Backus, 
	- Introduced BNF 
	- speed coding 
		- automatically incremented address registers
	- FORTRAN 1
		- I/O formatting 6 char variable names, user defined subroutines, if, do 
- Grace Hopper, 
	- FLOW-MATIC
		- first attempt to write data processing statements in english like constructs 
	- A-0 Developed one of the first compilers converting math into machine code
	- COBOL 
	- First compiler 
- Bjarne Stroustrup, 
	- Created C++ 
	- C with classes
		- first use of class public and private access control 
	- C++ 
		- virtual methods method name and operator overloading references as a type 
	- C++ 2.0
		- multiple inheritance 
		- abstract classes
	- C++ 3.0
		- templates
		- exception handling 
- Alan Kay, 
	- he pioneered OOP at XEROX PAC 
	- emphasized the objects 
	- LISP influenced his thoughts 
- Kernighan & Ritchie
	- both developed UNIX at bell labs 
	- automatically generating scanners and shift reduce bottom up parsers using lex and yacc 
---

- Know the notation for LL(1), LR(2), etc. and what it means. Understand how top-down and bottom-up parsing work.



---
left most right most parsing

- term 
	- term x factor
	- left recursive
- term
	- factor x term
	- right recursive
top down evaluation it matters
left recursive cannot parse it top down it will prevent it

bottom up recursion we prefer top down

left most vs right most derivation
- x := y +z * z;
- left most or right most is easier to program - start from same place and go from there
- all it is - do we work from left most token or right most token
- the reason this matters
	- top down 
		- LL(1)
		- left most of whatever the next token is 
	- bottom up
		- LR(1)
		- right most 
		- 1 in parenthesis shows how far ahead which is a token 
	- LL(1) 
		- L - where are we starting
		- L - Where are we deriving
		- 1 - token
	- 'k' in LL(k)
		- lookahead tokens 
		- higher k values allow parsing of more complex grammars but increase parsing complexity 
		- higher k can resolve ambiguities 
		- more look ahead means more computation and larger parsing tables 


---
# Quiz
- We saw that derivations of a sentence in a particular grammar can be leftmost or rightmost. What can we say about these derivations if the grammar is unambiguous?   
	- _That they will produce the same parse tree. One expression having more than one valid parse tree indicates the grammar is ambiguous._ 

- One method of parsing a string is to start with the string and identify portions that correspond to the right-hand side of some rule in the grammar, which are replaced with the corresponding nonterminal. This process continues until only the start symbol remains (meaning the string is valid in that grammar), or no match can be made (meaning the string is not valid in that grammar). This process is called 
	- _shift-reduce (bottom-up) parsing._ 

Suppose a grammar includes the rules  
	$<expr> -> <expr> + <expr>$
	$<expr> -> <expr> * <expr>$
In evaluating the expression a + b * c, it is not clear which rule should be applied first; the grammar seems to allow it to be either (a+b)*c or a+(b*c). This is an example of a
_shift-reduce error. The question is whether, after reading the a + b, to apply a rule and reduce it at once, or to shift the next tokens in, so the first thing that gets reduced is b*c. This grammar gives us no way of choosing between them._  

- in a written grammar, a terminal symbol is: 
	- _One that never appears on the left-hand side. (The next most popular choice was "never has context supplied on the left hand side," but in a CFG, that's true of every symbol.)_ 

- Extended Backus-Naur Form (EBNF) 
	- _has a more convenient notation but is no more expressive than regular BNF. For example, EBNF has a + to indicate "repeats 1 or more times" in addition to the star indicating 0 or more repetitions. But anything expressible in EBNF is also expressible in BNF._