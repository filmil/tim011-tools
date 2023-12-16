#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    FILE* f = fopen("0:file.txt", "wt");
    if (f == NULL) {
        printf("FAIL\n");
        return -1;
    }
    printf("PASS\n");
    fclose(f);
    return 0;
}
