* Set CPU to 1.79 Mhz
fast
 sta $FFD9
 rts

* Set CPU to 0.89 Mhz
slow
 sta $FFD8
 rts

* Map system ROMs into memory
romson
 clr romflag
 inc romflag
 sta $FFDE
 rts

* Take system ROMs out of memory map, set all-RAM mode
romsoff
 clr romflag
 sta $FFDF
 rts

* Wait for a key

keywait
	;lbsr romson
	jsr [$a000]
	;lbsr romsoff
	tsta
	beq keywait
	rts

* Wait forever
halt bra halt

* D = ABS(D)
absd
 tsta
 bge no@
 coma
 comb
 addd #1
no@
 rts

reset
	clra
	tfr a,dp
	clr $0071
	lbsr slow
	lbsr romson
	jmp $8C1B

