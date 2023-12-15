#include "stdio.h"
#include "stdlib.h"
#include "unistd.h"

int main();

int main() {
    close(1);
    FILE* f = fopen("file.txt", "wt");
    if (f == NULL ) {
        printf("oops");
        return -1;
    }
    printf("print==%d==\n", (int)1);
    fclose(f);
    return 0;
}
