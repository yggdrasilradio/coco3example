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
	lda #$55
	sta color
	lbsr gfxinit

	* clear screen
	lbsr gfxclear

	lda #$f
	sta color

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #160
	std x2
	ldd #0
	std y2

	lbsr line ; 0

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #319
	std x2
	ldd #112
	std y2

	lbsr line ; 90

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #160
	std x2
	ldd #224
	std y2

	lbsr line ; 180

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #0
	std x2
	ldd #112
	std y2

	lbsr line ; 270

	lda #$1
	sta color

* 45 degrees

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #272
	std x2
	ldd #0
	std y2

	lbsr line ; 45

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #272
	std x2
	ldd #224
	std y2

	lbsr line ; 135

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #48
	std x2
	ldd #224
	std y2

	lbsr line ; 225

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #48
	std x2
	ldd #0
	std y2

	lbsr line ; 320

* 22.5

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #0
	std x2
	ldd #48
	std y2

	lbsr line ; SNW

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #319
	std x2
	ldd #48
	std y2

	lbsr line ; SNE

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #0
	std x2
	ldd #176
	std y2

	lbsr line ; NSW

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #319
	std x2
	ldd #176
	std y2

	lbsr line ; NSE

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #104
	std x2
	ldd #0
	std y2

	lbsr line ;

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #104
	std x2
	ldd #224
	std y2

	lbsr line ;

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #216
	std x2
	ldd #224
	std y2

	lbsr line

	ldd #160
	std x1
	ldd #112
	std y1

	ldd #216
	std x2
	ldd #0
	std y2

	lbsr line

	* wait forever
	lbra halt

	include graphics.asm
	include utils.asm
	include line.asm

* Screen $7000

SCREEN	equ $7000

zprog
	end start
