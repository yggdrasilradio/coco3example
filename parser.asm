
verbs
 fcc "GO"
 fdb GoCommand-*
 fcc "LO"
 fdb LoadCommand-*
 fcc "SA"
 fdb SaveCommand-*
 fcc "EX"
 fdb ExecCommand-*
 fcc "ST"
 fdb StatCommand-*
 fcc "TE"
 fdb TestCommand-*
 fdb 0

objects
 fdb 0

Parse
* Parse the verb from the command
 ldd cmd
 std verb
* Parse the object, if any
 clr obj
 clr obj+1
 ldu #cmd
 lda ncmd
loop@
 deca
 blt xloop@
 ldb ,u
 cmpa #32
 bne loop@
 leau 1,u
 bra loop@
xloop@
 rts

DoVerb
 leau verbs,pcr
loop1@
 ldd ,u
 beq xloop1@
 ldd cmd
 cmpd ,u
 bne no@
 leau 2,u
 ldd ,u
 leau d,u
 jsr ,u
 rts
no@
 leau 4,u
 bra loop1@
xloop1@
 rts

DoCommand
 lbsr DoVerb
 rts

GoCommand
 ldu #window0
 stu currw
 lda #FONTAMBER
 lbsr PutChar
 leau gmsg,pcr
 lbsr DrawString
 lda #FONTGREEN
 lbsr PutChar
 lda #13 ; CRLF
 lbsr PutChar
 lda #$3f 	; WHITE
 sta $ffb3
 rts

gmsg
 fcn "GO COMMAND RECEIVED"

LoadCommand
 ldu #window0
 stu currw
 lda #FONTAMBER
 lbsr PutChar
 leau lmsg,pcr
 lbsr DrawString
 lda #FONTGREEN
 lbsr PutChar
 lda #13 ; CRLF
 lbsr PutChar
 lda #$3f 	; WHITE
 sta $ffb3
 rts

lmsg
 fcn "LOAD COMMAND RECEIVED"

SaveCommand
 ldu #window0
 stu currw
 lda #FONTAMBER
 lbsr PutChar
 leau smsg,pcr
 lbsr DrawString
 lda #FONTGREEN
 lbsr PutChar
 lda #13 ; CRLF
 lbsr PutChar
 lda #$3f 	; WHITE
 sta $ffb3
 rts

smsg
 fcn "SAVE COMMAND RECEIVED"

ExecCommand
 ldu #window0
 stu currw
 lda #FONTAMBER
 lbsr PutChar
 leau emsg,pcr
 lbsr DrawString
 lda #FONTGREEN
 lbsr PutChar
 lda #13 ; CRLF
 lbsr PutChar
 lda #$3f 	; WHITE
 sta $ffb3
 rts

emsg
 fcn "EXEC COMMAND RECEIVED"

StatCommand
 ldu #window0
 stu currw
 lda #FONTAMBER
 lbsr PutChar
 leau statmsg,pcr
 lbsr DrawString
 ldd #zprog
 lbsr DrawHex
 lda #FONTGREEN
 lbsr PutChar
 lda #13 ; CRLF
 lbsr PutChar
 lda #$3f 	; WHITE
 sta $ffb3
 rts

TestCommand
 ldu #window1
 stu currw
 lda #FONTAMBER
 lbsr PutChar
 leau testmsg,pcr
 lbsr DrawString
 ldb #100
 lbsr DrawByte
 lda #'%'
 lbsr PutChar
 lda #FONTGREEN
 lbsr PutChar
 lda #13 ; CRLF
 lbsr PutChar
 lda #$24 	; RED
 sta $ffb3
 rts

testmsg
 fcn "ENERGY LEVEL "

statmsg
 fcn "END ADDR: "
