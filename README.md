# Analizzatore di carriere universitarie

Progetto realizzato per il corso di **Compilatori**. Il programma analizza un documento contenente corsi, studenti e carriere universitarie, ne verifica la correttezza lessicale, sintattica e semantica e produce per ogni studente la media pesata e gli esami con voto massimo.

| | |
|---|---|
| Autore | Pietro Zarbo |
| Anno accademico | 2025/2026 |
| Tecnologie | C, Flex, Bison |

La [specifica originale](docs/specifica.pdf) è conservata nella repository.

## Funzionamento

L'elaborazione è divisa in quattro fasi:

```text
file di input -> scanner Flex -> parser Bison -> controlli semantici -> file di output
```

Lo scanner riconosce lessemi quali codici dei corsi, crediti, matricole, nominativi e voti. Il parser verifica la struttura delle tre sezioni del documento. Durante il parsing, due tabelle hash memorizzano corsi e studenti; ogni studente possiede inoltre la propria lista di esami.

Sono rilevati, tra gli altri, i seguenti errori semantici:

- corso o studente dichiarato più volte;
- carriera duplicata o associata a uno studente inesistente;
- esame relativo a un corso inesistente;
- esame ripetuto nella stessa carriera.

La lode è considerata superiore al voto 30 nella ricerca degli esami migliori, mentre ai fini della media pesata vale 30.

## Formato dei dati

L'input contiene tre sezioni separate da `%%%`: catalogo dei corsi, anagrafica degli studenti e carriere. Gli studenti sono separati da `&&&`.

```text
Y250 "Compilatori" 6
%%%
2055002161
Nome: Giacomo
Cognome: Secchia
%%%
2055002161 <Y250 : 30l>
```

Una riga di output contiene nome, cognome, media pesata e corsi nei quali è stato ottenuto il voto massimo:

```text
Giacomo Secchia 30.000000 <Compilatori>
```

## Compilazione

Sono necessari un compilatore C, Flex, Bison e Make.

```sh
make
```

L'eseguibile viene generato in `bin/progetto`.

## Esecuzione

```sh
bin/progetto file_input [file_output]
```

Se il secondo argomento è omesso, il risultato viene scritto nel file `output` nella directory corrente.

## Test

```sh
make test
```

Il comando confronta il risultato del caso valido con l'output atteso e verifica che i casi lessicale, sintattico e semantico non vengano accettati.

## Organizzazione

```text
src/       sorgenti Flex, Bison e tabella dei simboli
tests/     casi validi, output atteso e casi non validi
docs/      specifica originale del progetto
```

