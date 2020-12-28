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

"begin_progr" {return BGIN;}
"end_progr" {return END;}
@[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
":=" {return ASSIGN;}
[0-9]+ {return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}
