.segment "HEADER"
    .byte "NES"
    .byte $1a    
    .byte $02
    .byte $01
    .byte %00000000
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00, $00, $00, $00, $00
    
.segment "ZEROPAGE"

.segment "STARTUP"

;subroutines
VBlankWait:
    bit $2002
    bpl VBlankWait
    rts
;movement
MoveFwd:
    lda $0200, x
    clc
    adc #$01
    rts

MoveBkd:
    lda $0200, x
    sec
    sbc #$01
    rts

Move:
    and #$00000001
    beq :+
    jsr MoveFwd
    jmp MoveDone
:
    jsr MoveBkd
MoveDone:
    sta $0200, x
    rts

RESET:
    sei
    cld
    
    ;stop apu
    ldx #$40
    stx $4017

    ;init stack register
    ldx #$ff
    txs

    ;set ppu registers to 0
    inx
    stx $2000
    stx $2001

    stx $4010

    jsr VBlankWait

    ;clear memory
    txa
MEMCLR:
    sta $0000, x
    sta $0100, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    ;allocate sprite memory
    lda #$ff
    sta $0200, x
    lda #$00

    inx
    bne MEMCLR

    jsr VBlankWait

    lda #$02
    sta $4014
    nop

    lda #$3f
    sta $2006
    lda #$00
    sta $2006

    ldx #$00
LoadPalette:
    lda PaletteData, x
    sta $2007
    inx
    cpx #$20
    bne LoadPalette

;load sprites to allocated sprite memory
    ldx #$00
LoadSprite:
    lda OwOSprite, x
    sta $0200, x
    inx
    cpx #$18
    bne LoadSprite

    cli

    lda #%10010000
    sta $2000

    lda #%00011110
    sta $2001

    ;declare variables
    lda #$01
    ;vmovefwd .set 1
    sta $0000
    ;hmovefwd .set 1
    sta $0001

Loop:
    jmp Loop

NMI:
    ldx #$00 
MoveLoop:
    ;vertical
    lda $0000
    jsr Move
    inx
    inx
    inx
    ;horizontal
    lda $0001
    jsr Move
    inx
    cpx #$18
    bne MoveLoop
    
CheckWall:
    ;jmp EndHorChk
    ldx $0203
    cpx #$08
    beq :+
    cpx #$e8
    beq :+
    jmp EndHorChk
:
    lda $0001
    cmp #$00
    bne :+    
    lda #$01
    sta $0001
    jmp EndHorChk
:
    lda #$00
    sta $0001
EndHorChk:
    ;jmp EndVertChk
    ldx $0200    
    cpx #$08
    beq :+
    cpx #$d4
    beq :+
    jmp EndVertChk
:
    lda $0000
    cmp #$00
    bne :+    
    lda #$01
    sta $0000
    jmp EndVertChk
:
    lda #$00
    sta $0000
EndVertChk:

    ;update sprites
    lda #$02
    sta $4014
    rti

PaletteData:
    .byte $0f,$00,$00,$25,$0f,$00,$00,$25,$0f,$00,$00,$25,$0f,$00,$00,$25
    .byte $0f,$00,$00,$25,$0f,$00,$00,$25,$0f,$00,$00,$25,$0f,$00,$00,$25

OwOSprite:
    .byte $a0,$00,$00,$10
    .byte $a0,$01,$00,$18
    .byte $a0,$02,$00,$20
    .byte $a8,$03,$00,$10
    .byte $a8,$04,$00,$18
    .byte $a8,$05,$00,$20

.segment "VECTORS"
    .word NMI
    .word RESET

.segment "CHARS" 
    .incbin "res/owo.chr"