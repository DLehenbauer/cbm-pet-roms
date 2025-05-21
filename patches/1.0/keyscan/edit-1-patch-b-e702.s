!TO "edit-1-patch-b-e702.bin",plain

PIAK=$E812    ; I/O port B & DDR=$ff unless hitting certain keys
PIAL=$E810    ; Keyboard PIA: I/O port A & data direction register
SFDX=$0223    ; Key image
LSTX=$0203    ; Which key down; 255=none
SFST=$0204    ; Shift key: 1 if depressed
NDX=$020D     ; Number of characters in keyboard buffer
KEYD=$020F    ; Keyboard input buffer - 10 bytes
PREND=$E67E   ; (Exit from interrupt)
PIAL1=$E811   ; Control Register A
CHAR=$E75C    ; Keyboard table

; SFDX is initialized to $FF and SFST is initialized to $00 prior to
; entering the keyscan loop.
;
;KEY4   LDX #$FF
;       STX SFDX
;       INX
;       STX SFST

KL22=$E6F7
;KL22   LDY #8        ; 8 bits remaining to test in current col
;       LDA PIAK      ; A = keys pressed in selected (read from PIA1 PB)
;       CMP PIAK      ; Compare A with new value from PIA1 PB
;       BNE KL22      ; Debounce keys by looping until same

KL1=$E701
;KL1    LSR           ; Shift right, moving A[0] to Carry

*=$E702
       BCS CKIT      ; If Carry=1, key is not pressed.  Skip to next key.
       PHA           ; The key is pressed. Save remaining keys.
       LDA CHAR-1,X  ; Load entry from keyboard table
       BNE CKIS1     ; Check for shift key ($00 = shift)
       LDA #1        ; If shift pressed, set the shift flag.
       STA SFST
       BNE CKUT      ; Branch always taken
CKIS1  STX SFDX      ; Store pressed key index (if not a shift).
CKUT   PLA           ; Restore the remaining keys in the current row.
CKIT   DEX           ; Decrement index into keyboard table
       BEQ CKIT1     ; If we hit zero, we've reached the end of the scan.
       DEY           ; Decrement the number of keys remaining in current column.
       BNE KL1       ; If there are more keys, continue with next key.
       INC PIAL      ; Otherwise select the next row
       BNE KL22      ; Always jump to continue scanning with next row

CKIT1  LDA SFDX      ; Get the index of the last pressed key found during scan
       CMP LSTX      ; Compare with the previously pressed key, if any.
       BEQ PREND0    ; If it's the same key, it's being held.  Ignore it.
       STA LSTX      ; Otherwise we have a new pressed key.  Save it.
       TAX           ; Copy A -> X
       BMI PREND0    ; If the high bit is set, no key was found.
       LDA CHAR-1,X  ; Otherwise load the key value from the keyboard table.
       PHP
       AND #$7F
       PLP
       BMI KN1       ; If high bit was set (prior to AND), store the key index.
       LSR SFST      ; Test for shift flag
       BCC KN1       ; If no shift, store new key index
       CMP #$2C      ; Test for shifted numeric (in the range $2C..$3C)
       BCC DOSHFT    ; Not shifted numeric
       CMP #$3C      ; > $3C?
       BCS DOSHFT    ; Not shifted numeric
       SBC #$0F      ; Is shifted numeric. Subtract 15.
       CMP #$20      ; > $20? (SPACE)
       BCS KN1
       ADC #$20      ; Add 32 to convert to shifted symbol on numeric keypad.
       !byte $2c     ; $2c = BIT instruction to make following instruction NOP.
DOSHFT
       ORA #$80      ; Otherwise set the high bit of the key.

KN1    LDX NDX       ; Load the index into the keyboard buffer
       STA KEYD,X    ; Store the key in the keyboard buffer
       INX           ; Increment the index into the keyboard buffer
       JSR $E7EC
PREND0 JMP PREND

CHAR
       !byte $50, $e7, $3a, $03, $39, $36, $33, $df
       !byte $b1, $2f, $ff, $13, $4d, $20, $58, $12
       !byte $b2, $ff, $ff, $b0, $2c, $4e, $56, $5a
       !byte $b3, $00, $ff, $ae, $2e, $42, $43, $00
       !byte $b4, $db, $4f, $11, $55, $54, $45, $51
       !byte $14, $50, $49, $dc, $59, $52, $57, $89
       !byte $b6, $c0, $4c, $0d, $4a, $47, $44, $41
       !byte $b5, $3b, $4b, $dd, $48, $46, $53, $9b
       !byte $b9, $ff, $de, $b7, $b0, $37, $34, $31
       !byte $ff, $ff, $1d, $b8, $2d, $38, $35, $32
