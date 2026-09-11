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

%token <string_token> CC CN MATRICOLA STR
%token LODE  T_FIRST_NAME T_LAST_NAME
%token <int_token> CFU VOTO
%token SEP SEP_2 LAB RAB COL COMMA

%start Input
%%

Input: Sez_1 SEP Sez_2 SEP Sez_3
    ;

Sez_1: Elenco_Corsi
    ;

Elenco_Corsi: Corso
    | Corso Elenco_Corsi
    ;

Corso: CC CN CFU 
    ;

Sez_2: Elenco_Studenti
    ;

Elenco_Studenti: Studente
    | Studente SEP_2 Elenco_Studenti
    ;

Studente: MATRICOLA T_FIRST_NAME COL STR T_LAST_NAME COL STR
    ;

Sez_3: Elenco_Carriere
    ;

Elenco_Carriere: Carriera
    | Carriera Elenco_Carriere
    ;

Carriera: MATRICOLA LAB Elenco_Esami RAB
    ;

Elenco_Esami: Esame
    |
    | Esame COMMA Elenco_Esami
    ;

Esame: CC COL Voto
    ;

Voto: VOTO
    | LODE
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