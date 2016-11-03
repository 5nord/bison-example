#ifndef NODE_H
#define NODE_H

#include <stddef.h>
#include <stdarg.h>
#include <string.h>

enum node_type
{
    NODE_UNKNOWN = 0,
    NODE_EPSILON = 0,
    #define TREE(Kind) NODE_ ## Kind,
    #include "node.def"
    NODE_COUNT,
};

typedef struct loc {
    size_t begin;
    size_t end;
} loc_t;

typedef struct node {
    enum node_type type;
    union {
        struct node *first_child;
        const char *value;
    };
    struct node *next;
    loc_t loc;
} node_t;

/* Callback type for node_visit_children */
typedef int (*node_visitor_t) (node_t *node, void *priv);

/* stringify node_type */
const char *node_type_str(enum node_type);

/* check if node is a value-node or list-node */
int node_has_value(enum node_type);

/* check if node is a value-node or list-node */
int node_has_children(enum node_type);

/* chains two nodes together */
node_t *node_concat(node_t *first, node_t *second);

/* create new value node. Note: value is newly created using strdup */
node_t *new_node_value(loc_t *loc, enum node_type type, const char *str);

/* Create new parent node and add its children */
node_t *new_node_tree(loc_t *loc, enum node_type type, int n, ...);

/* Visit sibling nodes. Stops whens visitor has return value < 0 */
void node_visit(node_t *root, node_visitor_t visit, void *priv);

/* Visit children. Stops whens visitor has return value < 0 */
void node_visit_children(node_t *root, node_visitor_t visit, void *priv);

/* Merge two locations */
static inline
loc_t node_loc_merge(const loc_t *first, const loc_t *second)
{
    loc_t loc = {
        .begin = first->begin,
        .end   = second->end,
    };

    return loc;
}

/* Initialize a location */
static inline
loc_t node_loc_init(size_t line)
{
    loc_t loc = {
        .begin = line,
        .end   = line,
    };

    return loc;
}

/* Extend location */
static inline
void node_loc_extend(loc_t *loc, size_t line)
{
    loc->end = line;
}


#endif
