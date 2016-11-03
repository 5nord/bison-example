#include "example/node.h"
#include "example/parser.h"
#include <stdio.h>

int dump_tree(node_t *node, void *priv)
{
	int *indent = (int*) priv;

	printf("%*s%lu: %s",
           *indent*4, "",
           node->loc.begin,
           node_type_str(node->type));

	if (node_has_value(node->type))
		printf(": `%s`", node->value);

    printf("\n");

    ++(*indent);
    node_visit_children(node, dump_tree, indent);
    --(*indent);

	return 0;
}

int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <file-to-parse>\n\n", argv[0]);
        return 2;
    }

    node_t *root = example_parse(argv[1]);
    if (!root)
        return -1;

	int indent = 0;
	node_visit(root, dump_tree, &indent);

    return 0;
}
