%{
#include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
#include "language.tab.h"
%}

%option noyywrap

%%

"//".*  {}
"/**/"                 {} // "/* comm */"
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]  {}
("char"|"shot"|"short int"|"int"|"long"|"long int"|"long long"|"long long int"|"double"|"long double") { return SIGN_TIP; }
("bool"|"void"|"wchar_t"|"float") { return TRIVIAL_TIP;}
("signed"|"unsigned") {return TIP_SIGN;}
[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
("false"|"true"|[01]) {return BOOL_VAL;}
("/private/"|"/protected/"|"/public/")  {return ACCESMODIF;}
\'(.)\' {return CHAR_VAL;}
\"[^\n]*\" {return STRING_VAL}
(0|[+-]?[1-9][0-9]*) {return INT_VAL;}
([0-9]*[.])?[0-9]+ {return DOUBLE_VAL;}
"=" {return ASSIGN;}
"*=" {return MUL_ASSIGN;}
"%=" {return MOD_ASSIGN;}
"+=" {return ADD_ASSIGN;}
"-=" {return MIN_ASSIGN;}
"/=" {return DIV_ASSIGN;}

("/struct/") {return STRUCT;}
"begin_progr" {return BGIN;}
"end_progr" {return END;}
@[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
":=" {return ASSIGN;}
[0-9]+ {return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}
