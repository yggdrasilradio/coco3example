BLACK	equ %00000000
AMBER	equ %01010101
GREEN	equ %10101010
WHITE	equ %11111111

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
xstring rmb 1
ystring rmb 1
xpos	rmb 2
ypos	rmb 2
rowdata	rmb 1

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
	lda #BLACK
	sta color
	lbsr gfxclear

	lda #WHITE
	sta color
	ldd #0
	std x1
	std y1
	std y2
	ldd #639
	std x2
	lbsr line

	ldd #0
	std x1
	std y1
	std x2
	ldd #254
	std y2
	lbsr line

	ldd #0
	std x1
	ldd #224
	std y1
	std y2
	ldd #639
	std x2
	lbsr line

	ldd #639
	std x1
	std x2
	ldd #0
	std y1
	ldd #224
	std y2
	lbsr line

	ldd #1
	tfr d,x
	tfr d,y
	lda #GREEN
	sta color
	leau stest1,pcr
	lbsr DrawString5x5

	ldd #1
	tfr d,x
	ldd #2
	tfr d,y
	lda #AMBER
	sta color
	leau stest2,pcr
	lbsr DrawString5x5

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

stest1 fcc "THE QUICK BROWN FOX JUMPED OVER THE #LAZY DOG. 0123.456789"
 fcb 0
stest2 fcc "NOW: IS THE TIME, FOR ALL GOOD MEN TO COME TO THE AID OF THEIR PARTY!"
 fcb 0

 * fcc " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:,.!#"

	include	utils.asm
	include graphics.asm
	include line.asm
	include font.asm

* Screen $7000

SCREEN	equ $7000

	end start
