EndDraw:
	lda #$00
	sta PORTB
	rts
;----------------------------------------------------------------
;----------------------------------------------------------------
LoadDefaultCharset:
	ldy #$00
	lda #$90
	sta PORTB
CopyCharLoop$
	lda PORTB
	ora #0b00001000
	sta PORTB
	lda (Video),y
	sta CDAT
	lda PORTB
	and #0b11110111
	sta PORTB
	lda CDAT
	sta (Video),y
	iny
	bne CopyCharLoop$
	inc PORTB
	lda PORTB
	and #0b00000111
	bne CopyCharLoop$
	rts
;----------------------------------------------------------------
LoadCustomChars:
	tsx
	lda	$0101,x
	sta	ptr1
	lda	$0102,x
	sta	ptr1+1
	ldy	#$01
	lda	(ptr1),y
	sta ptr2
	iny
	lda	(ptr1),y
	sta ptr2+1
	tya
	clc
	adc	ptr1
	sta	$0101,x
	lda #$00
	adc	ptr1+1
	sta	$0102,x
;---
	ldy #$00
	lda (ptr2),y
	sta OPP1
	inc ptr2
	bcc nocarry1$
	inc ptr2+1
nocarry1$
	lda (ptr2),y
	sta OPP2
	inc ptr2
	bcc nocarry2$
	inc ptr2+1
nocarry2$
	lda OPP2
	sec
	sbc #$01
	lsr
	lsr
	lsr
	lsr
	lsr
	sta SCTH+1
	lda OPP1
	lsr
	lsr
	lsr
	lsr
	lsr
	clc
	adc #$90
	sta PORTB
	lda OPP2
	asl
	asl
	asl
	sec
	sbc #$01
	sta SCTH+2
	lda OPP1
	asl
	asl
	asl
	sta SCTH
CopyCharLoop$
	lda (ptr2),y
	sta CDAT
	tya
	clc
	adc SCTH
	tay
	lda CDAT
	sta (Video),y
	tya
	clc
	cmp SCTH+2
	bne continue$
	lda PORTB
	and #0b00000111
	cmp SCTH+1
	beq end$
continue$
	tya
	cmp #$FF
	bne NoPtrInc$
	inc PORTB
NoPtrInc$
	sec
	sbc SCTH
	tay
	iny
	bne CopyCharLoop$
	inc ptr2+1
	lda PORTB
	and #0b00000111
	bne CopyCharLoop$
end$
	rts
;----------------------------------------------------------------
;----------------------------------------------------------------
CharCalc: ;calculate page and byte address of the character from X and Y
	lda #ScrnW
	sta OPP1
	lda CHRY
	sta OPP2
	jsr GfxMul
	lda RSLT+1
	sta CHRH
	lda RSLT
	adc CHRX
	bcc end$
	inc CHRH
end$
	sta CHRL
	rts
;----------------------------------------------------------------
CharInc:		;'dirty' incrament char index.
	inc CHRX	;faster than CharCalc, but doesn't wrap around screen
	inc CHRL
	lda CHRL
	bne end$
	inc CHRH
end$
	rts
;----------------------------------------------------------------
CharDec:		;'dirty' decrament char index.
	dec CHRX	;faster than CharCalc, but doesn't wrap around screen
	dec CHRL
	lda CHRL
	cmp #$FF
	bne end$
	dec CHRH
end$
	rts
;----------------------------------------------------------------
;----------------------------------------------------------------
GetColor:		;read color data of cell
	clc
	lda CHRH
	adc #$10
	and #0b11110111
	sta PORTB
	ldy CHRL
	lda (Video),y
	sta COLR
	rts
;----------------------------------------------------------------
GetSymbol:		;read glyph data of cell
	clc
	lda CHRH
	adc #$10
	ora #0b00001000
	sta PORTB
	ldy CHRL
	lda (Video),y
	sta SYMB
	rts
;----------------------------------------------------------------
;----------------------------------------------------------------
SetColor:		;write color data to cell
	clc
	lda CHRH
	adc #$10
	and #0b11110111
	sta PORTB
	ldy CHRL
	lda COLR
	sta (Video),y
	rts
;----------------------------------------------------------------
SetSymbol:		;write glyph data to cell
	clc
	lda CHRH
	adc #$10
	ora #0b00001000
	sta PORTB
	ldy CHRL
	lda SYMB
	sta (Video),y
	rts
;----------------------------------------------------------------
;----------------------------------------------------------------
DrawTile:		;write color and glyph data to cell
	jsr SetSymbol
	jsr SetColor
	rts
;----------------------------------------------------------------
;----------------------------------------------------------------
ClearScreen: ;set up for FillRect to fill the screen with blank tiles
	lda #$20
	sta SYMB
	lda #$00
	sta SHX1
	sta SHY1
	lda #ScrnW
	sta SHX2
	lda #ScrnH
	sta SHY2
FillRect:	;fill rectangle on screen with single color and glyph byte
	lda SHY1
	sta CHRY
Yloop$
	lda SHX1
	sta CHRX
	jsr CharCalc
	lda SHY2
	cmp CHRY
	bne Xloop$
	rts
Xloop$
	jsr DrawTile
	jsr CharInc
	lda SHX2
	cmp CHRX
	bne Xloop$
	inc CHRY
	jmp Yloop$
;----------------------------------------------------------------
;----------------------------------------------------------------
; print data after jsr http://6502.org/source/io/primm.htm
PrintStr:
	jsr CharCalc
	tsx
	lda	$0101,x
	sta	STRL
	lda	$0102,x
	sta	STRH
	ldy	#$01
loop$
	lda	(STRL),y
	beq	end$
	sta	SYMB
	tya
	pha
	jsr	DrawTile
	jsr CharInc
	pla
	tay
	iny
	bne	loop$
end$
	tya
	clc
	adc	STRL
	sta	$0101,x
	lda #$00
	adc	STRH
	sta	$0102,x
	rts
;----------------------------------------------------------------
PrintStrPtr:
	ldy	#$00
loop$
	lda	(STRL),y
	beq	end$
	sta	SYMB
	tya
	pha
	jsr	DrawTile
	jsr CharInc
	pla
	tay
	iny
	bne	loop$
end$
	rts
;----------------------------------------------------------------
IncNum:
	jsr CharCalc
	jsr GetSymbol
	inc SYMB
	jsr SetSymbol
	lda SYMB
	cmp #$3A
	bne NoCarry$
	lda #$30
	sta SYMB
	jsr SetSymbol
	jsr CharDec
	jmp IncNum
NoCarry$
	rts
;----------------------------------------------------------------
;----------------------------------------------------------------
ImgRect:		;copy glyph and color data from memory to screen.
	lda SHY1
	sta CHRY
loopY$
	lda SHX1
	sta CHRX
	jsr CharCalc
	lda SHY2
	cmp CHRY
	bne loopX$
	rts
loopX$
	ldx #$00
	lda (SRCL,X)
	sta SYMB
	lda (SC2L,X)
	sta COLR
	jsr DrawTile
	jsr CharInc
	inc SRCL
	bne NoCarry1$
	inc SRCH
NoCarry1$
	inc SC2L
	bne NoCarry2$
	inc SC2H
NoCarry2$
	lda SHX2
	cmp CHRX
	bne loopX$
	inc CHRY
	jmp loopY$
;----------------------------------------------------------------
;----------------------------------------------------------------
GfxMul:
	lda OPP1
	sta SCTH
	lda #$00
	ldx #$08
	clc
L1$
	bcc L2$
	clc
	adc OPP2
L2$
	ror
	ror SCTH
	dex
	bpl L1$
	ldx SCTH
	sta RSLT+1
	txa
	sta RSLT
	rts
