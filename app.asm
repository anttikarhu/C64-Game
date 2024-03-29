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

CIA1IRQ         = $DC0D
RASTERREG       = $D011
IRQRASTER       = $D012
IRQADDRMSB      = $0314
IRQADDRLSB      = $0315
IRQCTRL         = $D01A
IRQFLAG         = $D019
IRQFINISH       = $EA31

JOYSTICK_B      = $DC01

JUMP_FORCE      = #13

INIT    JSR CLEAR

        ; === BACKGROUND AND FRAME COLORS TO BLACK AND GRAY
        LDA #0
        STA BG_CLR
        LDA #12
        STA FRM_CLR

        ; === SETUP SHIP
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
        LDY POS
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

        ; === SETUP GAME LOOP IN INTERRUPT
        LDA #%01111111 ; SWITCH OFF CIA-1 INTERRUPTS
        STA CIA1IRQ

        ; CLEAR VIC RASTER REGISTER
        AND RASTERREG 
        STA RASTERREG

        ; SETUP GAME LOGIC INTERRUPT AT RASTER LINE 250 (JUST OUTSIDE SCREEN)
        LDA #250 
        STA IRQRASTER
        LDA #<GAMEIRQ
        STA IRQADDRMSB
        LDA #>GAMEIRQ
        STA IRQADDRLSB

        ; RE-ENABLE RASTER INTERRUPTS ONLY AFTER SETUP
        LDA #%00000001 
        STA IRQCTRL

CNT     ; === WAIT UNTIL THE END OF TIMES
        JMP CNT

GAMEIRQ
        ; IF SHIP IS ACCELERATING UP, DO NOTHING FOR NOW
        LDA FLYING
        CMP #1
        BEQ UPDATE

        ; IF JOYSTICK NOT PRESSED UP, JUST UPDATE SHIP
        LDA JOYSTICK_B
        STA CURRJOY
        LDA #%00000001
        BIT CURRJOY
        BNE UPDATE

        ; IF PRESSED UP IN PREVIOUS ROUND, JUST UPDATE SHIP
        LDA #%00000001
        BIT PREVJOY
        BEQ UPDATE

JUMP    LDA #1
        STA FLYING
        LDA JUMP_FORCE
        STA ACCEL
        
UPDATE
        ; SKIP IF NOT MOVING
        LDA FLYING
        CMP #0
        BEQ NEXT

        ; IF MOVING UP, CONTINUE UPDATE
        LDA FLYING
        CMP #1
        BNE NEXT
        
        ; MOVE SHIP
        LDA POS
        CLC
        SBC ACCEL
        STA POS
        STA SPR0_Y

        ; SLOW DOWN, BUT SLOWLY DESCEND
        LDA ACCEL
        CMP #254
        BEQ BOTTOM
        DEC ACCEL

BOTTOM
        ; IF ALREADY AT THE BOTTOM, STOP
        LDX POS
        LDA #228
        JSR GT
        CMP #1
        BNE NEXT
        BEQ AT_BOTTOM

AT_BOTTOM
        LDA #0
        STA ACCEL
        STA FLYING

NEXT
        ; SAVE PREVIOUS JOYSTICK STATUS
        LDA CURRJOY
        STA PREVJOY

        ; RESET IRQ FLAG
        ASL IRQFLAG 
        ; LET MACHINE HANDLE OTHER IRQS
        JMP IRQFINISH 

        ; VARIABLES
POS     BYTE 229
ACCEL   BYTE 0
FLYING  BYTE 0
PREVJOY BYTE 0
CURRJOY BYTE 0

; MACRO: PUSHES REGISTERS TO STACK IN ORDER A, X, Y ============================
defm    M_PUSH_REGISTERS
        PHA
        TXA
        PHA
        TYA
        PHA
        endm
;===============================================================================

; MACRO: POPS REGISTERS FROM STACK IN ORGER Y, X, A ============================
defm    M_POP_REGISTERS
        PLA
        TAY
        PLA
        TAX
        PLA
        endm
; ==============================================================================

; GT, OR GREATER THAN FUNCTION =================================================
GT
        ; SUBROUTINE THAT CHECK IF VALUE IN X IS GREATER THAN VALUE IN A.
        ; LEAVES THE RESULT TO A (0 IF NOT, AND 1 IF WAS).
        ; X REGISTER = VALUE TO BE CHECKED FOR GREATNESS
        ; A REGISTER = VALUE THE X IS COMPARED TO

        STX GT_X_ST ; STORE X AND A,
        STA GT_A_ST
        M_PUSH_REGISTERS ; PUSH REGISTERS TO STACK TO BE A GOOD CITIZEN,
        LDA GT_A_ST ; AND GET A BACK FROM MEMORY

        CMP GT_X_ST ; CHECK IF X IS GREATER THAN A
        BCS GT_WAS_LE
        BCC GT_WAS_GT

GT_WAS_LE
        LDA #0
        STA GT_A_ST
        JMP GT_END
GT_WAS_GT
        LDA #1
        STA GT_A_ST
        JMP GT_END

GT_END  M_POP_REGISTERS ; GET REGISTERS FROM THE STACK,
        LDA GT_A_ST ; LOAD RESULT BACK TO ACCUMULATOR,
        RTS ; AND END THE SUBROUTINE.

GT_X_ST BYTE 0
GT_A_ST BYTE 0
; ==============================================================================

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





