#include <stdio.h>
#include <stdlib.h>

#include "lib/testing/minunit.h"

int foo = 7;
int bar = 4;

static char* test_foo() {
    mu_assert("error, foo != 7", foo == 7);
    return 0;
}

static char* test_bar() {
    mu_assert("error, bar != 4", bar == 4);
    return 0;
}

char* all_tests() {
    mu_run_test(test_foo);
    mu_run_test(test_bar);
    return 0;
}
 
