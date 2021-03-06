Programs are a series of sentences ending in periods, question marks, or exclamation points. For every sentence the average word length is calculated (hyphenated words count as one but don't count the hyphen character in length, similarly for apostrophies and other symbols), rounded to the nearest integer, and the ratio of [words of length greater than average]/[words of length less than average] is used to map a sentence to an instruction. (2/3 maps to the same instruction as 10/15)

    ratio | command  |   | ratio | command 
    :----:|:--------:|---|:-----:|:--------:
    13/7  | ASSIGN   |   | 7/3   | LESS?   
    2/3   | VALUE    |   | 9/5   | GREATER?
    0/1   | LITERAL  |   | 11/17 | OR      
    2/1   | LABEL    |   | 13/3  | AND     
    1/1   | GOTO     |   | 5/13  | NOT     
    1/2   | ADD      |   | 4/7   | INNUM   
    5/9   | SUBTRACT |   | 5/2   | INCHAR  
    3/4   | MULTIPLY |   | 15/14 | OUTNUM  
    4/1   | DIVIDE   |   | 3/7   | OUTCHAR 
    1/4   | MODULO   |   | 1/0   | RAND    
    2/9   | ABS      |   | 5/3   | EXIT    
    1/5   | EQUAL?   |   | ---   | NOP     

Prefix notation is used so ADD LITERAL 1 LITERAL 4 results in 5

# Built in functions:

ASSIGN VAR_ID VALUE
 sets variable VAR_ID to VALUE, creates variable VAR_ID if necessary, results in VALUE

VALUE VAR_ID
 Results in the value of variable VAR_ID. If there is no variable VAR_ID, NOP

LITERAL VALUE
 Results in the literal value following this instruction. This value is parsed differently from other sentences. Instead of the value being the ratio of [larger than average words]/[smaller than average words], this value is the number of words of average length. Note that it is not possible to have a literal negative.

LABEL ID
 A label with id ID is defined. A label with the same ID as a previously defined label overwrites the previous one. Putting a label in the middle of an expression is completely valid (for example: ADD LABEL LITERAL 1 OR VALUE NOP GOTO LITERAL 1). For a label to become defined, execution must reach the LABEL instruction.
 Results in 1.

GOTO ID
 Jump to label with id ID. If there is no label ID, NOP

ADD VALUE1 VALUE2
 Results in VALUE1 + VALUE2

SUBTRACT VALUE1 VALUE2
 Results in VALUE1 - VALUE2

MULTIPLY VALUE1 VALUE2
 Results in VALUE1 * VALUE2

DIVIDE VALUE1 VALUE2
 Results in VALUE1 / VALUE2 (integer division)

MODULO VALUE1 VALUE2
 Results in VALUE1 % VALUE2

ABS VALUE
 Results in the absuloute value of VALUE

EQUAL? VALUE1 VALUE2
 Results in VALUE1 == VALUE2 (0: false, 1: true)

LESS? VALUE1 VALUE2
 Results in VALUE1 < VALUE2

GREATER? VALUE1 VALUE2
 Results in VALUE1 > VALUE2

OR VALUE1 VALUE2
 VALUE1 || VALUE2 (true: 1 or greater, false: 0 or less)
 results in VALUE1 if VALUE1 is 1 or greater, otherwise results in VALUE2

AND VALUE1 VALUE2
 VALUE1 && VALUE2
 results in VALUE1 if VALUE1 is 0 or less, otherwise results in VALUE2

NOT VALUE
 !VALUE
 0 if VALUE is 1 or greater, 1 otherwise

INNUM
 reads a number from stdin (prefix '-' indicates negative value)
 what happens when it encounters a non-number on stdin is undefined.

INCHAR
 reads a single character from stdin, value of INCHAR is unicode id of character read
 results in 0 if eof read

OUTNUM VALUE
 outputs value as a number to stdout, results in the value output

OUTCHAR VALUE
 outputs value as a unicide character with VALUE as unicode id to stdout, results in the value output

RAND VALUE
 results in a random number range [0 VALUE] inclusive (a range [0 -5] is equilivant to the range [-5 0])

EXIT
 stops program execution

NOP
  any ratio other than those that map to instructions or a GOTO to a non-existent label. results in 0

# Notes:

Note that LITERAL is the only way to specify a literal value either in variable names or as LABELs or as targets for GOTOs, everything that takes arguments--aside from LITERAL--takes the argument in the form of the result of another expression. This is especially useful in LABELs and GOTOs as the expression GOTO RAND INCHAR is perfectly valid (goto the label with the id matching a random integer from 0 to the value of an input character).
Whether 0/0 results in RAND, LITERAL, GOTO, or NOP is undefined.
A GOTO as an argument to another instruction results in either 0 of there is no LABEL with the correct ID to go to (as if it were a NOP) or in the value of the label jumped to (1). If a GOTO is the first argument to an instruction that takes more than one argument, the second argument is the next expression after the LABEL jumped to.
If program execution reaches the end of the last sentence, there is an implicit EXIT.
There is no need for conditionals like IF as these could be built using OR and AND. IF COND1 THEN E1 ELSE E2 can be expressed as OR AND COND1 OR E1 LITERAL 1 E2 if E1 might evaluate to false, OR AND COND1 E1 E2 if E1 will always evaluate to true.
