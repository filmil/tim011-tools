#include <stdio.h>
#include <stdlib.h>

char* all_tests();

int tests_run = 0;

void minunit_write_test_ok() {
		FILE* f = fopen("TEST_OK", "wt");
		if (f == NULL) {
			exit(-1);
		}
	fwrite("ALL TESTS PASSED\n", 10, 1, f);
		fclose(f);
}
 
int main(int argc, char **argv) {
    char *result = all_tests();
    if (result != 0) {
         printf("%s\n", result);
    } else {
		minunit_write_test_ok();
        printf("\n\nALL TESTS PASSED\n");
    }
    printf("Tests run: %d\n", tests_run);
    return result != 0;
 }
