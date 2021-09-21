#include <stdio.h>

#include "tests/hello/putchar/putchar.h"

void outp(unsigned char val, unsigned int port) __sdcccall(1) __naked;

/*char hello[] = "hello world";*/

int main() {
   unsigned char vals[] = { 0x0, 0xaa, 0x55, 0xff};
   unsigned char c = 0;
   for (unsigned int i=0; i < 0x8000; i++) {
      unsigned char val = vals[c];
      outp(val, 0x8000 + i);
      c = (c+1) & 0x3;
   }
   return 0;
}

