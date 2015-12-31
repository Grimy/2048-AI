#include <stdint.h>
#include <stdio.h>

#define cell(y, x) ((grid >> (16 * (y) + 4 * (x))) & 0xf)

extern uint16_t uniq[];
extern uint16_t move_left[];
extern uint16_t move_right[];
extern uint16_t chaos[];

uint64_t grid;

static void display_grid() {
	static char tags[16][4] = {
		"   ", " 2 ", " 4 ", " 8 ", " 16", " 32", " 64", "128",
		"256", "512", " 1k", " 2k", " 4k", " 8k", "16k", "32k"
	};
	#define TAGS(y) tags[cell(y, 0)], tags[cell(y, 1)], tags[cell(y, 2)], tags[cell(y, 3)]
	printf("╔═══╤═══╤═══╤═══╗\n");
	printf("║%3s│%3s│%3s│%3s║\n", TAGS(0));
	printf("╟───┼───┼───┼───╢\n");
	printf("║%3s│%3s│%3s│%3s║\n", TAGS(1));
	printf("╟───┼───┼───┼───╢\n");
	printf("║%3s│%3s│%3s│%3s║\n", TAGS(2));
	printf("╟───┼───┼───┼───╢\n");
	printf("║%3s│%3s│%3s│%3s║\n", TAGS(3));
	printf("╚═══╧═══╧═══╧═══╝\n");
}

int main(void) {
	grid = 0x0123456789abcdef;
	display_grid();
}
