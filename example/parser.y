/* Procude a GLR parser */
%glr-parser

/* Create a parser-header files for flex */
%defines

/* Verbose error messages */
%error-verbose

/* Enable location tracking */
%locations

/* Create a pure parser */
%define api.pure

/* `driver_t` (defined below) holds shared data */
%parse-param              {driver_t *driver}

/* Pass flex's yyscanner through bison */
%parse-param              {void *scanner}
%lex-param                {void *scanner}

%code requires {
    #define _GNU_SOURCE
    #include <stdio.h>
    #include "node.h"

	typedef struct driver {
    	const char *file;
        FILE *fd;
    	node_t *root;
    	void *scanner;
	} driver_t;

    #define YYLTYPE loc_t
}

%union {
    const char *string;
    node_t *node; 
}

%{
    /* Bison needs these macros to handle custom locations */
	#define YYLLOC_DEFAULT(Cur, Rhs, N)                 \
	do                                                  \
  	if (N) {                                            \
        (Cur) = node_loc_merge(&(YYRHSLOC(Rhs, 1)),     \
                               &(YYRHSLOC(Rhs, N)));    \
  	} else {                                            \
      	(Cur).begin = (Cur).end = YYRHSLOC(Rhs, 0).end; \
  	}                                                   \
	while (0)

    /* Create a subtree of type `Type` */
    #define TREE(Type, ...) \
        new_node_tree(yylocp, NODE_ ## Type, \
                        COUNT_ARGS(__VA_ARGS__), ## __VA_ARGS__)
	#define COUNT_ARGS(...) \
		(sizeof((node_t*[]){__VA_ARGS__})/sizeof(node_t*))

    /* Create a value node to type `Type` */
    #define VALUE(Type, Str) \
        new_node_value(yylocp, NODE_ ## Type, Str)

    /* Create an empty node, this simplifies handling of optional elements
     * during AST traversal
     */
    #define EPSILON TREE(EPSILON)

    /* Constructing lists */
    #define LIST_NEW(Node)               Node
    #define LIST_APPEND(First, Second)   chainon((First), (Second))

    static inline node_t *chainon(node_t *first, node_t *second)
    {
        if (!first && !second)
            return NULL;

        if (!first)
            return second;

        if (!second)
            return first;

        return node_concat(first, second);
    }
%}

/* Parser header is shared between lexer, parser and user */
%code provides
{
    /* entry point for parsing files */
    node_t *example_parse(const char *file);

    /* shared error handler */
    void yyerror(loc_t *loc, driver_t *driver, void*, const char *msg);

    /* provided by lexer to circumvent lexer-header problems */
    extern void example_lexer_begin(driver_t *driver);
    extern void example_lexer_end(driver_t *driver);

    /* NOTE: lexer protoype is in the parser-header to prevent
     *       conflicting types.
     */
	#define YY_DECL int yylex \
               (YYSTYPE* yylval_param, loc_t* yylloc_param , void *yyscanner)
    extern YY_DECL;

}

%initial-action
{
    @$ = node_loc_init(1);
}

%token          TOK_EOF     0       "end of input"
%token <string> ID                  "identifier"
%token <string> STRING              "string literal"
%token <string> INTEGER             "integer literal"
%token <string> FLOAT               "float literal"

%token <node>   TOK_FOO             "foo"
%token <node>   TOK_BAR             "bar"

%type <node> Names Name
%type <node> FooBar OptBar

%% /* Grammar */

parse
    : Names  { driver->root = $1; }
    ;

Names
    : Name       { $$ = LIST_NEW($1);        }
    | Names Name { $$ = LIST_APPEND($1, $2); }
    ;

Name
    : ID         { $$ = VALUE(ID, $1); }
    | FooBar     { $$ = $1;            }
    ;
    
FooBar
    : "foo" OptBar { $$ = TREE(FOO, $2); }
    ;

OptBar
    : /* empty */ { $$ = EPSILON;   }
    | "bar"       { $$ = TREE(BAR); }
    ;

%% /* Footer */

void yyerror(loc_t *loc, driver_t *driver, void *scanner,  const char *msg)
{
    (void) scanner;
    fprintf(stderr, "%s:%ld error: %s\n", driver->file, loc->begin, msg);
}

node_t *example_parse(const char *file)
{
    driver_t driver;
    driver.file = file;
    driver.fd   = fopen(file, "r");
    example_lexer_begin(&driver);
    int ret = yyparse(&driver, driver.scanner);
    example_lexer_end(&driver);
    if (ret == 0)
        return driver.root;
    return NULL;
}
