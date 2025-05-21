; Original 1.0 keyscan implementation for Graphics keyboard for reference.

!TO "edit-1-keyscan-n.bin",plain

PIAK=$E812    ; I/O port B & DDR=$ff unless hitting certain keys
PIAL=$E810    ; Keyboard PIA: I/O port A & data direction register
SFDX=$0223    ; Key image
LSTX=$0203    ; Which key down; 255=none
SFST=$0204    ; Shift key: 1 if depressed
NDX=$020D     ; Number of characters in keyboard buffer
KEYD=$020F    ; Keyboard input buffer - 10 bytes
PREND=$E67E   ; (Exit from interrupt)
PIAL1=$E811   ; Control Register A

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
       JSR LE73F     ; Jump to decode the keyboard table.
       PLA           ; Restore the remaining keys in the current row.
CKIT   DEX           ; Decrement index into keyboard table
       BEQ CKIT1     ; If we hit zero, we've reached the end of the scan.
       DEY           ; Decrement the number of keys remaining in current column.
       BNE KL1       ; If there are more keys in current column, continue with next key.
       INC PIAL      ; Otherwise select the next row
       BNE KL22      ; Always jump to continue scanning with next row
CKIT1  LDA SFDX      ; Get the index of the last pressed key found during scan
       CMP LSTX      ; Compare with the previously pressed key, if any.
       BEQ PREND0    ; If it's the same key, it's being held.  Ignore it.
       STA LSTX      ; Otherwise we have a new pressed key.  Save it.
       TAX           ; Move the pressed key index to X
       BMI PREND0    ; If the high bit is set, no key was found.
       LDA CHAR-1,X  ; Otherwise load the key value from the keyboard table.
       LSR SFST      ; Test for shift flag
       BCC KN1       ; If no shift, skip.
       ORA #$80      ; Otherwise set the high bit of the key.
KN1    LDX NDX       ; Load the index into the keyboard buffer
       STA KEYD,X    ; Store the key in the keyboard buffer
       INX           ; Increment the index into the keyboard buffer
       CPX #10       ; Check if we've reached the end of the keyboard buffer.
       BNE KEYF      ; if not, Skip.
       LDX #0        ; Otherwise, wrap keyboard buffer around to 0.
KEYF   STX NDX       ; Store the new index in the keyboard buffer.
PREND0 JMP PREND     ; return from interrupt.
LE73F  LDA CHAR-1,X  ; Load entry from keyboard table
       BNE CKIS1     ; Check for shift key ($00 = shift)
       LDA #1        ; If shift pressed, set the shift flag.
       STA SFST
       BNE CKUT      ; Branch always taken -> RTS
CKIS1  CMP #$FF      ; Check for invalid key
       BEQ CKUT      ; If invalid, RTS
       CMP #$3C      ; Check for [stop] key
       BNE SPCK      ; If not stop key, jump to storing new key.
       BIT PIAL1
       BMI CKUT
SPCK   STX SFDX      ; Store pressed key
CKUT   RTS           ; Return to keyscan loop

CHAR   !byte $3d, $2e, $ff, $03, $3c, $20, $5b, $12
       !byte $2d, $30, $00, $3e, $ff, $5d, $40, $00
       !byte $2b, $32, $ff, $3f, $2c, $4e, $56, $58
       !byte $33, $31, $0d, $3b, $4d, $42, $43, $5a
       !byte $2a, $35, $ff, $3a, $4b, $48, $46, $53
       !byte $36, $34, $ff, $4c, $4a, $47, $44, $41
       !byte $2f, $38, $ff, $50, $49, $59, $52, $57
       !byte $39, $37, $5e, $4f, $55, $54, $45, $51
       !byte $14, $11, $ff, $29, $5c, $27, $24, $22
       !byte $1d, $13, $5f, $28, $26, $25, $23, $21
