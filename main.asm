clrd MACRO
	clra
	clrb
	ENDM

* Direct page

	org 0

* RAM storage

	org $1000

STACK	rmb 1
x1	rmb 2
y1	rmb 2
x2	rmb 2
y2	rmb 2
dx	rmb 2
dy	rmb 2
e	rmb 2
i	rmb 2
j	rmb 2
su	rmb 2
color	rmb 1

* Program

	org $3000 

start
	* disable interrupts
	orcc #$50

	* relocate stack
	lds #STACK

	* set direct page
	clra
	tfr a,dp

	* turn off ROMs
	lbsr romsoff

	* 1.78 Mhz CPU
	lbsr fast

	* init graphics
	lbsr gfxinit

	* clear screen
loop
	lda #%01010101
	sta color
	lbsr gfxclear

	lbsr keywait

	lda #%00000000
	sta color
	lbsr gfxclear

	lbsr keywait

	lda #%10101010
	sta color
	lbsr gfxclear

	lbsr keywait

	lda #%11111111
	sta color
	lbsr gfxclear

	lbsr keywait

	bra loop

	include	utils.asm
	include graphics.asm
	include line.asm

* Screen $7000

SCREEN	equ $7000

	end start
