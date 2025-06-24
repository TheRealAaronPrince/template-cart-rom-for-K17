;where in memory the cartrige data will be coppied to
;suggested to stay at 300, so page $200 can be used for extra variables
Location = $300

; headder
;----------------------------------------------------------------
	; leave these as is
	.org Location - $100 ;headder (should be placed $100 back from data)
	.db "K17" ; identify as rom cart
	
	.db $6C ; number of pages to copy
	; $6C is the biggest this can be.
	; compile first then use the cart length tool on the rom to see what this value should be, then recompile.
	; or you can leave it at $6C. making this smaller only means you aren't copying the blank area after the rom code.
	
	; leave this as is
	.word Location ; where to copy to
	
	; leave this as is unless you know what you are doing
	.word Location ; where to begin execution
	
	; for now, leave this at $00
	.db $00 ; reserved for future use
	
	.string "Example" ; program name max length 18 chars
	; used to show name on kernal boot screen
;----------------------------------------------------------------

; cartrige code
;----------------------------------------------------------------
	.org Location


; example code
;----------------------------------------------------------------
	lda #$F0
	sta COLR	;set text color.
	jsr ClearScreen		;fill screen with space characters
	jsr LoadCustomChars
	.word ExampleTiles
	lda #0
	sta CHRX	;set text X start pos to 0
	lda #0
	sta CHRY	;set text Y start pos to 0
	jsr PrintStr
	.string "Sphinx of black quartz, judge my vow."
	jsr EndDraw
HaltLoop:
	jmp HaltLoop
;----------------------------------------------------------------

	.include KbdKeyVals.asm
	.include definitions.asm
	.include Libs.asm

;----------------------------------------------------------------

ExampleTiles:
	.binary custom-font.bin