%{
#include "example/parser.h"
#define YY_EXTRA_TYPE driver_t*
#define YY_VALUE(Tok) (yylval->string = strdup(yytext), Tok)
#define YY_NEW_LINE
#define YY_USER_ACTION {             \
        yylloc->begin = yylloc->end; \
        yylloc->end   = yylineno;    \
}

#define yyterminate() return TOK_EOF;

%}

%option noyywrap nounput noinput batch reentrant
%option bison-bridge bison-locations
%option yylineno
%x COMMENT

ws         [ \t]
nl         [\r\n]
alpha      [A-Za-z]
alnum      [A-Za-z_0-9]
utf8       [\x01-\x7f]|[\x80-\xff]+
Identifier {alpha}{alnum}*

%% /* Rules */

{ws}+

<*>{
 {ws}+
 {nl}            YY_NEW_LINE;
 ^{ws}*#.+{nl}   YY_NEW_LINE;
 "//".*{nl}      YY_NEW_LINE;
 "/*"            BEGIN(COMMENT);
}

<COMMENT>{
 [^*\r\n]*
 [^*\r\n]*\n         YY_NEW_LINE;
 "*"+[^*/\r\n]*
 "*"+[^*/\r\n]*\r\n  YY_NEW_LINE;
 "*"+"/"             BEGIN(INITIAL);
}

<INITIAL>{
 "foo"          return TOK_FOO;
 "bar"          return TOK_BAR;
 {Identifier}   return YY_VALUE(ID);
}


"\0"            return TOK_EOF;
{utf8}          yyerror(yylloc, yyextra, NULL, "invalid input");

%% /* Footer */

void example_lexer_begin(driver_t *driver)
{
        yylex_init_extra(driver, &driver->scanner);
        yyrestart(driver->fd, driver->scanner);
}

void example_lexer_end(driver_t *driver)
{
        yylex_destroy(driver->scanner);
}
