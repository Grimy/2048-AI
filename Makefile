CC = clang

arrays.o: precompute.pl
	perl $< | $(CC) -xc -c -o $@ -
