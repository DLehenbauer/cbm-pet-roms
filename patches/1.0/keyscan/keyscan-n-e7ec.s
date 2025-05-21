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
*=$e7ec
       BRK
       BRK
       BRK
       BRK
       BRK
       BRK
       BRK

; JSR from $d47d
LE7F3  ASL
       ADC #$05
       LDY #$00
       RTS

       BRK
       BRK
       BRK
       BRK
       BRK
       BRK
       BRK
