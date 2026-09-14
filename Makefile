CC ?= cc
FLEX ?= flex
BISON ?= bison
CFLAGS ?= -std=c11 -Wall -Wextra -Wpedantic

BUILD := build
BIN := bin
PROGRAM := $(BIN)/progetto

.PHONY: all clean test

all: $(PROGRAM)

$(PROGRAM): $(BUILD)/parser.tab.c $(BUILD)/lex.yy.c src/symb_tab.c src/symb_tab.h | $(BIN)
	$(CC) $(CFLAGS) -I$(BUILD) -Isrc -o $@ $(BUILD)/parser.tab.c $(BUILD)/lex.yy.c src/symb_tab.c

$(BUILD)/parser.tab.c: src/parser.y | $(BUILD)
	$(BISON) -d -o $@ $<

$(BUILD)/parser.tab.h: $(BUILD)/parser.tab.c
	@:

$(BUILD)/lex.yy.c: src/scanner.fl $(BUILD)/parser.tab.h | $(BUILD)
	$(FLEX) -o $@ $<

$(BUILD) $(BIN):
	mkdir -p $@

test: $(PROGRAM)
	@set -e; tmp=$$(mktemp); trap 'rm -f "$$tmp"' EXIT; \
	$(PROGRAM) tests/valid/input.txt "$$tmp"; \
	cmp tests/valid/expected.txt "$$tmp"; \
	for input in tests/invalid/*.txt; do \
		if $(PROGRAM) "$$input" "$$tmp" >/dev/null 2>&1; then \
			echo "FAIL: $$input accettato" >&2; exit 1; \
		fi; \
	done; \
	echo "Test superati"

clean:
	rm -rf $(BUILD) $(BIN)
