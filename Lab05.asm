/**************************************************************************
 *	    File: Lab05.asm
 *  Lab Name: Pardon the Interruption...
 *    Author: Dr. Greg Nordstrom
 *   Created: 02/19/2021
 * Processor: ATmega128A (on the ReadyAVR board)
 *
 * Modified by: Mandy Wells
 * Modified on: 09/22/2026
 *
 * This program...
 *
 *************************************************************************/

 /*********
 * Interrupt Jump Table
 *********/
.org 0x0000                 ; next instruction address is 0x0000
                            ; (the location of the reset vector)
rjmp main					; allow reset to run this program

/**********
* Main code
**********/
.org 0x0020					; Move the "main" to 0x0020 to make room for ISRs

;added by Mandy
.def BlinkFreq = R20

.equ BlinkFreqMin = 1
.equ BlinkFreqMax = 15
.equ InitialBlinkFreq = BlinkFreqMin

main:                       ; jump here on reset
    ldi R16, HIGH(RAMEND)   ; initialize stack (default RAMEND = 0x10FF)
    out SPH, R16
    ldi R16, low(RAMEND)
    out SPL, R16

	/* Additional Setup before Main Loop */

    ;added by Mandy
    LDI BlinkFreq, InitialBlinkFreq

    LDI  R16,(1<<DDA7)		; Set the mask to make Port A.7 an output
    OUT  DDRA,R16		; Load bitmask to PORTA register

    ;added by Mandy
    LDI R16, (1 << DDA7)
    OUT DDRC, R16

    
mainLoop:
    CBI  PORTA, PORTA7       ; turn BOOT LED on (active low) by clearing PORTA.7

    ; kill some time
    ldi R16, 16-BlinkFreq    ; R16 is outer loop counter
outer_loop1:
    ldi R24, low(0xFFFF)     ; load low and high parts of R25:R24 pair with
    ldi R25, high(0xFFFF)    ; loop count by loading registers separately
    inner_loop1:
        sbiw R24, 1         ; decrement inner loop counter (R25:R24 pair)
        brne inner_loop1    ; loop back if R25:R24 isn't zero
    dec R16                 ; decrement the outer loop counter (R16)
    brne outer_loop1        ; loop back if R16 isn't zero

    sbi PORTA, PORTA7       ; turn BOOT LED off (active low) by setting PORTA.7

    ; kill some more time
    ldi R16, 16-BlinkFreq             ; R16 is outer loop counter
outer_loop2:
    ldi R24, low(0xFFFF)     ; load low and high parts of R25:R24 pair with
    ldi R25, high(0xFFFF)    ; loop count by loading registers separately
    inner_loop2:
        sbiw R24, 1         ; decrement inner loop counter (R25:R24 pair)
        brne inner_loop2    ; loop back if R25:R24 isn't zero
    dec R16                 ; decrement the outer loop counter (R16)
    brne outer_loop2        ; loop back if R16 isn't zero

    rjmp mainLoop           ; play it again, Sam...

/**********
* ISR code
**********/
.org 0x0200							; Load the ISR code higher than main code
int1_isr:
