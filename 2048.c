#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define row(grid, y) (((grid) >> ((3 ^ (y)) << 4)) & 0xFFFF)
#define merge(a, b, c, d) ((uint64_t) (a) << 12 | (uint64_t) (b) << 8 | (uint64_t) (c) << 4 | (uint64_t) (d))
#define _transpose(grid, y) __extension__ ({ \
	uint64_t row = row(grid, y); \
	(row | row << 12 | row << 24 | row << 36) & 0xF000F000F000FUL; \
})
#define transpose(grid) (merge(_transpose(grid, 0), _transpose(grid, 1), _transpose(grid, 2), _transpose(grid, 3)))
#define cell(y, x) ((row(grid, y) >> (12 - ((x) << 2))) & 0xF)
#define do_move(dir, grid) ((uint64_t) dir[row(grid, 0)] << 48 | (uint64_t) dir[row(grid, 1)] << 32 | (uint64_t) dir[row(grid, 2)] << 16 | (uint64_t) dir[row(grid, 3)])

extern const uint16_t uniq[];
extern const uint16_t move_left[];
extern const uint16_t move_right[];
extern const uint16_t chaos[];

typedef uint64_t Grid;

static void display_grid(Grid grid) {
	static char tags[16][4] = {
		"   ", " 2 ", " 4 ", " 8 ", " 16", " 32", " 64", "128",
		"256", "512", " 1k", " 2k", " 4k", " 8k", "16k", "32k"
	};
	#define TAGS(y) tags[cell(y, 0)], tags[cell(y, 1)], tags[cell(y, 2)], tags[cell(y, 3)]
	printf("╔═══╤═══╤═══╤═══╗\r\n");
	printf("║%3s│%3s│%3s│%3s║\r\n", TAGS(0));
	printf("╟───┼───┼───┼───╢\r\n");
	printf("║%3s│%3s│%3s│%3s║\r\n", TAGS(1));
	printf("╟───┼───┼───┼───╢\r\n");
	printf("║%3s│%3s│%3s│%3s║\r\n", TAGS(2));
	printf("╟───┼───┼───┼───╢\r\n");
	printf("║%3s│%3s│%3s│%3s║\r\n", TAGS(3));
	printf("╚═══╧═══╧═══╧═══╝\r\n");
	printf("0x%016lX\r\n", grid);
}

static Grid spawn_tile(Grid grid) {
	int pos;
	do {
		pos = (rand() % 16) << 2;
	} while (((grid >> pos) & 0xF));
	return grid | (uint64_t) (1 + !(rand() % 10)) << pos;
}

static Grid move(Grid grid) {
	Grid transposed = transpose(grid);
	Grid moves[4] = {
		transpose(do_move(move_left, transposed)),
		transpose(do_move(move_right, transposed)),
		do_move(move_right, grid),
		do_move(move_left, grid),
	};

	int c = 0;
	while (c < 'A' || c > 'D' || moves[c - 'A'] == grid) {
		c = getchar();
		if (c == EOF || c == 'q')
			return 0;
	}
	return moves[c - 'A'];
}

int main(void) {
	system("stty raw");
	system("stty -echo");
	Grid grid = 0;
	do {
		grid = spawn_tile(grid);
		display_grid(grid);
	} while ((grid = move(grid)));
}
