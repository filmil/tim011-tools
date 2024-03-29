;;  Port of zxchars.h to asz180.

    .module zx_chars_tim_font
    .area _CODE
    .globl _zxchars
    .globl timfont

;; timprint library looks for this global to get the font
;; description from.
timfont:

;;  Raw data for a ZX Spectrum 8x8 bit font.

_zxchars:
; zxchars.png [0, 0]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [1, 0]
    .db #0x00, #0xC0, #0xC0, #0xC0, #0xC0, #0x00, #0xC0, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [2, 0]
    .db #0x00, #0x30, #0x30, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x0C, #0x0C, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [3, 0]
    .db #0x00, #0x30, #0xFC, #0x30, #0x30, #0xFC, #0x30, #0x00
    .db #0x00, #0x0C, #0x3F, #0x0C, #0x0C, #0x3F, #0x0C, #0x00
; zxchars.png [4, 0]
    .db #0x00, #0x00, #0xF0, #0x30, #0xF0, #0x00, #0xF0, #0x00
    .db #0x00, #0x03, #0x3F, #0x03, #0x3F, #0x33, #0x3F, #0x03
; zxchars.png [5, 0]
    .db #0x00, #0x3C, #0x3C, #0x00, #0xC0, #0x30, #0x0C, #0x00
    .db #0x00, #0x30, #0x0C, #0x03, #0x00, #0x3C, #0x3C, #0x00
; zxchars.png [6, 0]
    .db #0x00, #0xC0, #0x30, #0xC0, #0x30, #0x0C, #0xF0, #0x00
    .db #0x00, #0x00, #0x03, #0x00, #0x33, #0x0C, #0x33, #0x00
; zxchars.png [7, 0]
    .db #0x00, #0x00, #0xC0, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x03, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [8, 0]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x0C, #0x03, #0x03, #0x03, #0x03, #0x0C, #0x00
; zxchars.png [9, 0]
    .db #0x00, #0x30, #0xC0, #0xC0, #0xC0, #0xC0, #0x30, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [10, 0]
    .db #0x00, #0x00, #0xC0, #0x00, #0xF0, #0x00, #0xC0, #0x00
    .db #0x00, #0x00, #0x0C, #0x03, #0x3F, #0x03, #0x0C, #0x00
; zxchars.png [11, 0]
    .db #0x00, #0x00, #0x00, #0x00, #0xF0, #0x00, #0x00, #0x00
    .db #0x00, #0x00, #0x03, #0x03, #0x3F, #0x03, #0x03, #0x00
; zxchars.png [12, 0]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0xC0
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x03, #0x03, #0x00
; zxchars.png [13, 0]
    .db #0x00, #0x00, #0x00, #0x00, #0xF0, #0x00, #0x00, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x3F, #0x00, #0x00, #0x00
; zxchars.png [14, 0]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0xC0, #0xC0, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x03, #0x03, #0x00
; zxchars.png [15, 0]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0xC0, #0x30, #0x00
    .db #0x00, #0x00, #0x30, #0x0C, #0x03, #0x00, #0x00, #0x00
; zxchars.png [0, 1]
    .db #0x00, #0xF0, #0x0C, #0x0C, #0xCC, #0x3C, #0xF0, #0x00
    .db #0x00, #0x0F, #0x3C, #0x33, #0x30, #0x30, #0x0F, #0x00
; zxchars.png [1, 1]
    .db #0x00, #0xC0, #0x30, #0x00, #0x00, #0x00, #0xF0, #0x00
    .db #0x00, #0x03, #0x03, #0x03, #0x03, #0x03, #0x3F, #0x00
; zxchars.png [2, 1]
    .db #0x00, #0xF0, #0x0C, #0x00, #0xF0, #0x0C, #0xFC, #0x00
    .db #0x00, #0x0F, #0x30, #0x30, #0x0F, #0x00, #0x3F, #0x00
; zxchars.png [3, 1]
    .db #0x00, #0xF0, #0x0C, #0x00, #0x00, #0x0C, #0xF0, #0x00
    .db #0x00, #0x0F, #0x30, #0x0F, #0x30, #0x30, #0x0F, #0x00
; zxchars.png [4, 1]
    .db #0x00, #0x00, #0xC0, #0x30, #0x0C, #0xFC, #0x00, #0x00
    .db #0x00, #0x03, #0x03, #0x03, #0x03, #0x3F, #0x03, #0x00
; zxchars.png [5, 1]
    .db #0x00, #0xFC, #0x0C, #0xFC, #0x00, #0x0C, #0xF0, #0x00
    .db #0x00, #0x3F, #0x00, #0x0F, #0x30, #0x30, #0x0F, #0x00
; zxchars.png [6, 1]
    .db #0x00, #0xF0, #0x0C, #0xFC, #0x0C, #0x0C, #0xF0, #0x00
    .db #0x00, #0x0F, #0x00, #0x0F, #0x30, #0x30, #0x0F, #0x00
; zxchars.png [7, 1]
    .db #0x00, #0xFC, #0x00, #0x00, #0x00, #0xC0, #0xC0, #0x00
    .db #0x00, #0x3F, #0x30, #0x0C, #0x03, #0x00, #0x00, #0x00
; zxchars.png [8, 1]
    .db #0x00, #0xF0, #0x0C, #0xF0, #0x0C, #0x0C, #0xF0, #0x00
    .db #0x00, #0x0F, #0x30, #0x0F, #0x30, #0x30, #0x0F, #0x00
; zxchars.png [9, 1]
    .db #0x00, #0xF0, #0x0C, #0x0C, #0xF0, #0x00, #0xF0, #0x00
    .db #0x00, #0x0F, #0x30, #0x30, #0x3F, #0x30, #0x0F, #0x00
; zxchars.png [10, 1]
    .db #0x00, #0x00, #0x00, #0xC0, #0x00, #0x00, #0xC0, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [11, 1]
    .db #0x00, #0x00, #0xC0, #0x00, #0x00, #0xC0, #0xC0, #0x30
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [12, 1]
    .db #0x00, #0x00, #0x00, #0x00, #0xC0, #0x00, #0x00, #0x00
    .db #0x00, #0x00, #0x0C, #0x03, #0x00, #0x03, #0x0C, #0x00
; zxchars.png [13, 1]
    .db #0x00, #0x00, #0x00, #0xF0, #0x00, #0xF0, #0x00, #0x00
    .db #0x00, #0x00, #0x00, #0x3F, #0x00, #0x3F, #0x00, #0x00
; zxchars.png [14, 1]
    .db #0x00, #0x00, #0xC0, #0x00, #0x00, #0x00, #0xC0, #0x00
    .db #0x00, #0x00, #0x00, #0x03, #0x0C, #0x03, #0x00, #0x00
; zxchars.png [15, 1]
    .db #0x00, #0xF0, #0x0C, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x0F, #0x30, #0x0C, #0x03, #0x00, #0x03, #0x00
; zxchars.png [0, 2]
    .db #0x00, #0xF0, #0x0C, #0xCC, #0xCC, #0x0C, #0xF0, #0x00
    .db #0x00, #0x0F, #0x33, #0x3C, #0x3F, #0x00, #0x0F, #0x00
; zxchars.png [1, 2]
    .db #0x00, #0xF0, #0x0C, #0x0C, #0xFC, #0x0C, #0x0C, #0x00
    .db #0x00, #0x0F, #0x30, #0x30, #0x3F, #0x30, #0x30, #0x00
; zxchars.png [2, 2]
    .db #0x00, #0xFC, #0x0C, #0xFC, #0x0C, #0x0C, #0xFC, #0x00
    .db #0x00, #0x0F, #0x30, #0x0F, #0x30, #0x30, #0x0F, #0x00
; zxchars.png [3, 2]
    .db #0x00, #0xF0, #0x0C, #0x0C, #0x0C, #0x0C, #0xF0, #0x00
    .db #0x00, #0x0F, #0x30, #0x00, #0x00, #0x30, #0x0F, #0x00
; zxchars.png [4, 2]
    .db #0x00, #0xFC, #0x0C, #0x0C, #0x0C, #0x0C, #0xFC, #0x00
    .db #0x00, #0x03, #0x0C, #0x30, #0x30, #0x0C, #0x03, #0x00
; zxchars.png [5, 2]
    .db #0x00, #0xFC, #0x0C, #0xFC, #0x0C, #0x0C, #0xFC, #0x00
    .db #0x00, #0x3F, #0x00, #0x0F, #0x00, #0x00, #0x3F, #0x00
; zxchars.png [6, 2]
    .db #0x00, #0xFC, #0x0C, #0xFC, #0x0C, #0x0C, #0x0C, #0x00
    .db #0x00, #0x3F, #0x00, #0x0F, #0x00, #0x00, #0x00, #0x00
; zxchars.png [7, 2]
    .db #0x00, #0xF0, #0x0C, #0x0C, #0x0C, #0x0C, #0xF0, #0x00
    .db #0x00, #0x0F, #0x30, #0x00, #0x3F, #0x30, #0x0F, #0x00
; zxchars.png [8, 2]
    .db #0x00, #0x0C, #0x0C, #0xFC, #0x0C, #0x0C, #0x0C, #0x00
    .db #0x00, #0x30, #0x30, #0x3F, #0x30, #0x30, #0x30, #0x00
; zxchars.png [9, 2]
    .db #0x00, #0xF0, #0x00, #0x00, #0x00, #0x00, #0xF0, #0x00
    .db #0x00, #0x3F, #0x03, #0x03, #0x03, #0x03, #0x3F, #0x00
; zxchars.png [10, 2]
    .db #0x00, #0x00, #0x00, #0x00, #0x0C, #0x0C, #0xF0, #0x00
    .db #0x00, #0x30, #0x30, #0x30, #0x30, #0x30, #0x0F, #0x00
; zxchars.png [11, 2]
    .db #0x00, #0x0C, #0x0C, #0xFC, #0x0C, #0x0C, #0x0C, #0x00
    .db #0x00, #0x0C, #0x03, #0x00, #0x03, #0x0C, #0x30, #0x00
; zxchars.png [12, 2]
    .db #0x00, #0x0C, #0x0C, #0x0C, #0x0C, #0x0C, #0xFC, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x3F, #0x00
; zxchars.png [13, 2]
    .db #0x00, #0x0C, #0x3C, #0xCC, #0x0C, #0x0C, #0x0C, #0x00
    .db #0x00, #0x30, #0x3C, #0x33, #0x30, #0x30, #0x30, #0x00
; zxchars.png [14, 2]
    .db #0x00, #0x0C, #0x3C, #0xCC, #0x0C, #0x0C, #0x0C, #0x00
    .db #0x00, #0x30, #0x30, #0x30, #0x33, #0x3C, #0x30, #0x00
; zxchars.png [15, 2]
    .db #0x00, #0xF0, #0x0C, #0x0C, #0x0C, #0x0C, #0xF0, #0x00
    .db #0x00, #0x0F, #0x30, #0x30, #0x30, #0x30, #0x0F, #0x00
; zxchars.png [0, 3]
    .db #0x00, #0xFC, #0x0C, #0x0C, #0xFC, #0x0C, #0x0C, #0x00
    .db #0x00, #0x0F, #0x30, #0x30, #0x0F, #0x00, #0x00, #0x00
; zxchars.png [1, 3]
    .db #0x00, #0xF0, #0x0C, #0x0C, #0xCC, #0x0C, #0xF0, #0x00
    .db #0x00, #0x0F, #0x30, #0x30, #0x30, #0x33, #0x0F, #0x00
; zxchars.png [2, 3]
    .db #0x00, #0xFC, #0x0C, #0x0C, #0xFC, #0x0C, #0x0C, #0x00
    .db #0x00, #0x0F, #0x30, #0x30, #0x0F, #0x0C, #0x30, #0x00
; zxchars.png [3, 3]
    .db #0x00, #0xF0, #0x0C, #0xF0, #0x00, #0x0C, #0xF0, #0x00
    .db #0x00, #0x0F, #0x00, #0x0F, #0x30, #0x30, #0x0F, #0x00
; zxchars.png [4, 3]
    .db #0x00, #0xFF, #0xC0, #0xC0, #0xC0, #0xC0, #0xC0, #0x00
    .db #0x00, #0x3F, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [5, 3]
    .db #0x00, #0x0C, #0x0C, #0x0C, #0x0C, #0x0C, #0xF0, #0x00
    .db #0x00, #0x30, #0x30, #0x30, #0x30, #0x30, #0x0F, #0x00
; zxchars.png [6, 3]
    .db #0x00, #0x0C, #0x0C, #0x0C, #0x0C, #0x30, #0xC0, #0x00
    .db #0x00, #0x30, #0x30, #0x30, #0x30, #0x0C, #0x03, #0x00
; zxchars.png [7, 3]
    .db #0x00, #0x0C, #0x0C, #0x0C, #0x0C, #0xCC, #0x30, #0x00
    .db #0x00, #0x30, #0x30, #0x30, #0x30, #0x33, #0x0C, #0x00
; zxchars.png [8, 3]
    .db #0x00, #0x0C, #0x30, #0xC0, #0xC0, #0x30, #0x0C, #0x00
    .db #0x00, #0x30, #0x0C, #0x03, #0x03, #0x0C, #0x30, #0x00
; zxchars.png [9, 3]
    .db #0x00, #0x03, #0x0C, #0x30, #0xC0, #0xC0, #0xC0, #0x00
    .db #0x00, #0x30, #0x0C, #0x03, #0x00, #0x00, #0x00, #0x00
; zxchars.png [10, 3]
    .db #0x00, #0xFC, #0x00, #0x00, #0xC0, #0x30, #0xFC, #0x00
    .db #0x00, #0x3F, #0x0C, #0x03, #0x00, #0x00, #0x3F, #0x00
; zxchars.png [11, 3]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x3F, #0x03, #0x03, #0x03, #0x03, #0x3F, #0x00
; zxchars.png [12, 3]
    .db #0x00, #0x00, #0x0C, #0x30, #0xC0, #0x00, #0x00, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x03, #0x0C, #0x00
; zxchars.png [13, 3]
    .db #0x00, #0xFC, #0xC0, #0xC0, #0xC0, #0xC0, #0xFC, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [14, 3]
    .db #0x00, #0xC0, #0xF0, #0xCC, #0xC0, #0xC0, #0xC0, #0x00
    .db #0x00, #0x00, #0x03, #0x0C, #0x00, #0x00, #0x00, #0x00
; zxchars.png [15, 3]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0xFF
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0xFF
; zxchars.png [0, 4]
    .db #0x00, #0xC0, #0x30, #0xFC, #0x30, #0x30, #0xFC, #0x00
    .db #0x00, #0x0F, #0x30, #0x03, #0x00, #0x00, #0x3F, #0x00
; zxchars.png [1, 4]
    .db #0x00, #0x00, #0xF0, #0x00, #0xF0, #0x0C, #0xF0, #0x00
    .db #0x00, #0x00, #0x03, #0x0C, #0x0F, #0x0C, #0x0F, #0x00
; zxchars.png [2, 4]
    .db #0x00, #0x30, #0x30, #0xF0, #0x30, #0x30, #0xF0, #0x00
    .db #0x00, #0x00, #0x00, #0x0F, #0x30, #0x30, #0x0F, #0x00
; zxchars.png [3, 4]
    .db #0x00, #0x00, #0xC0, #0x30, #0x30, #0x30, #0xC0, #0x00
    .db #0x00, #0x00, #0x0F, #0x00, #0x00, #0x00, #0x0F, #0x00
; zxchars.png [4, 4]
    .db #0x00, #0x00, #0x00, #0xF0, #0x0C, #0x0C, #0xF0, #0x00
    .db #0x00, #0x0C, #0x0C, #0x0F, #0x0C, #0x0C, #0x0F, #0x00
; zxchars.png [5, 4]
    .db #0x00, #0x00, #0xF0, #0x0C, #0xFC, #0x0C, #0xF0, #0x00
    .db #0x00, #0x00, #0x03, #0x0C, #0x03, #0x00, #0x0F, #0x00
; zxchars.png [6, 4]
    .db #0x00, #0x00, #0xC0, #0xC0, #0xC0, #0xC0, #0xC0, #0x00
    .db #0x00, #0x0F, #0x00, #0x03, #0x00, #0x00, #0x00, #0x00
; zxchars.png [7, 4]
    .db #0x00, #0x00, #0xF0, #0x0C, #0x0C, #0xF0, #0x00, #0xF0
    .db #0x00, #0x00, #0x0F, #0x0C, #0x0C, #0x0F, #0x0C, #0x03
; zxchars.png [8, 4]
    .db #0x00, #0x0C, #0x0C, #0xFC, #0x0C, #0x0C, #0x0C, #0x00
    .db #0x00, #0x00, #0x00, #0x03, #0x0C, #0x0C, #0x0C, #0x00
; zxchars.png [9, 4]
    .db #0x00, #0xC0, #0x00, #0xF0, #0xC0, #0xC0, #0xF0, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x03, #0x00
; zxchars.png [10, 4]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x30, #0xC0
    .db #0x00, #0x0C, #0x00, #0x0C, #0x0C, #0x0C, #0x0C, #0x03
; zxchars.png [11, 4]
    .db #0x00, #0x30, #0x30, #0xF0, #0xF0, #0x30, #0x30, #0x00
    .db #0x00, #0x00, #0x03, #0x00, #0x00, #0x03, #0x0C, #0x00
; zxchars.png [12, 4]
    .db #0x00, #0xC0, #0xC0, #0xC0, #0xC0, #0xC0, #0x00, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x0F, #0x00
; zxchars.png [13, 4]
    .db #0x00, #0x00, #0x3C, #0xCC, #0xCC, #0xCC, #0xCC, #0x00
    .db #0x00, #0x00, #0x03, #0x0C, #0x0C, #0x0C, #0x0C, #0x00
; zxchars.png [14, 4]
    .db #0x00, #0x00, #0xFC, #0x0C, #0x0C, #0x0C, #0x0C, #0x00
    .db #0x00, #0x00, #0x03, #0x0C, #0x0C, #0x0C, #0x0C, #0x00
; zxchars.png [15, 4]
    .db #0x00, #0x00, #0xF0, #0x0C, #0x0C, #0x0C, #0xF0, #0x00
    .db #0x00, #0x00, #0x03, #0x0C, #0x0C, #0x0C, #0x03, #0x00
; zxchars.png [0, 5]
    .db #0x00, #0x00, #0xFC, #0x0C, #0x0C, #0xFC, #0x0C, #0x0C
    .db #0x00, #0x00, #0x03, #0x0C, #0x0C, #0x03, #0x00, #0x00
; zxchars.png [1, 5]
    .db #0x00, #0x00, #0xF0, #0x0C, #0x0C, #0xF0, #0x00, #0x00
    .db #0x00, #0x00, #0x0F, #0x0C, #0x0C, #0x0F, #0x0C, #0x3C
; zxchars.png [2, 5]
    .db #0x00, #0x00, #0xC0, #0x30, #0x30, #0x30, #0x30, #0x00
    .db #0x00, #0x00, #0x0F, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [3, 5]
    .db #0x00, #0x00, #0xF0, #0x0C, #0xF0, #0x00, #0xFC, #0x00
    .db #0x00, #0x00, #0x03, #0x00, #0x03, #0x0C, #0x03, #0x00
; zxchars.png [4, 5]
    .db #0x00, #0xC0, #0xF0, #0xC0, #0xC0, #0xC0, #0x00, #0x00
    .db #0x00, #0x00, #0x03, #0x00, #0x00, #0x00, #0x0F, #0x00
; zxchars.png [5, 5]
    .db #0x00, #0x00, #0x0C, #0x0C, #0x0C, #0x0C, #0xF0, #0x00
    .db #0x00, #0x00, #0x0C, #0x0C, #0x0C, #0x0C, #0x03, #0x00
; zxchars.png [6, 5]
    .db #0x00, #0x00, #0x0C, #0x0C, #0x30, #0x30, #0xC0, #0x00
    .db #0x00, #0x00, #0x0C, #0x0C, #0x03, #0x03, #0x00, #0x00
; zxchars.png [7, 5]
    .db #0x00, #0x00, #0x0C, #0xCC, #0xCC, #0xCC, #0x30, #0x00
    .db #0x00, #0x00, #0x0C, #0x0C, #0x0C, #0x0C, #0x03, #0x00
; zxchars.png [8, 5]
    .db #0x00, #0x00, #0x0C, #0x30, #0xC0, #0x30, #0x0C, #0x00
    .db #0x00, #0x00, #0x0C, #0x03, #0x00, #0x03, #0x0C, #0x00
; zxchars.png [9, 5]
    .db #0x00, #0x00, #0x0C, #0x0C, #0x0C, #0xF0, #0x00, #0xF0
    .db #0x00, #0x00, #0x0C, #0x0C, #0x0C, #0x0F, #0x0C, #0x03
; zxchars.png [10, 5]
    .db #0x00, #0x00, #0xFC, #0x00, #0xC0, #0x30, #0xFC, #0x00
    .db #0x00, #0x00, #0x0F, #0x03, #0x00, #0x00, #0x0F, #0x00
; zxchars.png [11, 5]
    .db #0x00, #0x00, #0x00, #0xF0, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x3F, #0x03, #0x00, #0x03, #0x03, #0x3F, #0x00
; zxchars.png [12, 5]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x03, #0x03, #0x03, #0x03, #0x03, #0x03, #0x00
; zxchars.png [13, 5]
    .db #0x00, #0xFC, #0xC0, #0x00, #0xC0, #0xC0, #0xFC, #0x00
    .db #0x00, #0x00, #0x00, #0x0F, #0x00, #0x00, #0x00, #0x00
; zxchars.png [14, 5]
    .db #0x00, #0xC0, #0x30, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x0C, #0x03, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [15, 5]
    .db #0xF0, #0x0C, #0xC3, #0x33, #0x33, #0xC3, #0x0C, #0xF0
    .db #0x0F, #0x30, #0xC3, #0xC0, #0xC0, #0xC3, #0x30, #0x0F
; zxchars.png [0, 6]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [1, 6]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0x00, #0x00, #0x00, #0x00
; zxchars.png [2, 6]
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [3, 6]
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0x00, #0x00, #0x00, #0x00
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0x00, #0x00, #0x00, #0x00
; zxchars.png [4, 6]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0xFF, #0xFF, #0xFF, #0xFF
; zxchars.png [5, 6]
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
; zxchars.png [6, 6]
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0x00, #0x00, #0x00, #0x00
    .db #0x00, #0x00, #0x00, #0x00, #0xFF, #0xFF, #0xFF, #0xFF
; zxchars.png [7, 6]
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0x00, #0x00, #0x00, #0x00
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
; zxchars.png [8, 6]
    .db #0x00, #0x00, #0x00, #0x00, #0xFF, #0xFF, #0xFF, #0xFF
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [9, 6]
    .db #0x00, #0x00, #0x00, #0x00, #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0x00, #0x00, #0x00, #0x00
; zxchars.png [10, 6]
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
    .db #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00, #0x00
; zxchars.png [11, 6]
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0x00, #0x00, #0x00, #0x00
; zxchars.png [12, 6]
    .db #0x00, #0x00, #0x00, #0x00, #0xFF, #0xFF, #0xFF, #0xFF
    .db #0x00, #0x00, #0x00, #0x00, #0xFF, #0xFF, #0xFF, #0xFF
; zxchars.png [13, 6]
    .db #0x00, #0x00, #0x00, #0x00, #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
; zxchars.png [14, 6]
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
    .db #0x00, #0x00, #0x00, #0x00, #0xFF, #0xFF, #0xFF, #0xFF
; zxchars.png [15, 6]
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
    .db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF

