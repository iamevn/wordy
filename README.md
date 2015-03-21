# Wordy
wip esoteric programming language inspired by [Gertrude](http://p-nand-q.com/programming/languages/gplz/gertrude.html) and designed at 3am the week before finals.

The language is designed such that any set of period-separated (or question marks and exclamation points) sentences is valid source code. Each sentence maps to one of a couple dozen instructions. The instruction that a sentence represents is found by finding the average word length in that sentence (rounded to the nearest integer) and then counting the number of words above and below that average. The ratio [words above average]/[words below average] is looked up in the below table. 2/3 maps to the same instruction as 4/9 (VALUE) and any ratio not explicitly mapped to an instruction is a NOP.

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

These ratios are not final as I would like to do some analysis on text to see what common and uncommon ratios are so I can map more important instructions (like GOTO) to the more common ratios.

# Example cat program:

    Honestly this is very easy, much more simple than some.  
    It is named after the Unix command cat, although this command is actually more powerful.
    "I know what it means well enough when I find a thing," said the Duck, "it's generally a frog or a worm."
    In both cases the manufacturer is one and the same Jew.
    In the beginning there was no sense of heuristic algorithms with which they wrote.
    Weirdly thruvian melodics are not terribly complex.
    This is harder than I thought.
    We particularly cannot permit any individual State within the nation, and the Reich which represents it, sovereign power and independent State rank.
    It dried up any trickle of pity for him that may have remained in the pirates infuriated breast.
    Cats are fluffy but don't fuck with them unless you're ready for the consequences.

# Using the interpreter:

Run wordy.rkt with the first command line arg as the filename you want to interpret and with the optional flags --to-pseudocode or --wimpmode as second and/or third args. 

--to-pseudocode will translate the file to pseudocode and output that instead of running it

--wimpmode will set it to read pseudocode in the same format as --to-pseudocode outputs from the file instead of normal sentences.

    > racket wordy.rkt hello.txt
    Hello, world!
    > racket wordy.rkt cat.txt --to-pseudocode
    LABEL NOP ASSIGN NOP OUTCHAR INCHAR GOTO NOT VALUE NOP
    > racket wordy.rkt cat.txt --to-pseudocode > cat.wordy
    > racket wordy.rkt hello.txt --to-pseudocode | racket wordy.rkt cat.wordy --wimpmode
    ASSIGN GOTO NOP ADD MULTIPLY MULTIPLY LITERAL 2 LITERAL 2 LITERAL 2 MULTIPLY LITERAL 10 LITERAL 10 ASSIGN LITERAL 1 ADD VALUE GOTO NOP LITERAL 3 OUTCHAR SUBTRACT ADD MULTIPLY LITERAL 2 MULTIPLY LITERAL 5 LITERAL 2 DIVIDE VALUE LITERAL 0 LITERAL 2 LITERAL 2 OUTCHAR SUBTRACT VALUE LITERAL 1 MULTIPLY LITERAL 2 LITERAL 5 OUTCHAR OUTCHAR VALUE LITERAL 0 ASSIGN LITERAL 1 SUBTRACT OUTCHAR VALUE LITERAL 1 ADD LITERAL 1 MULTIPLY SUBTRACT VALUE LITERAL 1 VALUE NOP LITERAL 4 OUTCHAR ADD ASSIGN VALUE GOTO NOP MULTIPLY MULTIPLY LITERAL 2 LITERAL 2 ADD DIVIDE VALUE LITERAL 1 LITERAL 10 LITERAL 1 LITERAL 4 ASSIGN VALUE LITERAL 0 ADD OUTCHAR SUBTRACT VALUE VALUE LITERAL 0 LITERAL 8 MULTIPLY LITERAL 3 LITERAL 4 OUTCHAR ADD VALUE LITERAL 0 ADD LITERAL 5 LITERAL 6 OUTCHAR ADD VALUE NOP LITERAL 3 OUTCHAR ADD MULTIPLY LITERAL 2 LITERAL 3 VALUE NOP OUTCHAR VALUE NOP OUTCHAR MULTIPLY LITERAL 10 LITERAL 10 OUTCHAR SUBTRACT VALUE VALUE NOP ADD ADD LITERAL 3 LITERAL 4 LITERAL 4
    > cat hello.bf
    ++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
    > racket brainfuck->wordy.rkt hello.bf > bfhello.wordy
    > racket wordy.rkt bfhello.wordy --wimpmode
    Hello World!

# Walking through steps to interpret some text

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

For each sentence, find the average word length (round to nearest integer), count the number of words with length above, below, and equal to the average.

    avg 4, above 2, below 4, exact 2.
    avg 4, above 8, below 10, exact 3.
    avg 5, above 15, below 19, exact 5.

To translate this into instructions now, just find the ratio of above/below for each sentence.

    2/4 8/10 15/19

2/4 maps to the ADD instruction (1/2). 8/10 and 15/19 both map to NOP since they don't map exactly to another instruction.

    ADD NOP NOP

ADD takes two arguments. NOP takes no arguments and results in 0.

    ADD 0 0

0 + 0 is 0

    0

Using this method, any text could be interpreted with Wordy and would produce a valid program. One of the core ideas in designing Wordy was to make it as safe as possible. Part of the spec is that any undefined behavior, while left up to the implementer, must not crash or create errors during interpretation. Every possible program is valid.

# brainfuck to wordy pseudocode

As brainfuck is Turing Complete, a program that translates brainfuck into wordy pseudocode would be proof that wordy is Turing Complete.
For a right-infinite tape, rules to translate brainfuck into wordy are as follows:
    
    start of file -> LABEL LITERAL 0
    
    > -> AND VALUE LITERAL 0 ASSIGN LITERAL 0 ADD VALUE LITERAL 0 LITERAL 1
    < -> AND VALUE LITERAL 0 ASSIGN LITERAL 0 SUBTRACT VALUE LITERAL 0 LITERAL 1
    + -> AND VALUE LITERAL 0 ASSIGN VALUE LITERAL 0 ADD VALUE VALUE LITERAL 0 LITERAL 1
    - -> AND VALUE LITERAL 0 ASSIGN VALUE LITERAL 0 SUBTRACT VALUE VALUE LITERAL 0 LITERAL 1
    . -> AND VALUE LITERAL 0 OUTCHAR VALUE VALUE LITERAL 0
    , -> AND VALUE LITERAL 0 ASSIGN VALUE LITERAL 0 INCHAR
    [ -> AND VALUE LITERAL 0 OR VALUE VALUE LITERAL 0 GOTO LITERAL x
         OR VALUE LITERAL 0 LABEL SUBTRACT LITERAL 0 LITERAL x
    ] -> AND VALUE LITERAL 0 AND VALUE VALUE LITERAL 0 GOTO SUBTRACT LITERAL 0 LITERAL x
         VALUE LITERAL 0 LABEL LITERAL x
         (where 'x' is 1 for the first [] pair, 2 for the second, etc)
    
    end of file -> AND VALUE LITERAL 0 EXIT
                   ASSIGN LITERAL 0 LITERAL 1
                   GOTO LITERAL 0

I have included bf-to-wordy.c and brainfuck->wordy.rkt which both read in a brainfuck file and write out the translation to wordy pseudocode. They expect one commandline arg which is the filename to translate.
