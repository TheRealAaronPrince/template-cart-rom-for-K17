KbdRead:
	lda #$00
	sta CharIn
	lda #$FF
	sta KeyIdx
	ldx #$08
KbdLoop$
	dex
	txa
	tay
	lda (kbd),y
	sta kbdSnap,x
;filter out keys being held down
	eor kbdBuffA,x
	and kbdSnap,x
	sta kbdBuffB,x
	lda kbdSnap,x
	sta kbdBuffA,x
	lda kbdBuffB,x
	beq NoKey$
	
	lda #$07
	sta KeyIdx
	lda kbdBuffB,x
	and #0b00000001
	bne h0$

	lda #$06
	sta KeyIdx
	lda kbdBuffB,x
	and #0b00000010
	bne h0$

	lda #$05
	sta KeyIdx
	lda kbdBuffB,x
	and #0b00000100
	bne h0$

	lda #$04
	sta KeyIdx
	lda kbdBuffB,x
	and #0b00001000
	bne h0$

	lda #$03
	sta KeyIdx
	lda kbdBuffB,x
	and #0b00010000
	bne h0$

	lda #$02
	sta KeyIdx
	lda kbdBuffB,x
	and #0b00100000
	bne h0$

	lda #$01
	sta KeyIdx
	lda kbdBuffB,x
	and #0b01000000
	bne h0$

	lda #$00
	sta KeyIdx
h0$
	txa
	asl
	asl
	asl
	adc KeyIdx
	sta KeyIdx
NoKey$
	txa
	cmp #$00
	bne KbdLoop$
	jsr Modifyers
	lda ModKeys	;use different char table for capslock and shift
	and #0b11000000
	lsr
	adc KeyIdx
	cmp #$FF
	beq NoChar$
	tax
	lda CharTable,x
	sta CharIn
NoChar$
	rts
	
; set bits for modifyer keys
Modifyers:
	lda ModKeys
	and #0b10000000
	sta ModKeys
MKey1:	;capslock
	lda KeyIdx
	cmp #Key_capslock
	bne MKey2
	lda ModKeys
	eor #0b10000000
	sta ModKeys
MKey2:	;shift
	lda kbdSnap
	and #0b00010000
	beq MKey3
	lda ModKeys
	ora #0b01000000
	sta ModKeys
MKey3:	;control
	lda kbdSnap+7
	and #0b10000000
	beq MKey4
	lda ModKeys
	ora #0b00100000
	sta ModKeys
MKey4:	;super
	lda kbdSnap+7
	and #0b01000000
	beq MKey5
	lda ModKeys
	ora #0b00010000
	sta ModKeys
MKey5:	;alt
	lda kbdSnap+7
	and #0b00100000
	beq MKey6
	lda ModKeys
	ora #0b00001000
	sta ModKeys
MKey6:	;function
	lda kbdSnap+7
	and #0b00001000
	beq MKey7
	lda ModKeys
	ora #0b00000100
	sta ModKeys
MKey7:	;mod
	lda kbdSnap+7
	and #0b00000100
	beq MKey8
	lda ModKeys
	ora #0b00000010
	sta ModKeys
MKey8:	;menu
	lda kbdSnap+7
	and #0b00000010
	beq MKeyEnd
	lda ModKeys
	ora #0b00000001
	sta ModKeys
MKeyEnd
	rts

CharTable:
	.binary drivers\charTable.bin
