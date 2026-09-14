%error-verbose
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "symb_tab.h"
    int yylex(void);
    void yyerror (char const *);
    extern FILE *yyin;
    extern int yylineno;

    char *studente_corrente;
    char *corso_corrente;
%}

%union {
    char* string_token;
    int int_token;
}

%token <string_token> CC CN MATRICOLA STR
%token LODE T_FIRST_NAME T_LAST_NAME
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

Corso: CC CN CFU {inserisci_corso($1, $2, $3);}
    ;

Sez_2: Elenco_Studenti
    ;

Elenco_Studenti: Studente
    | Studente SEP_2 Elenco_Studenti
    ;

Studente: MATRICOLA T_FIRST_NAME COL STR T_LAST_NAME COL STR {inserisci_studente($1, $4, $7);}
    ;

Sez_3: Elenco_Carriere
    ;

Elenco_Carriere: Carriera
    | Carriera Elenco_Carriere
    ;

Carriera: MATRICOLA {
        Studente *studente = lookup_studente($1);
        if (studente == NULL) {
            fprintf(stderr, "error: line %d: semantic error: undeclared student '%s'\n", yylineno, $1);
            exit(EXIT_FAILURE);
        }
        if (studente->carriera_dichiarata) {
            fprintf(stderr, "error: line %d: semantic error: duplicate career for student '%s'\n", yylineno, $1);
            exit(EXIT_FAILURE);
        }
        studente->carriera_dichiarata = 1;
        studente_corrente = $1;
    } LAB Esami_Opzionali RAB
    ;

Esami_Opzionali: Elenco_Esami
    |
    ;

Elenco_Esami: Esame
    | Esame COMMA Elenco_Esami
    ;

Esame: CC {corso_corrente = $1;} COL Voto
    ;

Voto: VOTO {inserisci_esame(studente_corrente, corso_corrente, $1, 0);}
    | LODE {inserisci_esame(studente_corrente, corso_corrente, 30, 1);}
    ;

%%
int main(int argc, char **argv) {
    FILE *output;
    const char *nome_output;

    if (argc < 2 || argc > 3) {
        fprintf(stderr, "Uso: %s file_input [file_output]\n", argv[0]);
        return EXIT_FAILURE;
    }

    nome_output = argc == 3 ? argv[2] : "output";

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        perror(argv[1]);
        return EXIT_FAILURE;
    }

    output = fopen(nome_output, "w");
    
    if(output == NULL) {
        perror(nome_output);
        fclose(yyin);
        return EXIT_FAILURE;
    }

    if (yyparse() == 0) {
        salva_risultati(output);
    } else {
        fprintf(stderr, "Errore di parsing\n");
        fclose(yyin);
        fclose(output);
        libera_tabelle();
        return EXIT_FAILURE;
    }

    fclose(yyin);
    fclose(output);
    libera_tabelle();
    return EXIT_SUCCESS;
}

void yyerror(const char *s) {
    fprintf(stderr, "error: line %d: %s\n", yylineno, s);
}
