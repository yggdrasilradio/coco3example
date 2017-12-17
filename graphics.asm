
* init graphics

gfxinit
 pshs d

; INITIALIZATION REGISTER 0 $FF90
; 0  Coco 1/2 compatible: NO
; 0  MMU enabled: YES
; 0  GIME IRQ enabled: NO
; 0  GIME FIRQ enabled: NO
; 1  RAM at FExx is constant: YES		 ???
; 0  standard SCS (spare chip select): OFF
; 00 ROM map control: 16k internal, 16K external ???
 ldb #$08
 stb $FF90

; VIDEO MODE REGISTER $FF98
; 1  Graphic mode: YES
; 0  Unused
; 0  Composite color phase invert: NO
; 0  Monochrome on composite video out: NO
; 0  50Hz video: NO
; 00 Lines per row: one line per row		 ???
 ldb #$80
 stb $FF98

; VIDEO RESOLUTION REGISTER $FF99
; 0   Unused
; 11  LPF: 225
; 111 HRES: 160 bytes per row
; 01  CRES: 4 colors, 4 pixels per byte
 ldb #$7D
 stb $FF99

; VERTICAL OFFSET REGISTERS $FF9D - $FF9E
 ldd #$EE00
 sta $FF9D	MSB = ($70000 + addr) / 2048
 stb $FF9E	LSB = (addr / 8) AND $ff

; HORIZONTAL OFFSET REGISTER $FF9F
 clr $FF9F

; COLOR PALETTE REGISTERS $FFB0 - $FFBF
 lda #0		; BLACK
 sta $ffb0
 lda #48 	; YELLOW
 sta $ffb1
 lda #$12 	; GREEN $02 $10 $12
 sta $ffb2
 lda #$3f 	; WHITE
 sta $ffb3

 puls d,pc

* clear screen

gfxclear
 pshs d,x,u
 lda color
 ldb color
 ldx #160*225
 ldu #SCREEN
loop@
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 std ,u++
 leax -32,x
 bne loop@
 puls d,x,u,pc

* 640 x 225, 4 colors
* X is x
* Y is y
* B is color
pset
 pshs b
 ldu #SCREEN
 tfr y,d
 lda #160
 mul
 leau d,u
 tfr x,d
 asra
 rorb
 asra
 rorb
 leau d,u ; pointer to screen byte
 tfr x,d
 andb #$03
 leax bytetbl1,pcr
 leay bytetbl2,pcr
 lda ,u
 anda b,x
 sta ,u
 lda ,s
 anda b,y
 ora ,u
 sta ,u
 puls b,pc

bytetbl1
 fcb $3F
 fcb $CF
 fcb $F3
 fcb $FC
bytetbl2
 fcb $C0
 fcb $30
 fcb $0C
 fcb $03
