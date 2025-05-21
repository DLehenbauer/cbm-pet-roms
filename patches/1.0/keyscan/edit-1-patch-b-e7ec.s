!TO "edit-1-patch-b-e7ec.bin",plain

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

; 
*=$E7EC
       CPX #10       ; Check if we've reached the end of the keyboard buffer.
       BNE KEYF      ; if not, Skip.
       BEQ KEYE

; JSR from $d47d
LE7F3  ASL
       ADC #$05
       LDY #$00
LE7F8  RTS

KEYE   LDX #0        ; Otherwise, wrap keyboard buffer around to 0.
KEYF   STX NDX       ; Store the new index in the keyboard buffer.
       BNE LE7F8
       BRK