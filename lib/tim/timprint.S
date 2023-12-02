;; A port of timprint.lib to asz180.

;Graphics library for TIM-011, to be used with Small C compiler.
;It uses Small C function calling mechanism, but it could be easily
;modified for other schemes.

;TIMPRINT.LIB (c) 2021  Žarko Živanov, Marko Šolajić

;This program is free software: you can redistribute it and/or modify
;it under the terms of the GNU General Public License as published by
;the Free Software Foundation, either version 3 of the License, or
;(at your option) any later version.

;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.

;You should have received a copy of the GNU General Public License
;along with this program.  If not, see <http://www.gnu.org/licenses/>.
;


    .module timprint
    .hd64
    .area _CODE

    ; Exported
    .globl _prstr
    .globl _prsetinv
    .globl _chrinv

    ; Imported.
    .globl timfont

_cursorx:   .dw 0           ; current cursor x position
_cursory:   .dw 0           ; current cursor y position
_chrinv:    .db #0x00
_chrinv1:   .db #0x08     ; XOR value for drawing (0800 - no changes, 08FF - inverted chars)
_chrsub:    .dw #0x20       ; value to substract from char code (20 - ASCII, 0 - screen codes)

; puts character to screen and updates cursor position
; prchrxy(x, y, chr)
; x = 0 .. 63, y = 0 .. 31, chr 0-255 
; ofset = x*256*2 + y*4*2 + 8000H
prchrxy:
    POP AF  ; return address
    POP HL  ; chr
    POP DE  ; y
    POP BC  ; x
    PUSH    BC  ; Small C requires unmodified SP
    PUSH    DE
    PUSH    HL
    PUSH    AF

    ; save current position
    LD (_cursorx), BC
    LD (_cursory), DE
    ; entry point for the rest of char printing routines
_prchrxy0:
    ; calculate video address
    LD B, C
    SLA B
    SLA B
    SCF     ; add 80H
    RR B
    SLA E
    SLA E
    SLA E
    LD C, E

    ; calculate char address, each char is 16 bytes
    AND A
    LD DE, (_chrsub)    ; substract _chrsub value
    SBC HL, DE
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    LD DE, #timfont
    ADD HL, DE
;    EXX
;    LD HL,(_chrinv)     ; load _chrinv to HL'
;    EXX

    LD E, #2
_prchrxy1:
    PUSH BC
    PUSH DE
    LD DE,(_chrinv)      ; load _chrinv
;    LD D, 8

_prchrxy2:
    LD A,(HL)
;    EXX     ; XOR with _chrinv
;    XOR L
;    EXX
    XOR E
    OUT (C), A

    INC HL
    INC BC
    DEC D
    JP NZ, _prchrxy2

    POP DE
    POP BC
    INC B
    DEC E
    JP NZ, _prchrxy1

    ; calculate next char position
    ; x++; if (x>=64) {x=0; y++; if (y>=32) y=0;}
_prchrxy3:
    LD A,(_cursorx) ; x++
    INC A
    BIT 6,A         ; 6th bit set => x>=64
    JP Z, _prchrxy5
    LD A,(_cursory) ; y++
    INC A
    BIT 5,A         ; 5th bit set => y>=32
    JP Z, _prchrxy4
    XOR A           ; y=0
_prchrxy4:
    LD (_cursory),A
    XOR A           ; x=0
_prchrxy5:
    LD (_cursorx),A

    RET

; prints null-terminated string at current cursor position
; prstr(str)
; str passed in HL
_prstr:
    ;POP AF  ; return address
    ;POP HL  ; str
    ;PUSH HL
    ;PUSH AF
_prstr1:
    PUSH HL
    LD L,(HL)   ; get net xhar
    INC L       ; check if null
    DEC L
    JP Z, _prstr2
    LD H, #0
    LD BC,(_cursorx)
    LD DE,(_cursory)
    CALL _prchrxy0
    POP HL
    INC HL
    JP _prstr1
_prstr2:
    POP HL
    RET

; sets cursor position
; cursorxy(x, y)
; x = 0 .. 63, y = 0 .. 31
cursorxy:
    POP AF  ; return address
    POP HL  ; y
    POP DE  ; x
    PUSH    DE
    PUSH    HL
    PUSH    AF
    LD (_cursorx), DE
    LD (_cursory), HL
    RET

; sets XOR value for character drawing
; prsetinv(xor)
; xor=0 - normal drawing,  xor=0xFF - inverted drawing
; xor passed in hl
_prsetinv:
    LD (_chrinv), A
    RET

; sets the value to be substracted from character code
; prsetsub(sub)
; sub=0x20 - ASCII coding,  sub=0 - no coding
prsetsub:
    POP AF
    POP HL
    PUSH HL
    PUSH AF
    LD (_chrsub), HL
    RET


