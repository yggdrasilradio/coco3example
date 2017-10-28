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
	lda #%00000000
	sta color
	lbsr gfxclear

	* UP
	ldd #310
	std x1
	ldd #112
	std y1
	ldd #310
	std x2
	ldd #0
	std y2
	lda #%11111111
	sta color
	lbsr line

	* LEFT
	ldd #310
	std x1
	ldd #112
	std y1
	ldd #0
	std x2
	ldd #112
	std y2
	lda #%11111111
	sta color
	lbsr line

	* RIGHT
	ldd #310
	std x1
	ldd #112
	std y1
	ldd #619
	std x2
	ldd #112
	std y2
	lda #%11111111
	sta color
	lbsr line

	* DOWN
	ldd #310
	std x1
	ldd #112
	std y1
	ldd #310
	std x2
	ldd #224
	std y2
	lda #%11111111
	sta color
	lbsr line

	* UPPER LEFT
	ldd #310
	std x1
	ldd #112
	std y1
	ldd #0
	std x2
	ldd #0
	std y2
	lda #%01010101
	sta color
	lbsr line

	* LOWER RIGHT
	ldd #310
	std x1
	ldd #112
	std y1
	ldd #619
	std x2
	ldd #224
	std y2
	lda #%01010101
	sta color
	lbsr line

	* UPPER RIGHT
	ldd #310
	std x1
	ldd #112
	std y1
	ldd #619
	std x2
	ldd #0
	std y2
	lda #%01010101
	sta color
	lbsr line

	* LOWER LEFT
	ldd #310
	std x1
	ldd #112
	std y1
	ldd #0
	std x2
	ldd #224
	std y2
	lda #%01010101
	sta color
	lbsr line
	
	lbsr keywait

	lda #%01010101
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

	lbra loop

	include	utils.asm
	include graphics.asm
	include line.asm

* Screen $7000

SCREEN	equ $7000

	end start
