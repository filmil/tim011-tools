#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

int main() {
    FILE* f = fopen("file.txt", "wt");
    if (f == NULL) {
        printf("errno: %s(%d)\nFAIL\n", strerror(errno), errno);
        return -1;
    }
    printf("PASS\n");
    fclose(f);
    return 0;
}
