// This file is not really used.  We are only using it to demo multiple files
// compilation within a single target.

#include "tests/hello/putchar/putchar.h"

int getchar(int c) {
    c++;
    return 0;
}
