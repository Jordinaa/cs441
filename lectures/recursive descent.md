# Top down (predictive)
LL
left most
unambigous 
right recursive
- table driven
	- stack
		- push RHS onto stack
		- top of stack. row
		- 1st input table column
	- machine generated 
- Recursive descent 
	- 1 function per non terminal 
	- what rule is going to apply next - based on that rule what is going to come in next? if correct keep going else throw error

Always looking ahead and predicting what rule
WATCH OUT FOR 
- left recursion
	- term = term + term
	-  infinite recursion 
- common prefix
	- statement -> 
		- id := exon
	- st.tail -> expn
			- is (paramlist)

# Bottom up
always looking behind 
- shift reduced terminal 
	- take whats on stack and reduce it 
left recursive or right recursive 
LR
leftmost
# Different function for each type

