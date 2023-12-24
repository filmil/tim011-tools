#include <stdio.h>
#include <stdlib.h>

#include "lib/testing/minunit.h"

char* all_tests() {
    for (int i = 0; i < 10; ++i) {
        printf("print==%d==\n", i);
    }
    printf("PASS\n");
    minunit_write_test_ok();
    return 0;
}
