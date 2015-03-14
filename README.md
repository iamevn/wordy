# Wordy
wip esoteric programming language inspired by [Gertrude](http://p-nand-q.com/programming/languages/gplz/gertrude.html) and designed at 3am the week before finals.

The language is designed such that any set of period-separated sentences is valid source code. Each sentence maps to one of a couple dozen instructions. The instruction that a sentence represents is found by finding the average word length in that sentence (rounded to the nearest integer) and then counting the number of words above and below that average. The ratio [words above average]/[words below average] is looked up in the below table. 2/3 maps to the same instruction as 4/9 (VALUE) and any ratio not explicitly mapped to an instruction is a NOP.

    ratio | command
    :----:|:-------:
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

These ratios are not final as I would like to do some analysis on text to see what common and uncommon ratios are so I can map more important instructions (like GOTO) to the more common ratios.

# Example cat program:
    Honestly this is very easy, much more simple than some.
    It is named after the Unix command cat, although this command is actually more powerful.
    In the beginning there was no sense of heuristic algorithms with which they wrote.
    Weirdly thruvian melodics are not terribly complex.
    This is harder than I thought.
    Cats are fluffy but don't fuck with them unless you're ready for the consequences.

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

Using this method, any text could be interpreted with Wordy and would produce a valid program. One of the core ideas in Wordy was to make it as safe as possible. Part of the spec is that any undefined behavior, while left up to the implementer, must not crash or create errors during interpretation. Every possible program is valid.
