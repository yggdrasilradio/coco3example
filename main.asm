BLACK	equ %00000000
AMBER	equ %01010101
GREEN	equ %10101010
WHITE	equ %11111111

* this macro doesn't work exactly right
* asm thinks it's an illegal 6309 instruction
clrd MACRO
	clra
	clrb
	ENDM

* Direct page

	org 0

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
string	rmb 10
currw	rmb 2
irqcnt	rmb 1
romflag	rmb 1
ptr	rmb 2
words	rmb 1
ctrl	rmb 1

* RAM storage

	org $1000

STACK	rmb 1

window0
	rmb 1 ;  ,u XSTART
	rmb 1 ; 1,u YSTART
	rmb 1 ; 2,u XWIDTH
	rmb 1 ; 3,u YHEIGHT
	rmb 1 ; 4,u XCURSOR
	rmb 1 ; 5,u YCURSOR
	rmb 1 ; 6,u FILLPTR
	rmb 1 ; 7,u EMPTPTR
	rmb 256 ; 8,u BUFFER
window1
	rmb 1 ;  ,u XSTART
	rmb 1 ; 1,u YSTART
	rmb 1 ; 2,u XWIDTH
	rmb 1 ; 3,u YHEIGHT
	rmb 1 ; 4,u XCURSOR
	rmb 1 ; 5,u YCURSOR
	rmb 1 ; 6,u FILLPTR
	rmb 1 ; 7,u EMPTPTR
	rmb 256 ; 8,u BUFFER
window2
	rmb 1 ;  ,u XSTART
	rmb 1 ; 1,u YSTART
	rmb 1 ; 2,u XWIDTH
	rmb 1 ; 3,u YHEIGHT
	rmb 1 ; 4,u XCURSOR
	rmb 1 ; 5,u YCURSOR
	rmb 1 ; 6,u FILLPTR
	rmb 1 ; 7,u EMPTPTR
	rmb 256 ; 8,u BUFFER
window3
	rmb 1 ;  ,u XSTART
	rmb 1 ; 1,u YSTART
	rmb 1 ; 2,u XWIDTH
	rmb 1 ; 3,u YHEIGHT
	rmb 1 ; 4,u XCURSOR
	rmb 1 ; 5,u YCURSOR
	rmb 1 ; 6,u FILLPTR
	rmb 1 ; 7,u EMPTPTR
	rmb 256 ; 8,u BUFFER

* Program

	org $3000 

start
	* Disable IRQ and FIRQ
	orcc #%01010000

	* Relocate stack
	lds #STACK

	* Set direct page
	clra
	tfr a,dp

	* Turn on ROMs
	lbsr romson

	* 1.78 Mhz CPU
	lbsr fast

	* Init graphics
	lbsr gfxinit

	* Clear screen
	lda #BLACK
	sta color
	lbsr gfxclear

	* Draw borders
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
	ldd #0
	std x1
	ldd #75
	std y1
	std y2
	ldd #639
	std x2
	lbsr line
	ldd #320
	std x1
	std x2
	ldd #0
	std y1
	ldd #75
	std y2
	lbsr line
	ldd #0
	std x1
	ldd #150
	std y1
	std y2
	ldd #639
	std x2
	lbsr line
	ldd #320
	std x1
	std x2
	ldd #150
	std y1
	ldd #224
	std y2
	lbsr line

	* Create windows

	* Window 0
	ldu #window0
	lda #2	; XSTART
	ldb #1	; YSTART
	std ,u
	lda #50	; XWIDTH
	ldb #9	; YHEIGHT
	std 2,u
	clra	; XCURSOR
	clrb	; YCURSOR
	std 4,u
	std 6,u ; FILLPTR / EMPTPTR

	* Window 1
	ldu #window1
	lda #55	; XSTART
	ldb #1	; YSTART
	std ,u
	lda #51	; XWIDTH
	ldb #9	; YHEIGHT
	std 2,u
	clra	; XCURSOR
	clrb	; YCURSOR
	std 4,u
	std 6,u ; FILLPTR / EMPTPTR

	* Window 2
	ldu #window2
	lda #2	; XSTART
	ldb #23	; YSTART
	std ,u
	lda #51	; XWIDTH
	ldb #9	; YHEIGHT
	std 2,u
	clra	; XCURSOR
	clrb	; YCURSOR
	std 4,u
	std 6,u ; FILLPTR / EMPTPTR

	* Window 3
	ldu #window3
	lda #55 ; XSTART
	ldb #23	; YSTART
	std ,u
	lda #51	; XWIDTH
	ldb #9	; YHEIGHT
	std 2,u
	clra	; XCURSOR
	clrb	; YCURSOR
	std 4,u
	std 6,u ; FILLPTR / EMPTPTR

	* Set IRQ interrupt vector
	lda #$7e
	sta $10c
	leau IRQ,pcr
	stu $10d

	* Disable HSYNC
	lda $ff01
	anda #$fe
	sta $ff01

	* Enable VSYNC
	lda $ff03
	ora #$01
	sta $ff03

	* Enable IRQ
	andcc #%10101111

	* Draw test strings in windows

	* Window 0
	ldu #window0
	stu currw
	lda #GREEN
	sta color
	leau stest0,pcr
	lbsr DrawString

	* Window 1
	ldu #window1
	stu currw
	lda #AMBER
	sta color
	leau stest1,pcr
	lbsr DrawString

	* Window 2
	ldu #window2
	stu currw
	lda #WHITE
	sta color
	leau stest2,pcr
	lbsr DrawString

	* Window 3
	ldu #window3
	stu currw
	lda #GREEN
	sta color
	leau stest3,pcr
	lbsr DrawString

	lda #WHITE
	sta color
	ldu #window0
	stu currw

	* Read keyboard and echo characters to current window
loop@
	lbsr keywait
	cmpa #81 ; Q
	lbeq reset
	tfr a,b
	lbsr PutChar
	bra loop@

stest0	fcc "WINDOW 0"
 fcb 13
 fcc "LINE 1"
 fcb 13,0
stest1	fcc "WINDOW 1"
 fcb 13
 fcc "LINE 1"
 fcb 13
 fcc "LINE 2"
 fcb 13
 fcc "LINE 3"
 fcb 13
 fcc "LINE 4"
 fcb 13
 fcc "LINE 5"
 fcb 13,0
stest2	fcc "WINDOW 2"
 fcb 13
 fcc "LINE 1"
 fcb 13
 fcc "LINE 2"
 fcb 13
 fcc "LINE 3"
 fcb 13
 fcc "LINE 4"
 fcb 13
 fcc "LINE 5"
 fcb 13,0
stest3	fcc "WINDOW 3"
 fcb 13
 fcc "LINE 1"
 fcb 13
 fcc "LINE 2"
 fcb 13
 fcc "LINE 3"
 fcb 13
 fcc "LINE 4"
 fcb 13
 fcc "LINE 5"
 fcb 13,0

 include utils.asm
 include graphics.asm
 include line.asm
 include font.asm
 include strings.asm

IRQ
 orcc #%01010000 ; disable IRQ
 inc irqcnt
 lbsr GetChar
 tstb
 beq no@
 lbsr DrawChar
no@
 tst $ff02 ; dismiss interrupt
 andcc #%10101111 ; enable IRQ
 rti

; currw current window
; B character
PutChar
 pshs a,x,u
 ldu currw
 lda 6,u ; FILLPTR
 leax 8,u ; BUFFER
 stb a,x
 inc 6,u ; FILLPTR
 puls a,x,u,pc

; currw current window
; B character
GetChar
 pshs a,x,u
 clrb
 ldu currw
 lda 7,u ; EMPTPTR
 cmpa 6,u ; FILLPTR
 beq no@
 leax 8,u ; BUFFER
 ldb a,x
 inc 7,u ; EMPTPTR
no@
 puls a,x,u,pc

* Screen $7000

SCREEN	equ $7000

	end start
