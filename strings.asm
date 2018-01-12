; B	value
; color	color
; currw	current window
; BUG: THIS DOESN'T WORK FOR NUMBERS > 127
DrawByte

 ldu #string
 andb #$7f ; DEBUG
 pshs b

* hundreds digit
 lda #'0'
 sta ,u
loop@
 ldb ,s
 subb #100
 bmi xloop@
 stb ,s
 inc ,u
 bra loop@
xloop@

* tens digit
 lda #'0'
 sta 1,u
loop@
 ldb ,s
 subb #10
 bmi xloop@
 stb ,s
 inc 1,u
 bra loop@
xloop@

* ones digit
 puls b
 addb #'0'
 stb 2,u

* string terminator
 clr 3,u

; U string
; color color
 ldu #string
 lbsr DrawString

 rts

* D number
* currw current window
DrawHex
 pshs d,x
 ldu currw
 ldb ,s
 lsrb
 lsrb
 lsrb
 lsrb
 andb #$0f
 leax hextbl,pcr
 lda b,x
 lbsr PutChar
 ldb ,s
 andb #$0f
 leax hextbl,pcr
 lda b,x
 lbsr PutChar
 ldb 1,s
 lsrb
 lsrb
 lsrb
 lsrb
 andb #$0f
 leax hextbl,pcr
 lda b,x
 lbsr PutChar
 ldb 1,s
 andb #$0f
 leax hextbl,pcr
 lda b,x
 lbsr PutChar
 puls d,x,pc

hextbl
 fcc "0123456789ABCDEF"

