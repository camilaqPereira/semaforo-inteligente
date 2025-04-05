; AUTHOR: CAMILA BOA MORTE
; FILE DESCRIPTION: This file implements a intelligent semaphore...

;USAGE OF TIMERS AND INTERRUPTS

; 1) INT0 -> emergency mode
; 2) INT1 -> vehicle counter
; 3) TIMER/COUNTER0 -> semaphore counter control

; USAGE OF REGISTERS

; 1) R0 -> semaphore status
; 2) R1 -> semaphore timer counter
; 3) R2 -> Vehicle counter
; 4) R4 -> Timer0 counter

; USAGE OF INDIVIDUAL BITS
; 1) 20H -> Emergency mode flag
; 2) 21H -> Extend green time flag

;---------------------------------------------------------------------

	org	0000h		;Initial address
	ljmp setup		; Branch to main program

;------------- ISR -----------------------
;ISR for INT0 -> emergency mode
	org 0003h
	jmp isrint0

;ISR for TIMER0 -> 7-seg display
	org 000bh
	jmp isrt0


;ISR for INT1 -> vehicle counter
	org 0013h
	clr ea			; Disable interrupts
	clr ie1			; Clear INT1 interrupt flag
	inc r2			; Increment vehicle counter
	cjne r2, #05h, endirs1	; Jump if vehicle counter is not 5
	setb 21H		; Set extend green time flag
	clr ex1			; Disable vehicle counter

endirs1:
	setb ea
	reti


;--------------------------------------------

;-----------Program configuration------------

setup:
	mov dptr, #lookup	; Moving lookup table address to DPTR
	mov r0, #1h		; Starting semaphore with red
	mov r2, #0h		; Starting vehicle counter at 0
	mov r1, #0ah		; Initializing semaphore counter at 10d
	mov r4, #20d		; Initializing timer0 counter at 20d
	mov p2, r0		; Initializing LED semaphore
	clr 20H			; Clear emergency mode flag
	clr 21H			; Clear extend green time flag

	;Configuring timers and interrupts
	mov tl0, #low(65535 - 50000)		; Configuring initial value for timer0
	mov th0, #high(65535 - 50000)		; Configuring initial value for timer0
	mov tmod, #00000001b			; Configuring timer0 with mode 2 (16 bits)
	mov tcon, #00010101b			; Both interrupts are border sensitive
	mov ip, #00000101b			; Configure IRQ priority -> INT0, INT1, timers
	mov ie, #10000111b			; Enable interrupts

;--------------------------------------------

;--------------Main program------------------

main:
	cjne r1, #0h, $		; Waits until the timer0 is 0

	jbc 20H, emergencymode	; Jump if emergency mode was selected (clears flag)
	jbc 21H, extendgreentime; Jump if extend green time was set (clears flag)
	jmp display		; Else

emergencymode:
	mov r0, #1h		; Set state to red
	mov r1, #0fh		; Set semaphore counter to 15d
	jmp display

extendgreentime:
	mov r0, #2h		; Set status to green (not nedded)
	mov r1, #7h		; Set semaphore counter to 7d
	jmp display

display:
	;Update 7seg display
	mov a, r1
	mov b, #10d
	div ab

	movc a, @a+dptr		; Moving current counter segment code to acc
	mov p0, a

	mov a, b
	movc a, @a+dptr			; Moving current counter segment code to acc
	mov p1, a

	;Update LED semaphore
	mov p2, r0			; Update led values in P2

	;----------
	cjne r1, #0h, main		; Back to loop if semaphore counter isn't zero

	cjne r0, #4h, rotatestatus	; Jump if state != yellow (yellow is the current state)
	mov r1, #0ah			; Update semaphore counter to 10
	mov r0, #1h			; Update state to red
	jmp main

rotatestatus:
	mov a, r0			; acc = r0 (semaphore counter)
	rl a				; Shift left 1 position
	mov r0, a			; r0 = acc
	cjne r0, #2h, yellow		; Jump if state != yellow (state after updating is green)
	mov r1, #7h			; Update semaphore counter to 7
	setb ex1			; Enable extend green time interrupt
	jmp main

yellow:
	mov r1, #3h			; Update semaphore counter to 3 (state after updating is yellow)
	clr ex1				; Disables extend green time interrupt
	mov r2, #0h			; Reset counter
	jmp main
; ---------------- END OF MAIN ROUTINE --------------------------

isrint0:
	clr ea
	clr ie0
	setb 20H		; Set emergency mode flag
	setb ea
	reti


isrt0:
	clr ea
	clr tr0
	clr tf0
	dec r4					; Decrement timer0 counter
	mov tl0, #low(65535 - 50000)		; Configuring initial value for timer0
	mov th0, #high(65535 - 50000)		; Configuring initial value for timer0
	cjne r4, #0h, configt0 			; Jump if timer0 counter is 0
	jmp endirst0

configt0:
	mov r4, #20d				; Reset timer0 counter
	dec r1					; Decrement semaphore counter

endirst0:
	setb tr0				; Enable timer0
	setb ea
	reti

;------------ 7SEG DISPLAY LOOKUP TABLE --------------
; 0-9 segment code
lookup:
	db 0c0h, 0f9h, 0a4h, 0b0h, 99h, 92h, 82h, 0f8h, 80h, 90h

	end

