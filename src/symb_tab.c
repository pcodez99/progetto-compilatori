#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symb_tab.h"

extern int yylineno;

Corso *hash_table_corsi[HASHSIZE] = {NULL};
Studente *hash_table_studenti[HASHSIZE] = {NULL};

unsigned int hash(char *s) {
    unsigned int h = 0;
    for (; *s != '\0'; s++)
        h = (127 * h + *s) % HASHSIZE;
    return h;
}

//Ricerca del codice nella tabella HASH dei corsi
Corso *lookup_corso(char *codice) {
    Corso *c;

    if (codice == NULL)
        return NULL;

    for (c = hash_table_corsi[hash(codice)]; c != NULL; c = c->next) {
        if (strcmp(c->codice, codice) == 0)
            return c;
    }

    return NULL;
}

//Inserisci corso nella tabella
Corso *inserisci_corso(char *codice, char *nome, unsigned int cfu) {
    Corso *corso;
    unsigned int hashval;

    if (lookup_corso(codice) != NULL) {
        fprintf(stderr, "error: line %d: semantic error: duplicate course '%s'\n", yylineno, codice);
        exit(EXIT_FAILURE);
    }

    if ((corso = malloc(sizeof(*corso))) == NULL) return NULL;

    corso->codice = strdup(codice);
    corso->nome = strdup(nome);
    corso->cfu = cfu;
    hashval = hash(codice);
    corso->next = hash_table_corsi[hashval];
    hash_table_corsi[hashval] = corso;

    return corso;
}

//Ricerca della matricola nella tabella HASH degli studenti
Studente *lookup_studente(char *matricola) {
    Studente *studente;

    if (matricola == NULL)
        return NULL;

    for (studente = hash_table_studenti[hash(matricola)]; studente != NULL; studente = studente->next) {
        if (strcmp(studente->matricola, matricola) == 0)
            return studente;
    }

    return NULL;
}

//Inserisci studente nella tabella
Studente *inserisci_studente(char *matricola, char *nome, char *cognome) {
    Studente *studente;
    unsigned int hashval;

    if (lookup_studente(matricola) != NULL) {
        fprintf(stderr, "error: line %d: semantic error: duplicate student '%s'\n", yylineno, matricola);
        exit(EXIT_FAILURE);
    }

    if ((studente = malloc(sizeof(*studente))) == NULL) return NULL;

    studente->nome = strdup(nome);
    studente->cognome = strdup(cognome);
    studente->matricola = strdup(matricola);
    studente->esami = NULL;
    studente->bests = NULL;
    studente->max = 0;
    studente->media = 0.0f;
    studente->carriera_dichiarata = 0;
    hashval = hash(matricola);
    studente->next = hash_table_studenti[hashval];
    hash_table_studenti[hashval] = studente;

    return studente;
}

//Cerca esame nella lista degli esami
Esame *cerca_esame(Esame *testa, char *codice_corso) {
    Esame* current = testa;
    
    while (current != NULL) {
        if (strcmp(current->corso->codice, codice_corso) == 0) {
            return current;
        }
        current = current->next;
    }
    
    return NULL;
}

Esame *inserisci_esame(char *matricola, char *codice_corso, unsigned int voto, int lode) {
    Studente *studente;
    Corso *corso;
    Esame *esame;

    if (matricola == NULL || codice_corso == NULL || voto < 18 || voto > 30) return NULL;

    studente = lookup_studente(matricola);
    corso = lookup_corso(codice_corso);

    if (studente == NULL) {
        fprintf(stderr, "error: line %d: semantic error: undeclared student '%s'\n", yylineno, matricola);
        exit(EXIT_FAILURE);
    }
    if (corso == NULL) {
        fprintf(stderr, "error: line %d: semantic error: undeclared course '%s'\n", yylineno, codice_corso);
        exit(EXIT_FAILURE);
    }

    if (cerca_esame(studente->esami, corso->codice) != NULL) {
        fprintf(stderr, "error: line %d: semantic error: duplicate exam '%s' for student '%s'\n",
                yylineno, codice_corso, matricola);
        exit(EXIT_FAILURE);
    }

    if ((esame = malloc(sizeof(*esame))) == NULL) return NULL;

    unsigned int valore = lode ? 31 : voto;

    esame->corso = corso;
    esame->voto = voto;
    esame->lode = lode != 0;
    esame->next_best = NULL;

    if (studente->bests == NULL || valore > studente->max) {
        /* È il primo esame oppure è stato trovato un nuovo massimo. */
        studente->max = valore;
        studente->bests = esame;
    } else if (valore == studente->max) {
        /* Esame con voto uguale al massimo corrente. */
        esame->next_best = studente->bests;
        studente->bests = esame;
    }
    esame->next = studente->esami;
    studente->esami = esame;

    studente->media = calcola_media(studente);

    return esame;
}

double calcola_media(Studente *studente) {
    Esame *esame;
    unsigned int cfu_totali = 0;
    unsigned int somma_pesata = 0;

    if (studente == NULL) return 0.0;

    for (esame = studente->esami; esame != NULL; esame = esame->next) {
        cfu_totali += esame->corso->cfu;
        somma_pesata += esame->voto * esame->corso->cfu;
    }

    if (cfu_totali == 0) return 0.0;

    return (double)somma_pesata / cfu_totali;
}

void salva_risultati(FILE *output) {
    unsigned int i;
    Studente *studente;
    Esame *best;

    if (output == NULL) return;

    for (i = 0; i < HASHSIZE; i++) {
        for (studente = hash_table_studenti[i]; studente != NULL; studente = studente->next) {
            fprintf(output, "%s %s %f <", studente->nome, studente->cognome, studente->media);
            for(best = studente->bests; best != NULL; best = best->next_best) {
                fprintf(output, "%s", best->corso->nome);

                if (best->next_best != NULL) fprintf(output, ", ");
            }
            fprintf(output, ">\n");
        }
    }
}

void libera_tabelle(void) {
    unsigned int i;
    Studente *studente;
    Corso *corso;
    Esame *esame;

    for (i = 0; i < HASHSIZE; i++) {
        while (hash_table_studenti[i] != NULL) {
            studente = hash_table_studenti[i];
            hash_table_studenti[i] = hash_table_studenti[i]->next;

            while (studente->esami != NULL) {
                esame = studente->esami;
                studente->esami = studente->esami->next;
                free(esame);
            }

            free(studente->matricola);
            free(studente->nome);
            free(studente->cognome);
            free(studente);
        }

        while (hash_table_corsi[i] != NULL) {
            corso = hash_table_corsi[i];
            hash_table_corsi[i] = hash_table_corsi[i]->next;
            free(corso->codice);
            free(corso->nome);
            free(corso);
        }
    }
}
