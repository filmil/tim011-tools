#include <stdio.h>

#include "tests/hello/putchar/putchar.h"
#include "lib/testing/minunit.h"

void outp(unsigned char val, unsigned int port) __sdcccall(1);

char* all_tests() {
   unsigned char c = 0;
   for (unsigned int i=0; i < 0x8000; i++) {
      outp(c++, 0x8000 + i);
   }
   minunit_write_test_ok();
   return 0;
}

