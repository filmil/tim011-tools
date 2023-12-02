;/*
;    Graphics library for TIM-011, to be used with Small C compiler.
;    It uses Small C function calling mechanism, but it could be easily
;    modified for other schemes.

;    TIMGRAPH.LIB (c) 2021  Žarko Živanov, Marko Šolajić

;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.

;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.

;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;*/

;/*
;    NOTICE:
;        If index-based tiles are used, include for them should be placed
;        right after include for this library!
;*/

    .module timgraph
    .hd64
    .area _CODE

    .globl timtiles

; Pixel plot routine based on TIM-011 video memory layout, 512x256 with 2-bit pixels in shades of green or gray
; plotxy (int x, int y, int col)
; x = 0..511, y = 0..255, col = 0 ..3
; offset = int(x/4)*256 + y + 8000h
; pixelmask = col << ((x%4)*2)
_plotxy::
plotxy::
    ;POP AF  ; return address
    ;POP DE  ; col
    ;POP BC  ; y
    ;POP HL  ; x
    ;PUSH    HL  ; Small C requires unmodified SP
    ;PUSH    BC
    ;PUSH    DE
    ;PUSH    AF

    ; SDCC orders the parameters the other way around:
    ;
    ; ret address <- sp
    ; x
    ; y
    ; color
    pop af ; ret
    pop hl ; x
    pop bc ; y
    pop de ; color

    push de ; color
    push bc ; y
    push hl ; x
    push af ; ret

    PUSH DE ; save col
    PUSH HL ; save x

    SRL H   ; 16bit shift left 2
    RR L
    SRL H
    SCF     ; add 80H to final value
    RR L    ; L = int(x/4)
    LD B, L ; B = (x/4) + 80H, C = y, BC = int(x/4)*256 + y + 8000h

    ; this code is faster, but does not work for x>255
    ;LD A, L ; 4 cycles
    ;OR A ; 4 cycles - clear carry flag
    ;RRA ; 4 cycles
    ;SCF ; 4 cycles - set carry flag
    ;RRA ; 4 cycles - bit7 is set automatically
    ;LD B, A ; 4 cycles - set result to B - C is already set

    POP DE  ; x from stack
    LD A, E
    AND #0x03  ; A = x%4

    LD DE, #plottbl
    LD H, #0
    LD L, A
    ADD HL, DE  ; HL = plottbl + x mod 4

    IN A,(C) ; read pixels
    AND (HL) ; clear two bits

    POP DE  ; col from stack
    SLA E
    SLA E   ; DE = col << 2
    JP Z, plotout

    ADD HL, DE  ; add offset for color table
    OR (HL)

plotout:
    OUT (C), A  ; write pixels
    RET

plottbl:
    .db 0b11111100, 0b11110011, 0b11001111, 0b00111111   ; inverted mask for color 00B
    .db 0b00000001, 0b00000100, 0b00010000, 0b01000000   ; masks for color 01B
    .db 0b00000010, 0b00001000, 0b00100000, 0b10000000   ; masks for color 10B
    .db 0b00000011, 0b00001100, 0b00110000, 0b11000000   ; masks for color 11B


SCROLLREG .equ 0x00D0

; sets the value of TIM-011 scroll register at IO adress 00D0h
; scroll(n)
; n = 0 .. 255
_scroll::
scroll::
    POP HL  ; return address
    POP DE  ; scroll
    PUSH    DE
    PUSH    HL  ; Small C requires unmodified SP
    LD BC, #SCROLLREG
    OUT (C), E
    RET


; draws a line from x0,y0 to x1,y1
; line(col, x0, y0, x1, y1)
_linxpos:   .db 0    ; current x%4 value
_lindx:     .dw 0    ; abs(x1-x0)
_lindxneg:  .dw 0    ; -abs(x1-x0)
_lindy:     .dw 0    ; abs(y1-y0)
_linxleft:  .dw 0    ; how many x movements is left
_linyleft:  .dw 0    ; how many y movements is left
_linsy:     .dw 0    ; 1 or -1(255)
_linerr:    .dw 0
_line_flip::
line::
    POP AF  ; return address
    EX AF,AF'

    ; get coordinates from stack
    POP BC  ; y1
    POP HL  ; x1
    PUSH HL
    EXX     ; BC' = y1, HL' = x1
    POP DE  ; x1
    POP BC  ; y0
    POP HL  ; x0

    ; compare x0 and x1 - both positive numbers, can compare with simpler code
    AND A   ; clear carry
    SBC HL, DE
    ADD HL, DE
    JP C, _lindxdy
    EXX     ; swap if x1<x0

    ; NOW: HL,BC - x0,y0     HL',BC' - x1,y1     where x0<=x1 => sx = 1, dx >=0

; calculate dx, dy and sy
_lindxdy:
    LD (_linxleft), HL  ; x0
    LD (_linyleft), BC  ; y0
    LD (_lindx), HL     ; x0
    LD (_lindy), BC     ; y0
    EXX ; HL,BC - x1,y1
    PUSH HL
    PUSH BC
    ; calculate dx, xleft=dx and assume err=dx
    LD DE, (_lindx)
    AND A
    SBC HL, DE  ; x1-x0
    LD (_lindx), HL
    LD (_linxleft), HL
    LD (_linerr), HL    ; assume err = dx
    ; calculate -dx
    LD A,H      ; negate HL
    XOR #0xFF
    LD H,A
    LD A,L
    XOR #0xFF
    LD L,A
    LD DE, #1    ; add 1
    AND A
    ADD HL, DE
    LD (_lindxneg), HL  ; _lindxneg = -dx
    ; dy = y1-y0; if(dy<0) dy=-dy; sy = y0<y1 ? 1 : -1;
    POP HL  ; y1
    LD A, #1
    LD (_linsy), A      ; assume sy = 1
    ; calculate y1-y0
    LD DE, (_lindy)
    AND A
    SBC HL, DE  ; y1-y0
    JP NC, _lindxdy1
    ; calculate -dy
    LD A,H      ; negate HL
    XOR #0xFF
    LD H,A
    LD A,L
    XOR #0xFF
    LD L,A
    LD DE, #1    ; add 1
    AND A
    ADD HL, DE
    ; sy = -1
    LD A, #0xFF
    LD (_linsy), A
_lindxdy1:
    ; store calculated values
    LD (_lindy), HL
    LD (_linyleft), HL
    POP HL  ; x1
    EXX ; HL,BC - x0,y0

_linerr1:       ; err = (dx>dy ? dx : -dy) >> 1;   it is already assumed err = dx
    PUSH HL     ; x0
    ; compare dx and dy - both positive numbers, can compare with simpler code
    LD HL, (_lindx)
    LD DE, (_lindy)
    AND A
    SBC HL, DE
    JP NC, _linerrsh
_linerr2:
    EX DE,HL    ; HL = _lindy
    LD A,H      ; negate HL
    XOR #0xFF
    LD H,A
    LD A,L
    XOR #0xFF
    LD L,A
    LD DE, #1    ; add 1
    AND A
    ADD HL, DE
_linerrsh:
    ; >> 1
    SRA H
    RR L
    LD (_linerr), HL
    POP HL      ; x0

_linpix:
    ; calculate IO address and mask, taken from plotxy
    POP DE  ; col
    PUSH DE ; save col
    PUSH HL ; save x

    SRL H   ; 16bit shift left 2
    RR L
    SRL H
    SCF     ; add 80H to final value
    RR L    ; L = int(x/4)
    LD B, L ; B = (x/4) + 80H, C = y, BC = int(x/4)*256 + y + 8000h

    POP DE  ; x from stack
    LD A, E
    AND #0x3  ; A = x%4
    LD (_linxpos), A

    LD DE, #plottbl
    LD H, #0
    LD L, A
    ADD HL, DE  ; HL = plottbl + x mod 4

    ; NOW: HL - ponts to clear mask, BC - points to IO

    LD A, (HL)  ; A - clear mask
    POP DE  ; col from stack
    SLA E
    SLA E   ; DE = col << 2
    ADD HL, DE  ; HL now points to one of color masks
    INC DE      ; check if color was 0
    DEC DE
    JP Z, _linblack ; if yes, leave set mask at zero
    LD D, (HL)
_linblack:
    LD E, A

    ; NOW: D - set mask, E - clear mask, BC - points to IO

; main line drawing loop
_linloop:
    IN A,(C)    ; read pixels
    AND E       ; clear two bits
    OR  D       ; set pixels
    OUT (C), A  ; wtite to video memory

    ; check if all pixels are drawn (_linxleft == _linyleft == 0)
    LD HL, #_linxleft
    LD A, (HL)
    INC HL
    OR (HL)
    INC HL
    OR (HL)
    INC HL
    OR (HL)
    JP Z, _linend

    PUSH DE     ; masks
    ; e2 = err; if(e2 >-dx) { err -= dy; x0 += sx; }
    LD DE, (_linerr)    ; e2 = err
    PUSH DE     ; e2
    LD HL, (_lindxneg)  ; -dx

    ; compare -dx < e2
    LD A,H
    XOR D
    JP M,_lincmp12
    SBC HL,DE
    JR NC,_lincmp13
_lincmp11:
    JP _lincmp15
_lincmp12:
    BIT 7,D
    JR Z,_lincmp15
_lincmp13:
    OR A
_lincmp14:
    JP NC, _line21
_lincmp15:

    ; err -= dy
    POP HL      ; e2=err
    PUSH HL
    LD DE, (_lindy)
    AND A
    SBC HL, DE
    LD (_linerr), HL
    ; inc x coordinate = rotate masks, inc IO byte column
    POP HL      ; e2
    POP DE      ; masks
    RLC D
    RLC D
    RLC E
    RLC E
    PUSH DE     ; masks
    ; increment xpos and check if next column
    LD A, (_linxpos)
    INC A
    AND #0x3
    LD (_linxpos),A
    JP NZ, _line20
    ; next byte column
    INC B
_line20:
    ; dec xleft
    PUSH HL     ; e2
    LD HL, (_linxleft)
    DEC HL
    LD (_linxleft), HL

_line21:
    POP HL      ; e2
    ; if(e2 < dy) { err += dx; y0 += sy; }
    LD DE,(_lindy)

    ; compare e2 < dy
    LD A,H
    XOR D
    JP M,_lincmp22
    SBC HL,DE
    JR NC,_lincmp23
_lincmp21:
    JP _lincmp25
_lincmp22:
    BIT 7,D
    JR Z,_lincmp25
_lincmp23:
    OR A
_lincmp24:
    JP NC, _linnext
_lincmp25:

    ; err += dx
    LD HL,(_linerr)
    LD DE,(_lindx)
    ADD HL,DE
    LD (_linerr),HL
    ; inc/dec y coordinate = go to next/previous byte in column
    LD A,(_linsy)
    ADD A,C
    LD C,A
    ; dec _linyleft
    PUSH HL
    LD HL, (_linyleft)
    DEC HL
    LD (_linyleft), HL
    POP HL
_linnext:
    POP DE
    JP _linloop

_linend:
    PUSH BC
    PUSH BC
    PUSH BC
    PUSH BC
    PUSH BC
    EX AF,AF'
    PUSH AF
    RET

;/*
    ;TILE routines

    ;Tiles/sprites are 16x16 pixels graphic blocks. They can be positioned on 4-pixel boundaries
    ;anywhere inside TIM-011 video memory. This gives 0-127 for X and 0-63 for Y coordinate.
;*/

; tile size is 16x16 pixels, which is 4 bytes wide (2 bits per pixel) and 16 bytes high
; Tile data is organized by columns because TIM-011 video memory is organized by columns
SPRWBYT .equ 4
SPRHPIX .equ 16

; helper routine to calculate tile address
; if address in HL is 00-FFH, it is considered that this is tile number, and real address
;   is calculated as timtiles + L*64
; if address in HL is greater than 00FFH, it is considered as memory address
tileaddr:
    INC H
    DEC H
    JP NZ, tileaddr0
    ; shift left by 6 positions
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ; add base tile address
    PUSH DE
    LD DE, #timtiles
    ADD HL, DE
    POP DE
tileaddr0:
    RET

; puts tile on screen using OR with current content
; ortile(x, y, addr)
; x = 0 .. 127, y = 0 .. 63, addr 0-255 index based, or full address
; ofset = x*256 + y*4 + 8000H
ortile:
    POP AF  ; return address
    POP HL  ; addr
    POP DE  ; y
    POP BC  ; x
    PUSH    BC  ; Small C requires unmodified SP
    PUSH    DE
    PUSH    HL
    PUSH    AF
    CALL tileaddr

    ; x*256
    LD B, C
    ; add 80H to addr hi
    SLA B
    SCF
    RR B
    ; y*4
    SLA E
    SLA E
    LD C, E

    LD D, #SPRWBYT
    ; OR two columns of 16 bytes to two adjacent rows of video memory
ortile1:
    PUSH BC
    LD E, #SPRHPIX   ; 16 bytes

ortile2:
    IN A,(C)
    OR (HL)
    OUT (C), A

    INC HL
    INC BC
    DEC E
    JP NZ, ortile2

    POP BC
    INC B
    DEC D
    JP NZ, ortile1

    RET

; gets tile from screen
; gettile(x, y, addr)
; x = 0 .. 127, y = 0 .. 63, addr 0-255 index based, or full address
; ofset = x*256 + y*4 + 8000H
gettile:
    POP AF  ; return address
    POP HL  ; addr
    POP DE  ; y
    POP BC  ; x
    PUSH    BC  ; Small C requires unmodified SP
    PUSH    DE
    PUSH    HL
    PUSH    AF
    CALL tileaddr

    LD B, C
    SLA B
    SCF
    RR B
    SLA E
    SLA E
    LD C, E

    LD D, #SPRWBYT
gettile1:
    PUSH BC
    LD E, #SPRHPIX

gettile2:
    IN A,(C)
    LD (HL), A

    INC HL
    INC BC
    DEC E
    JP NZ, gettile2

    POP BC
    INC B
    DEC D
    JP NZ, gettile1

    RET

; puts tile to screen
; puttile(x, y, addr)
; x = 0 .. 127, y = 0 .. 63, addr 0-255 index based, or full address
; ofset = x*256 + y*4 + 8000H
_puttile_flip::
puttile::
    POP AF  ; return address
    POP HL  ; addr
    POP DE  ; y
    POP BC  ; x
    PUSH    BC  ; Small C requires unmodified SP
    PUSH    DE
    PUSH    HL
    PUSH    AF
    CALL tileaddr

    LD B, C
    SLA B
    SCF
    RR B
    SLA E
    SLA E
    LD C, E

    LD D, #SPRWBYT
puttile1:
    PUSH BC
    LD E, #SPRHPIX

puttile2:
    LD A,(HL)
    OUT (C), A

    INC HL
    INC BC
    DEC E
    JP NZ, puttile2

    POP BC
    INC B
    DEC D
    JP NZ, puttile1

    RET

; flips tile pixels horizontaly
; flptilex(addr)
; addr 0-255 index based, or full address
flptilex:
    POP BC  ; return address
    POP HL  ; addr
    PUSH HL
    PUSH BC
    CALL tileaddr
    EX DE,HL

    ; first, swap columns 0 and 3
    LD H, D
    LD A, #SPRHPIX*3
    ADD A, E        ; A = E + SPRHPIX*3
    JP NC, #flptilex0
    INC H
flptilex0:
    LD L, A         ; HL = DE + SPRHPIX*3

    ; column 0 and 3 swapping
    LD B, #SPRHPIX
flptilex1:
    LD A, (DE)
    CALL flip1byt
    EX AF,AF'
    LD A, (HL)
    CALL flip1byt
    LD (DE), A
    EX AF,AF'
    LD (HL), A

    INC HL
    INC DE
    DEC B
    JP NZ, flptilex1

    ; second, swap columns 1 and 2
    LD H, D
    LD A, #SPRHPIX
    ADD A, E        ; A = E + SPRHPIX
    JP NC, flptilex2
    INC H
flptilex2:
    LD L, A         ; HL = DE + SPRHPIX

    ; column 1 and 2 swapping
    LD B, #SPRHPIX
flptilex3:
    LD A, (DE)
    CALL flip1byt
    EX AF,AF'
    LD A, (HL)
    CALL flip1byt
    LD (DE), A
    EX AF,AF'
    LD (HL), A

    INC HL
    INC DE
    DEC B
    JP NZ, flptilex3

    RET

; helper function for flptilex
; flips 4 pixels inside one byte
;   7   6   5   4   3   2   1   0       start positions
;   <2  <2  >2  >2  <2  <2  >2  >2      movement to get to final position
;   1   0   3   2   5   4   7   6       final positions
flip1byt:
    LD C,A
    RRC C
    RRC C   ; 10765432
    RLCA
    RLCA    ; 54321076
    XOR C    
    AND       #0b00110011
    XOR C   ; 10325476
    RET

; flips tile pixels vertically
; flptiley(addr)
; addr 0-255 index based, or full address
flptiley:
    POP BC  ; return address
    POP HL  ; addr
    PUSH HL
    PUSH BC
    CALL tileaddr
    EX DE,HL

    LD B, #0x4
flptiley0:
    LD C, #SPRHPIX/2
    LD H, D
    LD A, #SPRHPIX-1
    ADD A, E        ; A = E + SPRHPIX-1
    JP NC, flptiley1
    INC H
flptiley1:
    LD L, A         ; HL = DE + SPRHPIX-1
    PUSH HL

flptiley2:
    LD A,(DE)
    EX AF,AF'
    LD A,(HL)
    LD (DE), A
    EX AF,AF'
    LD (HL), A
    INC DE
    DEC HL
    DEC C
    JP NZ, flptiley2

    POP DE
    INC DE
    DEC B
    JP NZ, flptiley0

    RET

