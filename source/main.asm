	characterindex = $64
	rowindex = $65
	cursorcolorindex = $67
	state = $68
	counter = $69

	colormempointer = $80
	screenmempointer = $82
	textpointer = $84

	screenmem = $0400
	charset = $3800
	cursorcolors = $42aa
	fadecolors = $42d0
	text = $4440
	colormem = $d800

	*= $0801

	lda #$00
	sta $d020
	sta $d021
	
	jsr setpointers
	jsr setstatepause

	sei

	lda #%00110101
	sta $01

	lda #%01111111
	sta $dc0d
	sta $dd0d

	lda #%00000001
	sta $d01a

	lda #%00011011
	sta $d011

	lda #%11001000
	sta $d016

	lda #%00011110
	sta $d018

	lda #$00
	sta $d012

	lda #<irq 
	sta $fffe
	lda #>irq
	sta $ffff
	
	cli
	
	jmp *

irq:
	asl $d019

	jsr getstate
	jsr writecursor

	lda #$00
	sta $d012

	lda #<irq
	sta $fffe
	lda #>irq
	sta $ffff

	rti

dissolve:
	lda counter
	cmp #$00
	beq dissolvedone

	jsr fadescreen

	dec counter
	rts

getstate:
	lda state
	cmp #$01
	beq writecharacter
	bpl dissolve
	bmi countdown
	rts

fadescreen:
	ldx counter
	lda fadecolors,x
	ldy #$00
-
	sta colormem,y
	sta colormem + 255,y
	sta colormem + 255 * 2,y

	iny
	bne -

	ldy #$00
-
	sta colormem + 255 * 3,y

	iny
	cpy #235
	bne -
	rts

dissolvedone:
	jsr advancescreen
	jsr setstatewrite
	jsr clearscreen
	rts

writecursor:
	ldx cursorcolorindex
	ldy characterindex
	lda cursorcolors,x
	sta (colormempointer),y

	lda #$40
	sta (screenmempointer),y

	lda cursorcolorindex
	cmp #26
	beq resetcursorcolor
	inc cursorcolorindex
	rts

resetcursorcolor:
	lda #$00
	sta cursorcolorindex
	rts

countdown:
	lda counter
	cmp #$00
	beq advancescreen
	dec counter
	rts

advancescreen:
	jsr setstatedissolve
	jsr clearindices
	jsr setcolorpointer
	jsr setscreenpointer
	rts

clearscreen:
	lda #$20
	ldx #$00
-
	sta screenmem,x
	sta screenmem + 255,x
	sta screenmem + 255 * 2,x

	inx
	bne -

	ldx #$00
-
	sta screenmem + 255 * 3,x

	inx
	cpx #235
	bne -
	rts

writecharacter:
	jsr getcolor

	ldy characterindex
	lda (textpointer),y
	cmp #$ff
	beq setpointers

	sta (screenmempointer),y
	cpy #39
	beq nextrow

	inc characterindex
	rts

getcolor:
	ldy characterindex
	lda #$01
	sta (colormempointer),y
	rts

pushpointeroffsets:
	clc

	lda colormempointer
	adc #40
	sta colormempointer
	lda colormempointer + 1
	adc #$00
	sta colormempointer + 1

	lda screenmempointer
	adc #40
	sta screenmempointer
	lda screenmempointer + 1
	adc #$00
	sta screenmempointer + 1
	rts

pushtextpointeroffset:
	clc

	lda textpointer
	adc #40
	sta textpointer
	
	lda textpointer + 1
	adc #$00
	sta textpointer + 1
	rts

nextrow:
	jsr pushtextpointeroffset

	lda rowindex
	cmp #24
	beq setstatepause

	jsr pushpointeroffsets

	lda #$00
	sta characterindex

	inc rowindex
	rts

setstatepause:
	lda #$00
	sta state
	
	lda #$7f
	sta counter
	rts

setstatewrite:
	lda #$01
	sta state
	rts

setstatedissolve:
	lda #$02
	sta state
	
	lda #31
	sta counter
	rts

setpointers:
	jsr clearindices
	jsr setcolorpointer
	jsr setscreenpointer
	jsr settextpointer
	jsr clearscreen
	rts

clearindices:
	lda #$00
	sta characterindex
	sta rowindex
	sta cursorcolorindex
	rts

setcolorpointer:
	lda #<colormem
	sta colormempointer
	lda #>colormem
	sta colormempointer + 1
	rts

setscreenpointer:
	lda #<screenmem
	sta screenmempointer
	lda #>screenmem
	sta screenmempointer + 1
	rts

settextpointer:
	lda #<text
	sta textpointer
	lda #>text
	sta textpointer + 1
	rts

	*= charset
	!source "data/charset"

	*= cursorcolors
	!byte $01,$01,$01,$01,$0f,$0f,$0f,$0f,$0c,$0c,$0c,$0c,$02,$02,$02,$0c,$0c,$0c,$0c,$0f,$0f,$0f,$0f,$01,$01,$01,$01

	*= fadecolors
	!byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$07,$07,$07,$07,$07,$07,$07,$07

	*= text
	!source "data/screens"	
	!byte $ff
