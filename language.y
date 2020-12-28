%{
#include <stdio.h>
extern FILE * yyin;
extern char * yytext;
extern int yylineno;

void yyerror(char * s)
{
     printf("eroare: %s la linia:%d\n",s,yylineno);
}
%}
%token ID TIP BGIN END ASSIGN NR 
%start begin

%%

/**************************************************************/
/**************** GLOBAL RULES ********************************/
/**************************************************************/

data_type : TRIVIAL_TIP
          | SIGN_TIP
          | TIP_SIGN SIGN_TIP
          ;

const_value : INT_VAL
          | CHAR_VAL
          | STRING_VAL
          | BOOL_VAL
          | DOUBLE_VAL
          ;

variable_idendifier : ID
          | variable_idendifier ',' ID
          ;

variable_dec : data_type variable_idendifier ';'
          | data_type ID ASSIGN expr ';'
          ;

statement : variable_dec
          | function_call
          | if_statement
          | for_statement
          | while_statement
          | dowhile_statement
          | asign_statement
          ;

statement_list : statement
          | statement_list statement
          ;

block_body : statement_list

ref_val : ID
          | ID PMEM ID
          | ID '.' ID
          ;

caller_params : expr
          | expr ',' caller_params
          ;

function_call : ID '(' caller_params ')' ';'
          | ID '(' ')' ';'
          ;

block : '{' block_body '}'
          | statement
          ;

asign_statement : ref_val ASSIGN expr ';' 
          | ref_val MUL_ASSIGN expr ';' 
          | ref_val MOD_ASSIGN expr ';' 
          | ref_val ADD_ASSIGN expr ';' 
          | ref_val MIN_ASSIGN expr ';' 
          | ref_val DIV_ASSIGN expr ';' 
          ;

/**************************************************************/
/**************** FOR RULES ***********************************/
/**************************************************************/

loop_init : statement 
          | ''
          ;

stop_cond : lo_expr
          | ''
          ;

loop_step : expr
          | ''
          ;

for_statement : FOR '(' loop_init ';' stop_cond ';' loop_step ')' block ;

/**************************************************************/
/************* WHILE & DO WHILE RULES *************************/
/**************************************************************/

dowhile_statement : DO block WHILE '(' lo_expr ')' ';'

while_statement: WHILE '(' stop_cond ')' block

/**************************************************************/
/**************** IF RULES ************************************/
/**************************************************************/

if_statement : IF '(' lo_expr ')' block
          | IF '(' lo_expr ')' block ELSE block 
          ;

/**************************************************************/
/**************** EXPRESIONS RULES ****************************/
/**************************************************************/

operand : ref_val
          | const_value
          | expr
          ;

lo_operand : ref_val
          | BOOL_VAL
          | function_call
          | lo_expr
          ;

lo_expr : NOT lo_expr 
          | lo_expr AND lo_expr
          | lo_expr OR lo_expr
          | lo_operand
          | arhimetic_expr GREATER arhimetic_expr
          | arhimetic_expr LOWER arhimetic_expr
          | arhimetic_expr EQUAL arhimetic_expr
          | arhimetic_expr NOT_EQ arhimetic_expr
          | arhimetic_expr LOWER_EQ arhimetic_expr
          | arhimetic_expr GREATER_EQ arhimetic_expr
          ;

value : const_value
          | ref_val
          | function_call
          ;

arhimetic_operand : INCR ref_val
          | ref_val
          | ref_val INCR
          | ref_val DECR
          | DECR ref_val
          | const_value
          | const_value INCR
          | const_value DECR
          | INCR const_value
          | DECR const_value
          | function_call
          | function_call INCR
          | function_call DECR
          | INCR function_call
          | DECR function_call
          ;

arhimetic_expr : arhimetic_operand
          | arhimetic_expr ADD arhimetic_expr
          | arhimetic_expr MIN arhimetic_expr
          | arhimetic_expr MUL arhimetic_expr
          | arhimetic_expr DIV arhimetic_expr
          | arhimetic_expr MOD arhimetic_expr

expr : lo_expr
          | arhimetic_expr
          | function_call
          | const_value
          | ref_val
          ;

/**************************************************************/
/**************** FUNCTIONS RULES *****************************/
/**************************************************************/

no_parameter : data_type ID ;

op_parameter : data_type ID ASSIGN const_value ;

no_parameter_list : no_parameter
               | no_parameter_list ',' no_parameter
               ;

// lista de parametrii optionali
// poate sa aiba doar la sfarsit
op_parameter_list : op_parameter_list ',' op_parameter
               | op_parameter
               | no_parameter
               | no_parameter_list ',' no_parameter
               ;

parameter_list : op_parameter_list

function_head : data_type ID '(' parameter_list ')'
          | data_type ID '(' ')'
          ;

function_dec : function_head ';' ;

function_def : function_head '{' block_body '}' ';' ;

function  : function_dec
          | function_def
          ;

/**************************************************************/
/**************** STRUCT && CLASS RULES ***********************/
/**************************************************************/

acces_modifier : ACCMDF ':' ;

member_declarations : variable_dec
          | STATIC variable_dec
          | function_dec
          | STATIC function_dec

struct_member : member_declarations
          | acces_modifier member_declarations
          ;

struct_body : struct_member
          | struct_body struct_member
          ;

struct_head : ID
          | ID '{' struct_body '}' 
          | ID '{' struct_body '}' variable_idendifier 
          ;

struct_dec : STRUCT struct_head ';'
          | CLASS struct_head ';'
          ;

/**************************************************************/
/**************** START RULES *********************************/
/**************************************************************/

declarations : variable_dec
          | variable_dec declarations
          | struct_dec 
          | struct_dec declarations
          | function
          | function declarations

begin     : declarations { printf("program corect sintactic\n"); }
          ;

%%

int main(int argc, char** argv)
{
     yyin=fopen(argv[1],"r");
     yyparse();
} 