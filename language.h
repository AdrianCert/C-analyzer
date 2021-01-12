#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEBUG 1
#define MAXVAR 500

#define dprintf(out, in, ...)          \
    ;                                  \
    if (DEBUG)                         \
    {                                  \
        fprintf(out, in, __VA_ARGS__); \
        fflush(out);                   \
    }
#define dprint(in, ...) \
    ;                   \
    dprintf(stdout, in, __VA_ARGS__);

int yylex();

extern FILE *yyin;
extern char *yytext;
extern int yylineno;

struct scope;
struct vartable;

struct functtable
{
    char type[25];
    char name[250];
    char parmlist[1250];
};


int cvar = 0;
int cfun = 0;

int fl_main = 0;
int sc_curr = 0;

int fl_vsig;
int fl_var_const;

char *indentifer_val;
char *tip = 0;

char tmp[250];

/**************************************************************/
/**************** SCOPE MANAGE FUNC ***************************/
/**************************************************************/
struct scope
{
    char *name;
    int level;
    struct scope *parent;
    struct vartable **variables;
};

struct scope *scope_init(char *name, struct scope *p)
{
    struct scope *s = (struct scope *)malloc(sizeof(struct scope));
    s->name = strdup(name);
    s->level = p ? p->level + 1 : 0;
    s->parent = p;
    s->variables = (struct vartable **)malloc(sizeof(struct vartable *));
    return s;
}

struct scope *current_scope = 0;

/**************************************************************/
/**************** MULTI VAR FUNC ******************************/
/**************************************************************/
char multi_var[25][250];
int multi_var_count = 0;
void multi_var_rec(char *name)
{
    memset(multi_var[multi_var_count], 0, 250);
    strcpy(multi_var[multi_var_count], name);
    multi_var_count++;
}

/**************************************************************/
/**************** DECLAR VAR FUNC *****************************/
/**************************************************************/
struct vartable
{
    char *type;
    char *name;
    char *value;
    struct scope * scope;
    int fl_sign;
    int fl_const;
    int defined_line;
};

struct vartable *vars = 0;
int vars_count = 0;

int var_exist(char *v, struct scope * s)
{
    // int i;
    // for (i = 0; i < cvar; i++)
    // {
    //     if (scopedeep <= variable[i].dscope)
    //     {
    //         if (strcmp(variable[i].name, vname) == 0)
    //         {
    //             return i;
    //         }
    //     }
    // }
    // return lina la care s-a definit;
    return -1;
}

void vars_add(char *type, char *name, char *value, int cnst, int sgn)
{
    int i;
    if ((i = var_exist(name, current_scope)) >= 0)
    {
        printf("Variable (%s)%s is already defined at line %d", type, name, i);
        exit(0);
    }
    if (cnst && !value)
    {
        printf("Variable is not allow define const without initalization\n");
        exit(0);
    }

    vars[vars_count].type = strdup(type);
    vars[vars_count].name = strdup(name);
    vars[vars_count].value = value ? strdup(value) : strdup("UNDEFINED");
    vars[vars_count].scope = current_scope;
    vars[vars_count].fl_const = cnst ? 1 : 0;
    vars[vars_count].fl_sign = sgn ? 1 : 0;
    vars[vars_count].defined_line = yylineno;
    vars_count++;
}

void vars_print(char *path)
{
    FILE *file;
    int i;

    if (!(file = fopen(path, "w")))
    {
        exit(0);
    }

    for (i = 0; i < vars_count; i++)
    {
        fprintf(file,
                "%s %s %s %s %d %d %d %d",
                vars[i].type,
                vars[i].name,
                vars[i].value,
                vars[i].scope->name,
                vars[i].scope->level,
                vars[i].fl_sign,
                vars[i].fl_const,
                vars[i].defined_line);
    }

    fclose(file);
}



void strrec(char *d, char *s)
{
    dprint("strrec %s %s\n", d, s);
    if (d)
        free(d);
    d = strdup(s);
}

void yyerror(char *s)
{
    printf("eroare: %s la linia:%d\n", s, yylineno);
}