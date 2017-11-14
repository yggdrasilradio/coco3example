
line
;	dx = abs(x2 - x1)
 ldd x2
 subd x1
 lbsr absd
 std dx
;	dy = abs(y2 - y1)
 ldd y2
 subd y1
 lbsr absd
 std dy
; 	is dy > dx?
 cmpd dx
 lbgt steep
;	Make sure x1 < x2
 ldd x1
 cmpd x2
 ble ok@
 ldx x1
 ldy x2
 stx x2
 sty x1
 ldx y1
 ldy y2
 stx y2
 sty y1
ok@
;	Is it sloping up?
 clr su
 ldd y1
 cmpd y2
 ble ok2@
 ldd y1
 aslb
 rola
 subd y2
 std y2
 inc su
ok2@
;	Let dx = x2 - x1
 ldd x2
 subd x1
 std dx
;	Let dy = y2 - y1
 ldd y2
 subd y1
 std dy
;	Let j = y1
 ldd y1
 std j
;	Let e = dy - dx
 ldd dy
 subd dx
 std e
;	for i = x1 to x2 - 1
 ldd x1
 std i
loop@
;		illuminate (i, j)
 ldx i
 ldy j
 tst su
 beq nosu@
 ldd y1
 aslb
 rola
 subd j
 tfr d,y
nosu@
 ldb color
 lbsr pset
;		if (e >= 0)
 ldd e
 bmi no@
;			j += 1
 ldd j
 addd #1
 std j
;			e -= dx
 ldd e
 subd dx
 std e
;		end if
no@
;		i += 1
 ldd i
 addd #1
 std i
;		e += dy
 ldd e
 addd dy
 std e
;	next i
 ldd i
 cmpd x2
 ble loop@
;	finish
 rts

steep
;	Make sure y1 < y2
 ldd y1
 cmpd y2
 ble ok@
 ldx x1
 ldy x2
 stx x2
 sty x1
 ldx y1
 ldy y2
 stx y2
 sty y1
ok@
;	Is it sloping up?
 clr su
 ldd x1
 cmpd x2
 ble ok2@
 ldd x1
 aslb
 rola
 subd x2
 std x2
 inc su
ok2@
;	Let dx = x2 - x1
 ldd x2
 subd x1
 std dx
;	Let dy = y2 - y1
 ldd y2
 subd y1
 std dy
;	Let i = x1
 ldd x1
 std i
;	Let e = dx - dy
 ldd dx
 subd dy
 std e
;	for j = y1 to y2 - 1
 ldd y1
 std j
loop@
;		illuminate (i, j)
 ldx i
 ldy j
 tst su
 beq nosu@
 ldd x1
 aslb
 rola
 subd i
 tfr d,x
nosu@
 ldb color
 lbsr pset
;		if (e >= 0)
 ldd e
 bmi no@
;			i += 1
 ldd i
 addd #1
 std i
;			e -= dy
 ldd e
 subd dy
 std e
;		end if
no@
;		i += 1
 ldd j
 addd #1
 std j
;		e += dx
 ldd e
 addd dx
 std e
;	next j
 ldd j
 cmpd y2
 ble loop@
;	finish
 rts
