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
