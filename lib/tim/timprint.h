#ifndef LIB_TIM_TIMPRINT_H_
#define LIB_TIM_TIMPRINT_H_

// Print the given string to the current screen position.
void inline prstr(const unsigned char* s) __sdcccall(1) __naked;

// Set inverse video value.
// Set to 0xff for inverse video. Set to 0x00 for normal video.
void inline prsetinv(unsigned char v) __sdcccall(1) __naked;

// Print a character in a tim font at the given coordinates.
// Args: 
//   - x: 0..63: the X character coordinate.
//   - y: 0..31: the Y character coordinate.
//   - c: the character to print.
void inline prchrxy(
		unsigned char x, unsigned char y, unsigned char c) __sdcccall(0) __naked;

// Set the cursor to the x,y coordinates.
//
// Args: 
//   - x: 0..63: the X character coordinate.
//   - y: 0..31: the Y character coordinate.
void inline cursorxy(unsigned char x, unsigned char y) __sdcccall(0) __naked;

void inline prsetsub(unsigned char v) __sdcccall(0) __naked;

// Char inversion. Set to 0x00 to draw regular characters, 0xff to draw inverse
// video.
extern char chrinv;

#endif // LIB_TIM_TIMPRINT_H_
