BLACK	equ %00000000
AMBER	equ %01010101
GREEN	equ %10101010
WHITE	equ %11111111

FONTAMBER equ 1
FONTGREEN equ 2
FONTWHITE equ 3

* this macro doesn't work exactly right
* asm thinks it's an illegal 6309 instruction
* but this is how you'd do a macro, anyway
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
ptr	rmb 2
words	rmb 1
ctrl	rmb 1
bksp	rmb 1
seed	rmb 2
odd	rmb 1

* RAM storage

	org $1000

STACK	rmb 1
cmd	rmb 100
ncmd	rmb 1

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

	* Turn off ROMs
	lbsr romsoff

	* 1.78 Mhz CPU
	lbsr fast

	* Init graphics
	lbsr gfxinit

	* Clear screen
	lda #BLACK
	sta color
	lbsr gfxclear

	* Clear command buffer
	clr ncmd
	clr cmd

	* Draw borders
; lbra no@
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
no@
	* Create windows

	* Window 0
	ldu #window0
	lda #2	; XSTART
	ldb #2	; YSTART
	std ,u
	lda #50	; XWIDTH
	ldb #8	; YHEIGHT
	std 2,u
	clra	; XCURSOR
	clrb	; YCURSOR
	std 4,u
	std 6,u ; FILLPTR / EMPTPTR

	* Window 1
	ldu #window1
	lda #55	; XSTART
	ldb #2	; YSTART
	std ,u
	lda #51	; XWIDTH
	ldb #8	; YHEIGHT
	std 2,u
	clra	; XCURSOR
	clrb	; YCURSOR
	std 4,u
	std 6,u ; FILLPTR / EMPTPTR

	* Window 2
	ldu #window2
	lda #2	; XSTART
	ldb #24	; YSTART
	std ,u
	lda #51	; XWIDTH
	ldb #8	; YHEIGHT
	std 2,u
	clra	; XCURSOR
	clrb	; YCURSOR
	std 4,u
	std 6,u ; FILLPTR / EMPTPTR

	* Window 3
	ldu #window3
	lda #55 ; XSTART
	ldb #24	; YSTART
	std ,u
	lda #51	; XWIDTH
	ldb #8	; YHEIGHT
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

	* Window titles
	ldx #2
	ldy #1
	leau wtitle0,pcr
	lbsr GfxString
	ldx #55
	ldy #1
	leau wtitle1,pcr
	lbsr GfxString
	ldx #2
	ldy #23
	leau wtitle2,pcr
	lbsr GfxString
	ldx #55
	ldy #23
	leau wtitle3,pcr
	lbsr GfxString
	ldx #2
	ldy #20
	leau wtitle4,pcr
	lbsr GfxString

	* Enable IRQ
	andcc #%10101111

	* Window 0
	;ldu #window0
	;stu currw
	;leau stest0,pcr
	;lbsr DrawString

	* Window 1
	;ldu #window1
	;stu currw
	;leau stest1,pcr
	;lbsr DrawString

	* Window 2
	;ldu #window2
	;stu currw
	;leau stest2,pcr
	;lbsr DrawString

	* Window 3
	;ldu #window3
	;stu currw
	;leau stest3,pcr
	;lbsr DrawString

loop@
	ldd seed
	addd #1
	std seed
	bra loop@

stest0
 fcb FONTGREEN
 fcb 13
 fcc "THIS IS A "
 fcb FONTAMBER
 fcc "LONG LINE"
 fcb FONTGREEN
 fcc " FOR US, HERE"
 fcb 13
 fcc "LINE 2"
 fcb 13
 fcc "LINE 3"
 fcb 13
 fcc "LINE 4"
 fcb 13
 fcc "LINE 5"
 fcb 0
stest1
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
 fcb 0
stest2
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
 fcb 0
stest3
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
 fcb 0

 include utils.asm
 include graphics.asm
 include line.asm
 include font.asm
 include strings.asm

IRQ
 orcc #%01010000 ; disable IRQ

* Turn on border (DEBUG)
 ;lda #100
 ;sta $ff9a

 inc irqcnt

* begin poll keyboard
 lbsr romson
 jsr [$a000]
 lbsr romsoff
 tsta
 beq nokey@
 clr bksp
 cmpa #3 ; BREAK
 lbeq reset
 cmpa #8 ; BACKSPACE
 bne nobksp@
 tst ncmd
 beq nokey@
 dec ncmd
 lda #' '
 inc bksp
nobksp@
* Store character in command buffer
 ldu #cmd
 ldb ncmd
 leau b,u
 sta ,u
 clr 1,u
 tst bksp
 beq no@
 clr ,u
no@
* Display character
 ldx #11
 ldb ncmd
 leax b,x
 ldy #20
 tfr a,b
 lbsr GfxChar
 leax 1,x
 ldb #' '
 lbsr GfxChar
 tst bksp
 bne nokey@
 inc ncmd
nokey@
* end poll keyboard

* Every half second, blink cursor
 lda irqcnt
 anda #%00001111 ; half second
 bne no@
 lda irqcnt
 anda #%00011111 ; quarter second
 bne curoff@
 ldb #'_'
 bra drawcur@
curoff@
 ldb #' '
drawcur@
 ldy #20
 ldx #11
 lda ncmd
 leax a,x
 lbsr GfxChar
no@

* Update all windows
 lbsr UpdateWindows

* Once a second, random chance of lines in window 0
 lda irqcnt
 anda #%00011111
 bne no@
 lbsr rand
 anda #$03
 bne no@
 ldu #window0
 stu currw
 ;lbsr rand ; random hex number
 ;lbsr DrawHex
 ;lda #' ' ; space
 ;lbsr PutChar
 ldb ncmd ; number of characters in command buffer
 lbsr DrawByte
 lda #' ' ; space
 lbsr PutChar
 ldb cmd ; 1st char of command
 lbsr DrawByte
 lda #' ' ; space
 lbsr PutChar
 ldb cmd+1 ; 2nd char of command
 lbsr DrawByte
 lda #' ' ; space
 lbsr PutChar
 ldb cmd+2 ; 3rd char of command
 lbsr DrawByte
 lda #13 ; CRLF
 lbsr PutChar
 ;leau stest0,pcr
 ;lbsr DrawString
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
 lbsr rand
 lbsr DrawHex
 lda #13
 lbsr PutChar
 ;leau stest1,pcr
 ;lbsr DrawString
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
 lbsr rand
 lbsr DrawHex
 lda #13
 lbsr PutChar
 ;leau stest2,pcr
 ;lbsr DrawString
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
 lbsr rand
 lbsr DrawHex
 lda #13
 lbsr PutChar
 ;leau stest3,pcr
 ;lbsr DrawString
no@

* Dismiss interrupt
 tst $ff02

 ;puls u
 ;stu currw

* Turn off border (DEBUG)
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

wtitle0
 fcn "WINDOW 0:"
wtitle1
 fcn "WINDOW 1:"
wtitle2
 fcn "WINDOW 2:"
wtitle3
 fcn "WINDOW 3:"
wtitle4
 fcn "COMMAND:"

wndlst
 fdb window0
 fdb window1
 fdb window2
 fdb window3
 fdb 0

UpdateWindows
 ldu #wndlst
loop@
 ldd ,u
 beq exit@
 std currw
 lbsr UpdateWindow
 leau 2,u
 bra loop@
exit@
 rts

UpdateWindow
 lbsr GetChar
 tsta
 beq no@
 tfr a,b
 lbsr DrawChar
no@
 rts

* Screen $7000

SCREEN	equ $7000

	end start
