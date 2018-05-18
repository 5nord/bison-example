# Bison Example

A parser generator like bison is very helpful for prototyping grammars,
unfortunately is requires quite some code to get it up and running. This is just
a very small example to show what boilerplate code I need to build a bison-based
parser.

What I like about bison is, you can compile and deploy a bison-project without
having any additional tools or runtime libraries installed. Further having a
C-interface avoids common issues with C++ runtime compatibility when deploying
shared libraries. 

This example uses autotools, a pure flex-scanner and bison-parser with locations
(in this this example only lines). Output is a simple tree, which links its
elements using single-linked lists. Simple routines for tree traversal are
provided, too.

The example-grammar is just nonsense:

    Names  ::= {Name}+
    Name   ::= ID | FooBar
    FooBar ::= "foo" [Bar]
    Bar    ::= "bar"


## Compilation

Normally auto-generated files like Makefile.in or parser.c are included in the
repository to simplify compilation. But I left them out, to keep the example
small. So, that's how you bootstrap autotools and compile this example:

    $ autoreconf -i
    $ ./configure
    $ make

# Notes

## Autotools

 * the scanner and parser files must have different base-names, or they will
   overwrite each other. I named them `lexer.l` and `parser.y` and put them into
   a sub-directory, in case a project requires more than one parser.
 * The parser builds as library. Don't forget to give Automake the proper,
   dependencies.


## AST

 * Node types are defined in `example/node.def`.
 * Nodes either have a value _or_ children.
 * Appending nodes is inefficient due to single-linked lists.
 * Line handling seems to be over-engineered. That's because in my projects I
   prefer to use file-offsets and line-caches instead; similar to clang or
   golang parsers. See https://github.com/nokia/ntt/blob/bison-parser/ttcn3/syntax/source.h for example.


## Bison

 * Virtually all rules have to return nodes, because nodes are lists. Empty
   rules return an Epsilon node. This makes evaluating the AST easier.
 * I did not change `yy`-prefix. If you require more than one parser you'll
   have to rename global symbols.

## Flex

 * For simplicity values are just `strdup`ed. 
 * Like with bison, you'll might have to change the prefix.

