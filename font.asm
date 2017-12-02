
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
 lda XCURSOR,u ; XCURSOR
 deca
 lblt xDrawRow
 sta XCURSOR,u
 ldb #' '
 stb ,s
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
 bhs xDrawRow

* convert row/column to pixel offsets
 ldb XCURSOR,u
 addb XSTART,u
 lda #6
 mul
 std x1

 ldb YCURSOR,u ; YCURSOR
 addb YSTART,u ; YSTART
 lda #7
 mul
 std y1

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

 ldu currw

* for each row
 ldd y1
 std ypos
 lda #5
 pshs a
DrawRow
 dec ,s
 bmi xDrawRow

* for each pixel in row
 ldb ,x+
 rolb
 stb rowdata
 ldd x1
 std xpos
 lda #5
 pshs a

DrawPixel
 dec ,s
 bmi xDrawPixel

* draw pixel
 ldu currw
 ldb COLOR,u
 rol rowdata
 bcs no@
 clrb
no@
 pshs x
 ldx xpos
 ldy ypos
 lbsr pset
 puls x

* next pixel
 ldd xpos
 addd #1
 std xpos
 bra DrawPixel
xDrawPixel
 leas 1,s

* next row
 ldd ypos
 addd #1
 std ypos
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
 fcc " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:,.!#*"
 fcb 0
* missing "$%&'()*=-<>?/

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
