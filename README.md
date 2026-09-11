# Progetto Compilatori

Progetto per il corso di Compilatori basato su un analizzatore lessicale realizzato con Flex.

## Requisiti

- Flex
- GCC

Su linux/mac è già presente (in teoria)

## Compilazione

```bash
flex lexer.fl
gcc lex.yy.c -o nome-file
```

## Esecuzione

```bash
./nome-file input
```

## Supporto VS Code

Il workspace consiglia l'estensione **Bison/Flex Language Support** e associa i
file `.fl` al linguaggio GNU Flex. In questo modo sono disponibili colorazione
sintattica e diagnostica mentre si modifica il lexer.

Per eseguire anche il controllo ufficiale di GNU Flex sul file aperto, usa
`Terminale > Esegui attività` e seleziona **Flex: lint file corrente**.
