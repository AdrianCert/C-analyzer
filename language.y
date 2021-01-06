%{
     #include <stdio.h>
     #include <stdlib.h>
     #include <string.h>

     #define MAXVAR 500
     int yylex();

     extern FILE * yyin;
     extern char * yytext;
     extern int yylineno;

     struct vartable {
          char *type;
          char *name;
          char *value;
          char *scope;
          int dscope;
          int fl_defined;
          int fl_const;
          int defined_line;
     };

     struct functtable {
          char type[25];
          char name[250];
          char parmlist[1250];
     };

     struct vartable variable[MAXVAR];
     struct functtable functions[MAXVAR];
     int cvar = 0;
     int cfun = 0;

     int fl_main = 0;
     int sc_curr = 0;
     int scopedeep = 0;
     char scopename[100];
     char * indentifer_val;

     int declaredvar(char * vname)
     {
          int i;
          for(i = 0; i < cvar; i++)
          {
               if(scopedeep <= variable[i].dscope)
               {
                    if( strcmp(variable[i].name, vname) == 0)
                    {
                         return i;
                    }
               }
          }
          return -1;
     }

     void vdecrare_init(char *type, char *name, char *scope, char *value, int cnst )
     {
          int i;
          if((i = declaredvar(name) ) >= 0)
          {
               printf("Variable (%s)%s is already defined at line %d", type, name, variable[i].defined_line);
               exit(0);
          }

          variable[cvar].type = strdup(type);
          variable[cvar].name = strdup(name);
          variable[cvar].value = strdup(value);
          variable[cvar].scope = strdup(scopename);
          variable[cvar].dscope = scopedeep;
          variable[cvar].fl_defined = 1;
          variable[cvar].fl_const = cnst ? 1 : 0;
          variable[cvar].defined_line = yylineno;
          cvar++;
     }

     void vdecrare(char *type, char *name, char *scope, int cnst )
     {
          int i;
          if((i = declaredvar(name) ) >= 0)
          {
               printf("Variable %s is already defined at line %d", name, variable[i].defined_line);
               exit(0);
          }
          if(cnst)
          {
               printf("Variable is not allow define const without initalization\n");
               exit(0);
          }

          variable[cvar].type = strdup(type);
          variable[cvar].name = strdup(name);
          variable[cvar].scope = strdup(scopename);
          variable[cvar].dscope = scopedeep;
          variable[cvar].fl_defined = 0;
          variable[cvar].fl_const = cnst ? 1 : 0;
          variable[cvar].defined_line = yylineno;
          cvar++;
     }

     void printvtable(char *path)
     {
          FILE * file;
          int i;

          if (!(file = fopen(path, "w")))
          {
               exit(0);
          }

          for( i = 0; i < cvar; i++)
          {
               fprintf(file,
                    "%s %s %s %s %d %d %d %d" ,
                    variable[i].type,
                    variable[i].name,
                    variable[i].value,
                    variable[i].scope,
                    variable[i].dscope,
                    variable[i].fl_defined,
                    variable[i].fl_const,
                    variable[i].defined_line );
          }

          fclose(file);
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

%type <str> SIGN_TIP ID TRIVIAL_TIP CHAR_VAL STRING_VAL
%type <num> BOOL_VAL INT_VAL lo_expr lo_operand
%type <rnum> DOUBLE_VAL arhimetic_expr expr ref_val const_value function_call calc_statement arhimetic_operand numeric_val

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
                             // strcat($$ , "dsdf"); 
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

eval_statement : EVAL '(' '"' arhimetic_expr '"'')' ';' { printf("%lf", $4); }

calc_statement : CALC '(' '"' arhimetic_expr '"' ')' ';' { $$ = $4; }

/**************************************************************/
/**************** FOR RULES ***********************************/
/**************************************************************/

loop_init : statement 
          |
          ;

stop_cond : lo_operand
          |
          ;

loop_step : expr
          |
          ;

condition: '(' lo_operand ')'
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

if_statement : IF condition block ELSE block
          | IF condition block 
          ;

/**************************************************************/
/**************** EXPRESIONS RULES ****************************/
/**************************************************************/

lo_operand : lo_expr;
          | '(' lo_expr ')' { $$ = $2; }
          ;

lo_expr : NOT lo_operand { $$ = !$2; }
          | lo_operand AND lo_operand { $$ = $1 && $3; }
          | lo_operand OR lo_operand { $$ = $1 || $3; }
          | lo_operand { $$ = $1; }
          | arhimetic_operand GREATER arhimetic_operand { $$ = $1 > $3; }
          | arhimetic_operand LOWER arhimetic_operand { $$ = $1 < $3; }
          | arhimetic_operand EQUAL arhimetic_operand { $$ = $1 == $3; }
          | arhimetic_operand NOT_EQ arhimetic_operand { $$ = $1 != $3; }
          | arhimetic_operand LOWER_EQ arhimetic_operand { $$ = $1 <= $3; }
          | arhimetic_operand GREATER_EQ arhimetic_operand { $$ = $1 >= $3; }
          //| const_value
          ;

numeric_val: ref_val { $$ = $1; }
          | function_call { $$ = $1; }
          | const_value { $$ = $1; }

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

begin     : declarations { printf("program corect sintactic\n"); }
          ;

%%

int main(int argc, char** argv)
{
     yyin=fopen(argv[1],"r");
     yyparse();
} 