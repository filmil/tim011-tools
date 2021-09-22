#include <stdio.h>

#include "tests/hello/putchar/putchar.h"

void outp(unsigned char val, unsigned int port) __sdcccall(1);

int main() {
   unsigned char c = 0;
   for (unsigned int i=0; i < 0x8000; i++) {
      outp(c++, 0x8000 + i);
   }
   return 0;
}

