%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
("false"|"true"|[01])   {
                            if( strcmp(yytext, "false") == 0) {
                                yylval.num = 0;
                            } else if( strcmp(yytext, "true") == 0) {
                                yylval.num = 1;
                            } else {
                                yylval.num = atoi(yytext);
                            }
                            printf("bool %d", yylval.num);
                            return BOOL_VAL;
                        }
([0-9]*[.])?[0-9]+      {
                            printf("l double\n");
                            return DOUBLE_VAL;
                        }
(0|[+-]?[1-9][0-9]*)    {
                            yylval.num = atoi(yytext);
                            printf("int %d", yylval.num);
                            return INT_VAL;
                        }
"="                     { return ASSIGN; }
"*="                    { return MUL_ASSIGN; }
"%="                    { return MOD_ASSIGN; }
"+="                    { return ADD_ASSIGN; }
"-="                    { return MIN_ASSIGN; }
"/="                    { return DIV_ASSIGN; }
">"                     { return GREATER; }
"<"                     { return LOWER; }
"->"                    { return PMEM; }
"++"                    { return INCR; }
"--"                    { return DECR; }
"=="                    { return EQUAL; }
"!="                    { return NOT_EQ; }
"<="                    { return LOWER_EQ; }
">="                    { return GREATER_EQ; }
"+"                     { return ADD; }
"-"                     { return MIN; }
"*"                     { return MUL; }
"\/"                    { return DIV; }
"%"                     { return MOD; }
"!"                     { return NOT; }
"||"|"or"               { return OR; }
"&&"|"and"              { return AND; }
"struct"                { return STRUCT; }
"const"                 { return CONST; }
"static"                { return STATIC; }
"print"                 { return PRINT; }
"if"                    { return IF; }
"else"                  { return ELSE; }
"while"                 { return WHILE; }
"do"                    { return DO; }
"for"                   { return FOR; }
"return"                { return RETURN; }
"eval"                  { return EVAL; }
"calc"                  { return CALC; }
"class"                 { return CLASS; }
[_a-zA-Z][_a-zA-Z0-9]*  { return ID; }
['"].['"]               { return CHAR_VAL; }
(["].*["])              { return STRING_VAL; }
[ \t]                   ;
\n                      { yylineno++; }
.                       { return yytext[0]; }

