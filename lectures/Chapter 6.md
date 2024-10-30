# Closure
- a function that remembers the lexical environment in which is was created
Can be thought of as a pair of pointers
- one to a block of code (defining the function)
- one to an environment (in which the function was created)

# Static 
- bindings are fixed 
- before run-time
- example: int 1;
- lexical scoping
# Dynamic
- bindings are changeable
- during run-time
- example: a=1; 
- python
	- can make a variable change from string to int reassigned etc
- scoping we can look at on the call stack
---
declarations or references 
- value name by a variable is called its denotation 

- Declarations have limited scope

---
TEST QUESTION for test 2 6.4.1 lexical scoping - the nested lambdas 
Shadow,
scope hole
visibility
inside work your way out
deep and shallow binding - function language doesn't matter because everything is immutable 

---
# Lexical Addressing 
lexical depth
declaration position
