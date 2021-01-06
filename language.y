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
          int fl_sign;
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

     int fl_vsig;
     int fl_var_const;
     
     int scopedeep = 0;
     char * scopename;

     char * indentifer_val;
     char * tip = 0;
     char * multiplev_name[10]; 
     int multiplev_count = 0;
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

     void vdecrare_init(char *type, char *name, char *scope, char *value, int cnst, int sgn )
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
          variable[cvar].fl_sign = sgn ? 1 : 0;
          variable[cvar].defined_line = yylineno;
          cvar++;
     }

     void vdecrare(char *type, char *name, char *scope, int cnst, int sgn)
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
          variable[cvar].fl_sign = sgn ? 1 : 0;
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
                    "%s %s %s %s %d %d %d %d %d" ,
                    variable[i].type,
                    variable[i].name,
                    variable[i].value,
                    variable[i].scope,
                    variable[i].dscope,
                    variable[i].fl_defined,
                    variable[i].fl_sign,
                    variable[i].fl_const,
                    variable[i].defined_line );
          }

          fclose(file);
     }

     void strrec( char *d, char *s)
     {
          if(d) free(d);
          d = strdup(s);
     }
     void yyerror(char * s)
     {
          printf("eroare: %s la linia:%d\n",s,yylineno);
     }

%}

%token SIGN_TIP TRIVIAL_TIP TIP_SIGN ID 
%token CHAR_VAL STRING_VAL INT_VAL DOUBLE_VAL
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

data_type : TRIVIAL_TIP            { strrec(tip,$1); fl_vsig = 0; }
          | SIGN_TIP               { strrec(tip,$1); fl_vsig = 0; }
          | TIP_SIGN SIGN_TIP      { strrec(tip,$2); fl_vsig = $1; }
          ;

const_numeric_value : INT_VAL      { $$ = $1; }
          | DOUBLE_VAL             { $$ = $1; }
          ;

const_string_value : CHAR_VAL      { $$ = strdup($1); }
          | STRING_VAL             { $$ = strdup($1); }
          ;

const_value : const_string_value   { $$ = strdup($1); }
          | const_numeric_value    { sprintf( $$, "%lf", $1); }
          ;

str_exp_val : expr                 { sprintf( $$, "%lf", $1); }

variable_idendifier : ID           { strrec(multiplev_name[multiplev_count++], $1); }
          | variable_idendifier ',' ID { strrec(multiplev_name[multiplev_count++], $3); }
          ;

variable_dec : data_type variable_idendifier ';'  {
                                                       int i;
                                                       for(i = 0; i < multiplev_count; i++)
                                                       {
                                                            vdecrare($1, multiplev_name[i], scopename, 0, fl_vsig);
                                                            strrec(multiplev_name[i], "-");
                                                       }
                                                       multiplev_count = 0;
                                                  }
          | CONST data_type variable_idendifier ';' {
                                                       int i;
                                                       for(i = 0; i < multiplev_count; i++)
                                                       {
                                                            vdecrare($2, multiplev_name[i], scopename, 1, fl_vsig);
                                                            strrec(multiplev_name[i], "-");
                                                       }
                                                       multiplev_count = 0;
                                                  }
          | data_type ID ASSIGN str_exp_val ';'        { vdecrare_init($1, $2, scopename, $4, 0, fl_vsig); }
          | CONST data_type ID ASSIGN str_exp_val ';'  { vdecrare_init($2, $3, scopename, $5, 0, fl_vsig); }
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
                              printvtable("s_table.txt");
                         }
          ;

%%

int main(int argc, char** argv)
{
     scopename = strdup("GLOBAL");
     yyin=fopen(argv[1],"r");
     yyparse();
} 