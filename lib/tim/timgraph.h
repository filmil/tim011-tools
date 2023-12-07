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

	// Make the enum 16-bit. SDCC will go to lengths to push just 1 byte to the
	// stack, while plotxy and other routines expect 16 bits. Without an enum
	// larger than 8 bits, the enum will be encoded as a byte.
	COLOR_UNUSED = 0x0fff,
} color_t;

// Plots a point at (x,y), in one of the 4 colors.
//
// Args:
// - x: 0..511
// - y: 0..255
// - color: one of color_t
extern void plotxy(int x, int y, color_t color) ASM_STDCALL;

// Puts a value into TIM's scroll register.
//
// Args:
// - v: 0..255: the value to write. (The arg is unsigned int due to the param
//   passing convention).
extern void scroll(unsigned int v) ASM_STDCALL;

// Draws a line in the given color, from (x0,y0) to (x1, y1).
//
// Args:
// - color: the color to draw in.
// - x0, y0: the start coordinate of the line.
// - x1, y1: the end coordinates of the line.
extern void line(color_t color, unsigned int x0, unsigned int y0, unsigned int x1, unsigned int y1);

// Puts a single tile on screen.
// 
// Args:
// - x: 0..127
// - y: 0..63
// - addr: the address pointing to the tile buffer.
extern void puttile(int x, int y, const char *addr);

// Draws a circle.
//
// Args:
// - x0,y0: the coordinates of the circle's origin.
// - radius: the circle radius, in pixels.
// - color: the color to draw the circle in.
void circle(int x0, int y0, int radius, color_t color);

// Draws an axis-aligned box (4 lines forming a rectangle).
// Args:
// - x0,y0: the coordinates of one of the box's corners.
// - x1,y1: the coordinates of the box corner diagonally from x0,y0.
// - color: the color to draw the box in.
void box(int x0, int y0, int x1, int y1, color_t col);

#endif // LIB_TIM_TIMGRAPH_H_
