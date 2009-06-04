#include <stdio.h>

/*
ENCODING
       The  following  byte  sequences are used to represent a character. The sequence to be used depends on
       the UCS code number of the character:

       0x00000000 - 0x0000007F:
           0xxxxxxx

       0x00000080 - 0x000007FF:
           110xxxxx 10xxxxxx
*/

void latin1_utf8(FILE* in, FILE* out) {
    int c;
    while ((c = getc(in)) != EOF) {
	if (c <= 0x7F) {
	    putc(c, out);
	} else {
	    putc(0xC0 | (c >> 6), out);
	    putc(0x80 | (c & 0x3F), out);
	}
    }
}

void json_escape(int c, FILE* out) {
    putc(0x5C, out);
    putc(c, out);
}

void latin1_json(FILE* in, FILE* out) {
    int c;
    while ((c = getc(in)) != EOF) {
	int e = -1;
	switch (c) {
	    case 0x22:
	    case 0x5C:
	    case 0x2F: e = c;  break;
	    case 0x08: e = 0x62; break;
	    case 0x0C: e = 0x66; break;
	    case 0x0A: e = 0x6E; break;
	    case 0x0D: e = 0x72; break;
	    case 0x09: e = 0x74; break;
	}
	if (e != -1) {
	    json_escape(e, out);
	} else if (c <= 0x1F) {
	    fprintf(out, "\\u00%.2x", c);
	} else if (c <= 0x7F) {
	    putc(c, out);
	} else {
	    putc(0xC0 | (c >> 6), out);
	    putc(0x80 | (c & 0x3F), out);
	}
    }
}

int main(int argc, char** argv) {
    //latin1_utf8(stdin, stdout);
    latin1_json(stdin, stdout);
}
