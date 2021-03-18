#include "mescc.h"
#include "CONIO2.LIB"

#include <timprint.lib>
#include "zxchars.h"

int main() {
    char *str1, *str2, *str3;
    int i;

    str1 = "Trla Baba Lan Da Joj Prodje Dan! ";
    str2 = "www.onceuponabyte.org ";
    str3 = "WWW.8BITCHIP.INFO ";
    for(i = 0; i < 28; i++) {
        prstr(str1);
        prstr(str2);
        prstr(str3);
        if (i&1)
            prsetinv(0xFF);
        else
            prsetinv(0x00);
    }
}

