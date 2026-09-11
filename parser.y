%error-verbose
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "symb.tab.h"
    int yylex();
    void yyerror (char const *);
    extern FILE *yyin;
%}

%union {
    char *string_token;
    int int_token;
}

%token <stringa> CC CN MATRICOLA FIRST_NAME LAST_NAME
%token LODE
%token <intero> CFU VOTO
%token SEP SEP_2 LAB RAB COL COMMA

%start Input
%%

Input: SEP | CC
    ;

%%
int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "Uso: %s file_input\n", argv[0]);
        return EXIT_FAILURE;
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        perror(argv[1]);
        return EXIT_FAILURE;
    }

    if (yyparse() == 0)
        printf("Input accettato\n");
    else
        printf("Input rifiutato\n");

    fclose(yyin);
    return EXIT_SUCCESS;
}
void yyerror(const char *s)
{
    fprintf(stderr, "Errore sintattico: %s\n", s);
}