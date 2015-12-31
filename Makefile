CC = clang -std=c99 -Weverything -Wno-missing-variable-declarations -Werror

2048: 2048.c arrays.o
	$(CC) -o $@ $^

arrays.o: precompute.pl
	perl $< | $(CC) -xc -c -o $@ -
