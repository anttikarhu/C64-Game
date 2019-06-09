; ALLOWS ONE TO START THE APPLICATION WITH RUN
; SYS 2064
*=$0801 
         BYTE $0C, $08, $0A, $00, $9E, $20, $32, $30, $36, $34, $00, $00, $00, $00, $00

CLEAR           = $E544

BG_CLR          = $D021
FRM_CLR         = $D020

SPR_ENABLE      = $D015
SPR_MSBX        = $D010
SPR_COLORMODE   = $D01C
SPR_COLOR0      = $D025
SPR_COLOR1      = $D026

SPR0_PTR        = $07F8
SPR0_X          = $D000
SPR0_Y          = $D001
SPR0_COLOR      = $D027
SPR0_DATA       = $0340

INIT    JSR CLEAR

        ; BACKGROUND AND FRAME COLORS TO BLACK AND GRAY
        LDA #0
        STA BG_CLR
        LDA #12
        STA FRM_CLR

        ; ENABLE SPRITE 0 WHICH WILL BE THE SHIP
        LDA #%00000001
        STA SPR_ENABLE

        ; SINGLE COLOR MODE FOR SHIP SPRITE
        LDA #%00000000
        STA SPR_COLORMODE

        ; SET SHIP COLOR TO WHITE
        LDA #1
        STA SPR0_COLOR
 
        ; SET SHIP X, THIS WILL NOT CHANGE
        LDX #%00000000
        STX SPR_MSBX
        LDX #50
        STX SPR0_X

        ; SET SHIP INITIAL Y
        LDY #229
        STY SPR0_Y

        ; SET SPRITE POINTER
        LDA #$0D
        STA SPR0_PTR

        ; LOAD SHIP DATA
        LDX #0
LD_SHIP LDA SHIP,X
        STA SPR0_DATA,X
        INX
        CPX #64
        BNE LD_SHIP
       
LOOP    ; WAIT UNTIL THE END OF TIMES
        JMP LOOP

        ; SHIP SPRITE
SHIP    BYTE 0,255,0
        BYTE 1,255,128
        BYTE 3,0,192
        BYTE 6,219,96
        BYTE 12,153,48
        BYTE 12,153,48
        BYTE 15,255,240
        BYTE 12,0,48
        BYTE 7,255,224
        BYTE 3,0,192
        BYTE 3,255,192
        BYTE 7,129,224
        BYTE 15,255,240
        BYTE 28,126,56
        BYTE 24,0,24
        BYTE 56,0,28
        BYTE 48,0,12
        BYTE 48,0,12
        BYTE 48,0,12
        BYTE 48,0,12
        BYTE 252,0,63
        BYTE 0




