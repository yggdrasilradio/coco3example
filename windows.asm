InitWindows

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
	lda #GREEN
	sta 8,u ; COLOR

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
	lda #GREEN
	sta 8,u ; COLOR

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
	lda #GREEN
	sta 8,u ; COLOR

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
	lda #GREEN
	sta 8,u ; COLOR

	rts

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
