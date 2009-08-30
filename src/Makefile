CC=gcc
CFLAGS=

all: recode
.PHONY: all clean

recode: recode.c
	$(CC) -o $@ $< $(CFLAGS)

clean:
	rm -f recode
