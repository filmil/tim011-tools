extern char* timfont;
extern char zxchars[];

void prstr(const char* s);
void prsetinv(int v);

int main(void) {
    // Initialize tim's font.
    timfont = zxchars;

    const char* str1 = "Trla Baba Lan Da Joj Prodje Dan! ";
    const char* str2 = "www.onceuponabyte.org ";
    const char* str3 = "WWW.8BITCHIP.INFO ";
    for(int i = 0; i < 28; i++) {
        prstr(str1);
        prstr(str2);
        prstr(str3);
        if (i&1)
            prsetinv(0x8FF);
        else
            prsetinv(0x800);
    }
    return 0;
}


