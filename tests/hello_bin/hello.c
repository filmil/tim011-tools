#include <stdio.h>

#include "tests/hello_bin/putchar.h"
#include "lib/testing/minunit.h"

char* all_tests() {
   printf("hello world!\n");
   put('\n');
   minunit_write_test_ok();
   return 0;
}

