%{
#include <stdio.h>
extern FILE * yyin;
extern char * yytext;
extern int yylineno;
%}
%token ID TIP BGIN END ASSIGN NR 
%start progr
%%
progr: declaratii bloc {printf("program corect sintactic\n");}
     ;

data_type : TRIVIAL_TIP
          | SIGN_TIP
          | TIP_SIGN SIGN_TIP
          ;

struct_dec : STRUCT { LIST_PART } ';'
          | STRUCT { LIST_PART } ID ';'
          | TYPEDEF STRUCT { LIST_PART } ID ';'

declaratii :  declaratie ';'
	   | declaratii declaratie ';'
	   ;
declaratie : TIP ID 
           | TIP ID '(' lista_param ')' // float @auds(int @aux)
           | TIP ID '(' ')'
           ;
lista_param : param
            | lista_param ','  param 
            ;
            
param : TIP ID
      ; 
      
/* bloc */
bloc : BGIN list END  
     ;
     
/* lista instructiuni */
list :  statement ';' 
     | list statement ';'
     ;

/* instructiune */
statement: ID ASSIGN ID
         | ID ASSIGN NR  		 
         | ID '(' lista_apel ')'
         ;
        
lista_apel : NR
           | lista_apel ',' NR
           ;
%%
void yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 