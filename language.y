%{
     #include <stdio.h>

     int yylex();

     extern FILE * yyin;
     extern char * yytext;
     extern int yylineno;

     struct vartable {
          char type[25]; 
     }

     void yyerror(char * s)
     {
          printf("eroare: %s la linia:%d\n",s,yylineno);
     }

%}

%token SIGN_TIP TRIVIAL_TIP TIP_SIGN ID 
%token BOOL_VAL CHAR_VAL STRING_VAL INT_VAL DOUBLE_VAL
%token ASSIGN MUL_ASSIGN MOD_ASSIGN ADD_ASSIGN MIN_ASSIGN DIV_ASSIGN
%token EQUAL NOT_EQ LOWER_EQ GREATER_EQ GREATER LOWER
%token EVAL CALC
%token CONST STATIC PRINT PMEM
%token RETURN IF ELSE WHILE DO FOR
%token STRUCT CLASS ACCESMODIF

%left OR AND NOT
%left MUL DIV MOD
%left ADD MIN
%left INCR DECR

%union
{
     char * str;
     int num;
     double rnum;
}

%type <str> SIGN_TIP ID TRIVIAL_TIP CHAR_VAL STRING_VAL
%type <num> BOOL_VAL INT_VAL lo_expr lo_operand
%type <rnum> DOUBLE_VAL arhimetic_expr expr ref_val const_value function_call calc_statement arhimetic_operand arhimetic_expr_r

%start begin

%%

/**************************************************************/
/**************** GLOBAL RULES ********************************/
/**************************************************************/

data_type : TRIVIAL_TIP { printf("Fc %s", $1);}
          | SIGN_TIP { printf("Fc %s", $1);}
          | TIP_SIGN SIGN_TIP { printf("Fc %s", $2);}
          ;

const_value : INT_VAL { printf("y int reg %d \n", $1); $$ = $1; }
          | CHAR_VAL { printf("y char\n"); }
          | STRING_VAL { printf("y string\n"); }
          | BOOL_VAL { printf("y bool\n"); }
          | DOUBLE_VAL { printf("y double\n"); }
          ;

variable_idendifier : ID {
                              char srt[100];
                             // strcmd$$ = 
                         }
          | variable_idendifier ',' ID
          ;

variable_dec : data_type variable_idendifier ';' //{ printf("%s, $1"); }
          | data_type ID ASSIGN expr ';' //{ printf("%s, $1"); }
          ;

statement : variable_dec
          | function_call
          | if_statement
          | for_statement
          | while_statement
          | dowhile_statement
          | asign_statement
          | eval_statement
          ;

statement_list : statement
          | statement_list statement
          ;

ref_val : ID { $$ = 0; } //call_get value;
          | ID PMEM ID { $$ = 0; } //call_get value;
          | ID '.' ID { $$ = 0; } //call_get value;
          ;

caller_params : expr
          | expr ',' caller_params
          ;

function_call : ID '(' caller_params ')' ';' { $$ = 0;}
          | ID '(' ')' ';' { $$ = 0; }
          ;

block : '{' statement_list '}'
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
/**************** EVAL & CALC RULES ***************************/
/**************************************************************/

eval_statement : EVAL '(' '"' arhimetic_expr '"'')' ';' { printf("ok"); }

calc_statement : CALC '(' '"' arhimetic_expr '"' ')' ';' { $$ = $4; }

/**************************************************************/
/**************** FOR RULES ***********************************/
/**************************************************************/

loop_init : statement 
          |
          ;

stop_cond : lo_expr
          |
          ;

loop_step : expr
          |
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

lo_operand : BOOL_VAL { $$ = $1; }
          | lo_expr;
          ;

lo_expr : NOT lo_operand { $$ = !$2; }
          | lo_operand AND lo_operand { $$ = $1 && $3; }
          | lo_operand OR lo_operand { $$ = $1 || $3; }
          | lo_operand { $$ = $1; }
          | '(' lo_expr ')' { $$ = $2; }
          | arhimetic_expr GREATER arhimetic_expr { $$ = $1 > $3; }
          | arhimetic_expr LOWER arhimetic_expr_r { $$ = $1 < $3; }
          | arhimetic_expr EQUAL arhimetic_expr_r { $$ = $1 == $3; }
          | arhimetic_expr NOT_EQ arhimetic_expr_r { $$ = $1 != $3; }
          | arhimetic_expr LOWER_EQ arhimetic_expr_r { $$ = $1 <= $3; }
          | arhimetic_expr GREATER_EQ arhimetic_expr_r { $$ = $1 >= $3; }
          ;

arhimetic_operand : INCR ref_val { $$ = ++$2; }
          | ref_val { $$ = $1; }
          | ref_val INCR { $$ = $1++; }
          | ref_val DECR { $$ = $1--; }
          | DECR ref_val { $$ = --$2; }
          | const_value { $$ = $1; } ;
          | const_value INCR { $$ = $1++; }
          | const_value DECR { $$ = $1--; }
          | INCR const_value { $$ = ++$2; }
          | DECR const_value { $$ = --$2; }
          | function_call { $$ = $1; }
          | function_call INCR { $$ = $1++; }
          | function_call DECR { $$ = $1++; }
          | INCR function_call { $$ = ++$2; }
          | DECR function_call { $$ = --$2; }
          ;

arhimetic_expr_r: '(' arhimetic_expr ')' { $$ = $2; }
          | arhimetic_expr { $$ = $1; }
          ;

// arhimetic_expr_l: '(' arhimetic_expr ')'
//           | arhimetic_expr
//           ;

arhimetic_expr : arhimetic_operand { $$ = $1; }
          | '(' arhimetic_expr ')' { $$ = $2; }
          | arhimetic_expr ADD arhimetic_expr { $$ = $1 + $3; }
          | arhimetic_expr MIN arhimetic_expr { $$ = $1 - $3; }
          | arhimetic_expr MUL arhimetic_expr { $$ = $1 * $3; }
          | arhimetic_expr DIV arhimetic_expr { $$ = $1 / $3; }
          | arhimetic_expr MOD arhimetic_expr { $$ = $1 - (int)($1 / $3); }
          // | '(' arhimetic_expr ADD arhimetic_expr ')' { $$ = $2 + $4; }
          // | '(' arhimetic_expr MIN arhimetic_expr ')' { $$ = $2 - $4; }
          // | '(' arhimetic_expr MUL arhimetic_expr ')' { $$ = $2 * $4; }
          // | '(' arhimetic_expr DIV arhimetic_expr ')' { $$ = $2 / $4; }
          // | '(' arhimetic_expr MOD arhimetic_expr ')' { $$ = $2 - (int)($2 / $4); }
          ;

expr : lo_expr { $$ = $1; }
          | arhimetic_expr { $$ = $1; }
          // | function_call
          // | const_value { $$ = $1; }
          // | ref_val { $$ = $1; }
          | calc_statement
          ;

/**************************************************************/
/**************** FUNCTIONS RULES *****************************/
/**************************************************************/

no_parameter : data_type ID ;

op_parameter : data_type ID ASSIGN const_value ;

no_parameter_list : no_parameter
               | no_parameter ',' no_parameter_list
               ;

// lista de parametrii optionali
// poate sa aiba doar la sfarsit
op_parameter_list : op_parameter ',' op_parameter_list
               | no_parameter_list
               | op_parameter
               ;

parameter_list : op_parameter_list

function_head : data_type ID '(' parameter_list ')'
          | data_type ID '(' ')'
          ;

function_dec : function_head ';' ;

function_def : function_head '{' statement_list '}' ';' ;

function  : function_dec
          | function_def
          ;

/**************************************************************/
/**************** STRUCT && CLASS RULES ***********************/
/**************************************************************/

acces_modifier : ACCESMODIF ':' ;

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

declarations : 
     variable_dec declarations
     | struct_dec declarations
     | function declarations
     | function
     | struct_dec
     | variable_dec
     ;

begin     : declarations { printf("program corect sintactic\n"); }
          ;

%%

int main(int argc, char** argv)
{
     yyin=fopen(argv[1],"r");
     yyparse();
} 