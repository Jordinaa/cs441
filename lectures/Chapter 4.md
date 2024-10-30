# interpretation versus compilation 
- both compilers and interpreters have a front end
	- consisting of: 
		- scanner- lexical analyzer
		- parser - synctactic analyzer
- interpreter
	- interpreter is a software simulation of machine which understands instructions in source language
	- interpreter provides a virtual machine for a programming language
- compiler
	- a program that translates a program in one language to an equivalent program in another language (target language)
	- compiler is just a translator nothing more
# Execution by interpretation
- Preprocessing
	- purges comments
- lexical analysis
	- scanning
- syntax analysis 
	- parsing
- semantic analysis
can run on other hardware just need new interpreter

# execution by compilation
- source program
	- string or list of lexemes
Front end
- scanner
- list of tokens
- context free grammar parser
compiler
- semantic analyzer
- code generator translator
translated program
- interpreter
parse it 
analyze it
pass it down to byte code

---
# levels of languages
1. machine - x86
2. assembly - mips
3. high level - python java scheme
4. fourth generation language - lex yacc
---
# 4.3 Run time systems methods of executions
1. traditional compilation directly to object code - fortran, c
2. hybrid systems - interprets of a compiled final representation through a compiled interpreter 
3. pure interpretation of a source program through a compiled interpreter - scheme ml
4. interpretation of either a source program or a compiled final representation through a stack of interpreted software interpreters 

# 4.4 low local view of execution by compilation 
mat expressions
- source program
front end
- representation
- list of lexemes
- list of tokens
- abstract syntax tree
compiler 
- assembly code
- object code
- program input -> interpreter -> program output
---
# 4.1 adv and disadv of compilers and interpreters
![[Pasted image 20240916112948.png]]
rapid development - interpreted languages

---
which compiler for compiling a language what am i looking at
- target platform
- what optimizations do apply etc
---
# 4.5 influence of language goals on implementations
- goals of a language - speed, ease, safety, etc
	- fortran, c - speed
- speed of the executable produced by a compiler is a direct result of the efficient decoding of machine instructions (high level statements) at rune-time coupled with few semantic checks at run time 
- implement a language designed to support static bindings through compilation because establishing those bindings and performing semantic checks for them can occur at compile time so they do not occupy CPU cycles at run-time 
- UNIX shell scripts - interpreted
- 