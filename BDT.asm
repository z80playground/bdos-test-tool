; BDOS test tool
; Known as BDT.COM
;
; This tool can be used to test the file-related functions of the CP/M BDOS (for CP/M v2.2)
; and report on what it finds.
; You could use this to compare two different BDOSes, or two different versions of the
; same BDOS, to compare differences, or ensure that bugs have not crept in.
;
; It is written by John Squires of https://8bitStack.co.uk for the Z80 Playground BDOS.
; But it should work on any CP/M v2.2 BDOS.

BDOS                            equ 5
BDOS_Print_String               equ 9
BDOS_Direct_Console_IO          equ 6   
BDOS_Console_Output             equ 2      

    org 0100H                               ; It's a .COM program

start:
    ld de, welcome_message
    call show_message

    ld de, press_any_key_message
    call show_message

    call wait_for_keypress
    call newline

    call test_7_IO_byte

    call wait_for_keypress

    jp 0000H                                ; Exit

show_message:
    ; Shows a message pointed to by DE. Message must end with "$" in the time-honored CP/M style.
    ld c, BDOS_Print_String
    jp BDOS

wait_for_keypress:
    ; Waits for a key to be pressed then returns.
    ld e, 0FFH
    ld c, BDOS_Direct_Console_IO
    call BDOS
    or a
    jr z, wait_for_keypress
    ret

;;;;;;;;;;;;;;;;;;;;
; General Messages

welcome_message:
    db 'Welcome to BDT, the BDOS test tool.',13,10
    db 'Written by John Squires, March 2021, for https://8bitStack.co.uk',13,10,'$'
    db 'This is v0.0000000000000000001',13,10,'$'

press_any_key_message:
    db 'Press any key...',13,10,'$'

a_message:
    db 'A = $'    

l_message:
    db 'L = $'    

newline_message:
    db 13,10,'$'

;;;;;;;;;;;;;;;;;;;;;;
; The tests

test_7_message:
    db 'BDOS function 7 - Get I/O byte',13,10,'$'

test_7_IO_byte:
    ld de, test_7_message
    call show_message

    ld c, 7
    call BDOS
    call report_on_8_bit_result
    jp newline

;;;;;;;;;;;;;;;;;;;
; Shared functions

report_on_8_bit_result:
    push hl
    push af

    ld de, a_message
    call show_message
    pop af
    call show_a_as_decimal
    call tab

    ld de, l_message
    call show_message
    pop hl
    ld a, l
    call show_a_as_decimal
    call newline
    ret

show_a_as_decimal:
	ld b, 0
show_a_as_decimal1:
	cp 10
	jr c, show_a_as_decimal_units
	inc b
	ld c, 10
	sub c
	jr show_a_as_decimal1

show_a_as_decimal_units:
	push af
	ld a, b
	cp 0
	jr z, show_a_as_decimal_units1
	add a, '0'
	call show_a_as_char
show_a_as_decimal_units1:
	pop af
	add a, '0'
	call show_a_as_char
	ret

show_a_as_char:
    push af
    push hl
    push de
    push bc
    ld c, BDOS_Console_Output
    ld e, a
    call BDOS
    pop bc
    pop de 
    pop hl
    pop af
    ret

newline:
    ld de, newline_message
    jp show_message

tab:
    ld a, 9
    jp show_a_as_char

