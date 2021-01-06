%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "language.tab.h"
%}

%option noyywrap

%%
("char"|"shot"|"short int"|"int"|"long"|"long int"|"long long"|"long long int"|"double"|"long double") { yylval.str = strdup(yytext); return SIGN_TIP; }
"//".*          {}
"/*.**/"        {} // "/* comm */"
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/] {}
("bool"|"void"|"wchar_t"|"float")   { yylval.str = strdup(yytext); return TRIVIAL_TIP;}
("private"|"protected"|"public")    { yylval.str = strdup(yytext); return ACCESMODIF;}
"signed"                { yylval.num = 1; return TIP_SIGN;}
"unsigned"              { yylval.num = 0; return TIP_SIGN;}
([0-9]*[.])?[0-9]+      {
                            char *real, *zecim, *ch = strdup(yytext);

                            real = strtok_r(ch, ".", &zecim);
                            yylval.rnum = atoi(real);

                            int k = 1;
                            int n = strlen(zecim);
                            while (n) { n--; k *= 10; }

                            yylval.rnum += (double)atoi(zecim) / k;
                            return DOUBLE_VAL;
                        }
(0|[+-]?[1-9][0-9]*)    {
                            yylval.num = atoi(yytext);
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
[_a-zA-Z][_a-zA-Z0-9]*  { yylval.str = strdup(yytext); return ID; }
['"].['"]               { yylval.str = strdup(yytext); return CHAR_VAL; }
(["].*["])              { yylval.str = strdup(yytext); return STRING_VAL; }
[ \t]                   ;
\n                      { yylineno++; }
.                       { return yytext[0]; }

