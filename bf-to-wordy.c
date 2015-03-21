#include <stdio.h>
#include <stdlib.h>

struct node {
	int val;
	struct node *next;
};

/* constructs a new node */
struct node *new_node(int val, struct node *next)
{
	struct node *new_node = (struct node*) malloc(sizeof(struct node));
	new_node->val = val;
	new_node->next = next;

	return new_node;
}

/* returns pointer to next field and frees memory for passed node */
struct node *delete_node(struct node *to_free)
{
	struct node *to_return = to_free->next;
	free(to_free);
	return to_return;
}

/* returns int val of top node in stack */
int peek(struct node *stack)
{
    return stack->val;
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        goto error;
    }
    FILE *input = fopen(argv[1], "r");
    if (input == NULL){
        goto error;
    }

    int next = fgetc(input);
    int x = 0;
    struct node *unmatched;

    printf("LABEL LITERAL 0\n");

    while (next != EOF) {
        switch(next){
            case '>':
                printf("AND VALUE LITERAL 0 ASSIGN LITERAL 0 ADD VALUE LITERAL 0 LITERAL 1\n");
                break;
            case '<':
                printf("AND VALUE LITERAL 0 ASSIGN LITERAL 0 SUBTRACT VALUE LITERAL 0 LITERAL 1\n");
                break;
            case '+':
                printf("AND VALUE LITERAL 0 ASSIGN VALUE LITERAL 0 ADD VALUE VALUE LITERAL 0 LITERAL 1\n");
                break;
            case '-':
                printf("AND VALUE LITERAL 0 ASSIGN VALUE LITERAL 0 SUBTRACT VALUE VALUE LITERAL 0 LITERAL 1\n");
                break;
            case '.':
                printf("AND VALUE LITERAL 0 OUTCHAR VALUE VALUE LITERAL 0\n");
                break;
            case ',':
                printf("AND VALUE LITERAL 0 ASSIGN VALUE LITERAL 0 INCHAR\n");
                break;
            case '[':
                x += 1;
                printf("AND VALUE LITERAL 0 OR VALUE VALUE LITERAL 0 GOTO LITERAL %d\nOR VALUE LITERAL 0 LABEL SUBTRACT LITERAL 0 LITERAL %d\n", x, x);
                unmatched = new_node(x, unmatched);
                break;
            case ']':
                printf("AND VALUE LITERAL 0 AND VALUE VALUE LITERAL 0 GOTO SUBTRACT LITERAL 0 LITERAL %d\nOR VALUE LITERAL 0 LABEL LITERAL %d\n", peek(unmatched), peek(unmatched));
                unmatched = delete_node(unmatched);
                break;
            default:
                break;
        }
        next = fgetc(input);
    }

    printf("AND VALUE LITERAL 0 EXIT\nASSIGN LITERAL 0 LITERAL 1\nGOTO LITERAL 0");

    return 0;
error:
    dprintf(2, "Usage: %s filename\n", argv[0]);
    return 1;
}

