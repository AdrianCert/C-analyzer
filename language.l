%{
#include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
#include "language.tab.h"
%}

%option noyywrap

%%
("char"|"shot"|"short int"|"int"|"long"|"long int"|"long long"|"long long int"|"double"|"long double") { return SIGN_TIP; }
"//".*          {}
"/*.**/"        {} // "/* comm */"
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/] {}
("bool"|"void"|"wchar_t"|"float")   { return TRIVIAL_TIP;}
("private"|"protected"|"public")    { return ACCESMODIF;}
("signed"|"unsigned")   { return TIP_SIGN;}
("false"|"true"|[01])   { return BOOL_VAL;}
(0|[+-]?[1-9][0-9]*)    { return INT_VAL;}
([0-9]*[.])?[0-9]+      { return DOUBLE_VAL;}
[_a-zA-Z][_a-zA-Z0-9]*  { return ID; }
"="                     { return ASSIGN; }
"*="                    { return MUL_ASSIGN; }
"%="                    { return MOD_ASSIGN; }
"+="                    { return ADD_ASSIGN; }
"-="                    { return MIN_ASSIGN; }
"/="                    { return DIV_ASSIGN; }
"struct"                { return STRUCT; }
">"                     { return GREATER; }
"<"                     { return LOWER; }
"++"                    { return INCR; }
"--"                    { return DECR; }
"=="                    { return EQUAL; }
"!="                    { return NOT_EQ; }
"<="                    { return LOWER_EQ; }
">="                    { return GREATER_EQ; }
"+"                     { return ADD; }
"-"                     { return MIN; }
"*"                     { return MUL; }
"||"|"or"               { return OR; }
"&&"|"and"              { return AND; }
"!"                     { return NOT; }
"div"                   { return DIV; }
"%"                     { return MOD; }
"const"                 { return CONST; }
"static"                { return STATIC; }
"->"                    { return PMEM; }
"print"                 { return PRINT; }
"if"                    { return IF; }
"else"                  { return ELSE; }
"while"                 { return WHILE; }
"do"                    { return DO; }
"for"                   { return FOR; }
"return"                { return RETURN; }
"class"                 { return CLASS; }
['""].['"]              { return CHAR_VAL; }
(["].*["])              { return STRING_VAL; }
[ \t]                   ;
\n                      { yylineno++; }
.                       { return yytext[0]; }

