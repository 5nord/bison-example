#include <stdlib.h>
#include <string.h>
#include "node.h"

static node_t *new_node(loc_t *loc, enum node_type type)
{
    node_t *node = calloc(1, sizeof *node);
    if (!node)
        return NULL;

    node->type = type;
    node->loc  = *loc;
    return node;
}

const char *node_type_str(enum node_type type)
{
    static const char *map[] = {
        #define TREE(Kind) [ NODE_ ## Kind ] = # Kind,
        #include "node.def"
    };

    return map[type];
}

int node_has_value(enum node_type type)
{
    switch (type)
    {
    #define VALUE(Kind) case NODE_ ## Kind:
    #include "node.def"
        return 1;
    default:
        return 0;
    };
}

int node_has_children(enum node_type type)
{
    /* NOTE: Current implementation has either a value or children */
    return !node_has_value(type);
}

node_t *node_concat(node_t *first, node_t *second)
{
    node_t *last = first;
    while (last->next)
        last = last->next;
    last->next = second;

    return first;
}

node_t *new_node_value(loc_t *loc, enum node_type type, const char *str)
{
    node_t *node = new_node(loc, type);
    if (!node)
        return NULL;
    node->value = strdup(str);
    return node;
}

node_t *new_node_tree(loc_t *loc, enum node_type type, int n, ...)
{
    node_t *node = new_node(loc, type);
    if (!node)
        return NULL;

    va_list ap;
    va_start(ap, n);

    node_t *last = node;
    for (int i=0; i<n; ++i)
    {
        node_t *child = va_arg(ap, node_t*);

        /* skip empty children */
        if (!child)
            continue;

        last->next = child;
        last = child;

        /* "flatten" children */
        while (last->next)
            last = last->next;
    }

    va_end(ap);

    node->first_child = node->next;
    node->next = NULL;

    return node;
}

void node_visit(node_t *node, node_visitor_t visit, void *priv)
{
    if (!visit)
        return;

    while (node)
    {
        if (visit(node, priv) < 0)
            return;
        node = node->next;
    }
}

void node_visit_children(node_t *root, node_visitor_t visit, void *priv)
{
    if (root && node_has_children(root->type))
        node_visit(root->first_child, visit, priv);
}
