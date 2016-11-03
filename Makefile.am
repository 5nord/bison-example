AM_CFLAGS = -g -O0 -W -Wall -Wextra

noinst_LIBRARIES           = libexampleparser.a
libexampleparser_a_SOURCES = \
		example/parser.y \
		example/parser.h \
		example/lexer.l  \
		example/node.c   \
		example/node.h   \
		example/node.def

bin_PROGRAMS = main
main_SOURCES = main.c
main_DEPENDENCIES = libexampleparser.a

LIBS = libexampleparser.a

maintainer-clean-local:
	-rm -f example/parser.h example/parser.output
