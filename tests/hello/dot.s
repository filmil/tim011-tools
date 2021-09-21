	.module dot
	.hd64
	.globl _outp
	.area _CODE
;; void outp(unsigned char val, unsigned int port) __sdcccall(1) __naked;
;; _sdcccall(1) calling convention:
;;    val -> a
;;    port -> de 
_outp:
	ld b, d
	ld c, e
	out (c), a
	ret
