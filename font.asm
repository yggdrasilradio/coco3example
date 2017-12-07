
* Vertically scroll current window
VScroll
 pshs d,x,y,u
 lbsr romsoff
 ldu currw

 * Point X to start of row
 ldx #SCREEN
 lda #7
 ldb YSTART,u
 mul
 lda #160
 mul
 leax d,x
 lda #6
 ldb XSTART,u
 mul
 asra
 rorb
 asra
 rorb
 leax d,x
 stx ptr

 lda XWIDTH,u
 ldb #6
 mul
 asra
 rorb
 asra
 rorb
 asra
 rorb
 stb words

 * For each row in window
 lda YHEIGHT,u ; YHEIGHT
 pshs a
VS0

 * For each word in row
 ldx ptr
 ldb words
 pshs b
VS1

 lda 1,s
 deca
 bne VSmove

 clrb
 std (0*160),x
 std (1*160),x
 std (2*160),x
 std (3*160),x
 std (4*160),x

 bra VScont

VSmove
 ldd 1120+(0*160),x
 std (0*160),x
 ldd 1120+(1*160),x
 std (1*160),x
 ldd 1120+(2*160),x
 std (2*160),x
 ldd 1120+(3*160),x
 std (3*160),x
 ldd 1120+(4*160),x
 std (4*160),x

VScont

 leax 2,x

 * Next word in row
 dec ,s
 bne VS1
 leas 1,s

 * Next row in window
 ldx ptr
 leax 1120,x
 stx ptr
 dec ,s
 bne VS0
 leas 1,s

 lbsr romson
 puls d,x,y,u,pc

; currw current window
; U string
; color color
DrawString

loop@
 lda ,u+
 beq xDrawString
 lbsr PutChar
 bra loop@

xDrawString
 rts

; B character
; currw window
DrawChar
 pshs d,x,y,u
 clr ctrl
 pshs b

* Get current window
 ldu currw

* Carriage return
 cmpb #13
 bne no@
 inc ctrl
 clr XCURSOR,u
 inc YCURSOR,u
* Need scrolling?
 lda YCURSOR,u
 cmpa YHEIGHT,u
 lblo xDrawRow
* Scroll window
 lbsr VScroll
 dec YCURSOR,u
 lbra xDrawRow
no@

* Backspace?
 cmpb #8
 bne no@
 lda XCURSOR,u
 deca
 lblt xDrawRow ; don't backspace past left margin
 lda XCURSOR,u
 pshs a
 ldb #' '
 lbsr DrawChar ; wipe out cursor
 puls a
 deca
 sta XCURSOR,u
 ldb #' '
 inc ctrl
no@

* Color code?
 lda #GREEN
 cmpb #FONTGREEN
 beq yes@
no1@
 lda #AMBER
 cmpb #FONTAMBER
 beq yes@
no2@
 lda #WHITE
 cmpb #FONTWHITE
 beq yes@
 bra no4@
yes@
 sta COLOR,u
 inc ctrl
 lbra xDrawRow
no4@

* Clip to window width
 lda XCURSOR,u
 inca
 cmpa XWIDTH,u
 lbhs xDrawRow

* convert row/column to pixel offsets

 ldx #SCREEN
 ldb YCURSOR,u
 addb YSTART,u
 lda #7
 mul
 lda #160
 mul
 leax d,x

 ldb XSTART,u
 addb XCURSOR,u
 andb #1
 stb odd
 ldb XSTART,u
 addb XCURSOR,u
 lda #3
 mul
 lsra
 rorb
 leax d,x
 stx ptr

 puls b

* point X to font data
 leau charset,pcr
 leax font-5,pcr
loop@
 leax 5,x
 tst ,u
 beq xDrawChar
 cmpb ,u+
 bne loop@

* for each row
 ldd y1
 std ypos
 lda #5
 pshs a
DrawRow
 dec ,s
 bmi xDrawRow

* Clear row
 ldu ptr
 ldd #%0000000000001111
 tst odd
 beq even@
* odd
 ldd #%1111000000000000
even@
 lbsr romsoff
 anda ,u
 andb 1,u
 std ,u
 lbsr romson

 ldb ,x+
 lsrb
 leau fmasks,pcr
 ldd b,u
 ldy ptr
 tst odd
 beq even@
* odd, shift over 4 bits
 lsra
 rorb
 lsra
 rorb
 lsra
 rorb
 lsra
 rorb
even@
* even
 ldu currw
 anda COLOR,u
 andb COLOR,u
 lbsr romsoff
 ora ,y
 orb 1,y
 std ,y
 lbsr romson

* next row
 ldd ptr
 addd #160
 std ptr
 bra DrawRow
xDrawRow
 tst ctrl ; don't advance cursor for control characters
 bne no@
 ldu currw
 inc XCURSOR,u
no@
 puls b

xDrawChar
 puls d,x,y,u,pc

charset
 fcc " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:,.!#_"
 fcb 0

font
 fcb 0x00,0x00,0x00,0x00,0x00 ;  (space)
 fcb 0x38,0x44,0x7c,0x44,0x44 ;  A
 fcb 0x78,0x44,0x78,0x44,0x78 ;  B
 fcb 0x3C,0x40,0x40,0x40,0x3C ;  C
 fcb 0x78,0x44,0x44,0x44,0x78 ;  D
 fcb 0x7c,0x40,0x78,0x40,0x7c ;  E
 fcb 0x7c,0x40,0x70,0x40,0x40 ;  F
 fcb 0x3c,0x40,0x4c,0x44,0x38 ;  G
 fcb 0x44,0x44,0x7c,0x44,0x44 ;  H
 fcb 0x38,0x10,0x10,0x10,0x38 ;  I
 fcb 0x04,0x04,0x04,0x44,0x38 ;  J
 fcb 0x44,0x48,0x70,0x48,0x44 ;  K
 fcb 0x40,0x40,0x40,0x40,0x7c ;  L
 fcb 0x44,0x6c,0x54,0x44,0x44 ;  M
 fcb 0x44,0x64,0x54,0x4c,0x44 ;  N
 fcb 0x38,0x44,0x44,0x44,0x38 ;  O
 fcb 0x78,0x44,0x78,0x40,0x40 ;  P
 fcb 0x7c,0x44,0x44,0x7c,0x10 ;  Q
 fcb 0x78,0x44,0x78,0x44,0x44 ;  R
 fcb 0x3c,0x40,0x38,0x04,0x78 ;  S
 fcb 0x7c,0x10,0x10,0x10,0x10 ;  T
 fcb 0x44,0x44,0x44,0x44,0x38 ;  U
 fcb 0x44,0x44,0x28,0x28,0x10 ;  V
 fcb 0x44,0x44,0x54,0x54,0x28 ;  W
 fcb 0x44,0x28,0x10,0x28,0x44 ;  X
 fcb 0x44,0x44,0x28,0x10,0x10 ;  Y
 fcb 0x7c,0x08,0x10,0x20,0x7c ;  Z
 fcb 0x38,0x44,0x44,0x44,0x38 ;  0
 fcb 0x10,0x30,0x10,0x10,0x38 ;  1
 fcb 0x78,0x04,0x38,0x40,0x7c ;  2
 fcb 0x78,0x04,0x38,0x04,0x78 ;  3
 fcb 0x18,0x28,0x48,0x7c,0x08 ;  4
 fcb 0x7c,0x40,0x78,0x04,0x78 ;  5
 fcb 0x38,0x40,0x78,0x44,0x38 ;  6
 fcb 0x7c,0x04,0x08,0x10,0x10 ;  7
 fcb 0x38,0x44,0x38,0x44,0x38 ;  8
 fcb 0x38,0x44,0x3C,0x04,0x38 ;  9
 fcb 0x00,0x10,0x00,0x10,0x00 ;  :
 fcb 0x00,0x00,0x00,0x20,0x40 ;  ,
 fcb 0x00,0x00,0x00,0x00,0x10 ;  .
 fcb 0x10,0x10,0x10,0x00,0x10 ;  !
 fcb 0x28,0x7c,0x28,0x7c,0x28 ;  #
 fcb 0x00,0x00,0x00,0x00,0x7c ;  (cursor)

; B character
; X x position in chars
; Y y position in chars
GfxChar
 pshs d,x,y,u

 pshs b

* convert row/column to screen pointer

 ldu #SCREEN
 tfr y,d
 lda #7
 mul
 lda #160
 mul
 leau d,u
 tfr x,d
 andb #1
 stb odd
 tfr x,d
 lda #3
 mul
 lsra ; was asra
 rorb
 leau d,u
 stu ptr

 puls b

* point X to font data
 leau charset,pcr
 leax font-5,pcr
loop@
 leax 5,x
 tst ,u
 beq xGfxChar
 cmpb ,u+
 bne loop@

* for each row
 lda #5
 pshs a
GfxRow
 dec ,s
 bmi xGfxRow

* Clear row
 ldu ptr
 ldd #%0000000000001111
 tst odd
 beq even@
* odd
 ldd #%1111000000000000
even@
 lbsr romsoff
 anda ,u
 andb 1,u
 std ,u
 lbsr romson

 ldb ,x+
 lsrb
 leau fmasks,pcr
 ldd b,u
 ldu ptr
 tst odd
 beq even@
* odd, shift over 4 bits
 lsra
 rorb
 lsra
 rorb
 lsra
 rorb
 lsra
 rorb
even@
* even
 lbsr romsoff
 ora ,u
 orb 1,u
 std ,u
 lbsr romson

* next row
 ldd ptr
 addd #160
 std ptr
 bra GfxRow

xGfxRow
 puls b

xGfxChar
 puls d,x,y,u,pc

; X x position in chars
; Y y position in chars
; U pointer to string
GfxString
 pshs d

loop@
 ldb ,u+
 beq xGfxString
 lbsr GfxChar
 leax 1,x
 bra loop@

xGfxString
 puls d,pc

fmasks
 fdb %0000000000000000
 fdb %0000000011000000
 fdb %0000001100000000
 fdb %0000001111000000
 fdb %0000110000000000
 fdb %0000110011000000
 fdb %0000111100000000
 fdb %0000111111000000
 fdb %0011000000000000
 fdb %0011000011000000
 fdb %0011001100000000
 fdb %0011001111000000
 fdb %0011110000000000
 fdb %0011110011000000
 fdb %0011111100000000
 fdb %0011111111000000
 fdb %1100000000000000
 fdb %1100000011000000
 fdb %1100001100000000
 fdb %1100001111000000
 fdb %1100110000000000
 fdb %1100110011000000
 fdb %1100111100000000
 fdb %1100111111000000
 fdb %1111000000000000
 fdb %1111000011000000
 fdb %1111001100000000
 fdb %1111001111000000
 fdb %1111110000000000
 fdb %1111110011000000
 fdb %1111111100000000
 fdb %1111111111000000
