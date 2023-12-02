
// From //lib/tim:tim_print_lib
void inline prstr(const char* s) __sdcccall(1) __naked;
void inline prsetinv(char v) __sdcccall(1) __naked;

extern char chrinv;

int main(void) {
    const char* str1 = "Trla Baba Lan Da Joj Prodje Dan! ";
    const char* str2 = "www.onceuponabyte.org ";
    const char* str3 = "WWW.8BITCHIP.INFO ";

    for(int i = 0; i < 28; i++) {
        prstr(str1);
        prstr(str2);
        prstr(str3);
        prsetinv((i & 1) ? 0xff : 0x00);
        // Doesn't seem to be any faster.  Standard tricks like loop unroll
                // also don't seemto do anything special.
        //chrinv = (i & 1) ? 0xff : 0x00;
    }
    return 0;
}


