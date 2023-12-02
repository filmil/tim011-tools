#ifndef LIB_TIM_TIMGRAPH_H_
#define LIB_TIM_TIMGRAPH_H_

#define ASM_STDCALL __sdcccall(0) __naked

// __sdcccall(1) means all params are passed on the stack. This is not the most
// efficient thing to do, but it is the easiest to port.

typedef enum {
	COLOR_BLACK = 0,
	COLOR_DARK_GREEN = 1,
	COLOR_LIGHT_GREEN = 2,
	COLOR_BRIGHT_GREEN = 3,
} color_t;

// Plots a point at (x,y), in one of the 4 colors.
//
// Args:
// - x: 0..511
// - y: 0..255
// - color: one of color_t
extern void plotxy(unsigned int x, unsigned int y, color_t color) ASM_STDCALL;

extern void scroll(unsigned int v) ASM_STDCALL;

// Draws a line in the given color, from (x0,y0) to (x1, y1).
//
// Args:
// - color: the color to draw in.
// - x0, y0: the start coordinate of the line.
// - x1, y1: the end coordinates of the line.
extern void line(color_t color, unsigned int x0, unsigned int y0, unsigned int x1, unsigned int y1) ASM_STDCALL;

extern void puttile(unsigned int x, unsigned int y, const char *addr) ASM_STDCALL;

#endif // LIB_TIM_TIMGRAPH_H_
