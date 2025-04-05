; AUTHOR: CAMILA BOA MORTE
; FILE DESCRIPTION: This file implements a intelligent semaphore...

;USAGE OF TIMERS AND INTERRUPTS

; 1) INT0 -> emergency mode
; 2) INT1 -> vehicle counter
; 3) TIMER/COUNTER0 -> semaphore control
; 4) TIMER/COUNTER1 with interrupt -> 7seg display control

; USAGE OF REGISTERS

; 1) R0 -> semaphore status
; 2) R1 -> semaphore timer counter
; 3) R3 -> Vehicle counter


;---------------------------------------------------------------------


	org	0000h		;Initial address
	ljmp setup		; Branch to main program

;------------- ISR -----------------------


; ISR timer/counter0
	org 000bh
	clr tr0
	clr tf0
	inc r0
	mov a, r0
	movc a, @a+dptr
	mov p0, a
	mov tl0, #0fah
	mov th0, #0ffh
	setb tr0
	reti
;--------------------------------------------

;-----------Program configuration------------
setup:
	mov dptr, #lookup	; Moving lookup table address to DPTR
	mov r0, #0h		; Starting counter at 0

	;Initializing 7seg display
	mov a, r0
	movc a, @a+dptr		; Moving current counter segment code to acc
	mov p0, a

	
	mov tmod, #00001010b	; Configuring timer mode to 2 (16 bits)
	mov tl0, #0feh
	mov th0, #0ffh

	mov ie, #10000010b	; Initializing interrupts
	mov ip, #0h		; Configuring interrupt priority

	setb tr0

	

; Main routine
main:
	jmp main


;------------ 7SEG DISPLAY LOOKUP TABLE --------------
lookup:
	db 0c0h	;Zero segment code
	db 0f9h	;One segment code
	db 0a4h	;Two segment code
	db 0b0h	;Three segment code
	db 99h	;Four segment code
	db 92h	;Five segment code
	db 82h	;Six segment code
	db 0f8h	;Seven segment code
	db 80h	;Eight segment code
	db 90h	;Nine segmento code

	end