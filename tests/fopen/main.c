#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include "lib/testing/minunit.h"

char* all_tests() {
    FILE* f = fopen("file.txt", "wt");
    if (f == NULL) {
        printf("errno: %s(%d)\nFAIL\n", strerror(errno), errno);
        return 0;
    }
    printf("PASS\n");
    fclose(f);
    minunit_write_test_ok();
    return 0;
}
