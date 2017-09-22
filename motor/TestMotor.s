.equ TIMER, 0xff202000
.equ TIMER2, 0xff202020 
.equ second_period, 10000000
.equ speed_period, 20000000
.equ TIMEOUT, 0x01
.equ PUSHBUTTONS, 0xFF200050

.equ REDLEDS, 0xFF200002
.equ LEGOCONTROLLA, 0xFF200070
.equ LEGOCONTROLLA_ECR, 0xFF20007C
.equ KEYBOARD, 0xFF200100

.equ PIXEL_BUFF, 0x08000000
.equ CHAR_BUFF, 0x09000000

.equ DOWN, 	0x72
.equ LEFT, 	0x6B
.equ RIGHT, 0x74
.equ UP, 	0x75
.equ BREAK, 0xF0

#----------------------------------------------Interrupt Service Routines---------------------------------------------#	
.section .exceptions, "ax"

handler:
	addi sp, sp, -44
	stw r8, 0(sp)
	stw r2, 4(sp)
	stw r3, 8(sp)
	stw r4, 12(sp)
	stw r5, 16(sp)
	stw r6, 20(sp)
	stw r9, 24(sp)
	stw r15, 28(sp)
	stw r16, 32(sp)
	stw r10, 36(sp)
	stw r11, 40(sp)
	br handler_text

handler_text:

	#---------------------------Check Source of Interrupt-------------------------------------------#
	rdctl et, ctl4                  # check the interrupt pending register (ctl4) 
	
	check_timer2:
		movia r10, 0x4
		and r11, r10, et			  # check if the pending interrupt is from Timer2
		beq r11, r10, handler_timer2
		
	br epilogue
	
	
handler_timer2:

	movia r8, TIMER2				#acknowledge timeout
	stw r0, 0(r8)
	
	movia r8, LEGOCONTROLLA
	ldwio r15, 0(r8)
	andi r15, r15, 0xFF
	
	movia r2, 0xFF
	beq r15, r2, turn_on
	
	movia r15, 0xfffffffc
	stwio r15, 0(r8)
	br epilogue
	
turn_on:

	movia r15, 0xfffffffc
	stwio r15, 0(r8)
	br epilogue
 #--------------------------------------------------------------------------------------------------------#

epilogue:
	ldw r8, 0(sp)
	ldw r2, 4(sp)
	ldw r3, 8(sp)
	ldw r4, 12(sp)
	ldw r5, 16(sp)
	ldw r6, 20(sp)
	ldw r9, 24(sp)
	ldw r15, 28(sp)
	ldw r16, 32(sp)
	ldw r10, 36(sp)
	ldw r11, 40(sp)
	addi sp, sp, 44
	
	subi ea, ea, 4
	eret
#------------------------------------------------------------------------------------------------------------------#


.text
.global _start
_start:

	movia sp, 0x04000000

	call SetUpPushButtons
	
	call SetUpTimer2
	
	movia r8, LEGOCONTROLLA
	
	movia r15, 0xffffffff
	stwio r15, 0(r8)
	
	movia r9, 0x4			# control register interrupt enabling (b12 for JP2, b7 for PS/2 keyboard, 2 for Timer 1, b0 for Timer0)
	wrctl ctl3, r9
	
	movia r9, 0x1
	wrctl ctl0, r9
	
loop:

	br loop
