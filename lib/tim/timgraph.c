#include "lib/tim/timgraph.h"

/* 16bit signed compare, Vladimir Savic
start:
    LD A,H
    XOR D
    JP M,labela2
    SBC HL,DE
    JR NC,labela3
labela1:
    SCF
    JP kraj
labela2:
    BIT 7,D
    JR Z,labela1
labela3:
    OR A
kraj:
; ako JE carry setovan, HL<DE
; ako carry NIJE setovan HL>=DE
*/


/*

    Drawing routines taken from
    https://github.com/MiguelVis/xpcw

*/

void circle(int x0, int y0, int radius, color_t col)
{
	int x, xh;
	int y, yh;
	int decision;

	x = radius;
	y = 0;
	decision = 1 - x;

	while(x >= y) {

		/* The PCW pixels are double in high */

		xh = x >> 1;  /* xh = x / 2 */
		yh = y >> 1;  /* yh = y / 2 */

		plotxy( x + x0,  yh + y0, col);
		plotxy( y + x0,  xh + y0, col);
		plotxy(-x + x0,  yh + y0, col);
		plotxy(-y + x0,  xh + y0, col);
		plotxy(-x + x0, -yh + y0, col);
		plotxy(-y + x0, -xh + y0, col);
		plotxy( x + x0, -yh + y0, col);
		plotxy( y + x0, -xh + y0, col);

		y++;

		if(decision <= 0) {
			decision += 2 * y + 1;
		}
		else {
			x--;
			decision += 2 * (y - x) + 1;
		}
	}
}


void box(int x0, int y0, int x1, int y1, color_t col)
{
    line(col, x0, y0, x1, y0);
    line(col, x0, y1, x1, y1);
    line(col, x0, y0, x0, y1);
    line(col, x1, y0, x1, y1);
}

// The "flip" versions exist to fix the parameter passing difference between
// MESCC and SDCC. SDCC and MESCC pass params in different order.

void line_flip(unsigned int y1, unsigned int x1, unsigned int y0, unsigned int x0, color_t color) ASM_STDCALL;
void line(color_t color, unsigned int x0, unsigned int y0, unsigned int x1, unsigned int y1) {
		line_flip(y1, x1, y0, x0, color);
}

void puttile_flip(const char *addr, int y, int x) ASM_STDCALL;
void puttile(int x, int y, const char *addr) {
		puttile_flip(addr, y, x);
}
