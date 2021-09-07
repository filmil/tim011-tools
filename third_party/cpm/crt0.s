	;; A crt0.s for CP/M.
	;;
	;; Does only two things, really: (1) locates the code entry point at 0x0100
	;; which is always the entry point of the code on CP/M; and (2) sets up
	;; globals and stack.

	.module crt0

	.globl	_main
	.globl	_init

    .area   _HEADER (ABS)
	.org 0x100
_init:
	;; Stack at the top of memory.
	ld	sp,#0xffff

    ;; Initialise global variables
    call	gsinit
	call	_main
	jp		_exit

_endinit:

	;; Ordering of segments for the linker.
	.area	_HOME
    .area   _GSINIT
    .area   _GSFINAL

	.area	_DATA
	.area	_BSEG
    .area   _BSS
    .area   _HEAP

    .area   _CODE
__clock::
	ld	a,#2
    rst     0x08
	ret

_exit::
	;; CP/M does a "call" into the new program, so "ret" should be enough
	;; to come back.
	ret

    .area   _GSINIT
gsinit::
    .area   _GSFINAL
    ret
