Inspired by Gertrude. Programs are a series of sentences ending in periods. For every sentence the average word length is calculated (hyphenated words count as one but don't count the hyphen character in length, similarly for apostrophies and other symbols), rounded to the nearest integer, and the ratio of [words of length greater than average]/[words of length less than average] is used to map a sentence to an instruction. (2/3 maps to the same instruction as 10/15)

ratio | command
------+---------
13/7  | ASSIGN
2/3   | VALUE
0/1   | LITERAL
2/1   | LABEL
1/1   | GOTO
1/2   | ADD
5/9   | SUBTRACT
3/4   | MULTIPLY
4/1   | DIVIDE
1/4   | MODULO
2/9   | ABS
1/5   | EQUAL?
7/3   | LESS?
9/5   | GREATER?
11/17 | OR
13/3  | AND
5/13  | NOT
4/7   | INNUM
5/2   | INCHAR
15/14 | OUTNUM
3/7   | OUTCHAR
1/0   | RAND
5/3   | EXIT
---   | NOP

Prefix notation is used so ADD LITERAL 1 LITERAL 4 results in 5

ASSIGN VAR_ID VALUE
 sets variable VAR_ID to VALUE, creates variable VAR_ID if necessary, results in VALUE

VALUE VAR_ID
 Results in the value of variable VAR_ID. If there is no variable VAR_ID, NOP

LITERAL VALUE
 Results in the literal value following this instruction. This value is parsed differently from other sentences. Instead of the value being the ratio of [larger than average words]/[smaller than average words], this value is the number of words of average length. Note that it is not possible to have a literal negative.

LABEL ID
 A label with id ID is defined. A label with the same ID as a previously defined label is a runtime error (alternative idea: just overwrite the previous one). Putting a label in the middle of an expression is completely valid (for example: ADD LABEL LITERAL 1 OR VALUE NOP GOTO LITERAL 1). For a label to become defined, execution must reach the LABEL instruction.
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

Note that LITERAL is the only way to specify a literal value either in variable names or as LABELs or as targets for GOTOs, everything that takes arguments--aside from LITERAL--takes the argument in the form of the result of another expression. This is especially useful in LABELs and GOTOs as the expression GOTO RAND INCHAR is perfectly valid (goto the label with the id matching a random integer from 0 to the value of an input character).
Whether 0/0 results in RAND, LITERAL, GOTO, or NOP is undefined.
A GOTO as an argument to another instruction results in either 0 of there is no LABEL with the correct ID to go to (as if it were a NOP) or in the value of the label jumped to (1). If a GOTO is the first argument to an instruction that takes more than one argument, the second argument is the next expression after the LABEL jumped to.
If program execution reaches the end of the last sentence, there is an implicit EXIT.
There is no need for conditionals like IF as these could be built using OR and AND. IF COND1 THEN E1 ELSE E2 can be expressed as OR AND COND1 OR E1 LITERAL 1 E2 if E1 might evaluate to false, OR AND COND1 E1 E2 if E1 will always evaluate to true.

Hello World program in pseudo-pseudocode:

ASSIGN GOTO NOP ADD MULTIPLY MULTIPLY LITERAL 2 LITERAL 2 LITERAL 2 MULTIPLY LITERAL 10 LITERAL 10
ASSIGN LITERAL 1 ADD VALUE GOTO NOP LITERAL 3
OUTCHAR SUBTRACT ADD MULTIPLY LITERAL 2 MULTIPLY LITERAL 5 LITERAL 2 DIVIDE VALUE LITERAL 0 LITERAL 2 LITERAL 2
OUTCHAR SUBTRACT VALUE LITERAL 1 MULTIPLY LITERAL 2 LITERAL 5
OUTCHAR OUTCHAR VALUE LITERAL 0
ASSIGN LITERAL 1 SUBTRACT OUTCHAR VALUE 1 ADD LITERAL 1 MULTIPLY SUBTRACT VALUE LITERAL 1 VALUE NOP LITERAL 4
OUTCHAR ADD ASSIGN VALUE GOTO NOP MULTIPLY MULTIPLY LITERAL 2 LITERAL 2 ADD DIVIDE VALUE LITERAL 1 LITERAL 10 LITERAL 1 LITERAL 4
ASSIGN VALUE LITERAL 0 ADD OUTCHAR SUBTRACT VALUE VALUE LITERAL 0 LITERAL 8 MULTIPLY LITERAL 3 LITERAL 4
OUTCHAR ADD VALUE LITERAL 0 ADD LITERAL 5 LITERAL 6
OUTCHAR ADD VALUE NOP LITERAL 3
OUTCHAR ADD MULTIPLY LITERAL 2 LITERAL 3 VALUE NOP
OUTCHAR VALUE NOP
OUTCHAR MULTIPLY LITERAL 10 LITERAL 10
OUTCHAR SUBTRACT VALUE VALUE NOP ADD ADD LITERAL 3 LITERAL 4 LITERAL 4

Translated to pseudocode (literal constants in {brackets} to signify that they're literals and not ratios):

13/7 1/1 4/3 1/2 3/4 3/4 0/1 {2} 0/1 {2} 0/1 {2} 3/4 0/1 {10} 
0/1 {10} 13/7 0/1 {1} 1/2 2/3 1/1 1/3 0/1 {3} 3/7 5/9 1/2 3/4 
0/1 {2} 3/4 0/1 {5} 0/1 {2} 4/1 2/3 0/1 {0} 0/1 {2} 0/1 {2} 
3/7 5/9 2/3 0/1 {1} 3/4 0/1 {2} 0/1 {5} 3/7 3/7 2/3 0/1 {0} 
13/7 0/1 {1} 5/9 3/7 2/3 {1} 1/2 0/1 {1} 3/4 5/9 2/3 0/1 {1} 
2/3 2/5 0/1 {4} 3/7 1/2 13/7 2/3 1/1 3/2 3/4 3/4 0/1 {2} 0/1 
{2} 1/2 4/1 2/3 0/1 {1} 0/1 {10} 0/1 {1} 0/1 {4} 13/7 2/3 0/1 
{0} 1/2 3/7 5/9 2/3 2/3 0/1 {0} 0/1 {8} 3/4 0/1 {3} 0/1 {4} 
3/7 1/2 2/3 0/1 {0} 1/2 0/1 {5} 0/1 {6} 3/7 1/2 2/3 5/4 0/1 
{3} 3/7 1/2 3/4 0/1 {2} 0/1 {3} 2/3 1/3 3/7 2/3 3/2 3/7 3/4 
0/1 {10} 0/1 {10} 3/7 5/9 2/3 2/3 3/1 1/2 1/2 0/1 {3} 0/1 {4} 
0/1 {4}

Hello World program in 167 sentences:

COMING SOON!

Interpreter:

PARTIALLY IMPLEMENTED! AND and OR are slightly broken


Cat:
LABEL NOP OUTCHAR INCHAR GOTO NOP

2/1 5/8 3/7 5/2 1/1 1/3

Honestly this is very easy, much more simple than some.
It is named after the Unix command cat, although this command is actually more powerful.
In the beginning there was no sense of heuristic algorithms with which they wrote.
Weirdly thruvian melodics are not terribly complex.
This is harder than I thought.
Cats are fluffy but don't fuck with them unless you're ready for the consequences.



Walking through the translation:

Say this was the source being interpreted:
    I'd just like to interject for a moment. What you're referring to as Linux, is
    in fact, GNU/Linux, or as I've recently taken to calling it, GNU plus Linux.
    Linux is not an operating system unto itself, but rather another free component
    of a fully functioning GNU system made useful by the GNU corelibs, shell
    utilities and vital system components comprising a full OS as defined by POSIX.
For each sentence, count the size of each word (ignore punctuation like ' / - " . so "I'd" is length two and "GNU/Linux" is length 8)
    2 4 4 2 9 3 1 6.
    4 5 9 2 2 5 2 2 4 8 2 2 3 8 5 2 7 2 3 4 5.
    5 2 3 2 9 6 4 6 3 6 7 4 9 2 1 5 11 3 6 4 6 2 3 3 8 5 9 3 5 6 10 10 1 4 2 2 7 2 5.
Find the average word length (round to nearest integer), count the number of words with length above, below, and equal to the average.
    avg 4, above 2, below 4, exact 2.
    avg 4, above 8, below 10, exact 3.
    avg 5, above 15, below 19, exact 5.
To translate this into instructions now, just find the ratio of above/below for each sentence.
    2/4 8/10 15/19
2/4 maps to the ADD instruction (1/2). 8/10 and 15/19 both map to NOP since they don't map exactly to another instruction.
    ADD NOP NOP
NOP results in 0 so this is ADD 0 0 which results in 0.
