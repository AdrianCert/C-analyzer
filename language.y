%{
     #include "language.h"
%}

%token CHAR_VAL STRING_VAL INT_VAL DOUBLE_VAL
%token ASSIGN MUL_ASSIGN MOD_ASSIGN ADD_ASSIGN MIN_ASSIGN DIV_ASSIGN
%token SIGN_TIP TRIVIAL_TIP TIP_SIGN ID
%token EQUAL NOT_EQ LOWER_EQ GREATER_EQ GREATER LOWER
%token EVAL CALC
%token CONST STATIC PRINT PMEM
%token RETURN IF ELSE WHILE DO FOR
%token STRUCT CLASS ACCESMODIF

%left NOT
%left AND
%left OR
%left MUL DIV MOD
%left ADD MIN
%left INCR DECR

%union
{
     char * str;
     int num;
     double rnum;
}

%type <str> SIGN_TIP
     TRIVIAL_TIP
     CHAR_VAL
     STRING_VAL
     ID
     const_string_value
     const_value
     str_exp_val
     data_type

%type <num> TIP_SIGN
     INT_VAL
     lo_expr

%type <rnum> DOUBLE_VAL 
     arhimetic_expr
     expr
     ref_val
     function_call
     calc_statement
     arhimetic_operand
     numeric_val
     const_numeric_value

%start begin

%%

/**************************************************************/
/**************** GLOBAL RULES ********************************/
/**************************************************************/

data_type : TRIVIAL_TIP            { $$ =strdup($1); fl_vsig = 0; }
          | SIGN_TIP               { $$ =strdup($1); fl_vsig = 0; }
          | TIP_SIGN SIGN_TIP      { $$ =strdup($2); fl_vsig = $1; }
          ;

const_numeric_value : INT_VAL      { $$ = $1; }
          | DOUBLE_VAL             { $$ = $1; }
          ;

const_string_value : CHAR_VAL      { $$ = strdup($1); }
          | STRING_VAL             { $$ = strdup($1); }
          ;

const_value : const_string_value   { $$ = strdup($1); }
          | const_numeric_value    { printf("constant_numerc_value %lf\n", $1); sprintf( $$, "%lf", $1); }
          ;

str_exp_val : expr                 { printf( "expr %lf\n", $1); sprintf( tmp, "%lf", $1); dprint("exit ok %c\n", '1');  $$ = strdup(tmp); }

variable_idendifier : ID           { multi_var_rec($1); }
          | variable_idendifier ',' ID { multi_var_rec($3); }
          ;

variable_dec : data_type variable_idendifier ';'  {
                                                       printf("variable delaration 1 %d\n", multi_var_count);
                                                       int i;
                                                       for(i = 0; i < multi_var_count; i++)
                                                       {
                                                            vars_add($1, multi_var[i], 0, 0, fl_vsig);
                                                       }
                                                       multi_var_count = 0;
                                                  }
          | CONST data_type variable_idendifier ';' {
                                                       printf("variable delaration 2\n");
                                                       int i;
                                                       for(i = 0; i < multi_var_count; i++)
                                                       {
                                                            vars_add($2, multi_var[i], 0, 1, fl_vsig);
                                                       }
                                                       multi_var_count = 0;
                                                  }
          | data_type ID ASSIGN str_exp_val ';'        { dprint("variable delaration %d\n", 2); dprint("str_expr %s\n", $4);vars_add($1, $2, $4, 0, fl_vsig); }
          | CONST data_type ID ASSIGN str_exp_val ';'  { vars_add($2, $3, $5, 1, fl_vsig); }
          ;

statement : variable_dec
          | function_call
          | if_statement
          | for_statement
          | while_statement
          | dowhile_statement
          | asign_statement
          | eval_statement
          | return_statement
          | print_statement
          ;

return_statement : RETURN expr ;

print_statement : PRINT '(' caller_params ')' ';' ;

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

eval_statement : EVAL '(' '"' arhimetic_expr '"'')' ';' { printf("%lf", $4); }

calc_statement : CALC '(' '"' arhimetic_expr '"' ')' ';' { $$ = $4; }

/**************************************************************/
/**************** FOR RULES ***********************************/
/**************************************************************/

loop_init : statement 
          |
          ;

stop_cond : lo_expr//lo_operand
          |
          ;

loop_step : expr
          |
          ;

condition: '(' stop_cond ')'
     ;

for_statement : FOR '(' loop_init ';' stop_cond ';' loop_step ')' block ;

/**************************************************************/
/************* WHILE & DO WHILE RULES *************************/
/**************************************************************/

dowhile_statement : DO block WHILE condition ';'

while_statement: WHILE condition block

/**************************************************************/
/**************** IF RULES ************************************/
/**************************************************************/

if_head : IF condition block ;

 if_else: ELSE block ;

if_statement : 
          if_head if_else
          // | if_head
          ;

/**************************************************************/
/**************** EXPRESIONS RULES ****************************/
/**************************************************************/

lo_expr : NOT lo_expr { $$ = !$2; }
          | lo_expr AND lo_expr { $$ = $1 && $3; }
          | lo_expr OR lo_expr { $$ = $1 || $3; }
          | arhimetic_operand GREATER arhimetic_operand { $$ = $1 > $3; }
          | arhimetic_operand LOWER arhimetic_operand { $$ = $1 < $3; }
          | arhimetic_operand EQUAL arhimetic_operand { $$ = $1 == $3; }
          | arhimetic_operand NOT_EQ arhimetic_operand { $$ = $1 != $3; }
          | arhimetic_operand LOWER_EQ arhimetic_operand { $$ = $1 <= $3; }
          | arhimetic_operand GREATER_EQ arhimetic_operand { $$ = $1 >= $3; }
          /* | numeric_val { $$ = $1; } */
          | '(' lo_expr ')' { $$ = $2; }
          ;

numeric_val: ref_val { $$ = $1; }
          | function_call { $$ = $1; }
          | const_numeric_value { $$ = $1; }

arhimetic_operand : numeric_val { $$ = $1; }
          | arhimetic_operand INCR { $$ = $1++; }
          | arhimetic_operand DECR { $$ = $1++; }
          | INCR arhimetic_operand { $$ = ++$2; }
          | DECR arhimetic_operand { $$ = --$2; }
          | '(' arhimetic_expr ')' { $$ = $2; }
          ;

arhimetic_expr : arhimetic_operand { $$ = $1; }
          | arhimetic_operand ADD arhimetic_operand { $$ = $1 + $3; }
          | arhimetic_operand MIN arhimetic_operand { $$ = $1 - $3; }
          | arhimetic_operand MUL arhimetic_operand { $$ = $1 * $3; }
          | arhimetic_operand DIV arhimetic_operand { $$ = $1 / $3; }
          | arhimetic_operand MOD arhimetic_operand { $$ = $1 - (int)($1 / $3); }
          ;

expr : arhimetic_expr { $$ = $1; }
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

begin     : declarations { 
                              printf("program corect sintactic\n");
                              vars_print("s_table.txt");
                              //printvtable("s_table.txt");
                         }
          ;

%%

int main(int argc, char** argv)
{
     current_scope  = scope_init("GLOBAL", 0);
     vars           = (struct vartable*)malloc(MAXVAR * sizeof(struct vartable));
     yyin           = fopen(argv[1],"r");
     yyparse();
     printf("program corect sintactic\n");
     return 0;
} 