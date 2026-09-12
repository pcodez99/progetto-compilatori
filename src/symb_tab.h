#include <stdio.h>

#define HASHSIZE 101

//struttura dei corsi
typedef struct corso {
    char *codice;
    char *nome;
    unsigned int cfu;
    struct corso *next;
} Corso;

//struttura per esame
typedef struct esame {
    Corso *corso;
    unsigned int voto;
    int lode;
    struct esame *next;
    struct esame *next_best;
} Esame;

//struttura per studente
typedef struct studente {
    char *matricola;
    char *nome;
    char *cognome;
    unsigned int max;
    float media;
    Esame *esami;
    Esame *bests;
    struct studente *next;
} Studente;

unsigned int hash(char *s);
Corso *lookup_corso(char *codice);
Studente *lookup_studente(char *matricola);
Corso *inserisci_corso(char *codice, char *nome, unsigned int cfu);
Studente *inserisci_studente(char *matricola, char *nome, char *cognome);
Esame *inserisci_esame(char *matricola, char *codice_corso, unsigned int voto, int lode);
unsigned int calcola_cfu(Studente *studente);
double calcola_media(Studente *studente);
void salva_risultati(FILE *output);
void libera_tabelle(void);
