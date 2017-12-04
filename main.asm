BLACK	equ %00000000
AMBER	equ %01010101
GREEN	equ %10101010
WHITE	equ %11111111

FONTAMBER equ 1
FONTGREEN equ 2
FONTWHITE equ 3

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
seed	rmb 2
curs	rmb 1

* RAM storage

	org $1000

STACK	rmb 1

XSTART equ 0
YSTART equ 1
XWIDTH equ 2
YHEIGHT equ 3
XCURSOR equ 4
YCURSOR equ 5
FILLPTR equ 6
EMPTPTR equ 7
COLOR equ 8
BUFFER equ 9

window0
	rmb 1 ;  ,u XSTART
	rmb 1 ; 1,u YSTART
	rmb 1 ; 2,u XWIDTH
	rmb 1 ; 3,u YHEIGHT
	rmb 1 ; 4,u XCURSOR
	rmb 1 ; 5,u YCURSOR
	rmb 1 ; 6,u FILLPTR
	rmb 1 ; 7,u EMPTPTR
	rmb 1 ; 8,u COLOR
	rmb 256 ; 9,u BUFFER
window1
	rmb 1 ;  ,u XSTART
	rmb 1 ; 1,u YSTART
	rmb 1 ; 2,u XWIDTH
	rmb 1 ; 3,u YHEIGHT
	rmb 1 ; 4,u XCURSOR
	rmb 1 ; 5,u YCURSOR
	rmb 1 ; 6,u FILLPTR
	rmb 1 ; 7,u EMPTPTR
	rmb 1 ; 8,u COLOR
	rmb 256 ; 9,u BUFFER
window2
	rmb 1 ;  ,u XSTART
	rmb 1 ; 1,u YSTART
	rmb 1 ; 2,u XWIDTH
	rmb 1 ; 3,u YHEIGHT
	rmb 1 ; 4,u XCURSOR
	rmb 1 ; 5,u YCURSOR
	rmb 1 ; 6,u FILLPTR
	rmb 1 ; 7,u EMPTPTR
	rmb 1 ; 8,u COLOR
	rmb 256 ; 9,u BUFFER
window3
	rmb 1 ;  ,u XSTART
	rmb 1 ; 1,u YSTART
	rmb 1 ; 2,u XWIDTH
	rmb 1 ; 3,u YHEIGHT
	rmb 1 ; 4,u XCURSOR
	rmb 1 ; 5,u YCURSOR
	rmb 1 ; 6,u FILLPTR
	rmb 1 ; 7,u EMPTPTR
	rmb 1 ; 8,u COLOR
	rmb 256 ; 9,u BUFFER
window4
	rmb 1 ;  ,u XSTART
	rmb 1 ; 1,u YSTART
	rmb 1 ; 2,u XWIDTH
	rmb 1 ; 3,u YHEIGHT
	rmb 1 ; 4,u XCURSOR
	rmb 1 ; 5,u YCURSOR
	rmb 1 ; 6,u FILLPTR
	rmb 1 ; 7,u EMPTPTR
	rmb 1 ; 8,u COLOR
	rmb 256 ; 9,u BUFFER

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

	* Window 4
	ldu #window4
	lda #2  ; XSTART
	ldb #20 ; YSTART
	std ,u
	lda #51	; XWIDTH
	ldb #1	; YHEIGHT
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
	
	* Enable cursor
	lbsr curson

	* Enable IRQ
	andcc #%10101111

	* Draw test strings in windows

	* Window 0
	ldu #window0
	stu currw
	leau stest0,pcr
	lbsr DrawString

	* Window 1
	ldu #window1
	stu currw
	leau stest1,pcr
	lbsr DrawString

	* Window 2
	ldu #window2
	stu currw
	leau stest2,pcr
	lbsr DrawString

	* Window 3
	ldu #window3
	stu currw
	leau stest3,pcr
	lbsr DrawString

	* Read keyboard and echo characters to Window 4
	ldu #window4
	stu currw
	ldb #WHITE
	stb COLOR,u
loop@
	ldd seed
	addd #1
	std seed
	lbsr keywait
	cmpa #3 ; BREAK
	lbeq reset
	lbsr PutChar
	bra loop@

stest0
 fcb FONTWHITE
 fcc "WINDOW 0"
 fcb FONTGREEN
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
stest1
 fcb FONTWHITE
 fcc "WINDOW 1"
 fcb FONTGREEN
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
stest2
 fcb FONTWHITE
 fcc "WINDOW 2"
 fcb FONTAMBER
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
stest3
 fcb FONTWHITE
 fcc "WINDOW 3"
 fcb FONTAMBER
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

 ;lda #100
 ;sta $ff9a

 ldu currw
 pshs u
 inc irqcnt

* Update window 0
 ldu #window0
 stu currw
 lbsr GetChar
 tsta
 beq no@
 tfr a,b
 lbsr DrawChar
no@

* Update window 1
 ldu #window1
 stu currw
 lbsr GetChar
 tsta
 beq no@
 tfr a,b
 lbsr DrawChar
no@

* Update window 2
 ldu #window2
 stu currw
 lbsr GetChar
 tsta
 beq no@
 tfr a,b
 lbsr DrawChar
no@

* Update window 3
 ldu #window3
 stu currw
 lbsr GetChar
 tsta
 beq no@
 tfr a,b
 lbsr DrawChar
no@

* Update window 4
 ldu #window4
 stu currw
 lbsr GetChar
 tsta
 beq no@
 tfr a,b
 lbsr DrawChar
no@

* Every half second, blink cursor in window 4
 tst curs
 beq no@
 lda irqcnt
 anda #%00001111
 bne no@
 lda irqcnt
 anda #%00011111
 bne curoff@
 ldb #'*'
 bra drawcur@
curoff@
 ldb #' '
drawcur@
 lbsr DrawChar
 dec XCURSOR,u
no@

* Once a second, random chance of lines in window 0
 lda irqcnt
 anda #%00011111
 bne no@
 lbsr rand
 anda #$03
 bne no@
 ldu #window0
 stu currw
 leau stest0,pcr
 lbsr DrawString
no@

* Once a second, random chance of lines in window 1
 lda irqcnt
 anda #%00011111
 bne no@
 lbsr rand
 anda #$03
 bne no@
 ldu #window1
 stu currw
 leau stest1,pcr
 lbsr DrawString
no@

* Once a second, random chance of lines in window 2
 lda irqcnt
 anda #%00011111
 bne no@
 lbsr rand
 anda #$03
 bne no@
 ldu #window2
 stu currw
 leau stest2,pcr
 lbsr DrawString
no@

* Once a second, random chance of lines in window 3
 lda irqcnt
 anda #%00011111
 bne no@
 lbsr rand
 anda #$03
 bne no@
 ldu #window3
 stu currw
 leau stest3,pcr
 lbsr DrawString
no@

 tst $ff02 ; dismiss interrupt
 puls u
 stu currw

 ;lda #0
 ;sta $ff9a

 andcc #%10101111 ; enable IRQ
 rti

; currw current window
; A character
PutChar
 pshs b,x,u
 ldu currw
 ldb FILLPTR,u
 leax BUFFER,u
 abx
 sta ,x
 inc FILLPTR,u
 puls b,x,u,pc

; currw current window
; A character
GetChar
 pshs b,x,u
 clra
 ldu currw
 ldb EMPTPTR,u
 cmpb FILLPTR,u
 beq no@
 leax BUFFER,u
 abx
 lda ,x
 inc EMPTPTR,u
no@
 puls b,x,u,pc

* Screen $7000

SCREEN	equ $7000

	end start
