
* Set CPU to 1.79 Mhz
fast
 sta $FFD9
 rts

* Set CPU to 0.89 Mhz
slow
 sta $FFD8
 rts

* Map system ROMs into memory
romson
 sta $FFDE
 rts

* Take system ROMs out of memory map, set all-RAM mode
romsoff
 sta $FFDF
 rts

* Wait forever
halt bra halt

* D = ABS(D)
absd
 tsta
 bge no@
 coma
 comb
 addd #1
no@
 rts

* Hard boot to RSDOS
reset
 clra
 tfr a,dp
 clr $0071
 lbsr slow
 lbsr romson
 jmp $8C1B

rndtbl   fcb   $af,$5b,$c1,$97,$d4,$cc,$30,$31,$51,$b8,$f3,$d0,$d4,$89,$ed,$1c
         fcb   $1b,$86,$b3,$8b,$72,$ad,$fe,$58,$0c,$42,$7b,$73,$38,$b0,$f9,$1b
         fcb   $a2,$87,$36,$9e,$8f,$44,$86,$4b,$b7,$7a,$89,$61,$64,$36,$cf,$fc
         fcb   $7a,$da,$7c,$01,$da,$4c,$dd,$0f,$8c,$8f,$ef,$cb,$fc,$ac,$59,$90
         fcb   $e4,$27,$f3,$b1,$26,$97,$5f,$a3,$15,$20,$31,$a1,$a7,$47,$3c,$28
         fcb   $e7,$97,$c3,$d0,$5b,$3b,$24,$94,$01,$b1,$55,$fe,$e6,$f5,$49,$9e
         fcb   $74,$bc,$46,$ac,$47,$55,$a4,$d9,$00,$e9,$fe,$60,$6a,$69,$80,$6a
         fcb   $8e,$68,$b1,$dc,$f9,$a5,$e3,$76,$65,$11,$fd,$5a,$22,$e1,$c2,$54
         fcb   $b8,$47,$cd,$70,$96,$72,$67,$0a,$cf,$ee,$c3,$c1,$04,$41,$73,$84
         fcb   $6b,$95,$85,$ed,$5d,$76,$3a,$fc,$c9,$bc,$16,$66,$06,$1d,$d0,$37
         fcb   $2c,$ff,$5b,$28,$e0,$93,$51,$dd,$96,$c2,$dc,$4a,$c9,$3e,$dc,$db
         fcb   $9c,$3f,$32,$44,$32,$7b,$b7,$67,$40,$64,$8e,$f5,$13,$0b,$91,$a1
         fcb   $87,$c3,$bb,$d8,$2c,$eb,$7d,$5f,$37,$ec,$1d,$8a,$15,$1f,$d4,$9a
         fcb   $6c,$13,$fc,$2a,$11,$66,$e7,$77,$e6,$d8,$1c,$5f,$fd,$f9,$67,$a2
         fcb   $d9,$81,$48,$a5,$05,$42,$07,$7c,$c7,$9a,$73,$e9,$cb,$af,$d0,$62
         fcb   $f9,$16,$b1,$b1,$bf,$63,$81,$c6,$33,$23,$5d,$5e,$93,$72,$9b,$19

* D random number
rand
 pshs u
 leau rndtbl,pcr
 ldb seed
 lda irqcnt
 mul
 adda irqcnt
 addb irqcnt
 eora b,u
 eorb a,u
 addd seed
 std seed
 puls u,pc
